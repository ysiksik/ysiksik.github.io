---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: Microservice와 Spring Cloud의 소개
date: '2023-02-17 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# Microservice와 Spring Cloud의 소개

# Microservice와 Spring Cloud의 소개
* toc
{:toc}

## Software Architecture
+ The History of IT System
  + 1960 ~ 1980s : Fragile, Cowboys
    + Mainframe, Hardware
  + 1990 ~ 2000s : Robust, Distributed
    + Changes
  + 2010s ~ : Resilient/Anti-Fragile, Cloud Native
    + Flow of value의 지속적인 개선
  + ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud.png)

### Antifragile
+ Auto scaling
  + 자동 확장성을 갖는 특징
  + 사용량에 따라 자동으로 인스턴스를 증가할 수 있는 환경
  + ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud2.png)
+ Microservices
  + 전체 서비스들을 구축하고있는 개별적인 모듈이나 기능을 독립적으로 개발하고 배포하고 운영할 수 있도록 세분화된 서비스
+ Chaos engineering
  + 시스템이 급격하게 예측하지 못하는 상황이라도 견딜수 있고 신뢰성을 쌓기위해 운영중인 소프트웨어 시스템의 실행하는 방법이나 규칙
  + 시스템의 어떤 변동이나 예견되 혹은 예견되지 않은 불확실성에 대해서도 안정적인 서비스를 제공할 수 있도록 구축되어야한다
  + ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud3.png)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud4.png)
+ Continuous deployments
  + 지속정인 통합, 지속적인 배포
  
### Cloud Native Architecture
+ 확장 가능한 아키택처
  + 시스템의 수평적 확장에 유연
  + 확장된 서버로 시스템의 부하분산, 가용성 보장
  + 시스템 또는, 서비스 어플리케이션 단위의 패키지(컨테이너 기반 패키지)
  + 모니터링
+ 탄력적 아키텍쳐
  + 서비스 생성 - 통합 - 배포, 비즈니스 환경 변화에 대응 시간 단축 
  + 분활 된 서비스 구조
  + 무상태 통신 프로토콜
  + 서비스의 추가와 삭제 자동으로 감지
  + 변경된 서비스 요청에 따라 사용자 요청 처리(동적 처리)
+ 장애 격리(Fault isolation)
  + 특정 서비스에 오류가 발생해도 다른 서비스에 영향 주지 않는다

### Cloud Native Application
+ ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud5.png)

#### CI/CD
+ 지속적인 통합, CI(Continuous Integration)
  + 통합 서버, 소스 관리 (SCM), 빌드 도구, 테스트 도구
  + ex) Jenkins, Team CI, Travis CI
+ 지속적 배포
  + Continuous Delivery
  + Continuous Deployment
  + Pipe line
  + ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud6.png)
+ 카나리 배포와 블루그린 배포
  + ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud7.png)

#### DevOps
+ ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud8.png)

#### Container 가상화
+ ![img.png](../../../../assets/img/spring-cloud-msa/Microservice-SpringCloud9.png)

## 12 Factors([https://12factor.net/](https://12factor.net/))
+ SaaS 애플리케이션을 만들기 위한 방법론으로써 프로그래밍 언에 비종속정이며 DB, Queue, Memory-cache 등과 조합할 수 있는 방법론
+ 이 방법론은 시간이 지나면서 망가지는 소프트웨어 유지비용을 줄이는 방법에 집중해 이상적인 개발 방법을 찾고자 했다 
+ 클라우드 네이티브 어플리케이션을 구축함에 있어서 고려해봐야될 12가지 항목 
+ ![img.png](Microservice-SpringCloud10.png)
  1. 버전 관리되는 하나의 코드베이스와 다양한 배포
  2. 명시적으로 선언되고 분리된 종속성
  3. 환경(environment)에 저장된 설정
  4. 백엔드 서비스를 연결된 리소스로 취급
  5. 철저하게 분리된 빌드와 실행 단계
  6. 애플리케이션을 하나 혹은 여러개의 무상태(stateless) 프로세스로 실행
  7. 포트 바인딩을 사용해서 서비스를 공개함
  8. 프로세스 모델을 사용한 확장
  9. 빠른 시작과 그레이스풀 셧다운(graceful shutdown)을 통한 안정성 극대화
  10. 개발, 스테이징, 프로덕션 환경을 최대한 비슷하게 유지
  11. 로그를 이벤트 스트림으로 취급
  12. 개발, 스테이징, 프로덕션 환경을 최대한 비슷하게 유지

