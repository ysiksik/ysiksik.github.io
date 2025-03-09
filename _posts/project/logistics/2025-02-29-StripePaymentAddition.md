---
layout: post
bigtitle: '유저 구매 과정 개선 - Stripe 결제 수단 추가'
subtitle: 유저 구매 과정 개선 - Stripe 결제 수단 추가
date: '2025-02-28 00:00:01 +0900'
categories:
- logistics
comments: true
---

# 유저 구매 과정 개선 - Stripe 결제 수단 추가

# 유저 구매 과정 개선 - Stripe 결제 수단 추가
* toc
{:toc}

## 프로젝트 개요
현재 Paypal 결제만 지원하는 문제로 인해 일부 글로벌 시장에서 결제 옵션이 제한됨. 이를 해결하기 위해 Stripe 결제를 추가하여 더 많은 고객이 원활하게 결제를 진행할 수 있도록 개선.
+ **프로젝트명:** 유저 구매 과정 개선 - Stripe 결제 수단 추가
+ **프로젝트 일정**
  * 2025년 02월 01일 ~ 2025년 03월 13일 
+ **역할:** 백엔드 개발자
+ **프로젝트 목적:**
  + Saas 내 Stripe 결제 수단을 추가하여 결제 전환율을 향상.
  + 기존 Paypal 정책과 동일한 구독 정책을 유지하면서, Stripe를 통해 구독 결제를 지원.
  + 사용자가 편리하게 결제할 수 있도록 결제 프로세스를 최적화.
+ **프로젝트 팀 구성:**
  + **백엔드 개발:** 2명
  + **프론트엔드 개발:** 2명
  + **기획:** 1명
  + **디자인:** 1명
  + **QA:** 1명
+ **기술 스택:**
  + **백엔드:** Java, Kotlin, Spring Boot
  + **API 설계:** RESTful API
  + **결제 시스템:** Stripe Subscriptions API
  + **데이터베이스:** MSSQL, Redis
  + **배포 및 운영:** Azure DevOps
  + **로그 관리:** Slack API 연동 (에러 로그 자동 전송)
  + **보안:** Spring Security, JWT 인증

## 개발 내용
1. 결제 수단 추가
   + Stripe 결제를 구독 결제 방식으로 추가하여 결제 선택지 확장.
   + 매달/매년 자동 결제 기능 구현 및 구독 갱신 처리.
   + 기존 Paypal 결제 방식과 동일한 정책 적용하여 사용자 경험 일관성 유지.
2. 구독 결제 프로세스 개선
   + 구독 생성: 사용자가 선택한 플랜에 따라 Stripe 결제 세션 생성 및 처리.
   + 구독 변경: 사용자가 플랜을 변경할 경우, 기존 구독을 해지하고 새로운 구독을 생성.
   + 구독 해지: 사용자가 구독을 해지할 경우, Stripe API를 통해 자동 해지 처리 및 구독 종료.
   + 결제 실패 처리: Stripe Webhook을 활용하여 결제 실패 시 사용자에게 알림 및 재결제 유도.
3. 구독 정보 및 관리 페이지 개선
   + My Plan & Credit 페이지 내 Stripe 결제 내역 추가 및 구독 상태 표시.
   + 결제 수단(Credit Card 등) 정보 표시.
   + Stripe Subscription ID를 Billing ID로 변환하여 내부 관리 시스템과 연동.
   + Stripe에서 제공하는 결제 ID와 내부 Order ID 매핑을 통한 투명한 결제 이력 관리.
4. 구매 페이지 최적화
   + 결제 모델 선택 기능 추가: 월간/연간 구독 옵션을 제공하고 할인 혜택 안내
   + Stripe 결제 UI 개선: Stripe Checkout 연동을 통한 원활한 결제 프로세스 제공.
   + 플랜 업그레이드 최적화: 기존 플랜 사용자에게 적절한 업그레이드 옵션을 추천하여 추가 구매 유도.


