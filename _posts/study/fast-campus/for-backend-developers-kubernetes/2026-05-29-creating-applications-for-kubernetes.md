---
layout: post
bigtitle: 'Part 2. 백엔드 개발과 Kubernetes'
subtitle: Ch 2. Kubernetes를 위한 애플리케이션 생성 
date: '2026-05-29 00:00:00 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 2. Kubernetes를 위한 애플리케이션 생성

# Ch 2. Kubernetes를 위한 애플리케이션 생성
* toc
{:toc}

---

## 01. Kubernetes를 위한 애플리케이션 생성

### Kubernetes를 위한 애플리케이션 생성

쿠버네티스에서 애플리케이션을 실행하기 위해서는 먼저 애플리케이션을 컨테이너 이미지로 만들어야 한다.

과거에는 서버에 직접 JDK를 설치하고, 빌드된 JAR 파일을 복사한 뒤 실행하는 방식이 일반적이었다. 하지만 Docker가 대중화된 이후에는 애플리케이션 실행에 필요한 모든 구성 요소를 하나의 컨테이너 이미지에 포함하는 방식이 보편화되었다.

```text
Spring Project
      ↓
application.jar
      ↓
Container Image
      ↓
Container
```

이렇게 생성된 컨테이너 이미지는 Docker와 같은 컨테이너 런타임을 통해 실행될 수 있다.

---

### Kubernetes에서의 실행 단위

컨테이너는 애플리케이션 실행의 기본 단위이지만 Kubernetes에서는 컨테이너를 직접 배포하지 않는다.

Kubernetes가 관리하는 가장 작은 배포 단위는 **Pod** 이다.

```mermaid
graph LR
    Container --> Pod
    Pod --> ReplicaSet
    ReplicaSet --> Deployment
```

Pod는 하나 이상의 컨테이너를 포함할 수 있으며, 같은 Pod 내부의 컨테이너들은 네트워크와 저장소를 비교적 자유롭게 공유할 수 있다.

---

### Kubernetes의 주요 Workload

Kubernetes는 다양한 실행 목적에 맞는 Workload 객체를 제공한다.

```mermaid
graph LR
    CronJob
    Job
    Deployment
    StatefulSet
    DaemonSet
```

각 객체의 역할은 다음과 같다.

| 객체          | 역할                |
| ----------- | ----------------- |
| Deployment  | 일반적인 서버 애플리케이션 배포 |
| StatefulSet | 상태를 가지는 애플리케이션 실행 |
| DaemonSet   | 모든 노드에 하나씩 Pod 실행 |
| Job         | 일회성 작업 실행         |
| CronJob     | 스케줄 기반 작업 실행      |

실제 운영 환경에서는 대부분 Deployment를 사용하며, ReplicaSet은 Deployment 내부에서 자동으로 관리된다. Deployment는 ReplicaSet의 기능에 더해 버전 관리, 롤링 업데이트, 롤백 기능까지 제공한다.

---

### 애플리케이션의 Kubernetes 배포 과정

일반적인 배포 과정은 다음과 같다.

```mermaid
graph LR
    A[Source Code]
    --> B[Container Image]

    B --> C[Deployment]

    C --> D[Pod]

    D --> E[Service]
```

1. 애플리케이션을 컨테이너 이미지로 생성
2. Deployment 작성
3. Pod 생성
4. Service 연결
5. 외부 또는 내부 네트워크에 노출

배포 과정에서 필요에 따라 다음과 같은 설정을 추가할 수 있다.

* Label
* Node Selector
* Affinity
* Environment Variable
* ConfigMap
* Secret
* Volume



---

### 애플리케이션의 Containerization

컨테이너 이미지를 생성하는 방법은 여러 가지가 있지만 대표적으로 Dockerfile과 Gradle Jib를 많이 사용한다.

---

#### Dockerfile 사용

```dockerfile
FROM openjdk:19

COPY ./build/libs/my-app-*.jar /app.jar

CMD ["java", "-jar", "/app.jar"]
```

##### 설정 설명

###### FROM

```dockerfile
FROM openjdk:19
```

컨테이너 이미지의 베이스 이미지를 지정한다.

위 예제에서는 OpenJDK 19가 설치된 이미지를 사용한다.

---

###### COPY

```dockerfile
COPY ./build/libs/my-app-*.jar /app.jar
```

빌드된 JAR 파일을 컨테이너 내부로 복사한다.

```text
호스트 파일
↓
./build/libs/my-app.jar

컨테이너 내부
↓
/app.jar
```