+ 코드 베이스(Code Base)
  + 코드베이스는 VCS(Version Control System)을 사용해 변화를 추적하고 코드를 저장하는 저장소를 의미한다(예: Git, SVN)
  + 이 방법론에서는 코드 베이스 앱이 항상 1 대 1 관계를 맺어야한다고 하는데, 쉡게 말해 코드는 한 곳에서 개발/배포 되어야한다. 
  + 코드 베이스가 여러개 인경우
    + 앱이 아닌 분산 시스템으로 간주하고, 각각 코드 베이스별로 앱으로서 12 Factors를 따른다
  + 여러 앱이 동일한 코드를 공유하는 경우
    + 12 Factors를 위반하므로 공유되는 코드를 라이브러리화 하고 각 앱에 종속성을 주입한다
  + 앱 배포가 여러개인 경우(개발/알파/릴리지 등)
    + 코드 베이스 자체는 동일하게 유지하며, Git branch 등으로 동일한 앱을 여러개로 배포할 수 있다 
+ 종속성 (Dependencies)
  + 전체 시스템에 특정 패키지가 암묵적으로 존재하는 것에 절대 의존하지 않으며, 애플리케이션의 모든 종속성은 명시적으로 선언해 사용해야한다
  + 대부분의 Java 프로젝트에서는 Gradle 이나 Maven을 이용해서 의존성을 관리할 수 있다 
  + 게다가, Spring boot의 경우에는 내장 톰캣이나 jetty를 임베딩해 배포까지 가능하다
+ 설정 (Config)
  + 설정은 동일한 앱의 배포 단계(개발/알파/릴리즈 등)에 따라 달라질 수 있는 모든 것들을 의미한다 
  + 예시
    + 데이터베이스 접속 정보
    + OAuth 또는 외부 서비스 인증정보
    + 호스트 네임에 따라 달라지는 값
    + 서비스 포트 정보
  + 이 정보들은 코드 상수 형태라도 저장되면 안되며, 코드 베이스와 WAS 설정파일 (예: JNDI 설정)에도 저장하지 않는 것을 권장한다
  + 12 Factor App 에서는 이 규약을 준수하기 위한 방법으로 환경변수를 사용하는 것을 제시하며, Spring Cloud를 이용하는 경우 Spring Cloud Config를 사용하는 것도 좋은 방법이다
+ 백엔드 서비스 (Backing services)
  + 백엔드 서비스는 네트워크를 통해 이용하는 모든 서비스를 위미하며, 서드파티 서비스 또한 포함된다
    + 데이터 베이스
    + 메시지 큐
    + SMTP 서비스
    + 캐시 시스템
    + Push 서비스
    + Amazon S3
    + Google Maps
    + 기타 등등
  + 12 Factor App 에서는 이 백엔드 서비스를 연결된 리소스 취급하고, 자유롭게 연결 및 분리가 가능해야하고 코드 수정 없이 전환이 가능해야한다
  + 예를 들어, 하나의 My-SQL DB는 하나의 리소스 이다. 그리고 애플리케이션 레이어에서 샤딩을 하는 두 개의 MySQL DB는 서로 다른 리소스로 구분한다
  + 이 규약의 경우 리소스 연결 정보를 Config로 지정해 준수할 수 있다
  + 예를 들어, 개발 단계와 배포 단계의 데이터베이스 연결 정보를 Config로 지정해 코드 수정 없이 배포 단계마다 적절한 데이터베이스에 연결하도록 할 수 있다 