## 주요 기능 및 API 연동
+ Stripe API 연동
  + 구독 Checkout 세션 생성 (사용자가 결제를 시작하면 Stripe에서 세션을 생성) 
  + 구독 정보 조회 (Stripe의 결제 상태 및 플랜 정보 조회)
  + 구독 취소 (사용자가 구독을 해지할 경우, Stripe에서 구독을 취소)
  + Webhook을 통한 결제 실패 감지 및 대응
+ 서비스 백엔드 API 역할
  + 구독 생성 및 관리: Stripe Checkout 세션을 관리하고, 구독 생성 후 내부 데이터베이스에 구독 정보를 저장.
  + 구독 변경 및 해지 처리: 사용자가 구독을 변경 또는 해지할 경우, Stripe API를 호출하여 상태를 갱신하고 내부 시스템에도 반영.
  + 구독 플랜 가격 정보 제공: 내부 API에서 Stripe 및 Paypal 플랜 가격을 관리하고 사용자에게 제공.
  + 결제 오류 및 실패 대응: Stripe Webhook을 통해 실패 정보를 수신하여 사용자에게 알림을 전송하고, Slack을 통해 운영팀에 즉시 알림.
  + 내부 정산 시스템과 연동: Stripe 결제 데이터를 기반으로 사용자의 구독 상태 및 결제 이력을 관리하고, 정산 프로세스를 자동화.
+ 백엔드 개발
  + Stripe Webhook을 활용한 결제 상태 추적 및 자동 업데이트.
  + Slack 알림을 통한 결제 오류 및 상태 모니터링.
  + Redis 및 DB를 활용한 결제 세션 관리 및 트랜잭션 데이터 저장.

## 구독 결제 프로세스 및 아키텍처 

### 구독 생성 Flow Chart

~~~mermaid

flowchart TD
    
    %% 시스템 정의
    1["Front Page"]:::front
    2["Backend API"]:::backend
    3["Stripe"]:::stripe

    %% 구독 결제 흐름
    A["구독 결제 시작"] --> B["플랜 조회 API 호출"]:::backend
    B --> C["구독 결제 페이지 이동"]:::front
    C --> D["세션 생성 API 호출"]:::backend
    
    D --> E["Stripe에 구독 생성 요청"]:::stripe
    E --> F{"Stripe 구독 생성 성공 여부"}:::stripe
    
    %% Stripe 구독 생성 성공/실패 분기
    F -- ✅ 성공 --> G["구독 생성 API 호출"]:::backend
    F -- ❌ 실패 --> H["구독 실패 페이지 이동"]:::front

    %% Tradlinx 구독 생성 후 처리
    G --> I{"Tradlinx 구독 생성 성공 여부"}:::backend
    I -- ✅ 성공 --> J["구독 성공 페이지 이동"]:::front
    I -- ❌ 실패 --> K["Slack 메시지 전송"]
    K --> L["구독 대기 페이지 이동"]:::front
    

    %% 색상 스타일 지정
    classDef front fill:#ffeb3b,stroke:#333,stroke-width:2px;
    classDef backend fill:#ff80ab,stroke:#333,stroke-width:2px;
    classDef stripe fill:#81d4fa,stroke:#333,stroke-width:2px;

~~~

### 구독 생성 Sequence Diagram

~~~mermaid

