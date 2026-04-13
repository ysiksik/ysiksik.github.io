---
layout: post
bigtitle: 'Part 1. 개발자를 위한 Kubernetes 입문'
subtitle: Ch 6. Kubernetes 객체 - Configuration
date: '2026-04-13 00:00:03 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 6. Kubernetes 객체 - Configuration

# Ch 6. Kubernetes 객체 - Configuration
* toc
{:toc}

---


## 01. Environment Variables

쿠버네티스에서 실행되는 애플리케이션은
단순한 정적 프로그램이 아니라 **환경에 따라 동적으로 동작해야 하는 서비스**다.

예를 들어:

* 개발 / 스테이징 / 운영 환경마다

  * DB 주소
  * 계정 정보
  * 외부 API endpoint

👉 모두 달라진다

같은 이미지라도 환경에 따라 다르게 동작해야 하기 때문에
**설정 주입 방식이 필수**가 된다.

---

## 환경 변수란?

환경 변수(Environment Variable)는
운영체제 또는 Shell 수준에서 설정되는 변수다.

```bash
export DB_HOST=192.168.1.10
export DB_PORT=3306
export DB_USER=root
export DB_PASSWORD=password
```

### 특징

* 언어/프레임워크와 무관하게 사용 가능
* 실행 시점에 값 주입 가능
* 코드 변경 없이 설정 변경 가능

---

## Kubernetes에서의 환경 변수

쿠버네티스에서는 환경 변수를 다음과 같이 본다:

> “컨테이너 실행 시 외부 설정을 주입하는 가장 기본적인 방법”

---

### Kubernetes 관점

* Pod Spec에 정의
* 컨테이너 내부로 주입
* 이미지 변경 없이 설정 변경 가능

👉 **Immutable Image + Mutable Config 구조 완성**

---

### 개발자 관점

환경 변수는:

* 빌드 없이 변경 가능
* 배포 없이 설정 변경 가능

👉 **DevOps에서 매우 중요한 설계 포인트**

---

### 애플리케이션 관점

환경 변수는:

* 가장 빠른 설정 접근 방식
* 외부 의존성 없음
* 장애 전파 없음

예를 들어:

* Config Server 사용 → 네트워크 장애 시 서비스 기동 실패
* 환경 변수 사용 → 즉시 로컬에서 접근 가능

👉 안정성과 성능 측면에서 가장 단순하고 강력한 방식

---

## Kubernetes에서 환경 변수 정의

환경 변수는
👉 **컨테이너 단위로 정의된다 (중요)**

---

### YAML 예시

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-test-pod
spec:
  containers:
  - name: my-container
    image: busybox
    env:
    - name: SAMPLE_ENV
      value: "Sample Environment"
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.name
    command: ["sh","-c","sleep 1000"]
```

---

## YAML 상세 설명

### env

```yaml
env:
```

* 환경 변수 정의 영역
* key-value 형태로 설정

---

### 기본 값 설정

```yaml
- name: SAMPLE_ENV
  value: "Sample Environment"
```

* 단순 문자열 값 주입

---

### valueFrom (동적 주입)

```yaml
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
```

👉 Kubernetes 내부 값을 참조해서 주입

---

## fieldRef / fieldPath 의미

### fieldRef

* Kubernetes 리소스 필드 참조

### fieldPath

* 실제 참조할 경로

예시:

| fieldPath          | 의미     |
| ------------------ | ------ |
| metadata.name      | Pod 이름 |
| metadata.namespace | 네임스페이스 |
| status.podIP       | Pod IP |

---

## 중요한 포인트 (실무 핵심)

### 1. 환경 변수는 “컨테이너 레벨”

👉 Pod 전체가 아니라 각 컨테이너마다 따로 설정됨

---

### 2. 이미지 정보는 환경 변수로 못 가져옴

예:

* image
* image tag

👉 직접 참조 불가능

---

### 3. Kubernetes 메타데이터 주입 가능

활용 예:

* 로그에 Pod 이름 출력
* trace용 식별자

---

### 4. 이미 Kubernetes가 기본 환경 변수 제공

예:

```
KUBERNETES_SERVICE_HOST
KUBERNETES_SERVICE_PORT
HOSTNAME
```

👉 굳이 다시 정의할 필요 없음

---

## 실제 주입 결과 예시

```bash
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.96.0.1
HOSTNAME=env-test-pod
SAMPLE_ENV=Sample Environment
POD_NAME=env-test-pod
```

👉 컨테이너 내부에서 바로 사용 가능

---

## 왜 환경 변수가 중요한가 (실무 관점)

여기서 한 단계 더 중요한 포인트가 있다.

너 이력서 보면:

* 배치 시스템
* 결제 시스템
* 외부 API 연동

이런 구조에서는 공통적으로:

👉 **환경별 설정 분리**가 필수다

---

### 환경 변수 없으면 생기는 문제

* 코드에 설정 하드코딩
* 환경별 빌드 필요
* 배포 복잡도 증가

---

### 환경 변수 사용하면

* 하나의 이미지로 모든 환경 대응
* 운영 중 설정 변경 가능
* CI/CD 단순화

---

## 한 줄 핵심 정리

👉 환경 변수는 Kubernetes에서
**“코드와 설정을 분리하는 가장 기본이자 중요한 메커니즘”**

---


