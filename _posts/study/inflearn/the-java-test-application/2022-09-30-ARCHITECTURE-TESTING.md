---
layout: post
bigtitle: '더 자바, 애플리케이션을 테스트하는 다양한 방법'
subtitle: 아키텍처 테스트
date: '2022-09-30 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java-test-application
comments: true
---

# 아키텍처 테스트

# 아키텍처 테스트
* toc
{:toc}

## ArchUnit 소개
+ [https://www.archunit.org/](https://www.archunit.org/)
+ 애플리케이션의 아키텍처를 테스트 할 수 있는 오픈 소스 라이브러리로, 패키지, 클래스, 레이어, 슬라이스 간의 의존성을 확인할 수 있는 기능을 제공한다.

### 아키텍처 테스트 유즈 케이스
+ A 라는 패키지가 B(또는 C,D) 패키지에만 사용 되고 있는지 확인 가능
+ *Service라는 이름의 클래스들이 *Controller 또는 *Service 라는 이름의 클래스에서만 참조하고 있는지 확인 
+ *Service 라는 이름의 클래스들이 ..service.. 라는 패키지에 들어있는지 확인 
+ A라는 애노테이션을 선언한 메소드만 특정 패키지 또는 특정 애노테이션을 가진 클래스를 호출하고 있는지 확인.
+ 특정한 스타일의 아키텍처를 따르고 있는지 확인

### 참고
+ [https://blogs.oracle.com/javamagazine/unit-test-your-architecture-with-archunit](https://blogs.oracle.com/javamagazine/unit-test-your-architecture-with-archunit)
+ [https://www.archunit.org/userguide/html/000_Index.html](https://www.archunit.org/userguide/html/000_Index.html)
+ [Moduliths](https://github.com/odrotbohm/moduliths)


## ArchUnit 설치
+ [https://www.archunit.org/userguide/html/000_Index.html#_junit_5](https://www.archunit.org/userguide/html/000_Index.html#_junit_5)
+ JUnit 5용 ArchUnit 설치

~~~xml

<dependency>
    <groupId>com.tngtech.archunit</groupId>
    <artifactId>archunit-junit5-engine</artifactId>
    <version>0.12.0</version>
    <scope>test</scope>
</dependency>

~~~

+ 주요 사용법
  1. 특정 패키지에 해당하는 클래스를 (바이트코드를 통해) 읽어들이고
  2. 확인할 규칙을 정의하고 
  3. 읽어들인 클래스들이 그 규칙을 잘 따르는지 확인한다

~~~java

@Test
public void Services_should_only_be_accessed_by_Controllers() {
    // TODO : 특정 패키지에 해당하는 클래스를 (바이트코드를 통해) 읽어들이고
    JavaClasses importedClasses = new ClassFileImporter().importPackages("com.mycompany.myapp");

    // TODO : 확인할 규칙을 정의하고 
    ArchRule myRule = classes()
        .that().resideInAPackage("..service..")
        .should().onlyBeAccessed().byAnyPackage("..controller..", "..service..");

    // TODO : 읽어들인 클래스들이 그 규칙을 잘 따르는지 확인한다
    myRule.check(importedClasses);
}

~~~

+ JUnit 5 확장팩 제공
  + @AnalyzeClasses: 클래스를 읽어들여서 확인할 패키지 설정
  + @ArchTest: 확인할 규칙 정의

## ArchUnit: 패키지 의존성 확인하기 
+ 확인하려는 패키지 구조

<div class="language-mermaid">
graph LR;
    Study-->Domain;
    Study-->Member;
    Member-->Domain;
</div>

+ 실제로 그런지 확인
  + ..domain.. 패키지에 있는 클래스는 ..study.., ..member.., ..domain에서 참조 가능.
  + ..member.. 패키지에 있는 클래스는 ..study..와 ..member..에서만 참조 가능.
    + (반대로) ..domain.. 패키지는 ..member.. 패키지를 참조하지 못한다.
  + ..study.. 패키지에 있는 클래스는 ..study.. 에서만 참조 가능.
  + 순환 참조 없어야 한다.

~~~java

public class ArchTests {

    @Test
    void packageDependencyTests() {
        JavaClasses classes = new ClassFileImporter().importPackages("me.test.inflearnthejavatest");

        // TODO : ..domain.. 패키지에 있는 클래스는 ..study.., ..member.., ..domain에서 참조 가능.
        ArchRule domainPackageRule = classes().that().resideInAPackage("..domain..")
                .should().onlyBeAccessed().byClassesThat()
                .resideInAnyPackage("..study..", "..member..", "..domain..");
        domainPackageRule.check(classes);

        // TODO : ..domain.. 패키지는 ..member.. 패키지를 참조하지 못한다.
        ArchRule memberPackageRule = noClasses().that().resideInAPackage("..domain..")
                .should().accessClassesThat().resideInAPackage("..member..");
        memberPackageRule.check(classes);

        // TODO : ..study.. 패키지에 있는 클래스는 ..study.. 에서만 참조 가능.
        ArchRule studyPackageRule = noClasses().that().resideOutsideOfPackage("..study..")
                .should().accessClassesThat().resideInAnyPackage("..study..");
        studyPackageRule.check(classes);

        // TODO : 순환 참조 없어야 한다.
        ArchRule freeOfCycles = slices().matching("..inflearnthejavatest.(*)..")
                .should().beFreeOfCycles();
        freeOfCycles.check(classes);
    }

}

~~~

## ArchUnit: JUnit 5 연동하기
+ @AnalyzeClasses: 클래스를 읽어들여서 확인할 패키지 설정
+ @ArchTest: 확인할 규칙 정의

~~~java

@AnalyzeClasses(packagesOf = App.class)
public class ArchTests {

    // TODO : ..domain.. 패키지에 있는 클래스는 ..study.., ..member.., ..domain에서 참조 가능.
    @ArchTest
    ArchRule domainPackageRule = classes().that().resideInAPackage("..domain..")
            .should().onlyBeAccessed().byClassesThat()
            .resideInAnyPackage("..study..", "..member..", "..domain..");

    // TODO : ..domain.. 패키지는 ..member.. 패키지를 참조하지 못한다.
    @ArchTest
    ArchRule memberPackageRule = noClasses().that().resideInAPackage("..domain..")
            .should().accessClassesThat().resideInAPackage("..member..");

    // TODO : ..study.. 패키지에 있는 클래스는 ..study.. 에서만 참조 가능.
    @ArchTest
    ArchRule studyPackageRule = noClasses().that().resideOutsideOfPackage("..study..")
            .should().accessClassesThat().resideInAnyPackage("..study..");

    // TODO : 순환 참조 없어야 한다.
    @ArchTest
    ArchRule freeOfCycles = slices().matching("..inflearnthejavatest.(*)..")
            .should().beFreeOfCycles();

}

~~~

## ArchUnit: 클래스 의존성 확인하기
+ 확인하려는 클래스 의존성

<div class="language-mermaid">
graph LR;
    StudyController-->StudyService;
    StudyController-->StudyRepository;
    StudyService-->StudyRepository;
</div>

+ 테스트 할 내용
  + StudyController는 StudyService와 StudyRepository를 사용할 수 있다.
  + Study* 로 시작하는 클래스는 ..study.. 패키지에 있어야 한다.
  + StudyRepository는 StudyService와 StudyController를 사용할 수 없다.

~~~java

@AnalyzeClasses(packagesOf = App.class)
public class ArchClassTests {

    // TODO : StudyController는 StudyService와 StudyRepository를 사용할 수 있다.
    @ArchTest
    ArchRule controllerClassRule = classes().that().haveSimpleNameEndingWith("Controller")
            .should().accessClassesThat().haveSimpleNameEndingWith("Service")
            .orShould().accessClassesThat().haveSimpleNameEndingWith("Repository");

    // TODO : StudyRepository는 StudyService와 StudyController를 사용할 수 없다.
    @ArchTest
    ArchRule repositoryClassRule = noClasses().that().haveSimpleNameEndingWith("Repository")
            .should().accessClassesThat().haveSimpleNameEndingWith("Service");

    // TODO : Study* 로 시작하는 클래스는 ..study.. 패키지에 있어야 한다.
    @ArchTest
    ArchRule studyClassesRule = classes().that().haveSimpleNameStartingWith("Study")
            .and().areNotEnums()
            .and().areNotAnnotatedWith(Entity.class)
            .should().resideInAnyPackage("..study..");

}

~~~