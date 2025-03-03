---
layout: post
bigtitle: '구독 결제 - PAYPAL'
subtitle: 구독 결제 - PAYPAL
date: '2025-02-28 00:00:01 +0900'
categories:
- logistics
comments: true
---

# 구독 결제 - PAYPAL

# 구독 결제 - PAYPAL
* toc
{:toc}

## 프로젝트 개요
해당 프로젝트는 사용자를 위한 정기 구독(Paypal) 결제 시스템을 도입하는 것을 목표로 합니다.
사용자가 보다 원활하게 SaaS 서비스를 이용할 수 있도록 Paypal을 통한 구독 결제 및 관리 시스템을 구축했습니다.
+ **프로젝트명:** 구독 결제 - PAYPAL
+ **프로젝트 일정**
  + Kickoff: 2024년 7월 15일
  + Demo Day: 2024년 7월 31일
  + 결제 기능 출시: 2024년 8월 14일
  + 프로젝트 종료: 2024년 8월 26일
  + 정식 오픈: 2024년 8월 27일
+ **역할:** 백엔드 개발자
+ **프로젝트 목적:**
  + PayPal 기반의 정기 구독 결제 기능 추가
  + 정기 구독 관리 시스템 구축 (결제, 취소, 일시 정지, 갱신 등)
  + 기존 프라이싱 플랜 재구성 및 SaaS 고객 대상 맞춤형 플랜 도입
  + 사용자의 플랜 변경(업그레이드/다운그레이드) 지원
  + SaaS 서비스 내에서 구독 관리 및 결제 내역 제공
  + 자동 결제 프로세스 구축 및 결제 실패 처리 대응 시스템 개발
+ **프로젝트 팀 구성:**
  + **백엔드 개발:** 4명
  + **프론트엔드 개발:** 2명
  + **기획:** 1명
  + **디자인:** 1명
  + **QA:** 1명
+ **기술 스택:**
  + **백엔드:** Java, Spring Boot
  + **API 설계:** RESTful API
  + **결제 시스템:** PayPal Subscriptions API
  + **데이터베이스:** MSSQL, Redis
  + **배포 및 운영:** Azure DevOps
  + **로그 관리:** Slack API 연동 (에러 로그 자동 전송)
  + **보안:** Spring Security, JWT 인증

## 프로젝트 주요 기능

### Pricing Plan 개편
+ 기존 프라이싱 플랜을 개선하여 글로벌 유저 친화적인 플랜 도입
+ 월간/연간 결제 모델 추가 (연간 결제 시 할인 제공)
+ Free Trial 사용자에 대한 프로모션 및 유료 전환 유도
+ SaaS 내 구독 관리 페이지 제공

### PayPal 정기 구독 결제 시스템 구축
+ PayPal API를 활용한 정기 결제 시스템 연동
+ 사용자의 결제 정보 저장 및 정기 결제 자동화
+ 결제 실패 시 구독 취소 또는 복구 처리 로직 구현
+ 유료 결제 성공/실패 알림 메일 전송
+ PayPal의 Subscription API를 활용하여 월간 및 연간 결제 옵션 제공
+ 구독 시작일과 결제 일정을 자동으로 설정
+ 사용자의 결제 상태 변경(결제 성공, 실패, 취소) 시 실시간 업데이트 처리

### Paypal 기반 구독 관리
+ Paypal을 통한 일시 중지/취소 처리
  + 사용자가 Paypal에서 구독을 일시 정지할 경우, 내부 시스템에서 확인 후 구독을 자동 일시 중지
  + Paypal에서 구독 취소 시, SaaS 구독도 자동 취소
+ Slack 연동 CX 지원
  + Paypal을 통한 구독 취소 및 일시 중지 이벤트 발생 시, Slack 알림을 통해 CX(Customer Experience)팀이 즉시 확인 가능

### 사용자 구독 관리 기능
+ 사용자가 SaaS 내에서 구독 정보 확인 및 변경 가능
+ 구독 변경 시 차액 계산 후 추가 결제 또는 크레딧 환불 지원
+ 구독 취소 및 환불 요청 기능 제공
+ 구독 변경/취소 시 확인 이메일 자동 발송
+ 사용자가 PayPal 내에서 직접 구독 취소 가능
+ SaaS에서 구독 취소 요청 시 PayPal과 연동하여 즉시 처리

