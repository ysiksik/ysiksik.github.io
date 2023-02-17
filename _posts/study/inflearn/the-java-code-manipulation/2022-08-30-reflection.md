---
layout: post
bigtitle: '더 자바, 코드를 조작하는 다양한 방법'
subtitle: 리플렉션
date: '2022-08-30 00:00:00 +0900'
categories:
    - the-java-code-manipulation
comments: true
---

# 리플렉션

# 리플렉션
* toc
{:toc}

## 스프링의 Dependency Injection 은 어떻게 동작할까

+ TestService.java

~~~java

public class TestService {
  @Service
  @Autowired
  TestRepository testRepository;
}

~~~

+ TestRepository 인스턴스는 어떻게 null이 아닌걸까
+ 스프링은 어떻게 TestService 인스턴스에 TestRepository 인스턴스를 넣어준 것일까


## 리플렉션 API 1부: 클래스 정보 조회

### 리플렉션의 시작은 Class<T>
+ [https://docs.oracle.com/javase/8/docs/api/java/lang/Class.html](https://docs.oracle.com/javase/8/docs/api/java/lang/Class.html)

### Class<T>에 접근하는 방법
+ 모든 클래스를 로딩 한 다음 Class<T>의 인스턴스가 생긴다. "타입.class"로 접근할 수 있다.
+ 모든 인스턴스는 getClass() 메소드를 가지고 있다. "인스턴스.getClass()"로 접근할 수 있다.
+ 클래스를 문자열로 읽어오는 방법
  + Class.forName("FQCN")
  + 클래스패스에 해당 클래스가 없다면 ClassNotFoundException 이 발생한다.

~~~java

    public static void main(String[] args) throws ClassNotFoundException {

        Class<Test> testClass = Test.class;

        Test test = new Test();
        Class<? extends Test> aClass = test.getClass();
        
        Class<?> aClass1 = Class.forName("me.whiteship.java8to11.Test");

    }


~~~

### Class<T>를 통해 할 수 있는 것
+ 필드 (목록) 가져오기
+ 메소드 (목록) 가져오기
+ 상위 클래스 가져오기
+ 인터페이스 (목록) 가져오기
+ 애노테이션 가져오기 
+ 생성자 가져오기
+ 등등

~~~java

public static void main(String[] args) throws ClassNotFoundException {

        Class<Test> testClass = Test.class;

        /**
         * .getFields() public 필드 밖에 리턴을 안 한다
         */
        Arrays.stream(testClass.getFields()).forEach(System.out::println);

        /**
         * .getDeclaredFields() 모든 필드를 다 가져온다.
         * .getDeclaredFields("필드 이름") 특정 필드만 가져온다
         */
        Arrays.stream(testClass.getDeclaredFields()).forEach(System.out::println);


        /**
         * 필드의 값 출력
         * .setAccessible(true) 접근 지시자 무시
         */
        Test test = new Test();
        Arrays.stream(testClass.getDeclaredFields()).forEach(f -> {
            try {
                f.setAccessible(true);
                System.out.printf("%s %s", f, f.get(test));

            } catch (IllegalAccessException e) {
                throw new RuntimeException(e);
            }
        });

        /**
         *  .getMethods() 메소드 목록
         */
        Arrays.stream(testClass.getMethods()).forEach(System.out::println);

        /**
         * .getConstructors() 생성자 목록
         */
        Arrays.stream(testClass.getConstructors()).forEach(System.out::println);


        /**
         * .getSuperclass() 상위 클래스
         */
        System.out.println(testClass.getSuperclass());


        /**
         * getInterfaces() 인터페이스 목록
         */
        Arrays.stream(testClass.getInterfaces()).forEach(System.out::println);


        Arrays.stream(testClass.getDeclaredFields()).forEach(f -> {
            int modifiers = f.getModifiers();
            System.out.println(f);
            System.out.println(Modifier.isPrivate(modifiers)); // Private 인지
            System.out.println(Modifier.isStatic(modifiers)); // Static 인지
            f.getDeclaredAnnotations(); // 애노테이션 정보
        });


}

~~~

## 애노테이션과 리플렉션

### 중요 어노테이션
+ @Retention: 해당 애노테이션을 언제까지 유지할 것 인가? 소스, 클래스, 런타임
  + default : 클래스
  + 소스 , 클래스 : 바이트 코드를 로딩했을때는 메모리 상에 남지 않음
  + 런타임 까지 애노테이션을 유지하고 싶으면 런타임으로 설정해야함

~~~java

@Retention(RetentionPolicy.RUNTIME)
public @interface testAnno {
}

~~~

+ @Inherit: 해당 애노테이션을 하위 클래스까지 전달할 것인가?

~~~java

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.FIELD})
@Inherited
public @interface testAnno {
    
    String test() default "test";

    int n() default 10;
}


~~~

+ @Target: 어디에 사용할 수 있는가?

~~~java

@Retention(RetentionPolicy.RUNTIME)
@Target({ElementType.TYPE, ElementType.FIELD})
public @interface testAnno {
}


~~~

### 리플렉션
+ getAnnotations(): 상속 받은 (@Inherit) 애노테이션까지 조회
+ getDeclaredAnnotations(): 자기 자신에만 붙어 있는 애노테이션 조회

~~~java

public class TestMain {