+ 빌드, 릴리즈, 실행 (Build, release, run)
  + 12 Factor App 에서는 코드 베이스를 빌드, 릴리즈, 실행 단계로 엄격히 분리한다, 코드 변경은 반드시 빌드 단계에서만 이루어져야 하며, 모든 릴리즈는 항상 유니크한 릴리즈 아이디를 가져한다
  + 또 릴리즈는 추가만 가능하며 한번 만들어진 릴리즈는 변경될수 없고 이전 버전으로 롤백이 가능해야 한다 
  + 빌드
    + 코드 베이스를 빌드라는 실행 가능한 번들로 변환시키는 단계 
    + 새로운 코드가 배포될 때마다 개발자에 의해 시작
  + 릴리즈
    + 빌드 단계에서 만들어진 빌드와 배포의 현재 설정을 결합하는 단계
  + 실행(런타임)
    + 서버가 재부팅되거나 프로세스 매니저에 의해 실행 
+ 프로세스 (Process)
  + 애플리케이션은 무상태 프로세스로 실행되어야하고, 아무것도 공유하지 않아야한다 
  + 유지될 필요가 잇는 모든 데이터는 백엔드 서비스(예: 데이터베이스, Redis)에 저장되어야한다 
  + SaaS 애플리케이션 자체가 Scale-out 이 가능하기 때문에 각 인스턴스가 메모리와 파일을 공유할 수 없고, 공유하더라도 메모리에 저장된 내용이 다른 프로세스에 의해 처리될 수 있으므로 로컬의 상태를 없애야한다
+ 포트 바인딩 (Port binding)
  + 애플리케이션을 다른 애플리케이션에서 런타임 인젝션이 아닌 HTTP 서비스로 접그할 수 있도록 포트 바인딩한다.
  + 예를 들면, 각각의 마이크로 서비스 A가 B의 서비스를 사용해야하는 경우 B의 데이터베이스 접속 정보와 계정, 권한을 A에게 부여해 B의 데이터베이스 접속하는 것은 이 규약을 위반하는 것이다 
  + 이 규약을 준수하기 위해서는 A에서 B 서비스로 HTTP 요청을 통해 원하는 데이터를 읽고/쓰고/수정/삭제 해야한다
+ 동시성 (Concurrency)
  + 애플리케이션은 Scale-out이 가능해야하며, 프로세스가 데몬 형태가 아니어야한다. 앞선 프로세스 규약에서 애플리케이션이 무상태이고 아무것도 공유되지 않기 때문에 자유롭게 확장하고, 자유롭게 축소할 수 있다
+ 폐기 기능 (Disposability)
  + 12 Factor App 에서는 프로세스의 시작과 종료, 배포가 빈번하기 때문에 애플리케이션의 시작 시간과 종료 시간의 최소화가 중요하다
  + 또한 종료에 있어서는 종료 시그널을 받고 나서 애플리케이션은 신규 요청은 받지 않고 기존 요청은 최대한 빠르게 처리한 이후 종료되어야한다 
  + long polling의 경우에는 연결이 끊긴 시점에 바로 다시 연결을 시도해야하고, worker 프로세스의 경우에는 현재 처리중인 작업을 작업 큐로 되돌리고 종료해야한다
  + 하드웨어 에러에 의해 갑작스런 다운에도 견고해야하며, Spring Cloud를 사용하는 경우 Spring Cloud Circuit B reaker를 통해 이러한 장애를 대비할 수 있다
