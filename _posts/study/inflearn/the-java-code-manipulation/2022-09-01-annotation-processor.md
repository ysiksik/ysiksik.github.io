---
layout: post
bigtitle: '더 자바, 코드를 조작하는 다양한 방법'
subtitle: 애노테이션 프로세서
date: '2022-09-01 00:00:00 +0900'
categories:
    - the-java-code-manipulation
comments: true
---

# 애노테이션 프로세서

# 애노테이션 프로세서
* toc
{:toc}

## Lombok(롬복)은 어떻게 동작하는 걸까?

### [Lombok](https://projectlombok.org/)
+ @Getter, @Setter, @Builder 등의 애노테이션과 애노테이션 프로세서를 제공하여 표준적으로 작성해야 할 코드를 개발자 대신 생성해주는 라이브러리.

### 롬복 사용하기 
+ 의존성 추가

~~~xml

<dependency>
    <groupId>org.projectlombok</groupId>
    <artifactId>lombok</artifactId>
    <version>1.18.8</version>
    <scope>provided</scope>
</dependency>

~~~

+ IntelliJ lombok 플러그인 설치
+ IntelliJ Annotation Processing 옵션 활성화

### 롬복 동작 원리
+ 컴파일 시점에 [애노테이션 프로세서](https://docs.oracle.com/javase/8/docs/api/javax/annotation/processing/Processor.html) 를 사용하여 __소스코드의 AST(abstract syntax tree)를 조작__ 한다.

### 논란 거리
+ 공개된 API 가 아닌 컴파일러 내부 클래스를 사용하여 기존 소스 코드를 조작한다.
+ 특히 이클립스의 경우엔 java agent 를 사용하여 컴파일러 클래스까지 조작하여 사용한다.
해당 클래스들 역시 공개된 API 가 아니다보니 버전 호환성에 문제가 생길 수 있고 언제라도 그런 문제가 발생해도 이상하지 않다.
+ 그럼에도 불구하고 엄청난 편리함 때문에 널리 쓰이고 있으며 대안이 몇가지 있지만 롬복의 모든 기능과 편의성을 대체하진 못하는 현실이다.
  + [AutoValue](https://github.com/google/auto/blob/master/value/userguide/index.md)
  + [Immutables](https://immutables.github.io)

### 참고
+ [https://docs.oracle.com/javase/8/docs/api/javax/annotation/processing/Processor.html](https://docs.oracle.com/javase/8/docs/api/javax/annotation/processing/Processor.html)
+ [https://projectlombok.org/contributing/lombok-execution-path](https://projectlombok.org/contributing/lombok-execution-path)
+ [https://stackoverflow.com/questions/36563807/can-i-add-a-method-to-a-class-from-a-compile-time-annotation](https://stackoverflow.com/questions/36563807/can-i-add-a-method-to-a-class-from-a-compile-time-annotation)
+ [http://jnb.ociweb.com/jnb/jnbJan2010.html#controversy](http://jnb.ociweb.com/jnb/jnbJan2010.html#controversy)
+ [https://www.oracle.com/technetwork/articles/grid/java-5-features-083037.html](https://www.oracle.com/technetwork/articles/grid/java-5-features-083037.html)

## 애노테이션 프로세서 1부

### [Processor 인터페이스](https://docs.oracle.com/en/java/javase/11/docs/api/java.compiler/javax/annotation/processing/Processor.html)
+ 여러 라운드(rounds)에 거쳐 소스 및 컴파일 된 코드를 처리 할 수 있다.

### 유틸리티
+ [AutoService](https://github.com/google/auto/tree/master/service) : 서비스 프로바이더 레지스트리 생성기

~~~xml

<dependency>
    <groupId>com.google.auto.service</groupId>
    <artifactId>auto-service</artifactId>
    <version>1.0-rc6</version>
</dependency>

~~~

~~~java

@AutoService(Processor.class)
public class FraudProcessor extends AbstractProcessor {
...
}

~~~

+ 컴파일 시점에 애노테이션 프로세서를 사용하여 META-INF/services/javax.annotation.processor.Processor 파일 자동으로 생성해 줌.

### 소스 

+ 어노테이션 생성
  + 컴파일 타임에 쓰고 바이트 코드에는 필요가 없음 
  + Retention SOURCE 레벨 까지만 유지 설정

~~~java

@Retention(RetentionPolicy.SOURCE)
public @interface Fraud {

}

~~~

+ Processor 생성

~~~java

@AutoService(Processor.class)
public class FraudProcessor extends AbstractProcessor {

    /**
     * 어떤 에노테이션을 처리할 것인가
     *
     * @return 애노테이션의 문자열
     */
    @Override
    public Set<String> getSupportedAnnotationTypes() {
        return Set.of(Fraud.class.getName());
    }

    /**
     * 소스 버전 지정, 상위에 지정된거 사용해서 상관 없음
     *
     * @return
     */
    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latestSupported();
    }

    /**
     * @param annotations the annotation types requested to be processed
     * @param roundEnv    environment for information about the current and prior round
     *                    라운드 개념으로 동작,
     *                    여러 라운드에 걸처서 처리 각라운드마다 프로세서에게 특정한 엘리먼트를 찾으면 처리를 시킨다, 처리 결과가 다름 라운드 넘어갈수 있다
     * @return 만약에 true 를 리턴하면 해당 애노테이션 타입을 처리한것 , 다음 프로세서들 한테 에노테이션을 처리하라고 부탁하지 않음
     */
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {

        Set<? extends Element> elements = roundEnv.getElementsAnnotatedWith(Fraud.class); // 애노테이션 찾아옴

        for (Element element : elements){
            if (element.getKind() != ElementKind.INTERFACE){ // 인터페이스 체크
                processingEnv.getMessager().printMessage(Diagnostic.Kind.ERROR, "can'tScam " + element.getSimpleName()); // 인터페이스가 아닐경우 에러 발생
            }else {
                processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE, "Procession "+ element.getSimpleName());
            }
        }


        return true;
    }
}

~~~

### ServiceProvider
+ 자바에서 기본적으로 제공
+ 확장 포인트 제공
+ [https://itnext.io/java-service-provider-interface-understanding-it-via-code-30e1dd45a091](https://itnext.io/java-service-provider-interface-understanding-it-via-code-30e1dd45a091)

### 참고
+ [http://hannesdorfmann.com/annotation-processing/annotationprocessing101](http://hannesdorfmann.com/annotation-processing/annotationprocessing101)
+ [http://notatube.blogspot.com/2010/12/project-lombok-creating-custom.html](http://notatube.blogspot.com/2010/12/project-lombok-creating-custom.html)
+ [https://medium.com/@jintin/annotation-processing-in-java-3621cb05343a](https://medium.com/@jintin/annotation-processing-in-java-3621cb05343a)
+ [https://iammert.medium.com/annotation-processing-dont-repeat-yourself-generate-your-code-8425e60c6657](https://iammert.medium.com/annotation-processing-dont-repeat-yourself-generate-your-code-8425e60c6657)
+ [https://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html#processing](https://docs.oracle.com/javase/7/docs/technotes/tools/windows/javac.html#processing)

## 애노테이션 프로세서 2부

### [Filer](https://docs.oracle.com/en/java/javase/11/docs/api/java.compiler/javax/annotation/processing/Filer.html) 인터페이스
+ 소스 코드, 클래스 코드 및 리소스를 생성할 수 있는 인터페이스

### 유틸리티
+ [javapoet]() : 소스 코드 생성 유틸리티

~~~java

@AutoService(Processor.class)
public class FraudProcessor extends AbstractProcessor {

    /**
     * 어떤 에노테이션을 처리할 것인가
     *
     * @return 애노테이션의 문자열
     */
    @Override
    public Set<String> getSupportedAnnotationTypes() {
        return Set.of(Fraud.class.getName());
    }

    /**
     * 소스 버전 지정, 상위에 지정된거 사용해서 상관 없음
     *
     * @return
     */
    @Override
    public SourceVersion getSupportedSourceVersion() {
        return SourceVersion.latestSupported();
    }

    /**
     * @param annotations the annotation types requested to be processed
     * @param roundEnv    environment for information about the current and prior round
     *                    라운드 개념으로 동작,
     *                    여러 라운드에 걸처서 처리 각라운드마다 프로세서에게 특정한 엘리먼트를 찾으면 처리를 시킨다, 처리 결과가 다름 라운드 넘어갈수 있다
     * @return 만약에 true 를 리턴하면 해당 애노테이션 타입을 처리한것 , 다음 프로세서들 한테 에노테이션을 처리하라고 부탁하지 않음
     */
    @Override
    public boolean process(Set<? extends TypeElement> annotations, RoundEnvironment roundEnv) {

        Set<? extends Element> elements = roundEnv.getElementsAnnotatedWith(Fraud.class); // 애노테이션 찾아옴

        for (Element element : elements){
            if (element.getKind() != ElementKind.INTERFACE){ // 인터페이스 체크
                processingEnv.getMessager().printMessage(Diagnostic.Kind.ERROR, "can'tScam " + element.getSimpleName()); // 인터페이스가 아닐경우 에러 발생
            }else {
                processingEnv.getMessager().printMessage(Diagnostic.Kind.NOTE, "Procession "+ element.getSimpleName());
            }


            TypeElement typeElement = (TypeElement) element;
            ClassName className = ClassName.get(typeElement);

            MethodSpec takeItOut = MethodSpec.methodBuilder("takeItOut")
                    .addModifiers(Modifier.PUBLIC)
                    .returns(String.class)
                    .addStatement("return $S", "APPLE!")
                    .build();

            TypeSpec testServiceImpl = TypeSpec.classBuilder("testServiceImpl")
                    .addModifiers(Modifier.PUBLIC)
                    .addSuperinterface(className)
                    .addMethod(takeItOut)
                    .build();


            Filer filer = processingEnv.getFiler();
            try {
                JavaFile.builder(className.packageName(), testServiceImpl)
                        .build()
                        .writeTo(filer);
            } catch (IOException e) {
                processingEnv.getMessager().printMessage(Diagnostic.Kind.ERROR, "FATAL ERROR: "+ e);
            }

        }
        return true;
    }
}

~~~

## 애노테이션 프로세서 정리

### 애노테이션 프로세서 사용 예
+ 롬복
+ AutoService: java.util.ServiceLoader용 파일 생성 유틸리티
+ @Override
  + [https://stackoverflow.com/questions/18189980/how-do-annotations-like-overridework-internally-in-java/18202623](https://stackoverflow.com/questions/18189980/how-do-annotations-like-overridework-internally-in-java/18202623)
+ [Dagger 2](https://github.com/google/dagger) : 컴파일 타임 DI 제공
+ 안드로이드 라이브러리
  + [ButterKinfe](http://jakewharton.github.io/butterknife/) : @BindView (뷰 아이디와 애노테이션 붙인 필드 바인딩)
  + [DeepLinkDispatch](https://github.com/airbnb/DeepLinkDispatch) : 특정 URI 링크를 Activity 로 연결할 때 사용

### 애노테이션 프로세서 장점
+ 런타임 비용이 제로

### 애노테이션 프로세서 단점
+ 기존 클래스 코드를 변경할 때는 약간의 hacking 이 필요하다

