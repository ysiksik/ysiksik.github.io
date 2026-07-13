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

### 환경 변수란?

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

### Kubernetes에서의 환경 변수

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

### Kubernetes에서 환경 변수 정의

환경 변수는
👉 **컨테이너 단위로 정의된다 (중요)**

---

#### YAML 예시

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

### YAML 상세 설명

#### env

```yaml
env:
```

* 환경 변수 정의 영역
* key-value 형태로 설정

---

#### 기본 값 설정

```yaml
- name: SAMPLE_ENV
  value: "Sample Environment"
```

* 단순 문자열 값 주입

---

#### valueFrom (동적 주입)

```yaml
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
```

👉 Kubernetes 내부 값을 참조해서 주입

---

### fieldRef / fieldPath 의미

#### fieldRef

* Kubernetes 리소스 필드 참조

#### fieldPath

* 실제 참조할 경로

예시:

| fieldPath          | 의미     |
| ------------------ | ------ |
| metadata.name      | Pod 이름 |
| metadata.namespace | 네임스페이스 |
| status.podIP       | Pod IP |

---

### 중요한 포인트 (실무 핵심)

#### 1. 환경 변수는 “컨테이너 레벨”

👉 Pod 전체가 아니라 각 컨테이너마다 따로 설정됨

---

#### 2. 이미지 정보는 환경 변수로 못 가져옴

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

### 실제 주입 결과 예시

```bash
KUBERNETES_SERVICE_PORT=443
KUBERNETES_SERVICE_HOST=10.96.0.1
HOSTNAME=env-test-pod
SAMPLE_ENV=Sample Environment
POD_NAME=env-test-pod
```

👉 컨테이너 내부에서 바로 사용 가능

---

### 왜 환경 변수가 중요한가 (실무 관점)

여기서 한 단계 더 중요한 포인트가 있다.

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

### 한 줄 핵심 정리

👉 환경 변수는 Kubernetes에서
**“코드와 설정을 분리하는 가장 기본이자 중요한 메커니즘”**

---

## 02. ConfigMap & Secret

앞에서 환경 변수를 통해 설정을 주입하는 방법을 살펴봤다.
하지만 실제 서비스에서는 다음과 같은 요구가 생긴다.

* 설정 값이 많아짐
* 환경별 설정 분리 필요
* 민감 정보(DB 비밀번호 등) 보호 필요

이 문제를 해결하기 위해 Kubernetes는
👉 **ConfigMap과 Secret**이라는 설정 전용 객체를 제공한다.

---

### ConfigMap vs Secret

| 구분 | ConfigMap        | Secret               |
| -- | ---------------- | -------------------- |
| 용도 | 일반 설정값           | 민감 정보                |
| 예시 | DB_HOST, profile | DB_PASSWORD, API_KEY |
| 보안 | 없음               | 제한적 보호               |

---

### ConfigMap

ConfigMap은
👉 **외부에 공개되어도 괜찮은 설정값을 저장하는 객체**다.

---

### ConfigMap YAML 예시

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
data:
  profile: "dev"
  db_host: "10.20.30.40"
  welcome-script: |
    echo Hello!
    echo DB is $db_host
```

---

### ConfigMap 필드 설명

* `data`
  → key-value 형태의 설정값 저장

* 멀티라인 데이터 (`|`)
  → 파일 형태의 설정 가능

```yaml
welcome-script: |
  echo Hello!
  echo DB is $db_host
```

👉 스크립트, 설정 파일 저장에 유용

---

### Secret

Secret은
👉 **외부에 노출되면 안 되는 민감 정보를 저장하는 객체**다.

---

### Secret 생성 (CLI)

```bash
kubectl create secret generic my-db --from-literal=DB_PW=mypassword
```

---

### Secret YAML 예시

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: my-secret
type: Opaque
data:
  DB_PW: bXlwYXNzd29yZAo=
stringData:
  API_KEY: ABCD-1234-5678-ZYX
```

---

### Secret 필드 설명

* `data`
  → base64 인코딩된 값

* `stringData`
  → 평문 입력 (자동 인코딩됨)

* `type: Opaque`
  → 일반적인 Key-Value Secret

---

### Secret 보안 특징 (중요)

Secret은 완전한 암호화 저장소가 아니다.

#### 기본 특징

* etcd에 저장됨
* base64 인코딩 (암호화 아님)
* CLI에서 기본적으로 값 숨김

#### 위험 요소

* etcd 접근 가능 → 모든 Secret 조회 가능
* base64 → 쉽게 복호화 가능

#### 보안 강화 방법

* etcd encryption 활성화
* RBAC 접근 제어
* Secret 접근 최소화

---

### 설정 주입 방법

ConfigMap과 Secret은 Pod에 두 가지 방식으로 주입할 수 있다.

---

### 1. 환경 변수 방식

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-config-app
spec:
  containers:
  - name: my-container
    image: my-app:1.0.0
    env:
    - name: SPRING_PROFILES_ACTIVE
      valueFrom:
        configMapKeyRef:
          name: my-config
          key: profile
    - name: DB_PASSWORD
      valueFrom:
        secretKeyRef:
          name: my-secret
          key: DB_PW
```

---

### 환경 변수 방식 설명

* `configMapKeyRef`
  → ConfigMap에서 값 가져오기

* `secretKeyRef`
  → Secret에서 값 가져오기

* `name`
  → ConfigMap/Secret 이름

* `key`
  → 해당 설정 값의 키

👉 가장 간단하고 많이 사용하는 방식

---

### 2. Volume Mount 방식

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: my-image
    volumeMounts:
    - name: config-volume
      mountPath: /config-files
  volumes:
  - name: config-volume
    configMap:
      name: my-config
      items:
      - key: welcome-script
        path: "welcome.sh"
```

---

### Volume 방식 설명

* `volumes.configMap`
  → ConfigMap을 볼륨으로 연결

* `volumeMounts.mountPath`
  → 컨테이너 내부 경로

* `items`
  → 특정 key만 파일로 매핑

---

### 결과

컨테이너 내부:

```
/config-files/welcome.sh
```

👉 파일 내용 = ConfigMap 값

---

### 언제 어떤 방식을 사용할까?

| 방식     | 사용 상황       |
| ------ | ----------- |
| 환경 변수  | 간단한 설정값     |
| 파일 마운트 | 설정 파일, 스크립트 |

---

### 실무 핵심 포인트

#### 1. ConfigMap = 일반 설정

* profile
* host
* feature flag

---

#### 2. Secret = 민감 정보

* DB 비밀번호
* API Key
* 인증 토큰

---

#### 3. 코드와 설정 분리

👉 가장 중요한 설계 원칙

* 이미지 → 코드
* ConfigMap/Secret → 설정

---

### 한 줄 핵심 정리

👉 ConfigMap과 Secret은
**“코드와 설정을 분리하고 환경별 구성을 가능하게 하는 핵심 메커니즘”**

---