---

###### CMD

```dockerfile
CMD ["java", "-jar", "/app.jar"]
```

컨테이너가 실행될 때 수행할 명령어를 지정한다.

---

#### Docker 이미지 빌드

```shell
docker build -t my-repo/my-app:0.0.1 .
```

##### 옵션 설명

###### -t

```shell
-t my-repo/my-app:0.0.1
```

생성될 이미지 이름과 태그를 지정한다.

```text
Repository : my-repo/my-app
Tag        : 0.0.1
```

---

### Gradle Jib 사용

Docker를 설치하지 않고도 이미지를 생성할 수 있다.

```groovy
jib {
    from {
        image = "openjdk:19"
    }

    to {
        image = "my-repo/my-app"
        tags = ['latest', '0.0.1']
    }

    container {
        creationTime = "USE_CURRENT_TIMESTAMP"
    }
}
```

##### 설정 설명

###### from

```groovy
from {
    image = "openjdk:19"
}
```

베이스 이미지를 지정한다.

---

###### to

```groovy
to {
    image = "my-repo/my-app"
}
```

생성될 이미지 이름을 지정한다.

---

###### tags

```groovy
tags = ['latest', '0.0.1']
```

하나의 이미지에 여러 태그를 부여할 수 있다.

---

###### creationTime

```groovy
creationTime = "USE_CURRENT_TIMESTAMP"
```

이미지 생성 시간을 현재 시각으로 설정한다.

---

### Deployment 스펙 작성

이미지를 만들었다면 이제 Kubernetes에 배포할 Deployment를 작성한다.

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: my-app

spec:
  replicas: 2

  selector:
    matchLabels:
      app: my-app

  template:
    metadata:
      labels:
        app: my-app

    spec:
      containers:
      - name: my-container
        image: my-repo/my-app:0.0.1
```

---

#### Deployment 설정 설명

##### apiVersion

```yaml
apiVersion: apps/v1
```

Deployment API 버전

---

##### kind

```yaml
kind: Deployment
```

생성할 객체 유형

---

##### metadata.name

```yaml
metadata:
  name: my-app
```

Deployment 이름

---

##### replicas

```yaml
replicas: 2
```

동시에 실행할 Pod 개수

```text
replicas: 2

→ Pod 2개 생성
```

---

##### selector

```yaml
selector:
  matchLabels:
    app: my-app
```

Deployment가 관리할 Pod를 식별하는 기준

---

##### template.metadata.labels

```yaml
labels:
  app: my-app
```

생성될 Pod의 Label

selector와 동일해야 한다.

---

##### containers

```yaml
containers:
- name: my-container
```

Pod 내부에서 실행될 컨테이너 정의

---

##### image

```yaml
image: my-repo/my-app:0.0.1
```

실행할 컨테이너 이미지

---

### 환경 변수 추가

애플리케이션 실행 시 환경 변수를 주입할 수도 있다.

```yaml
containers:
- name: my-container
  image: my-repo/my-app:0.0.1

  env:
  - name: SPRING_PROFILES_ACTIVE
    value: "dev"
```

#### env

```yaml
env:
```

컨테이너 환경 변수 정의

---

#### SPRING_PROFILES_ACTIVE

```yaml
- name: SPRING_PROFILES_ACTIVE
  value: "dev"
```

Spring Boot의 활성 프로파일 지정

```text
application-dev.yml
```

설정이 적용된다.

---

### Kubernetes 적용

Deployment YAML 작성이 완료되었다면 다음 명령어로 클러스터에 적용할 수 있다.

```shell
kubectl apply -f my-app.yaml
```

실행 흐름은 다음과 같다.

```mermaid
graph LR
    A[my-app.yaml]
    --> B[kubectl apply]
    --> C[Deployment]
    --> D[ReplicaSet]
    --> E[Pod]
```

Deployment가 생성되면 내부적으로 ReplicaSet이 생성되고, ReplicaSet이 실제 Pod를 생성 및 관리하게 된다.

---

### 정리

Kubernetes에서 애플리케이션을 배포하는 과정은 크게 다음 순서로 이루어진다.

```text
Spring Project
↓
Jar Build
↓
Container Image 생성
↓
Deployment 작성
↓
Pod 생성
↓
Service 연결
↓
운영
```

실제 운영 환경에서는 Deployment를 중심으로 ConfigMap, Secret, Volume, Service, Ingress 등을 함께 사용하여 완전한 애플리케이션 실행 환경을 구성하게 된다.
