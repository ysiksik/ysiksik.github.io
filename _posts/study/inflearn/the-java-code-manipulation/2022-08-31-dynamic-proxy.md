---
layout: post
bigtitle: '더 자바, 코드를 조작하는 다양한 방법'
subtitle: 다이나믹 프록시
date: '2022-08-31 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java-code-manipulation
comments: true
---

# 다이나믹 프록시

# 다이나믹 프록시
* toc
{:toc}

## 스프링 데이터 JPA 동작
+ 스프링 데이터 JPA 에서 인터페이스 타입의 인스턴스는 누가 만들어 주는가?
  + Spring AOP 를 기반으로 동작하며 RepositoryFactorySupport 에서 프록시를 생성한다.

## 프록시 패턴

<div class="language-mermaid">
graph LR;
    클라이언트-->서브젝트;
    프록시-.->서브젝트;
    리얼서브젝트-.->서브젝트;
    프록시-->리얼서브젝트;
</div>

<div class="language-mermaid">
graph LR;
    클라이언트-->프록시;
    프록시-->리얼서브젝트;
</div>

+ 프록시와 리얼 서브젝트가 공유하는 인터페이스가 있고, 클라이언트는 해당 인터페이스 타입으로 프록시를 사용한다.
+ 클라이언트는 프록시를 거쳐서 리얼 서브젝트를 사용하기 때문에 프록시는 리얼 서브젝트에 대한 접근을 관리하거나 부가기능을 제공하거나 리턴값을 변경할 수도 있다.
+ 리얼 서브젝트는 자신이 해야 할 일만 하면서(SRP) 프록시를 사용해서 부가적인 기능(접근 제한, 로깅, 트랜젝션 등)을 제공할 때 이런 패턴을 주로 사용한다.
+ 문제 
  + 굉장히 번거롭다
  + 부가적인 기능을 추가할 때마다 프록시를 만들어야 한다.
  + 프록시가 프록시를 감싸는 경우도 발생한다.
  + 타겟으로 위임하는 코드가 중복해서 발생할 수 있다.
+ 매번 프록시 클래스를 만드는게 아니라 런타임에 동적으로 프록시를 만드는 방법을 __다이나믹프록시__ 라고 한다.
  + 자바 리플렉션 패키지에서 제공하는 기능이 있다.
+ 서브젝트
~~~java

public interface TestService {
    void rent(String str );
}


~~~

+ 리얼 서브젝트

~~~java

public class DefaultTestServiceImpl implements TestService{
    @Override
    public void rent(String str) {
        System.out.println("rent : " + str);
    }
}

~~~

+ 프록시

~~~java

public class TestProxy implements TestService{

    TestService testService;

    public TestProxy(TestService testService) {
        this.testService = testService;
    }

    @Override
    public void rent(String str) {
        System.out.println("시작");
        testService.rent(str);
        System.out.println("끝");
    }
}

~~~

