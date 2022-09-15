---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 승팡, 케이의 REST Docs
date: '2022-09-14 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 승팡, 케이의 REST Docs
[https://youtu.be/BoVpTSsTuVQ](https://youtu.be/BoVpTSsTuVQ)

# 승팡, 케이의 REST Docs
* toc
{:toc}

## API 문서 자동화의 필요성 
+ 비효율적인 커뮤니케이션
+ Production 코드와의 불일치
+ 문서에 대한 신뢰성 문제 

## Swagger VS REST Docs
+ Swagger
  + OpenAPI Spec 에 맞게 디자인하고 문서화하고 빌드하기 위한 도구들의 모음
  + OpenAPI Spec
    + 이전에는 Swagger Spec 으로 알려졌던 OpenAPI Spec 은 RESTful 웹 서비스를 설명, 생성, 소비 및 시각화하기 위한 기계 판독 가능 인터페이스 사양이다. 
    + 쉽게말해서 API 자체를 설명하는 인터페이스 스펙이라고 보면 된다.
  + 장점
    + Annotation 기반으로 문서 생성.
    + 쉽게 적용할 수 있다.
    + 화면에서 API 테스트 가능하다.
  + 단점
    + Production 코드에 문서화를 위한 코드 필요
    + 검증되지 않은 API 문서 생성
+ REST Docs
  + 테스트 코드 기반으로 RESTful 문서 생성을 돕는 도구 
  + Asciidoctor 를 사용하여 HTML 를 생성
  + 테스트로 생성된 snippet 을 사용해서 snippet 이 올바르지 않으면 생성된 테스트가 실패하여 정확성을 보장
  + Asciidoctor
    + AsciiDoc 을 HTML, DocBook 등으로 변환하기 위한 빠른 텍스트 프로세서 
    + AsciiDoc 은 adoc 형식의 파일 형식이다.
  + snippet
    + snippet 은 문서화에 필요한 문서 조각이다.
  + 장점
    + 테스타가 성공해야 문서가 생성
    + api 명세 최신화가 강제
    + Production 코드에 영향이 없다
  + 단점
    + 어렵다
    + 테스트 코드 양이 많아진다
+ 두가지를 동시에 사용하는 방법도 존재
  + REST Docs 를 openAPI Spec 으로 변환 후 Swagger UI 에서 사용하는 방법
  + REST Docs 를 openAPI Spec 으로 변환 방법
    + ePage 라는 기업에서 오픈소스로 만들어 놓은게 있다. 이 REST Docs 를 openAPI Spec 으로 변환 하는 게 있다. 

## REST Docs 환경세팅
+ ![img.png](/assets/img/elegant-tekotok/restDocs.png)
  1. Asciidoctor 파일을 컨버팅 하고 Build 폴더에 복사하기 위한 플러그인 
+ ![img.png](/assets/img/elegant-tekotok/restDocs2.png) 
  2. asciidoctorExt 를 configurations 로 지정
+ ![img.png](/assets/img/elegant-tekotok/restDocs3.png)  
  3. adoc 파일에서 사용할 snippet 속성이 자동으로 build/generated-snippets 를 가리키도록 해준다.
+ ![img.png](/assets/img/elegant-tekotok/restDocs4.png)
  4. snippets 파일이 저장될 경로 snippetsDir 로 변수 설정
  5. 출력할 디렉토리 snippetsDir로 설정
  6. Asciidoctor 에서 asciidoctorExt 설정 사용
  7. .adoc 파일에서 다른 .adoc 를 include 하여 사용하는 경우 경로를 동일한 경로를 baseDir 로 동일하게 설정 
  8. Input 디렉토리를 snippetsDir 로 설정
  9. Gradle build 시 test -> asciidoctor 순으로 진행된다.
+ ![img.png](/assets/img/elegant-tekotok/restDocs5.png)
  10. asciidoctor 가 실행될 때 처음으로 해당 경로에 있는 파일들을 지운다. - 기존 생성파일 지움
  11. 실행 task 를 정의하고 type 을 복사로 정의 from 에 위치한 파일들을 into 로 복사
  12. Gradle build 시 asciidoctor -> createDocument 순으로 진행된다.
  13. Gradle build 시 createDocument -> bootJar 순으로 진행된다.
  14. Gradle build 시 asciidoctor.outputDir 에 HTML 파일이 생이고 이것을 jar 안에 resources/static 폴더에 복사

+ 빌드 -> 테스트 성공하고 asciidoctor 가 실행되고 -> asciidoctor 성공 하면 createDocument task 가 실행되고 -> createDocument 성공하면 bootJar 가 실행된다.


## Controller Test 초기 세팅

~~~java

@Autowired 
protected RestDocumentationResultHandler restDocs;

@Autowired
protected ObjectMapper objectMapper; 

~~~
+ RestDocumentationResultHandler
  + REST Docs 의 결과를 핸들링
   
~~~java

@BeforeEach
void setUp(
        final WebApplicationContext context,
        final RestDocumentationContextProvider provider
){
    
    this.mockMvc = MockMvcBuilders.webAppcontextSetup(context)
        .apply(MockMvcRestDocumentation.documentationConfiguration(provider))
        .alwaysDo(restDocs)
        .build()
    
}

~~~
+ MockMvc 세팅
  + MockMvc 세팅이 번거로우면 자동 주입 가능
    + @AutoConfigureMockMvc - MockMvc 를 자동 주입 
      + MockMvcBuilders.webAppcontextSetup(context) 를 자동으로 해준다
    + @AutoConfigureRestDocs - REST Docs 관련 진행 자동 주입
      + MockMvcRestDocumentation.documentationConfiguration(provider) 를 자동으로 해준다
    + 편리하다는 장점이 있지만 커스터마이징 하기가 좀 어렵다는 단점이 있다.

![img.png](/assets/img/elegant-tekotok/restDocs6.png)
+ prettyPrint
  + snippet 좀 더 가독성 있게 이쁘게 출력하고 싶으면 prettyPrint preprocess 에 걸어 주면 된다.
  + preprocess 걸어 주기 위해서는 RestDocsConfiguration 이란 클래스 만들어서 RestDocumentationResultHandler 의 write 메서드를 Bean 으로 등록해 주면 된다.
    + Spring 이 관리 해주 수 있다.
  + identifier 를 보면 클래스명과 메소드명을 적어 줬다
    + identifier 는 snippet 가 생성되는 디렉토리 경로 명을 작성 해 주는 것이다.
  + prettyPrint 적용 전과 후
    + ![img.png](/assets/img/elegant-tekotok/restDocs7.png)

## Controller Test 테스트 코드 작성
![img.png](/assets/img/elegant-tekotok/restDocs9.png)
![img.png](/assets/img/elegant-tekotok/restDocs8.png)
![img.png](/assets/img/elegant-tekotok/restDocs10.png)
+ 응답 필드를 지정해주기 위해 responseFields 로 지정해 주었다.
  + 타입은 생략이 가능하다

![img.png](/assets/img/elegant-tekotok/restDocs11.png)
![img.png](/assets/img/elegant-tekotok/restDocs12.png)
+ 쿼리 파람을 넘겨준 경우는 requestParameters 를 이용하면 된다.
  + parameterWithName 은 fieldWithPath 랑 유사한 기능을 한다. 
+ 리스트안에 객체를 지정해주기 위해서 endWithPrefix 를 사용한다. 
  + endWithPrefix 는 rollinpapers 안의 객체를 명시해 주기 위해서 rollinpapers 라는 접두사를 앞에 넣어 준 거다. 리스트를 의미하는 대괄호를 넣어 준 걸 확인할 수 있다.

![img.png](/assets/img/elegant-tekotok/restDocs13.png)
+ RestDocumentationResultHandler 를 설정해주고 스프링 부트 테스트를 설정해주면은 RestDocumentationResultHandler 가 알아서 실제 요청 값과 응답 값에 따라서 API를 직접 생성해준다.
  + 대신 이렇게 하면 description, type 은 지정해 줄 수가 없다. 
    + 실제 요청 값과 응답 값을 스프링부트 테스트를 설정해서 SpringBootTest 가 분석해 준 것이기 때문이다.
+ ![img.png](/assets/img/elegant-tekotok/restDocs14.png)
  + restDocs RestDocumentationResultHandler 을 직접 이렇게 alwaysDo 로 결과마다 endDo 에 항상 실행되게 해 놓은 것을 알수 있다. 

## AsciiDoctor 문법
+ 생성된 스니펫을 사용하기 전에, adoc 소스 파일을 생성해야 합니다. .adoc 파일명은 원하는 대로 지정할 수 있습니다. 결과로, .adoc 소스 파일명과 같은 이름의 html 문서가 생성 됩니다. 
+ adoc 파일은 src/docs/asciidoc 이란느 디렉토리안에 설정해주면 된다.
+ index.adoc 은 여러 API 명세들을 한번에 확인할 수 있도록 members.adoc, messages.adoc 이런 adoc 파일들을 index.adoc 에 한꺼번에 넣기 위해서 생성해 준다.  
+ AsciiDoc 이라는 인텔리제이에서 제공해주는 플러그인을 설치하면 미리 볼 수 있다.

1. =, ==, ===
   + ![img.png](/assets/img/elegant-tekotok/restDocs15.png)
2. :source-highlighter:highlightjs - 가독성 있게 색깔 표시
   + ![img.png](/assets/img/elegant-tekotok/restDocs16.png)
3. :toc:left
   + ![img.png](/assets/img/elegant-tekotok/restDocs17.png)
   + toc는 Table of Contents 의 약자 
   + API 명세에 대한 안내가 되어있다. 왼쪽에 toc가 생긴걸 확인할 수 있다. right 는 오른 쪽 up 으로 작성하면 위쪽으로 된다.
4. :toclevels: 2
   + ![img.png](/assets/img/elegant-tekotok/restDocs18.png)
   + API 명세 안내가 되어있다. 
   + 가독성에 따라서 원하는대로 toclevels 을 설정  
5. :sectlinks:
   + ![img.png](/assets/img/elegant-tekotok/restDocs19.png)
   + 클릭하면 해당 API로 이동할 수 있도록 링크 옵션을 걸어준다.
6. include::
   + ![img.png](/assets/img/elegant-tekotok/restDocs20.png)
   + index.adoc 에서 다른 adoc 파일들을 include 한다.
