---
layout: post
bigtitle: '실무에 바로 쓰는 DDD기반으로 유연성과 확정성 있게 MSA 설계하기'
subtitle: 마이크로서비스 아키텍처 참조 모델
date: '2026-04-13 00:00:04 +0900'
categories:
    - designing-an-msa
comments: true

---

# 마이크로서비스 아키텍처 참조 모델

# 마이크로서비스 아키텍처 참조 모델
* toc
{:toc}

---


## 마이크로서비스 아키텍처 참조 모델 이해

마이크로서비스 아키텍처를 실제로 구축하려고 하면 단순히 “서비스를 나눈다”는 개념만으로는 부족하다.
서비스를 어떻게 배치하고, 어떻게 연결하고, 어떻게 운영할 것인지까지 포함된 **참조 모델(Reference Model)**이 필요하다.

클라우드 네이티브 환경에서의 마이크로서비스 아키텍처는
컨테이너, API 게이트웨이, 서비스 메시, 텔레메트리 등의 요소로 구성되며
이러한 구조는 시스템의 유연성과 확장성을 높이는 데 핵심적인 역할을 한다.

---

## 마이크로서비스 아키텍처 참조 모델이란?

마이크로서비스 아키텍처 참조 모델은
클라우드 환경에서 애플리케이션을 구성하기 위한 표준적인 구조를 의미한다.

이 모델은 단순한 서비스 분리가 아니라 다음을 모두 포함한다.

* 서비스 배포 방식
* 서비스 간 통신 구조
* 운영 및 모니터링 방식
* 확장 및 장애 대응 전략

즉, **“서비스를 어떻게 나누고, 어떻게 운영할 것인가에 대한 전체 설계 구조”**라고 볼 수 있다.

---

## 전체 아키텍처 구조

참조 모델은 크게 내부 아키텍처와 외부 아키텍처로 나눌 수 있다.

강의 자료의 구조를 보면, 전체 시스템은 다음과 같은 흐름으로 구성된다

* 사용자(UI)
* API Gateway
* 마이크로서비스
* 컨테이너 플랫폼 (Kubernetes)
* 백킹 서비스 (DB, Cache, MQ)
* CI/CD
* 텔레메트리

아래 구조는 클라우드 네이티브 환경에서 마이크로서비스 아키텍처가 어떤 요소들로 구성되는지를 보여준다.  
클라이언트 요청은 API Gateway를 통해 유입되고, 각 서비스는 컨테이너 기반 환경에서 실행된다.  
서비스 간 통신은 Service Mesh가 담당하며, 데이터 처리는 DB, Cache, MQ와 같은 백킹 서비스에 의존한다.  
또한 CI/CD를 통해 배포가 자동화되고, Telemetry를 통해 시스템 상태를 지속적으로 관찰할 수 있다.

~~~mermaid

flowchart TD
    UI[사용자 UI / Client]

    AGW[API Gateway<br/>인증 / 인가<br/>API 조합<br/>라우팅]

    subgraph MS[마이크로서비스 영역]
        SA[Service A]
        SB[Service B]
    end

    subgraph PLATFORM[컨테이너 플랫폼 / Kubernetes]
        K8S[K8S Cluster<br/>Master Node / Worker Node]
        CT1[Container A]
        CT2[Container B]
    end

    subgraph BACKING[백킹 서비스]
        DB[(DB / Storage)]
        CACHE[(Cache)]
        MQ[(MQ)]
    end

    subgraph CICD[CI/CD]
        SCM[형상 관리]
        BUILD[빌드 자동화]
        DEPLOY[배포 자동화]
        REGISTRY[이미지 저장소]
    end

    SM[Service Mesh<br/>Service Discovery<br/>Routing<br/>Load Balancing]
    TEL[Telemetry<br/>Logging / Metrics / Tracing / Monitoring]
    AUTO[Auto Scaling]

    UI --> AGW
    AGW --> SA
    AGW --> SB

    SA --> CT1
    SB --> CT2

    CT1 --> K8S
    CT2 --> K8S

    SA --> DB
    SA --> CACHE
    SA --> MQ
    SB --> DB
    SB --> CACHE
    SB --> MQ

    SM --> SA
    SM --> SB

    SA --> TEL
    SB --> TEL
    K8S --> AUTO

    SCM --> BUILD --> REGISTRY --> DEPLOY --> K8S

~~~


~~~mermaid

flowchart LR
    Client[Client / UI] --> Gateway[API Gateway]

    Gateway --> ServiceA[Service A]
    Gateway --> ServiceB[Service B]

    ServiceA <--> Mesh[Service Mesh]
    ServiceB <--> Mesh

    ServiceA --> DB[(DB)]
    ServiceA --> Cache[(Cache)]
    ServiceA --> MQ[(MQ)]

    ServiceB --> DB
    ServiceB --> Cache
    ServiceB --> MQ

    ServiceA --> Telemetry[Telemetry]
    ServiceB --> Telemetry

    CICD[CI/CD Pipeline] --> K8S[Kubernetes]
    K8S --> ServiceA
    K8S --> ServiceB