+ 개발/프로덕션 환경 일치 (Dev/prod parity)
  + 개발 환경, 스테이징 환경, 프로덕션 환경을 최대한 비슷하게 유지하는 것을 의미한다. 
  + 보통 이 3단계 사이에는 세 가지 큰 차이점이 있다
    + 시간의 차이
      + 개발자가 작업한 코드는 프로덕션에 반영되기 까지 시간이 소요된다
    + 담당자의 차이
      + 대부분의 경우 개발자가 작성한 코드를 시스템 엔지니어가 배포한다
    + 툴의 차이 
      + 배포 환경과 개발자의 환경이 OS 부터 사용 제품, 툴에 있어 다를 수 있다
  + 12 Factor App은 개발 환경과 프로덕션 환경의 차이를 최대한 작게 유지해 지속적인 배포가 가능하도록 설계되어있다.
  + 특히, 데이터베이스, 큐잉 시스템, 캐시와 같은 벡엔드 서비스는 두 환경의 일치가 가장 중요한 영역이다.
  + 하지만 동시에 개발자 입장에서는 프로덕션에서 사용하는 서비스보다 가벼운 환경을 구축해 개발하는 것을 원하는 경우가 많다. (예를 들어, 프로덕션 데이터베이스는 MySQL인데 개발자 로컬 데이터베이스는 H2를 사용하는 경우)
  + 12 Factor App에서는 이것 또한 프로덕션 단계에서의 오류 가능성이 존재하므로 강력히 제한하며, 저도 사실 요즘은 Docker를 통해서 데이터베이스도 손쉽고 간단하게 구축이 가능하니 충분히 준수할만한 규약이라고 생각한다.

<table style="border-collapse: collapse; width: 100%;">
<tbody>
<tr>
<td style="width: 33.3333%;">&nbsp;</td>
<td style="width: 33.3333%;">전통적인 애플리케이션</td>
<td style="width: 33.3333%;">12 Factor App</td>
</tr>
<tr>
<td style="width: 33.3333%;">배포 간의 간격</td>
<td style="width: 33.3333%;">몇 주</td>
<td style="width: 33.3333%;">몇 시간</td>
</tr>
<tr>
<td style="width: 33.3333%;">코드 작성자와 코드 배포자</td>
<td style="width: 33.3333%;">다른 사람</td>
<td style="width: 33.3333%;">같은 사람</td>
</tr>
<tr>
<td style="width: 33.3333%;">개발 환경과 프로덕션 환경</td>
<td style="width: 33.3333%;">불일치</td>
<td style="width: 33.3333%;">최대한 유사하게</td>
</tr>
</tbody>
</table>

+ 로그 (Logs)
  + 로그는 모든 실행중인 프로세스와 서비스의 아웃풋 스트림으로부터 수집된 이벤트가 시간순으로 정렬된 스트림이다. 때문에 애플리케이션은 아웃풋 스트림의 전달이나 저장에 절대 관여하지 않는다.
  + SaaS 애플리케이션은 언제든 인스턴스가 삭제되고 생성될 수 있으므로 로그는 스트림으로 취급해 별도 저장소에 보관해야한다.
+ 어드민 프로세스 (Admin processes)
  + 어드민 또는 유지보수 작업을 일회성 프로세스(데이터베이스 마이그레이션, 일회성 스크립트 실행 등)로 실행해야 한다.

### 12 Factors + 3
1. One codebase, one application (하나의 코드베이스, 하나의 애플리케이션) 
2. __API first (API 우선)__
3. Dependency management (종속성 관리)
4. Design, build, release, and run (설계, 빌드, 릴리스 및 실행)
5. Configuration, credentials, and code (구성, 자격 증명 및 코드)
6. Logs (로그)
7. Disposability (일회용)
8. Backing services (지원 서비스)
9. Environment parity (환경 패리티)
10. Administrative processes (행정 절차)
11. Port binding (포트 바인딩)
12. Stateless processes (상태 비저장 프로세스)
13. Concurrency (동시성)
14. __Telemetry (원격)__
15. __Authentication and authorization (인증 및 권한 부여)__