### 백오피스 기능
+ 운영팀이 백오피스에서 프라이싱 플랜 및 결제 내역 관리 가능
+ 구독 정산 확인 및 관리 기능 추가
+ SaaS 내 플랜 부여 및 변경 기능 제공

### 정기 결제 시스템
+ Trial 및 유료 플랜 전환 프로세스
  + 신규 사용자는 2주간 무료 Trial을 이용할 수 있으며, Trial 종료 후 유료 구독이 자동 시작됨.
  + Trial 기간 중 유료 구독을 결제할 경우, 즉시 Trial이 종료되고 유료 플랜이 시작됨.
  + Trial 중 정기 구독을 결제한 사용자에게는 400 Credit이 추가 지급됨.
+ 정기 결제 성공 처리
  + 결제가 정상적으로 이루어지면 이메일을 통해 결제 확인 알림이 자동 전송됨.
+ 결제 실패 정책
  + 최초 결제 실패 시 5일 간격으로 두 차례(5일 후, 10일 후) 추가 결제 시도를 진행.
  + 최종 결제 실패 시, 구독이 자동 취소되고 해당 사용자의 플랜이 만료 처리됨.

  
## 구독 결제 프로세스 및 아키텍처 

### 구독 생성 Flow Chart

~~~mermaid

flowchart TD
  A[Front Page]:::yellow
  B[Backend API]:::red
  C[PayPal SDK/API]:::gray

  D[구독 결제]
  E[구독 소개 페이지]:::yellow
  F[구독 주문 페이지]:::yellow
  G[플랜 조회 API]:::red

  H[PayPal 구독 생성 요청]:::gray
  I{"PayPal 구독 성공?"}:::black
  J[구독 생성 API 호출]:::red
  K[PayPal 구독 활성화]:::gray
  L[PayPal 결제 확인]:::gray
  M{"결제 성공?"}:::black

  N[구독 성공 페이지]:::yellow
  O[구독 실패 페이지]:::yellow
  P[PayPal 구독 취소]:::gray

  %% 흐름 연결
  D --> E
  E -->|조회 요청| G
  G --> F
  F --> H
  H --> I
  I -- No --> O
  I -- Yes --> J

  J --> K
  K --> L
  L --> M

  M -- Yes --> N
  M -- No --> P
  P --> O


  classDef yellow fill:#FFD700,stroke:#333,stroke-width:2px;
  classDef red fill:#FF6666,stroke:#333,stroke-width:2px;
  classDef gray fill:#BEBEBE,stroke:#333,stroke-width:2px;
  classDef black fill:#444,stroke:#fff,stroke-width:2px,color:#fff;

~~~

### 구독 생성 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant FRONT
  participant SaaS
  participant MEMBERSHIP_API
  participant PAYMENT_API
  participant PAYPAL
  participant ALARM_CENTER
  participant SLACK

  FRONT->>PAYPAL: 구독 생성 요청 (상태: continue)
  PAYPAL-->>FRONT: 구독 성공 응답 (상태: continue)
  FRONT->>SaaS: 구독 데이터 생성 요청 

  SaaS->>MEMBERSHIP_API: 구독 생성 요청
  alt 기존 구독 있음
    MEMBERSHIP_API-->>SaaS: 구독 실패 응답
    SaaS-->>FRONT: 구독 실패 응답
  else 기존 구독이 트라이얼 플랜
    MEMBERSHIP_API-->>SaaS: 크레딧 400 충전 후 신규 구독 생성 응답
  else 신규 구독
    MEMBERSHIP_API-->>SaaS: 구독 생성 결과 응답
  end

  SaaS->>PAYMENT_API: 구독 결제 정보 저장
  PAYMENT_API->>PAYPAL: 구독 상태 활성화 (상태: active)
  PAYMENT_API->>PAYPAL: 결제 상태 확인
  PAYPAL-->>PAYMENT_API: 결제 상태 응답
  alt 결제 성공
    PAYMENT_API-->>SaaS: 구독 결제 정보 응답
    SaaS-->>FRONT: 성공 응답
    PAYMENT_API-)ALARM_CENTER: 구독 시작 메일 발송 (비동기)
    PAYMENT_API-)SLACK: 구독 시작 알림 (비동기)
  else 결제 실패
    PAYMENT_API->>PAYPAL: 구독 취소 요청 (상태: cancel)
    PAYMENT_API-->>SaaS: 실패 응답
    SaaS->>MEMBERSHIP_API: 구독 롤백 요청
    MEMBERSHIP_API-->>SaaS: 구독 롤백 응답
    SaaS-->>FRONT: 실패 응답
    PAYMENT_API-)SLACK: 구독 실패 알림 (비동기)
  end


