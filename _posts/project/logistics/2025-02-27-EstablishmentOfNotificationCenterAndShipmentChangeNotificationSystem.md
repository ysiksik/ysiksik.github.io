---
layout: post
bigtitle: '알림 센터 및 선적 변경 알림 시스템 구축'
subtitle: 알림 센터 및 선적 변경 알림 시스템 구축
date: '2025-02-27 00:00:01 +0900'
categories:
- logistics
comments: true
---

# 알림 센터 및 선적 변경 알림 시스템 구축

# 알림 센터 및 선적 변경 알림 시스템 구축
* toc
{:toc}

## 프로젝트 개요
서비스 내 선적 데이터 변동을 사용자에게 효과적으로 안내하는 시스템입니다.
B/L을 기반으로 선적 데이터 변경 사항을 추적하고, 이를 사용자에게 알림 및 이메일 형태로 제공하는 것이 목표입니다.
+ **프로젝트명:** 알림 센터 및 선적 변경 알림 프로젝트
+ **프로젝트 일정 및 작업 범위**
  + Kickoff: 2024년 4월 18일
  + 개발 일정:
    + 기획 & 디자인: 4월 19일 ~ 5월 10일
    + 백엔드 개발: 4월 19일 ~ 5월 31일 (백오피스 포함)
    + QA: 6월 3일 ~ 6월 11일
    + 배포일: 2024년 6월 12일
+ **역할:** 백엔드 개발자
+ **프로젝트 목적:**
  + 선적 데이터 변경 사항을 자동으로 감지하고 사용자에게 알림 제공
  + 알림 센터를 통한 통합적인 알림 관리 시스템 구축
  + 알림 센터 개발을 통해 이메일, 카카오톡 알림 관리 및 발송 기능 추가
  + SaaS 내 알림 페이지에서 변경 이력 확인 가능하도록 설계
  +  국가별 타임존을 고려한 메일 및 알림 발송
  + 선적 데이터 변경 사항 조회 및 알림 관리 API 구축
+ **프로젝트 팀 구성:**
  + **백엔드 개발:** 2명
  + **프론트엔드 개발:** 1명
  + **기획:** 1명
  + **디자인:** 1명
  + **QA:** 1명

  
## 프로젝트 주요 기능

### 알림 센터 구축
+ 전체 제품 내 발송되는 모든 알림(이메일, 카카오톡) 관리
+ 알림의 발송 이력 관리 및 재전송 기능 제공 (백오피스)
+ 알림 유형별 필터링 및 로그 저장

### 선적 데이터 변경 사항 기록 및 알림 발송
+ B/L 등록 후, 발생하는 선적 데이터 변경 사항 기록
+ 주요 데이터 변경 사항:
  + 입출항 정보 (POL, TS, POD) 변경
  + ETD(출항예정일)/ETA(도착예정일) 변경
  + 항구 및 선박 정보 변경
  + 일정 지연 시 배지(Badge) 표시
+ SaaS 내 알림 페이지에서 변동 사항 확인 가능

### Saas 내 알림 페이지 및 상세 내역 제공
+ OV SaaS 우측 상단 GNB 영역 내 알림 아이콘 추가
+ 업데이트 시점을 기준으로 변동 내역 제공
+ Master B/L 클릭 시, 개별 업데이트 내역 상세 페이지로 이동
+ 최대 30일간 변경 이력 저장 및 필터링 기능 제공

### 변경 알림 발송 정책 적용
+ 국가별 타임존을 고려한 알림 발송
+ 한국 사용자: 국문 이메일 / 해외 사용자: 영문 이메일 발송
+ 각국의 현지 시간 기준으로 오전 8시 / 오후 5시에 알림 발송
+ 공휴일을 제외한 평일 2회 발송
+ 한 번의 알림에 최대 5개까지 변경 이력 포함


## 알림 센터

### 스펙
+ 기술 스펙
  + **백엔드:** Java 21, Spring Boot 3.2.5, Gradle
  + **API 설계:** gRPC 기반 마이크로서비스 구조
  + **데이터베이스:** MSSQL
  + **메시지 큐:** Azure Service Bus 활용 (비동기 알림 처리)
  + **로그 관리:** Slack API 연동 (에러 로그 자동 전송)
  + **배포 및 운영:** Azure DevOps
  + **문서:** proto docs
