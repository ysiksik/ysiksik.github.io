---
layout: post
bigtitle: '더 자바, 애플리케이션을 테스트하는 다양한 방법'
subtitle: 도커와 테스트
date: '2022-09-14 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java-test-application
comments: true
---

# 도커와 테스트

# 도커와 테스트
* toc
{:toc}

## Testcontainers 소개
+ 테스트에서 도커 컨테이너를 실행할 수 있는 라이브러리
  + [https://www.testcontainers.org/](https://www.testcontainers.org/)
  + 테스트 실행시 DB를 설정하거나 별도의 프로그램 또는 스크립트를 실행할 필요 없다.
  + 보다 Production 에 가까운 테스트를 만들 수 있다.
  + 테스트가 느려진다.

## Testcontainers 설치

### Testcontainers JUnit 5 지원 모듈 설치

~~~xml

<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>junit-jupiter</artifactId>
    <version>1.15.1</version>
    <scope>test</scope>
</dependency>

~~~
+ [https://www.testcontainers.org/test_framework_integration/junit_5/](https://www.testcontainers.org/test_framework_integration/junit_5/)

### @Testcontainers
+ JUnit 5 확장팩으로 테스트 클래스에 @Container 를 사용한 필드를 찾아서 컨테이너 라이프사이클 관련 메소드를 실행해준다.

### @Container
+ 인스턴스 필드에 사용하면 모든 테스트 마다 컨테이너를 재시작 하고, 스태틱 필드에 사용하면 클래스 내부 모든 테스트에서 동일한 컨테이너를 재사용한다. 

### 여러 모듈을 제공하는데, 각 모듈은 별도로 설치해야 한다.
+ Postgresql 모듈 설치
+ [https://www.testcontainers.org/modules/databases/](https://www.testcontainers.org/modules/databases/)
+ [https://www.testcontainers.org/modules/databases/postgres/](https://www.testcontainers.org/modules/databases/postgres/)

~~~xml

<dependency>
    <groupId>org.testcontainers</groupId>
    <artifactId>postgresql</artifactId>
    <version>1.15.1</version>
    <scope>test</scope>
</dependency>

~~~

~~~properties

spring.datasource.url=jdbc:tc:postgresql:///studytest
spring.datasource.driver-class-name=org.testcontainers.jdbc.ContainerDatabaseDriver

~~~

~~~java

@SpringBootTest
@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
@Testcontainers
class StudyServiceTest {

    @Mock MemberService memberService;

    @Autowired StudyRepository studyRepository;

    @Container
    static PostgreSQLContainer postgreSQLContainer = new PostgreSQLContainer()
            .withDatabaseName("studytest");

    @BeforeEach
    void beforeEach() {
        studyRepository.deleteAll();
    }

    @Test
    void createNewStudy() {
        // Given
        StudyService studyService = new StudyService(memberService, studyRepository);
        assertNotNull(studyService);

        Member member = new Member();
        member.setId(1L);
        member.setEmail("test@email.com");

        Study study = new Study(10, "테스트");

        given(memberService.findById(1L)).willReturn(Optional.of(member));

        // When
        studyService.createNewStudy(1L, study);

        // Then
        assertEquals(1L, study.getOwnerId());
        then(memberService).should(times(1)).notify(study);
        then(memberService).shouldHaveNoMoreInteractions();
    }

    @DisplayName("다른 사용자가 볼 수 있도록 스터디를 공개한다.")
    @Test
    void openStudy() {
        // Given
        StudyService studyService = new StudyService(memberService, studyRepository);
        Study study = new Study(10, "더 자바, 테스트");
        assertNull(study.getOpenedDateTime());

        // When
        studyService.openStudy(study);

        // Then
        assertEquals(StudyStatus.OPENED, study.getStatus());
        assertNotNull(study.getOpenedDateTime());
        then(memberService).should().notify(study);
    }

}

~~~

## Testcontainers, 기능 살펴보기
+ 컨테이너 만들기
  + New GenericContainer(String imageName)
+ 네트워크
  + withExposedPorts(int...)
  + getMappedPort(int) - 매핑된 포트 확인
+ 환경 변수 설정
  + withEnv(key, value)
+ 사용할 준비가 됐는지 확인하기
  + waitingFor(Wait)
  + Wait.forHttp(String url)
  + Wait.forLogMessage(String message)
+ 로그 살펴보기
  + getLogs() - 로그 전부 가져오기 
  + followOutput() - 스트리밍

~~~java

@SpringBootTest
@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
@Testcontainers
@Slf4j
class StudyServiceTest {

    @Mock MemberService memberService;

    @Autowired StudyRepository studyRepository;

    @Container
    static GenericContainer postgreSQLContainer = new GenericContainer("postgres")
            .withExposedPorts(5432)
            .withEnv("POSTGRES_DB", "studytest");

    @BeforeAll
    static void beforeAll() {
        Slf4jLogConsumer logConsumer = new Slf4jLogConsumer(log);
        postgreSQLContainer.followOutput(logConsumer);
    }

    @BeforeEach
    void beforeEach() {
        System.out.println("===========");
        System.out.println(postgreSQLContainer.getMappedPort(5432));
        studyRepository.deleteAll();
    }

    @Test
    void createNewStudy() {
        // Given
        StudyService studyService = new StudyService(memberService, studyRepository);
        assertNotNull(studyService);

        Member member = new Member();
        member.setId(1L);
        member.setEmail("test@email.com");

        Study study = new Study(10, "테스트");

        given(memberService.findById(1L)).willReturn(Optional.of(member));

        // When
        studyService.createNewStudy(1L, study);

        // Then
        assertEquals(1L, study.getOwnerId());
        then(memberService).should(times(1)).notify(study);
        then(memberService).shouldHaveNoMoreInteractions();
    }

    @DisplayName("다른 사용자가 볼 수 있도록 스터디를 공개한다.")
    @Test
    void openStudy() {
        // Given
        StudyService studyService = new StudyService(memberService, studyRepository);
        Study study = new Study(10, "더 자바, 테스트");
        assertNull(study.getOpenedDateTime());

        // When
        studyService.openStudy(study);

        // Then
        assertEquals(StudyStatus.OPENED, study.getStatus());
        assertNotNull(study.getOpenedDateTime());
        then(memberService).should().notify(study);
    }

}

~~~

## Testcontainers, 컨테이너 정보를 스프링 테스트에서 참조하기
+ @ContextConfiguration
  + 스프링이 제공하는 애노테이션으로, 스프링 테스트 컨텍스트가 사용할 설정 파일 또는 컨텍스를 커스터마이징할 수 있는 방법을 제공한다.
+ ApplicationContextInitializer
  + 스프링 ApplicationContext 를 프로그래밍으로 초기화 할 때 사용할 수 있는 콜백 인터페이스로, 특정 프로파일을 활성화 하거나, 프로퍼티 소스를 추가하는 등의 작업을 할 수 있다.
+ TestPropertyValues
  + 테스트용 프로퍼티 소스를 정의할 때 사용한다.
+ Environment
  + 스프링의 핵심 API 로, 프로퍼티와 프로파일을 담당한다.
+ 전체 흐름
  1. Testcontainer 를 사용해서 컨테이너 생성 
  2. ApplicationContextInitializer 를 구현하여 생성된 컨테이너에서 정보를 추출하여 Environment 에 넣어준다. 
  3. @ContextConfiguration 을 사용해서 ApplicationContextInitializer 구현체를 등록한다.
  4. 테스트 코드에서 Environment, @Value, @ConfigurationProperties 등 다양한 방법으로 해당 프로퍼티를 사용한다.


~~~java

@SpringBootTest
@ExtendWith(MockitoExtension.class)
@ActiveProfiles("test")
@Testcontainers
@Slf4j
@ContextConfiguration(initializers = StudyServiceTest.ContainerPropertyInitializer.class)
class StudyServiceTest {

    @Mock MemberService memberService;

    @Autowired StudyRepository studyRepository;

    @Value("${container.port}") int port;

    @Container
    static GenericContainer postgreSQLContainer = new GenericContainer("postgres")
            .withExposedPorts(5432)
            .withEnv("POSTGRES_DB", "studytest");

    @BeforeAll
    static void beforeAll() {
        Slf4jLogConsumer logConsumer = new Slf4jLogConsumer(log);
        postgreSQLContainer.followOutput(logConsumer);
    }

    @BeforeEach
    void beforeEach() {
        System.out.println("===========");
        System.out.println(port);
        studyRepository.deleteAll();
    }

    @Test
    void createNewStudy() {
        // Given
        StudyService studyService = new StudyService(memberService, studyRepository);
        assertNotNull(studyService);

        Member member = new Member();
        member.setId(1L);
        member.setEmail("test@email.com");

        Study study = new Study(10, "테스트");

        given(memberService.findById(1L)).willReturn(Optional.of(member));

        // When
        studyService.createNewStudy(1L, study);

        // Then
        assertEquals(1L, study.getOwnerId());
        then(memberService).should(times(1)).notify(study);
        then(memberService).shouldHaveNoMoreInteractions();
    }

    @DisplayName("다른 사용자가 볼 수 있도록 스터디를 공개한다.")
    @Test
    void openStudy() {
        // Given
        StudyService studyService = new StudyService(memberService, studyRepository);
        Study study = new Study(10, "더 자바, 테스트");
        assertNull(study.getOpenedDateTime());

        // When
        studyService.openStudy(study);

        // Then
        assertEquals(StudyStatus.OPENED, study.getStatus());
        assertNotNull(study.getOpenedDateTime());
        then(memberService).should().notify(study);
    }

    static class ContainerPropertyInitializer implements ApplicationContextInitializer<ConfigurableApplicationContext> {

        @Override
        public void initialize(ConfigurableApplicationContext context) {
            TestPropertyValues.of("container.port=" + postgreSQLContainer.getMappedPort(5432))
                    .applyTo(context.getEnvironment());
        }
    }

}

~~~