### 참고 
+ [https://www.oodesign.com/proxy-pattern.html](https://www.oodesign.com/proxy-pattern.html)
+ [https://en.wikipedia.org/wiki/Proxy_pattern](https://en.wikipedia.org/wiki/Proxy_pattern)
+ [https://en.wikipedia.org/wiki/Single_responsibility_principle](https://en.wikipedia.org/wiki/Single_responsibility_principle)


## 다이나믹 프록시 실습
+ 런타임에 특정 인터페이스들을 구현하는 클래스 또는 인스턴스를 만드는 기술
+ “an application can use a dynamic proxy class to create an object that implements multiple arbitrary event listener interfaces”
  + “응용 프로그램은 동적 프록시 클래스를 사용하여 여러 임의 이벤트 수신기 인터페이스를 구현하는 개체를 만들 수 있습니다”
  + [https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/proxy.html](https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/proxy.html)

### 프록시 인스턴스 만들기
+ Object Proxy.newProxyInstance(ClassLoader, Interfaces, InvocationHandler)

~~~java

class DefaultTestServiceImplTest {

    TestService testService = (TestService) Proxy.newProxyInstance(TestService.class.getClassLoader(), new Class[]{TestService.class},
            new InvocationHandler() {
                TestService testService = new DefaultTestServiceImpl();

                @Override
                public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {

                    if (method.getName().equals("rent")) {
                        System.out.println("시작");
                        Object invoke = method.invoke(testService, args);
                        System.out.println("종료");
                        return invoke;
                    } else {
                        return method.invoke(testService, args);
                    }
                }
            }
    );

    @Test
    void test() {
        testService.rent("진행");
    }
}

~~~

+ 유연한 구조가 아니다. 그래서 스프링 AOP 등장
+ 제약사항 클래스 기반의 프록시는 만들지 못한다. 인터페이스 기반으로 만들어야 한다.

### 참고
+ [https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/proxy.html](https://docs.oracle.com/javase/8/docs/technotes/guides/reflection/proxy.html)
+ [https://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Proxy.html#newProxyInstance-java.lang.ClassLoader-java.lang.Class:A-java.lang.reflect.InvocationHandler](https://docs.oracle.com/javase/8/docs/api/java/lang/reflect/Proxy.html#newProxyInstance-java.lang.ClassLoader-java.lang.Class:A-java.lang.reflect.InvocationHandler)

## 클래스의 프록시가 필요하다면?
+ 서브 클래스를 만들 수 있는 라이브러리를 사용하여 프록시를 만들 수 있다.

### CGlib
+ [https://github.com/cglib/cglib/wiki](https://github.com/cglib/cglib/wiki)
+ 스프링, 하이버네이트가 사용하는 라이브러리
+ 버전 호환성이 좋치 않아서 서로 다른 라이브러리 내부에 내장된 형태로 제공되기도 한다.

~~~xml

<dependency>
    <groupId>cglib</groupId>
    <artifactId>cglib</artifactId>
    <version>3.3.0</version>
</dependency>

~~~

~~~java

class DefaultTestServiceImplTest {

    @Test
    void test() {

        MethodInterceptor handler = new MethodInterceptor() {
            DefaultTestServiceImpl testService = new DefaultTestServiceImpl();
            @Override
            public Object intercept(Object o, Method method, Object[] objects, MethodProxy methodProxy) throws Throwable {
                System.out.println("시작");
                Object invoke = method.invoke(testService, objects);
                System.out.println("종료");
                return invoke;

            }
        };

        DefaultTestServiceImpl testService = (DefaultTestServiceImpl) Enhancer.create(DefaultTestServiceImpl.class, handler);

        testService.rent("진행");
    }
}

~~~

### ByteBuddy
+ [https://bytebuddy.net/#/](https://bytebuddy.net/#/)
+ 바이트 코드 조작 뿐 아니라 런타임(다이나믹) 프록시를 만들 때도 사용할 수 있다.

~~~xml

<dependency>
    <groupId>net.bytebuddy</groupId>
    <artifactId>byte-buddy</artifactId>
</dependency>

~~~

~~~java

class DefaultTestServiceImplTest {

    @Test
    void test() throws NoSuchMethodException, InvocationTargetException, InstantiationException, IllegalAccessException {

        Class<? extends DefaultTestServiceImpl> procyClass = new ByteBuddy().subclass(DefaultTestServiceImpl.class)
                .method(named("rent")).intercept(InvocationHandlerAdapter.of(new InvocationHandler() {
                    DefaultTestServiceImpl defaultTestService = new DefaultTestServiceImpl();

                    @Override
                    public Object invoke(Object proxy, Method method, Object[] args) throws Throwable {
                        System.out.println("시작");
                        Object invoke = method.invoke(defaultTestService, args);
                        System.out.println("종료");
                        return invoke;
                    }
                }))
                .make().load(DefaultTestServiceImpl.class.getClassLoader()).getLoaded();

        DefaultTestServiceImpl testService = procyClass.getConstructor(null).newInstance();

        testService.rent("진행");
    }
}

~~~

### 서브 클래스를 만드는 방법읜 단점
+ 상속을 사용하지 못하는 경우 프록시를 만들 수 없다.
  + Private 생성자만 있는 경우
  + Final 클래스인 경우
+ 인터페이스가 있을 때는 인터페이스의 프록시를 만들어 사용할 것.

## 다이나믹 프록시 정리

### 다이나믹 프록시
+ 런타임에 인터페이스 또는 클래스의 프록시 인스턴스 또는 클래스를 만들어 사용하는 프로그래밍 기법

### 다이나믹 프록시 사용처
+ 스프링 데이터 JPA
+ 스프링 AOP
+ Mockito
+ 하이버네이트 lazy initialzation

### 참고
+ [http://tutorials.jenkov.com/java-reflection/dynamic-proxies.html](http://tutorials.jenkov.com/java-reflection/dynamic-proxies.html)