    public static void main(String[] args) throws ClassNotFoundException {

        Class<Test> testClass = Test.class;

        /**
         * 상속 받은 (@Inherit) 애노테이션까지 조회
         */
        Arrays.stream(testClass.getAnnotations()).forEach(System.out::println);


        /**
         * 자기 자신에만 붙어 있는 애노테이션 조회
         */
        Arrays.stream(testClass.getDeclaredAnnotations()).forEach(System.out::println);


        Arrays.stream(testClass.getDeclaredFields()).forEach(f -> {
            Arrays.stream(f.getDeclaredAnnotations()).forEach(System.out::println); // 필드에 붙어 있는 애노테이션 조회
            Arrays.stream(f.getDeclaredAnnotations()).forEach(annotation -> {  // 애노테이션 값 참조
                if (annotation instanceof TestAnno){
                    TestAnno testAnno = (TestAnno) annotation;
                    System.out.println(testAnno.test());
                    System.out.println(testAnno.n());
                }
            });
        });

    }

}

~~~

## 리플렉션 API 2부: 클래스 정보 수정 또는 실행

### Class 인스턴스 만들기
+ Class.newInstance() 는 deprecated 됐으며 이제부터는 생성자를 통해서 만들어야 한다.

### 생성자로 인스턴스 만들기
+ Constructor.newInstance(params)

### 필드 값 접근하기/설정하기
+ 특정 인스턴스가 가지고 있는 값을 가져오는 것이기 때문에 인스턴스가 필요하다.
+ Field.get(object)
+ Field.set(Object, value)
+ Static 필드를 가져올 때는 object 가 없어도 되니간 null 을 넘기면 된다.

### 메소드 실행하기
+ Object Method.invoke(Object, params)


~~~java

public class Test {

    public static String A = "A";

    private String B = "B";

    public Test() {
    }

    public Test(String b) {
        B = b;
    }

    private void c(){
        System.out.println("C");
    }

    public int sum(int left, int right){
        return left + right;
    }

}

~~~


~~~java

public class App {
    public static void main(String[] args) throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException, NoSuchFieldException {

        Class<Test> testClass = Test.class;

        Constructor<Test> constructor = testClass.getConstructor(null);
        Test test = (Test) constructor.newInstance();

        Constructor<Test> constructor2 = testClass.getConstructor(String.class);
        Test test2 = (Test) constructor2.newInstance("test");


        Field a = Test.class.getDeclaredField("A");
        System.out.println(a.get(null));
        a.set(null, "test");
        System.out.println(a.get(null));

        Field b = Test.class.getDeclaredField("B");
        b.setAccessible(true);
        System.out.println(b.get(test));
        b.set(test, "test");
        System.out.println(b.get(test));


        Method c = Test.class.getDeclaredMethod("c");
        c.setAccessible(true);
        c.invoke(test);


        Method method = Test.class.getDeclaredMethod("sum", int.class, int.class);
        int invoke = (int) method.invoke(test, 1, 2);
        System.out.println(invoke);
    }

}

~~~

## 나만의 DI 프레임워크 만들기
+ @Inject 라는 애노테이션 만들어서 필드 주입 해주는 컨테이너 서비스 만들기

~~~java

@Retention(RetentionPolicy.RUNTIME)
public @interface Inject {

}

~~~

~~~java

public class TestService {
    @Inject
    TestRepository testRepository;
}

~~~

+ ContainerService.java

~~~java

public class ContainerService {

    public static <T> T getObject(Class<T> classType) {

        T instance = createInstance(classType);

        Arrays.stream(classType.getDeclaredFields()).forEach(field -> {
            if (field.getAnnotation(Inject.class) != null){
                Object fieldInstance = createInstance(field.getType());
                field.setAccessible(true);
                try {
                    field.set(instance, fieldInstance);
                } catch (IllegalAccessException e) {
                    throw new RuntimeException(e);
                }
            }
        });


        return instance;

    }

    private static <T> T createInstance(Class<T> classType) {
        try {
            return classType.getConstructor(null).newInstance();
        } catch (InstantiationException | IllegalAccessException | InvocationTargetException | NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }
    
}

~~~

> + classType 에 해당하는 타입의 객체를 만들어준다.
> + 단, 해당 객체의 필드 중에서 @Inject 가 있다면 해당 필드도 같이 만들어 제공한다.

## 리플렉션 정리

### 리플렉션 사용시 주의할 것
+ 지나친 사용은 성능 이슈를 야기할 수 있다, 반드시 필요한 경우에만 사용할 것
+ 컴파일 타임에 확인되지 않고 런타임 시에만 발생하는 문제를 만들 가능성이 있다.
+ 접근 지시자를 무시할 수 있다.

### 스프링
+ 의존성 주입
+ MVC 뷰에서 넘어온 데이터를 객체에 바인딩 할 때

### 하이버네이트
+ @Entity 클래스에 Setter 가 없다면 리플렉션을 사용한다.

### JUnit
+ [https://junit.org/junit5/docs/5.0.3/api/org/junit/platform/commons/util/ReflectionUtils.html](https://junit.org/junit5/docs/5.0.3/api/org/junit/platform/commons/util/ReflectionUtils.html)

### 참고
+ [https://docs.oracle.com/javase/tutorial/reflect/index.html](https://docs.oracle.com/javase/tutorial/reflect/index.html)