+ 주요 기능
  + gRPC: 고효율 원격 프로시저 호출 구조 구현. gRPC 서버와 클라이언트 간 통신 인터페이스를 프로토콜 버퍼로 정의.
  + Azure Service Bus: Azure 클라우드 기반 메시징 서비스를 활용하여 메시지 교환 지원.
  + Spring Data JPA: 데이터베이스 영속성 관리 및 CRUD 작업을 간편하게 처리.
  + Slack API: 에러 메시지 전송을 위한 Slack과의 통합 구현.
+ 구현 세부사항
  + 재전송 기능: gRPC 통신으로 구현.
  + 전송 이력 조회: gRPC 통신을 사용하여 구현.
  + 메시지 전송 기능: Azure Service Bus, GRPC를 통해 메시지를 받고 처리하는 방식으로 구현.

### 구조

#### AZURE SERVICE BUS
알림 서비스는 Azure Service Bus를 활용하여 이메일 및 카카오톡 알림을 비동기적으로 처리하며, 확장성과 안정성을 보장합니다.
각 알림 유형은 Service Bus 내 별도의 Topic으로 관리되며, 수신된 메시지를 이벤트 기반으로 처리합니다.
+ 이메일 발송 요청
  + Azure Service Bus를 통해 이메일 발송 요청을 처리
  + 발송 실패 시 재시도(재전송) 및 에러 로그 자동 기록
  + 맞춤형 템플릿을 적용하여 이메일 본문 구성
+ 카카오톡 알림 전송
  + Azure Service Bus를 통해 카카오 발송 요청을 처리
  + 템플릿 기반 메시지 설정을 통해 동적 콘텐츠 생성 가능
  + 사용자별 카카오톡 연동 계정을 기반으로 개별 메시지 전송

#### gRPC API 설계
+ 메일 서비스 
  + 이메일 발송 내역 조회
  + 이메일 발송 요청
  + 이메일 재전송 요청
+ 카카오 서비스
  + 카카오톡 알림 전송
  + 카카오톡 발송 내역 조회
  + 카카오톡 알림 재전송 요청


## 선적 변경 메일 발송 배치 

### 스펙
+ 기술 스펙
  + **백엔드:** Java 17, Spring Boot 2.7.3, Maven
  + **Batch:** Spring Batch
  + **데이터베이스:** MSSQL
  + **배포 및 운영:** Azure DevOps

### 프로세스

#### 알림 전송 전체 프로세스

~~~mermaid

sequenceDiagram
    participant CD as "선적 데이터 변경 히스토리 저장"
    participant SU as "선적 데이터 변경 알람 히스토리 저장"
    participant BC as "Batch 처리"
    participant AC as "알림 센터"
    participant MS as "메세지 전송"
    participant TR as "전송 기록 저장"
    SU-->>CD: 데이터 참조
    BC->>SU: 데이터 조회
    SU->>BC: 데이터
    BC->>AC: 알림 전송 요청
    AC->>MS: 메세지 전송
    AC->>TR: 전송 기록 저장

~~~
+ 변경 사항 감지: 선적 데이터 변경 알람 히스토리 에서 데이터 변경 여부 확인
+ 알림 요청 생성: Batch 에서 특정 기준에 따라 알림 요청 생성
+ Azure Service Bus 처리: 알림 센터가 Azure 메시지 큐를 통해 메시지를 전달
+ 알림 전송 및 기록: 메시지 전송 서비스에서 메일 발송 후 전송 기록 저장

#### 알림 전송 Batch 프로세스

~~~mermaid

sequenceDiagram
  participant BT as "BATCH"
  participant TI as "타임존 정보"
  participant UL as "유저 정보"
  participant AL as "[SHIPGO] 변경 알람 목록 정보"
  participant MP as "선적 데이터 변경 사항 조회 API"
  participant AC as "알림 센터"
  BT->>TI: UTC 정보로 국가 코드 조회
  TI->>BT: 국가 코드 응답
  BT->>UL: 국가 코드에 해당하는 유저 조회
  UL->>BT: 유저 응답
  BT->>AL: 유저 정보에 해당 하는 변경 알림 정보 조회
  AL->>BT: 변경 알림 정보 응답
  BT->>MP: 변경 사항 정보 API 요청
  MP->>BT: 변경 사항 응답
  BT->>AC: 메세지 가공후 전달