~~~

### 구독 변경 Flow Chart

~~~mermaid

flowchart TD
  A[Front Page]:::yellow
  B[Backend API]:::red
  C[PayPal SDK/API]:::gray

  D[구독 변경]
  E[구독 변경 페이지]:::yellow
  F[구독 주문 페이지]:::yellow
  G[플랜 조회 API]:::red

  H[PayPal 구독 변경 요청]:::gray
  I{"PayPal 구독 성공?"}:::black
  J[구독 변경 API 호출]:::red
  K[기존 구독 취소 & 변경 구독 활성화]:::gray

  M{"변경 성공?"}:::black

  N[구독 성공 페이지]:::yellow
  O[구독 실패 페이지]:::yellow
  P[PayPal 구독 취소]:::gray

  %% 흐름 연결
  D --> E
  E -->|조회 요청| G
  G --> F
  F --> H
  H --> I
  I -- No --> O
  I -- Yes --> J

  J --> K
  K --> M
  

  M -- Yes --> N
  M -- No --> P
  P --> O

  %% 스타일 지정
  classDef yellow fill:#FFD700,stroke:#333,stroke-width:2px;
  classDef red fill:#FF6666,stroke:#333,stroke-width:2px;
  classDef gray fill:#BEBEBE,stroke:#333,stroke-width:2px;
  classDef black fill:#444,stroke:#fff,stroke-width:2px,color:#fff;


~~~
### 구독 변경 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant FRONT
  participant SaaS
  participant MEMBERSHIP_API
  participant PAYMENT_API
  participant PAYPAL
  participant ALARM_CENTER
  participant SLACK

  FRONT->>PAYPAL: 구독 생성 요청 (상태: continue, 시작일: 기존 구독 끝나는 시점)
  PAYPAL-->>FRONT: 구독 성공 응답 (상태: continue, 시작일: 기존 구독 끝나는 시점)
  FRONT->>SaaS: 구독 변경 요청 

  SaaS->>MEMBERSHIP_API: 구독 변경 요청
  alt 기존 구독이 트라이얼 플랜
    MEMBERSHIP_API-->>SaaS: 구독 변경 불가 응답
    SaaS-->>FRONT: 구독 변경 실패 응답
  else 기존 구독 없음
    MEMBERSHIP_API-->>SaaS: 구독 변경 불가 응답
    SaaS-->>FRONT: 구독 변경 실패 응답
  else 기존 구독 있음
    MEMBERSHIP_API-->>SaaS: 기존 구독 만료, 변경 구독 생성 결과 응답
  end

  SaaS->>PAYMENT_API: 변경 구독 결제 정보 저장 요청
  PAYMENT_API->>PAYPAL: 기존 구독 취소 요청
  PAYPAL-->>PAYMENT_API: 기존 구독 취소 응답
  alt 기존 구독 취소 성공
    PAYMENT_API->>PAYPAL: 변경 구독 상태 활성화 (상태: active)
    PAYMENT_API-->>SaaS: 변경 구독 결제 정보 생성 응답
    SaaS-->>FRONT: 성공 응답
    PAYMENT_API-)ALARM_CENTER: 구독 변경 메일 발송 (비동기)
    PAYMENT_API-)SLACK: 구독 변경 알림 (비동기)
  else 기존 구독 취소 실패
    PAYMENT_API-->>SaaS: 실패 응답
    SaaS->>MEMBERSHIP_API: 구독 롤백 요청
    MEMBERSHIP_API-->>SaaS: 구독 롤백 응답
    SaaS-->>FRONT: 실패 응답
    PAYMENT_API-)SLACK: 구독 실패 알림 (비동기)
  end


~~~

### 구독 해지 Flow Chart

~~~mermaid