sequenceDiagram
    participant Front
    participant Saas
    participant Payment_API
    participant Stripe
    participant Membership_API
    participant Service_Bus
    participant Redis
    participant Slack
    participant ALARM_CENTER

    Front->>Saas: 세션 생성 요청
    Saas->>Payment_API: 사용자 결제 유효성 검사 요청
    Payment_API->>Stripe: 결제 내역 요청
    Stripe-->>Payment_API: 결제 내역 응답

    alt 결제 유효성 검사 실패
        Payment_API-->>Saas: 에러 응답 (ex 결제 내역 있음)
        Saas-->>Front: 에러 응답 (ex 결제 내역 있음)
    else 결제 유효성 검사 성공
        Payment_API-->>Saas: 유효성 검증 통과 응답
        Saas->>Membership_API: 사용자 구독 유효성 검사 요청

        alt 구독 유효성 검사 실패
            Membership_API-->>Saas: 에러 응답 (ex 구독 내역 있음)
            Saas-->>Front: 에러 응답 (ex 구독 내역 있음)
        else 구독 유효성 검사 성공
            Membership_API->>Redis: 상태 저장
            Membership_API-->>Saas: 유효성 검증 통과 응답

            Saas->>Payment_API: 세션 생성 요청
            Payment_API->>Stripe: 세션 생성 요청
            Stripe-->>Payment_API: 세션 응답
            Payment_API->>Redis: 상태 업데이트
            Payment_API-->>Saas: 세션 응답
            Saas-->>Front: 세션 응답

            Front->>Stripe: 구독 결제 요청
            alt Stripe 구독 생성 실패 (Cancel URL 호출)
                Stripe-->>Front: 구독 생성 실패 (Cancel URL 호출)
            else Stripe 구독 생성 성공 (Success URL 호출)
                Stripe-->>Front: 구독 생성 성공 (Success URL 호출)
                Front->>Saas: 구독 생성 요청

                alt 구독 생성 성공
                    Saas->>Payment_API: 구독 결제 정보 생성 요청
                    Payment_API->>Redis: 상태 업데이트
                    Payment_API-->>Saas: 생성 성공 응답
                    par
                        Payment_API-)Slack: 구독 시작 알림 발송
                        Payment_API-)ALARM_CENTER: 구독 시작 메일 발송
                    end
                    Saas->>Membership_API: 구독 정보 생성 요청
                    Membership_API->>Redis: 상태 정보 삭제
                    Membership_API-->>Saas: 생성 성공 응답
                    Saas-->>Front: 생성 성공 응답
                else 구독 생성 실패
                    Saas->>Slack: 실패 알림 발송
                    Saas-->>Front: 구독 생성 실패 응답
                end
            end
        end
    end

~~~

### 구독 변경 Flow Chart

~~~mermaid

flowchart TD
    
    %% 시스템 정의
    1["Front Page"]:::front
    2["Backend API"]:::backend
    3["Stripe"]:::stripe

    A["구독 변경 시작"] --> B["플랜 조회 API 호출"]:::backend
    B --> C["구독 변경 페이지 이동"]:::front
    C --> D["구독 변경 세션 생성 API 호출"]:::backend
    
    D --> E["Stripe에 변경 구독 생성 요청"]:::stripe
    E --> F{"Stripe 변경 구독 생성 성공 여부"}:::stripe
    
    %% Stripe 구독 생성 성공/실패 분기
    F -- ✅ 성공 --> G["변경 구독 생성 API 호출"]:::backend
    G --> M["stripe에 기존 구독 삭제 요청"]:::stripe
    M --> N["Tradlinx 변경 구독 생성 및 기존 구독 해지"]:::backend
    F -- ❌ 실패 --> H["구독 실패 페이지 이동"]:::front

    %% Tradlinx 구독 생성 후 처리
    N --> I{"Tradlinx 구독 생성 성공 여부"}:::backend
    I -- ✅ 성공 --> J["구독 성공 페이지 이동"]:::front
    I -- ❌ 실패 --> L["Slack 메시지 전송"]
    L --> K["구독 대기 페이지 이동"]:::front
    

    %% 색상 스타일 지정
    classDef front fill:#ffeb3b,stroke:#333,stroke-width:2px;
    classDef backend fill:#ff80ab,stroke:#333,stroke-width:2px;
    classDef stripe fill:#81d4fa,stroke:#333,stroke-width:2px;


~~~

### 구독 변경 Sequence Diagram

~~~mermaid

