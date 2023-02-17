---
layout: post
bigtitle: '더 자바, 코드를 조작하는 다양한 방법'
subtitle: 바이트코드 조작
date: '2022-08-29 00:00:00 +0900'
categories:
    - the-java-code-manipulation
comments: true
---

# 바이트코드 조작

# 바이트코드 조작
* toc
{:toc}

## 코드 커버리지는 어떻게 측정할까?

### 코드커버리지, 테스트 코드가 확인한 소스 코드를 %
+ JaCoCo를 써보자
+ [https://www.eclemma.org/jacoco/trunk/doc/index.html](https://www.eclemma.org/jacoco/trunk/doc/index.html)
+ [http://www.semdesigns.com/Company/Publications/TestCoverage.pdf](http://www.semdesigns.com/Company/Publications/TestCoverage.pdf)
+ pom.xml에 플러그인 추가

~~~xml

<plugin>
    <groupId>org.jacoco</groupId>
    <artifactId>jacoco-maven-plugin</artifactId>
    <version>0.8.4</version>
    <executions>
        <execution>
            <goals>
                <goal>prepare-agent</goal>
            </goals>
        </execution>
        <execution>
            <id>report</id>
            <phase>prepare-package</phase>
            <goals>
                <goal>report</goal>
            </goals>
        </execution>
    </executions>
</plugin>

~~~

+ 메이븐 빌드

      mvn clean verify

+ 커버리지 만족 못할시 빌드 실패하도록 설정

~~~xml

<execution>
    <id>jacoco-check</id>
    <goals>
        <goal>check</goal>
    </goals>
    <configuration>
        <rules>
            <rule>
                <element>PACKAGE</element>
                <limits>
                    <limit>
                        <counter>LINE</counter>
                        <value>COVEREDRATIO</value>
                        <minimum>0.50</minimum>
                    </limit>
                </limits>
            </rule>
        </rules>
    </configuration>
</execution>

~~~

+ 바이트 코드를 읽어서 바이트 코드에서 코드 커버리지를 챙겨야 하는 부분의 개수를 세고 코드가 실행될 때 그중에 몇 개를 지나가는지 카운팅을 하고 비교를 해서 보여주고 계산한다.

## 바구니에서 사과를 꺼내는 마술
+ 아무것도 없는 Basket 에서 "APPLE"을 꺼내는 마술
+ Basket.java

~~~java

public class Basket {
    public String takeItOut() {
        return "";
    }
}

~~~

+ Imposter.java

~~~java

public class Imposter {
    public static void main(String[] args) {
        System.out.println(new Basket().takeItOut());
    }
}

~~~

### 바이트 코드 조작 라이브러리
+ [ASM](https://asm.ow2.io/)
  + 가장 고전적이고 널리 쓰이고 있다.
  + 어렵다.
+ [Javassist](https://www.javassist.org/)
+ [ByteBuddy](https://bytebuddy.net/#/)
  + 최근에는 많이 쓰인다.
  + 쉽다.

~~~java

public class Imposter {

    public static void main(String[] args) {
        try {
            new ByteBuddy().redefine(Basket.class).method(named("takeItOut")).intercept(FixedValue.value("APPLE"))
                    .make().saveIn(new File("C:\\PROJECT\\IntelliJ\\studyWorkspaces\\study\\target\\classes\\"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }  // 여기 까지 먼저 실행해야 한다. 미리 조작을 해논다.

        System.out.println(new Basket().takeItOut()); // 조작 후에 실행 
    }

}

~~~

+ 아래처럼 구현하면 따로 실행할 필요 없이 한 번에 조작이 가능하다.
  + 클래스 로딩 순서에 의존 적이다. 
  + 다른 곳에서 Basket 을 먼저 읽었으면 안 먹힌다.

~~~java

public class Imposter {

    public static void main(String[] args) {

        ClassLoader classLoader = Imposter.class.getClassLoader();
        TypePool typePool = TypePool.Default.of(classLoader);

        try {
            new ByteBuddy().redefine(typePool.describe("me.whiteship.java8to11.Basket").resolve(),
                            ClassFileLocator.ForClassLoader.of(classLoader))
                    .method(named("takeItOut")).intercept(FixedValue.value("APPLE"))
                    .make().saveIn(new File("C:\\PROJECT\\IntelliJ\\studyWorkspaces\\inflearn-the-java8\\target\\classes\\"));
        } catch (IOException e) {
            throw new RuntimeException(e);
        }

        System.out.println(new Basket().takeItOut());
    }

}


~~~

+ Basket 라는 클래스를 애플리케이션 클래스 로더가 읽고 ByteBuddy를 로딩할 때 Basket 클래스 를 읽으면 Basket 클래스는 하나지만 JVM 안에서는 두개랑 마찬가지다
  + 패키도도 같고 풀패키지 이름도 갖지만 서로 다르다.

## javaagent 실습

### javaagent JAR 만들기 
+ [https://docs.oracle.com/javase/8/docs/api/java/lang/instrument/package-summary.html](https://docs.oracle.com/javase/8/docs/api/java/lang/instrument/package-summary.html)
+ 붙이는 방식은 시작시 붙이는 방식 premain 과 런타임 중에 동적으로 붙이는 방식 agentmain 이 있다.
+ Instrumentation 을 사용한다.

### javaagent 붙여서 사용하기
+ 클래스로더가 클래스를 읽어올 때 javaagent 를 거쳐서 변경된 바이트코드를 읽어들여 사용한다.

+ ImposterAgent.java (새로운 프로젝트)

~~~java

public class ImposterAgent {

    public static void premain(String agentArgs, Instrumentation inst) {
        new AgentBuilder.Default()
                .type(ElementMatchers.any())
                .transform((builder, typeDescription, classLoader, javaModule) ->
                        builder.method(named("takeItOut")).intercept(FixedValue.value("APPLE"))).installOn(inst);
    }

}


~~~

+ pom.xml (새로운 프로젝트)

~~~xml

<dependencies>
    <dependency>
        <groupId>net.bytebuddy</groupId>
        <artifactId>byte-buddy</artifactId>
        <version>1.10.1</version>
    </dependency>
</dependencies>
<build>
<plugins>
    <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>3.1.2</version>
        <configuration>
            <archive>
                <index>true</index>
                <manifest>
                    <addClasspath>true</addClasspath>
                </manifest>
                <manifestEntries>
                    <mode>development</mode>
                    <url>${project.url}</url>
                    <key>value</key>
                    <Premain-Class>me.whiteship.java8to11.ImposterAgent</Premain-Class>
                    <Can-Redefine-Classes>true</Can-Redefine-Classes>
                    <Can-Retransform-Classes>true</Can-Retransform-Classes>
                </manifestEntries>
            </archive>
        </configuration>
    </plugin>
</plugins>
</build>

~~~

+ javaagent 적용 (기존 프로젝트의 VM options)

        -javaagent:/Users/siksik/studyWorkspace/ImposterAgent/target/ImporsterAgent-1.0-SNAPSHOT.jar

+ Imposter 실행 (기존 프로젝트)

~~~java

public class Imposter {

    public static void main(String[] args) {
        System.out.println(new Basket().takeItOut()); // 조작 후에 실행 
    }

}

~~~

+ 이전의 방식은 클래스 파일을 변경하는 방식이었다. __지금의 방식은__ 클래스 파일 자체가 바뀌지 않고 로딩 할 때 javaagent를 거쳐서 변경된 바이트코드를 읽어 메모리에 들어가는 방식으로 동작한다.

## 바이트코드 조작 툴 활용 예

+ 프로그램 분석
  + 코드에서 버그 찾는 툴
  + 코드 복잡도 계산
+ 클래스 파일 생성
  + 프록시
    + 스프링 AOP
    + 하이버네이트 lazing loading 하는 객체들을 프록시 객체로 만들어 제공
    + mock 프레임워크 
  + 특정 API 호출 접근 제한
  + 스칼라 같은 언어의 컴파일러
+ 그밖에도 자바 소스 코드 건드리지 않고 코드 변경이 필요한 여려 경우에 사용할 수 있다.
  + 프로파일러 (newrelic)
    + 메모리를 얼마나 사용하는지
    + 스레드가 몇개인지
    + 스레드가 어떻게 활성화 되어 있고 어떤 스레드가 바쁜지
  + 최적화
  + 로깅
  + 무궁무진 하다 
+ 스프링이 컴포넌트 스캔을 하는 방법 (asm)
  + 컴포넌트 스캔으로 빈으로 등록할 후보 클래스 정보를 찾는데 사용
  + ClassPathScanningCandidateComponentProvider -> SimpleMetadataReader
  + ClassReader 와 Visitor 사용해서 클래스에 있는 메타 정보를 읽어온다.
+ 참고
  + [https://www.youtube.com/watch?v=39kdr1mNZ_s](https://www.youtube.com/watch?v=39kdr1mNZ_s)
  + ASM, Javassist, ByteBuddy, CGlib