~~~


---

## 내부 아키텍처

내부 아키텍처는 실제 애플리케이션이 실행되는 환경이다.

### 구성 요소

* UI (사용자 인터페이스)
* 클러스터 환경 (Kubernetes)

Kubernetes 환경은 일반적으로 다음과 같이 구성된다.

* 마스터 노드: 전체 클러스터 관리
* 워커 노드: 실제 컨테이너 실행

이 구조를 통해 서비스는 물리적인 서버에 종속되지 않고 유연하게 운영된다.

---

## 외부 아키텍처

외부 아키텍처는 서비스가 외부 요청을 처리하는 구조이다.

핵심은 **컨테이너 중심 구조**이다.

### 주요 요소

* REST API
* API 인증 / 인가
* API 조합
* 백엔드 서비스 (Service A, Service B 등)

이 구조는 클라이언트와 내부 서비스 간의 결합도를 낮추는 역할을 한다.

---

## 컨테이너 기반 운영 환경

컨테이너는 마이크로서비스 아키텍처의 핵심 실행 단위이다.

### 특징

* 애플리케이션을 격리된 환경에서 실행
* 동일한 환경에서 실행 보장
* 빠른 배포 가능

### 운영 환경 구성

* 개발 환경
* 검증(테스트) 환경
* 운영 환경

각 환경은 동일한 컨테이너 이미지를 사용하여 일관성을 유지한다.

---

## 컨테이너 관리 및 자동화

컨테이너 기반 환경에서는 관리 자동화가 필수적이다.

### 주요 요소

* 형상 관리
* 빌드 자동화
* 배포 자동화
* 이미지 저장소

이 과정은 CI/CD 파이프라인으로 구성된다.

---

## CI/CD (지속적 통합 / 지속적 배포)

CI/CD는 클라우드 네이티브 환경에서 핵심적인 역할을 한다.

### 구성 요소

* 빌드 자동화
* 테스트 자동화
* 배포 자동화

### 효과

* 빠른 피드백
* 안정적인 배포
* 반복 작업 제거

---

## 핵심 아키텍처 구성 요소

마이크로서비스 참조 모델에서 반드시 포함되는 핵심 요소들을 정리하면 다음과 같다.

---

### API Gateway

외부 요청이 가장 먼저 도달하는 지점이다.

#### 역할

* REST API 요청 수신
* 인증 / 인가 처리
* API 조합 (Aggregation)
* 서비스 라우팅

#### 효과

* 단일 진입점 제공
* 클라이언트와 내부 서비스 분리

---

### 서비스 메시 (Service Mesh)

서비스 간 통신을 제어하는 계층이다.

#### 역할

* 서비스 발견 (Service Discovery)
* 라우팅
* 로드밸런싱
* 보안 통신

서비스 간 통신 로직을 애플리케이션 코드에서 분리하여
운영 측면에서 제어할 수 있도록 한다.

---

### 텔레메트리 (Telemetry)

시스템 상태를 관찰하고 데이터를 수집하는 기술이다.

#### 역할

* 로그 수집
* 메트릭 수집
* 트레이싱

#### 특징

애플리케이션은 중앙 시스템으로 데이터를 자동 전송하여
운영자가 전체 상태를 한눈에 파악할 수 있도록 한다.

---

## 백킹 서비스 (Backing Services)

마이크로서비스는 데이터 저장소와 메시징 시스템과 함께 동작한다.

### 구성 요소

* DB (데이터베이스)
* 스토리지
* 캐시
* MQ (메시지 큐)

이들은 애플리케이션과 분리된 독립 서비스로 관리된다.

---

## 확장성과 오토스케일링

클라우드 네이티브 환경에서는 트래픽 변화에 따라 자동으로 확장할 수 있어야 한다.

### 특징

* 필요 시 인스턴스 자동 증가
* 트래픽 감소 시 자동 축소

이를 통해 비용 효율성과 성능을 동시에 확보할 수 있다.

---

## 정리

마이크로서비스 아키텍처 참조 모델은 단순한 구조도가 아니다.

다음 요소들이 유기적으로 결합된 시스템이다.

* 컨테이너 기반 실행 환경
* API Gateway를 통한 진입 제어
* Service Mesh를 통한 통신 관리
* Telemetry를 통한 관측
* CI/CD 기반 자동화
* 백킹 서비스를 통한 데이터 처리

---

### 한 줄 요약

마이크로서비스 아키텍처 참조 모델은
클라우드 네이티브 환경에서 서비스의 확장성과 유연성을 확보하기 위해
컨테이너, API Gateway, 서비스 메시, 텔레메트리 등을 포함한 통합 아키텍처 구조이다.

---