sequenceDiagram
    participant Front
    participant Saas
    participant Payment_API
    participant Stripe
    participant Membership_API
    participant Service_Bus
    participant Redis
    participant Slack
    participant ALARM_CENTER

    Front->>Saas: 세션 생성 요청
    Saas->>Payment_API: 사용자 결제 유효성 검사 요청
    Payment_API->>Stripe: 결제 내역 요청
    Stripe-->>Payment_API: 결제 내역 응답

    alt 결제 유효성 검사 실패
        Payment_API-->>Saas: 에러 응답 (ex 결제 내역 있음)
        Saas-->>Front: 에러 응답 (ex 결제 내역 있음)
    else 결제 유효성 검사 성공
        Payment_API-->>Saas: 유효성 검증 통과 응답
        Saas->>Membership_API: 사용자 구독 유효성 검사 요청

        alt 구독 유효성 검사 실패
            Membership_API-->>Saas: 에러 응답 (ex 구독 내역 없음)
            Saas-->>Front: 에러 응답 (ex 구독 내역 없음)
        else 구독 유효성 검사 성공
            Membership_API->>Redis: 상태 저장
            Membership_API-->>Saas: 유효성 검증 통과 응답

            Saas->>Payment_API: 세션 생성 요청
            Payment_API->>Stripe: 세션 생성 요청
            Stripe-->>Payment_API: 세션 응답
            Payment_API->>Redis: 상태 업데이트
            Payment_API-->>Saas: 세션 응답
            Saas-->>Front: 세션 응답

            Front->>Stripe: 구독 결제 요청
            alt Stripe 구독 생성 실패 (Cancel URL 호출)
                Stripe-->>Front: 구독 생성 실패 (Cancel URL 호출)
            else Stripe 구독 생성 성공 (Success URL 호출)
                Stripe-->>Front: 구독 생성 성공 (Success URL 호출)
                Front->>Saas: 구독 생성 요청

                alt 구독 생성 성공
                    Saas->>Payment_API: 구독 결제 정보 변경 요청
                    Payment_API->>Stripe: 기존 구독 취소 요청
                    Stripe-->>Payment_API: 기존 구독 취소 응답
                    Payment_API->>Redis: 상태 업데이트
                    Payment_API-->>Saas: 생성 성공 응답
                    par
                        Payment_API-)Slack: 구독 변경 알림 발송
                        Payment_API-)ALARM_CENTER: 구독 변경 메일 발송
                    end
                    Saas->>Membership_API: 구독 정보 변경 요청
                    Membership_API->>Redis: 상태 정보 삭제
                    Membership_API-->>Saas: 변경 성공 응답
                    Saas-->>Front: 변경 성공 응답
                else 구독 생성 실패
                    Saas->>Slack: 실패 알림 발송
                    Saas-->>Front: 구독 변경 실패 응답
                end
            end
        end
    end

~~~

### STRIPE WEBHOOK으로 구독 생성 Sequence Diagram

~~~mermaid

sequenceDiagram
    participant STRIPE
    participant PAYMENT_API
    participant REDIS
    participant AZURE_SERVICE_BUS
    participant MEMBERSHIP_API
    participant ALARM_CENTER
    participant SLACK

    STRIPE--)PAYMENT_API: 구독 세션 CHECK OUT 성공 WEBHOOK
    PAYMENT_API->>STRIPE: 구독 정보 요청
    STRIPE-->>PAYMENT_API: 구독 정보 응답

    alt STRIPE 구독 정보 요청 실패
        PAYMENT_API-->>SLACK: 구독 정보 조회 실패 알림
        PAYMENT_API-->>STRIPE: 구독 정보 요청 재시도 또는 실패 응답
    else 구독 정보 요청 성공
        PAYMENT_API->>PAYMENT_API: 구독 정보에서 메타 데이터 조회
        PAYMENT_API->>REDIS: 상태 정보 조회
        REDIS-->>PAYMENT_API: 상태 정보 응답
        PAYMENT_API->>PAYMENT_API: (메타 데이터 + 상태 정보)로 구독 결제 정보 생성

        par
            PAYMENT_API-)SLACK: 구독 시작 알림 발송
            PAYMENT_API-)ALARM_CENTER: 구독 시작 메일 발송
        end

        PAYMENT_API->>AZURE_SERVICE_BUS: 구독 생성 요청 메시지 전송
        MEMBERSHIP_API--)AZURE_SERVICE_BUS: 구독 생성 메시지 수신
        MEMBERSHIP_API->>MEMBERSHIP_API: 구독 생성 완료
    end


~~~

### 구독 해지 Flow Chart

~~~mermaid