flowchart TD
  A[구독 해지]
  B[구독 변경 페이지]:::yellow
  C{"구독 해지?"}:::black
  D[End]
  E[구독 해지 API]:::red
  F[PayPal 구독 취소]:::gray

  %% 연결 관계
  A --> B
  B --> C
  C -- NO --> B
  C -- YES --> D
  C --> E
  E -.-> F

  %% 스타일 지정
  classDef yellow fill:#FFD700,stroke:#333,stroke-width:2px;
  classDef red fill:#FF6666,stroke:#333,stroke-width:2px;
  classDef gray fill:#BEBEBE,stroke:#333,stroke-width:2px;
  classDef black fill:#444,stroke:#fff,stroke-width:2px,color:#fff;


~~~

### 구독 해지 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant FRONT
  participant SaaS
  participant MEMBERSHIP_API
  participant PAYMENT_API
  participant PAYPAL

  FRONT->>SaaS: 구독 해제 요청
  SaaS->>PAYMENT_API: 구독 해제 요청
  PAYMENT_API->>PAYPAL: 구독 취소 요청
  PAYPAL-->>PAYMENT_API: 구독 취소 완료 응답
  PAYMENT_API-->>SaaS: 구독 결제 정보 삭제 및 PAYPAL 구독 취소 성공 응답
  SaaS->>MEMBERSHIP_API: 구독 해제 요청 (구독 만료일을 현재 구독 만료일로 설정)
  MEMBERSHIP_API-->>SaaS: 구독 해제 성공 응답
  SaaS-->>FRONT: 구독 해제 완료 응답

~~~

### 페이팔 구독 결제 성공 웹훅 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant PAYPAL
  participant PAYMENT_API
  participant ALARM_CENTER
  participant SLACK

  PAYPAL--)PAYMENT_API: 결제 성공 웹훅 이벤트 전송
  PAYMENT_API->>PAYMENT_API: 웹훅 검증 (구독 결제 여부 확인)

  alt 구독 결제 성공
    PAYMENT_API->>PAYMENT_API: 결제 내역 저장
    PAYMENT_API-)ALARM_CENTER: 결제 성공 메일 발송 (비동기)
    PAYMENT_API-)SLACK: 결제 성공 알림 전송 (비동기)
  end

~~~


### 페이팔 인보이스 결제 성공 웹훅 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant PAYPAL
  participant PAYMENT_API
  participant SLACK

  PAYPAL--)PAYMENT_API: 인보이스 결제 성공 웹훅 이벤트 전송
  PAYMENT_API->>PAYMENT_API: 인보이스 아이템 타입에 맞는 결제 내역 저장
  PAYMENT_API-)SLACK: 인보이스 결제 성공 알림 전송 (비동기)
  

~~~


### 페이팔 구독 결제 실패로 인한 상태 변경 웹훅 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant PAYPAL
  participant PAYMENT_API
  participant MEMBERSHIP_API
  participant AZURE_SERVICE_BUS
  participant ALARM_CENTER
  participant SLACK

  PAYPAL->>PAYPAL: 결제 실패 감지 (1차 시도)
  PAYPAL--)PAYMENT_API: 결제 실패 웹훅 이벤트 전송
  PAYMENT_API-)SLACK: 결제 실패 알림 전송 (비동기)
  PAYPAL->>PAYPAL: 5일 후 재결제 시도 (2차 시도)
  PAYPAL--)PAYMENT_API: 결제 실패 웹훅 이벤트 전송
  PAYMENT_API-)SLACK: 결제 실패 알림 전송 (비동기)
  PAYPAL->>PAYPAL: 5일 후 재결제 시도 (3차 시도)
  PAYPAL--)PAYMENT_API: 결제 실패 웹훅 이벤트 전송
  PAYMENT_API-)SLACK: 결제 실패 알림 전송 (비동기)

  alt 모든 결제 시도 실패
    PAYPAL->>PAYPAL: 구독 상태를 SUSPEND로 변경
    PAYPAL--)PAYMENT_API: 웹훅 이벤트 전송 (구독 상태: SUSPEND)
    
    PAYMENT_API->>PAYPAL: 구독 취소 요청
    PAYPAL--)PAYMENT_API: 구독 취소 완료 응답
    
    PAYMENT_API->>PAYMENT_API: 구독 결제 정보 삭제
    PAYMENT_API->>AZURE_SERVICE_BUS: 구독 해제 메시지 큐에 전송
    PAYMENT_API-)ALARM_CENTER: 구독 해제 메일 전송 (비동기)
    PAYMENT_API-)SLACK: 구독 해제 알림 전송 (비동기)
    
    MEMBERSHIP_API--)AZURE_SERVICE_BUS: 구독 해제 요청 메시지 수신
    MEMBERSHIP_API->>MEMBERSHIP_API: 구독 해제 처리 (구독 만료일 업데이트)
  end