~~~
+ 타임존 고려: 국가별 UTC 기준으로 사용자 그룹 분류 후 알림 배치 실행
+ 변경 알림 필터링: 특정 조건을 만족하는 데이터만 알림 대상으로 지정
+ 선적 데이터 변경 API 호출: 선적 상태 및 운송 스케줄 변경 감지
+ Azure Service Bus 큐 등록: 이메일 전송 요청 등록

#### 데이터 쌓는 전체 흐름도

~~~mermaid

sequenceDiagram
    participant A as "Crawler]
    participant B as "[Shipment] consumer-collect-data-processor"
    participant C as "[Database] MS-SQL
    participant D as "[ShipGO] consumer-cargotrack-management"
    A ->> B : 수집된 데이터 전송, [Topic] shipment / [Subscription] processor
    B ->> B : 데이터 프로세싱
    B ->> C : 변경 사항이 있다면 변경 사항 저장
    B ->> D : 수집 이후 알림 내역 업데이트 [Topic] shipment-command / [Subscription] cargo-track-management
    D ->> D : 변경 사항 데이터를 알림 내역으로 가공
    D ->> C : 알림 내역 저장

~~~
+ 크롤러 기반 데이터 수집: Crawler(A)에서 선적 변경 데이터를 주기적으로 가져옴
+ 데이터 정제 및 저장: Processor(B)에서 변경된 운송 상태를 감지하고, DB에 저장
+ 알림 내역 변환: Consumer(D)에서 알림 데이터를 가공하여 알림 센터(AC)에 전달
+ Batch 트리거: 선적 변경 데이터가 특정 조건을 만족하면 배치 실행

## 선적 변경 알림 관련 API

### 스펙
+ 기술 스펙
  + **백엔드:** Java 17, Spring Boot 2.7.3, Maven
  + **API 설계:** RESTful API
  + **데이터베이스:** MSSQL
  + **배포 및 운영:** Azure DevOps

### 구조
+ 특정 카테고리 및 페이지 기반 조회
  + 특정 카테고리(SCHEDULE, MOVEMENT, PORT_VESSEL)로 필터링하여 알림 히스토리를 조회.
+ 새로운 알림 존재 여부 확인
  + 현재 사용자의 계정에 읽지 않은 알림이 있는지 확인.
+ 특정 B/L 관련 알림 조회
  + 특정 B/L 번호에 대한 알림 내역 조회.
+ 알림 읽음 처리
  + 특정 알림 ID들을 읽음 처리하거나 전체 알림을 읽음 처리.

## 선적 데이터 변경 사항 관련 API

### 스펙
+ 기술 스펙
  + **백엔드:** Java 17, Spring Boot 2.7.3, Maven
  + **API 설계:** RESTful API
  + **데이터베이스:** MSSQL
  + **배포 및 운영:** Azure DevOps

### 구조
+ 선적 경로 변경 내역 조회
  + routeHistoryId를 기반으로 특정 선적의 변경 사항을 조회
  + 변경된 POL(출항지), POD(도착지), 선박 정보 등의 데이터 제공
+ 선적 변경 사항 목록 조회
  + 다중 routeHistoryId 또는 shipmentId 기준으로 변경 내역 조회
  + detectTypes(변경 유형: POL_ETD, ETA 변경 등) 필터링 지원
+ 다중 경로 변경 내역 조회
  + 여러 개의 routeHistoryId 목록을 기준으로 변경 내역 조회

## 성과 및 기여도
+ 알림 센터 및 선적 변경 알림 시스템 구축
+ 알림 센터 도입으로 통합적인 알림 관리 가능
+ 선적 데이터 변경 사항을 자동 추적하여 즉각적인 안내 제공
+ 국가별 타임존 적용으로 사용자 맞춤형 서비스 제공
+ gRPC 기반 마이크로서비스 구조 도입으로 성능 최적화
+ Azure Service Bus 활용으로 안정적인 메시지 큐 시스템 구축
+ Slack API 연동으로 실시간 장애 감지 및 대응 체계 구축