flowchart TD
    
    1["Front Page"]:::front
    2["Backend API"]:::backend
    3["Stripe"]:::stripe
    
  A[구독 해지]
  B[구독 변경 페이지]:::front
  C{"구독 해지?"}:::front
  D[End]
  E[구독 해지 API]:::backend
  F[STRIPE 구독 취소]:::stripe
  A --> B
  B --> C
  C -- NO --> B
  C -- YES --> D
  C --> E
  E -.-> F
  
  classDef front fill:#ffeb3b,stroke:#333,stroke-width:2px;
  classDef backend fill:#ff80ab,stroke:#333,stroke-width:2px;
  classDef stripe fill:#81d4fa,stroke:#333,stroke-width:2px;


~~~

### 구독 해지 Sequence Diagram

~~~mermaid

sequenceDiagram
    participant FRONT
    participant SaaS
    participant MEMBERSHIP_API
    participant PAYMENT_API
    participant STRIPE
    FRONT->>SaaS: 구독 해제 요청
    SaaS->>PAYMENT_API: 구독 해제 요청
    PAYMENT_API->>STRIPE: 구독 취소 요청
    STRIPE-->>PAYMENT_API: 구독 취소 완료 응답
    PAYMENT_API-->>SaaS: 구독 결제 정보 삭제 및 PAYPAL 구독 취소 성공 응답
    SaaS->>MEMBERSHIP_API: 구독 해제 요청 (구독 만료일을 현재 구독 만료일로 설정)
    MEMBERSHIP_API-->>SaaS: 구독 해제 성공 응답
    SaaS-->>FRONT: 구독 해제 완료 응답

~~~


### STRIPE 구독 결제 성공 웹훅 Sequence Diagram

~~~mermaid

sequenceDiagram
    participant STRIPE
    participant PAYMENT_API
    participant ALARM_CENTER
    participant SLACK
    STRIPE--)PAYMENT_API: 결제 성공 웹훅 이벤트 전송
    PAYMENT_API->>PAYMENT_API: 웹훅 검증 (구독 결제 여부 확인)
    alt 구독 결제 성공
        PAYMENT_API->>PAYMENT_API: 결제 내역 저장
        PAYMENT_API-)ALARM_CENTER: 결제 성공 메일 발송 (비동기)
        PAYMENT_API-)SLACK: 결제 성공 알림 전송 (비동기)
    end
    
~~~

### STRIPE 구독 결제 실패로 인한 상태 변경 웹훅 Sequence Diagram

~~~mermaid

sequenceDiagram
    participant STRIPE
    participant PAYMENT_API
    participant MEMBERSHIP_API
    participant AZURE_SERVICE_BUS
    participant ALARM_CENTER
    participant SLACK
    STRIPE->>STRIPE: 결제 실패 감지 (1차 시도)
    STRIPE--)PAYMENT_API: 결제 실패 웹훅 이벤트 전송
    PAYMENT_API-)SLACK: 결제 실패 알림 전송 (비동기)
    STRIPE->>STRIPE: 5일 후 재결제 시도 (2차 시도)
    STRIPE--)PAYMENT_API: 결제 실패 웹훅 이벤트 전송
    PAYMENT_API-)SLACK: 결제 실패 알림 전송 (비동기)
    STRIPE->>STRIPE: 5일 후 재결제 시도 (3차 시도)
    STRIPE--)PAYMENT_API: 결제 실패 웹훅 이벤트 전송
    PAYMENT_API-)SLACK: 결제 실패 알림 전송 (비동기)
    alt 모든 결제 시도 실패
        STRIPE->>STRIPE: 구독 상태를 CANCEL로 변경
        STRIPE--)PAYMENT_API: 웹훅 이벤트 전송 (구독 상태: CANCEL)
        PAYMENT_API->>PAYMENT_API: 구독 결제 정보 삭제
        PAYMENT_API->>AZURE_SERVICE_BUS: 구독 취소 메시지 큐에 전송
        PAYMENT_API-)ALARM_CENTER: 구독 취소 메일 전송 (비동기)
        PAYMENT_API-)SLACK: 구독 취소 알림 전송 (비동기)
        MEMBERSHIP_API--)AZURE_SERVICE_BUS: 구독 취소 요청 메시지 수신
        MEMBERSHIP_API->>MEMBERSHIP_API: 구독 취소 처리 (구독 만료일 업데이트)
    end

~~~