~~~

### 관리자 구독 취소 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant BACKOFFICE
  participant SaaS
  participant PAYMENT_API
  participant PAYPAL
  participant MEMBERSHIP_API

  BACKOFFICE->>SaaS: 구독 취소 요청
  SaaS->>PAYMENT_API: 구독 취소 요청
  PAYMENT_API->>PAYPAL: 구독 취소 요청
  PAYPAL--)PAYMENT_API: 구독 취소 완료 응답

  PAYMENT_API-->>SaaS: 구독 취소 성공 응답
  SaaS->>MEMBERSHIP_API: 구독 정보 취소 요청
  MEMBERSHIP_API->>MEMBERSHIP_API: 구독 상태를 '취소'로 업데이트


~~~

### 사용자가 직접 PayPal에서 구독 취소하는 경우 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant PAYPAL
  participant PAYMENT_API
  participant MEMBERSHIP_API
  participant AZURE_SERVICE_BUS
  participant ALARM_CENTER
  participant SLACK

  PAYPAL--)PAYMENT_API: 웹훅 이벤트 전송 (구독 상태: CANCEL)
        
  PAYMENT_API->>PAYMENT_API: 구독 결제 정보 삭제
  PAYMENT_API->>AZURE_SERVICE_BUS: 구독 취소 메시지 큐에 전송
  PAYMENT_API-)SLACK: 구독 취소 알림 전송 (비동기)
    
  MEMBERSHIP_API--)AZURE_SERVICE_BUS: 구독 취소 요청 메시지 수신
  MEMBERSHIP_API->>MEMBERSHIP_API: 구독 취소 처리 
  


~~~


### 페이팔 환불 웹훅 Sequence Diagram

~~~mermaid

sequenceDiagram
  participant PAYPAL
  participant PAYMENT_API

  %% 환불 처리
  PAYPAL--)PAYMENT_API: 환불 웹훅 이벤트 전송
  PAYMENT_API->>PAYMENT_API: 웹훅 검증 (환불 여부 확인)
  PAYMENT_API->>PAYMENT_API: 기존 결제 내역 조회
  PAYMENT_API->>PAYMENT_API: 결제 상태를 '환불'로 업데이트

~~~

## API 

### 구독 결제 및 플랜 관리
+ 플랜 가격 조회: 구독 가능한 플랜별 가격을 확인할 수 있음.
+ 구독 생성: 사용자가 특정 플랜을 선택하여 구독할 수 있음.
+ 구독 변경: 기존 구독을 다른 플랜으로 변경할 수 있음.
+ 구독 취소 및 해제: 사용자가 구독을 취소하거나 즉시 해제할 수 있음.
+ 구독 업그레이드: 기존 플랜을 업그레이드하여 추가 기능을 이용 가능.

### 사용자 구독 정보 관리
+ 현재 및 미래 구독 조회: 로그인한 사용자의 현재 및 예정된 구독 정보를 확인 가능.
+ 구독 상태 조회: 사용자의 구독 활성 상태를 확인 가능.
+ 구독 크레딧 관리: 사용자가 보유한 크레딧 정보를 조회 가능.

### 결제 및 인보이스 관리
+ 구독 결제 처리: 다양한 결제 수단(PayPal 등)을 통해 결제 가능.
+ 결제 내역 조회: 사용자의 결제 내역을 확인할 수 있음.
+ 인보이스 발행: 사용자의 결제 내역에 대한 인보이스를 생성하여 발행 가능.

## 성과 및 기여도
+ PayPal 기반 글로벌 정기 구독 시스템 구축
+ SaaS 내 Pricing Plan 개편 및 사용 편의성 향상
+ PayPal API를 활용한 자동 결제 및 구독 관리 시스템 도입
+ 결제 실패 복구 및 구독 유지 기능을 통한 고객 만족도 향상
+ Webhook 기반 결제 상태 동기화 및 결제 실패 예외 처리 로직 구현
