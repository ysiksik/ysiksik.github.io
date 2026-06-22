---
layout: post
bigtitle: 'Part 2. 백엔드 개발과 Kubernetes'
subtitle: Ch 5. Service를 이용해 애플리케이션끼리 통신하기
date: '2026-06-18 00:00:01 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 5. Service를 이용해 애플리케이션끼리 통신하기

# Ch 5. Service를 이용해 애플리케이션끼리 통신하기
* toc
{:toc}

---

## 01. MSA를 위한 애플리케이션 간의 내부 통신과 Kubernetes Service

### MSA를 위한 애플리케이션 간의 내부 통신과 Kubernetes Service

쿠버네티스 환경에서는 애플리케이션 간의 통신과 외부 트래픽 처리를 위해 다양한 네트워크 객체를 사용한다.

외부에서 클러스터 내부로 들어오는 요청은 Ingress, NodePort Service, LoadBalancer Service 등을 통해 처리한다.

반대로 클러스터 내부의 애플리케이션 간 통신은 ClusterIP Service를 통해 이루어진다.

또한 클러스터 내부에서 외부 시스템을 호출하기 위해 ExternalName Service를 사용할 수 있다.

#### Kubernetes 네트워크 구성

```text
외부 사용자
      │
      ▼
   Ingress
      │
      ▼
Frontend Service
      │
      ▼
Backend Service
      │
      ▼
ExternalName Service
      │
      ▼
외부 Database
```

쿠버네티스에서는 각 네트워크 객체가 담당하는 역할이 명확하게 구분된다.

* Ingress : 외부 → 내부 진입
* ClusterIP Service : 내부 서비스 간 통신
* ExternalName Service : 내부 → 외부 호출
* NodePort / LoadBalancer : 외부 노출

서비스가 많아질수록 이러한 역할 분리가 더욱 중요해진다.

---

### ClusterIP Service와 서비스 디스커버리

MSA 환경에서는 서비스 간 호출이 매우 빈번하게 발생한다.

이때 Service는 단순한 네트워크 라우터 역할뿐만 아니라 서비스 디스커버리 역할도 담당한다.

즉, 호출하는 애플리케이션은 실제 Pod의 IP를 알 필요가 없다.

Service 이름만 알고 있으면 된다.

#### Service 정의

```yaml
apiVersion: v1
kind: Service
metadata:
  name: user-service

spec:
  selector:
    app: user-app

  ports:
    - protocol: TCP
      port: 8080
```

#### Service의 주요 역할

##### 라우팅 대상 지정

```yaml
selector:
  app: user-app
```

서비스가 어떤 Pod를 대상으로 트래픽을 전달할지 결정한다.

즉, Service를 호출하면 실제로는 selector에 의해 선택된 Pod들로 요청이 전달된다.

##### 서비스 식별자 제공

```yaml
metadata:
  name: user-service
```

서비스 이름은 DNS 이름으로 사용된다.

따라서 다른 애플리케이션은 Pod IP를 직접 사용하지 않고 Service 이름을 통해 통신한다.

---

### 애플리케이션 간 호출

#### Service 이름 기반 호출

```java
RestClient httpClient = RestClient.create();

httpClient
    .get()
    .uri("http://user-service:8080/users/" + userId)
    .retrieve()
    .body(UserInfo.class);
```

호출 과정은 다음과 같다.

```text
api-server
    │
    ▼
user-service
    │
    ▼
user-app Pod
```

애플리케이션은 Service 이름만 알고 있으면 된다.

실제 Pod 개수나 IP 변경 여부는 신경 쓸 필요가 없다.

쿠버네티스가 자동으로 서비스 디스커버리와 로드 밸런싱을 수행한다.

---

### Service와 Deployment 관계

실무에서는 대부분 다음과 같은 구조를 사용한다.

```text
Deployment
      │
      ▼
ReplicaSet
      │
      ▼
Pods
      ▲
      │
Service
```

일반적으로 하나의 애플리케이션은 다음 구성을 가진다.

* Deployment 1개
* Service 1개

즉,

```text
user-app
   ↔
user-service
```

처럼 1:1 형태로 대응되는 경우가 많다.

---

### Service의 Port 설정

Service의 Port는 호출 규칙이 아니라 노출할 포트를 정의하는 것이다.

```yaml
ports:
  - protocol: TCP
    port: 8080
```

많은 개발자들이 Service가 하나의 포트만 가진다고 생각하기 쉽지만 실제로는 여러 포트를 동시에 노출할 수 있다.

```yaml
ports:
  - port: 8080
  - port: 9090
  - port: 50051
```

따라서 Service는 특정 포트 하나를 의미하는 객체가 아니라 여러 포트를 대표할 수 있는 네트워크 엔드포인트라고 이해하는 것이 좋다.

---

### Ingress와 Service 관계

외부 요청은 직접 Pod로 연결되지 않는다.

Ingress는 반드시 Service를 대상으로 트래픽을 전달한다.

#### Ingress 정의

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: user-ingress

spec:
  rules:
    - http:
        paths:
          - pathType: Prefix
            path: /user
            backend:
              service:
                name: user-service
                port:
                  number: 8080
```

#### 요청 흐름

```text
사용자 요청
    │
    ▼
Ingress
    │
    ▼
user-service
    │
    ▼
user-app Pod
```

외부에서만 호출되는 애플리케이션이라 하더라도 Service가 필요하다.

Ingress의 타겟이 Service이기 때문이다.

---

### Ingress Path 전달 방식

기본적으로 Ingress는 Path를 그대로 전달한다.

예를 들어

```text
/user/users/1001
```

요청이 들어오면

```text
/user/users/1001
```

그대로 백엔드까지 전달된다.

즉,

```yaml
path: /user
```

는 단순히 라우팅 기준일 뿐 자동으로 제거되지 않는다.

---

### Path Rewrite

경우에 따라서는 Prefix를 제거하고 싶을 수 있다.

예를 들어

```text
/user/users/1001
```

을

```text
/ users/1001
```

형태로 백엔드에 전달하고 싶을 수 있다.

이 경우 NGINX Ingress의 Rewrite 기능을 사용한다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: user-ingress

  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2

spec:
  rules:
    - http:
        paths:
          - pathType: ImplementationSpecific
            path: /user(/|$)(.*)
```

#### Rewrite 결과

```text
외부 요청
/user/users/1001

↓

백엔드 전달
/users/1001
```

이 기능은 API Gateway 역할을 수행할 때 자주 사용된다.

---

### ExternalName Service

ExternalName Service는 다른 Service들과 성격이 조금 다르다.

실제 트래픽을 라우팅하지 않는다.

DNS 별칭(Alias)을 제공하는 역할을 수행한다.

```text
backend-app
      │
      ▼
database-service
      │
      ▼
db.example.com
```

애플리케이션은 실제 주소를 알 필요 없이 Service 이름만 사용하면 된다.

#### 장점

* 외부 시스템 주소 변경 시 코드 수정 불필요
* 설정 중앙화 가능
* 운영 환경 변경 대응 용이

---

### Kubernetes 환경에서 애플리케이션 설계 원칙

#### 애플리케이션과 Service를 함께 설계

하나의 애플리케이션은 하나의 Service를 가진다는 관점으로 설계하는 것이 일반적이다.

#### Service 이름을 신중하게 결정

Service 이름은 코드에서 직접 사용된다.

```java
http://user-service
http://order-service
http://payment-service
```

따라서 의미가 명확한 이름을 사용하는 것이 중요하다.

#### 세션에 의존하지 않는 구조

Service는 여러 Pod에 트래픽을 분산한다.

따라서 요청은 항상 다른 Pod로 전달될 수 있다고 가정해야 한다.

가능하면

* Stateless 구조
* 세션 외부 저장
* 요청 독립 처리

방식을 사용하는 것이 좋다.

#### 호출 대상의 확장성을 고려하지 말 것

애플리케이션은 단순히 Service를 호출하기만 하면 된다.

* Pod 개수
* 장애 발생
* 스케일 아웃
* Pod 재생성

등은 쿠버네티스가 처리한다.

애플리케이션은 호출 자체에만 집중하는 것이 바람직하다.

---

### 정리

* ClusterIP Service는 MSA 내부 통신의 핵심이다.
* Service는 서비스 디스커버리와 로드 밸런싱을 담당한다.
* 대부분 Deployment와 Service는 1:1 구조로 설계된다.
* 애플리케이션은 Service 이름으로 통신한다.
* Ingress의 대상은 Pod가 아니라 Service이다.
* Path Prefix는 기본적으로 그대로 전달된다.
* Rewrite 설정을 이용하면 Prefix 제거가 가능하다.
* ExternalName Service는 DNS Alias 역할을 수행한다.
* 애플리케이션은 Pod가 아닌 Service를 기준으로 설계하는 것이 쿠버네티스 친화적인 구조이다.

## 02. Service 정의 및 애플리케이션 간 HTTP 통신 실습

이번 실습에서는 Kubernetes 환경에서 여러 애플리케이션을 배포한 뒤 Service를 이용한 내부 통신과 Ingress를 이용한 외부 통신을 구성해본다.

실습 목표는 다음과 같다.

* Kind 기반 Kubernetes 클러스터 구성
* NGINX Ingress Controller 설치
* Service를 이용한 애플리케이션 간 통신
* Ingress를 이용한 외부 노출
* Path Rewrite 적용

### 전체 구조

최종적으로 다음과 같은 구조를 구성한다.

```text
외부 사용자
      │
      ▼
Ingress
      │
      ▼
api-service
      │
      ▼
api-app

      │ HTTP 호출
      ▼

user-service
      │
      ▼
user-app
```

---

### Kind 클러스터 재생성

Ingress 실습을 위해 기존 Kind 클러스터를 삭제한 후 Ingress를 사용할 수 있는 형태로 다시 생성한다.

기존 클러스터 삭제

```bash
kind delete cluster
```

Ingress 지원용 Kind 설정 파일 생성

```yaml
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4

nodes:
  - role: control-plane

    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"

    extraPortMappings:
      - containerPort: 80
        hostPort: 80
        protocol: TCP

      - containerPort: 443
        hostPort: 443
        protocol: TCP
```

클러스터 생성

```bash
kind create cluster --config kind-config.yaml
```

위 설정은 다음 목적을 가진다.

* Ingress Controller가 배치될 수 있도록 노드 라벨 추가
* 로컬 PC의 80, 443 포트를 클러스터와 연결
* 브라우저에서 직접 Ingress 테스트 가능

---

### NGINX Ingress Controller 설치

Ingress는 리소스만 생성한다고 동작하지 않는다.

Ingress 규칙을 실제로 처리할 Controller가 필요하다.

NGINX Ingress Controller 설치

```bash
kubectl apply -f \
https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
```

설치 확인

```bash
kubectl get pods -n ingress-nginx
```

Controller 준비 대기

```bash
kubectl wait \
--namespace ingress-nginx \
--for=condition=ready pod \
--selector=app.kubernetes.io/component=controller \
--timeout=90s
```

---

### 기존 애플리케이션 배포

기존에 작성한 Deployment를 적용한다.

```bash
kubectl apply -f deployment.yaml
```

배포 상태 확인

```bash
kubectl get pods
```

---

### Namespace 및 Secret 생성

Namespace나 Secret은 실무에서도 명령어로 생성하는 경우가 많다.

```bash
kubectl create namespace dev
```

```bash
kubectl create secret generic api-secret \
  --from-literal=API_KEY=my-secret-key
```

---

### User Service 생성

User 애플리케이션을 위한 Service 생성

```yaml
apiVersion: v1
kind: Service

metadata:
  name: user-service

spec:
  selector:
    app: user-app

  ports:
    - protocol: TCP
      port: 8080
```

적용

```bash
kubectl apply -f user-service.yaml
```

---

### Service DNS 확인

Service가 생성되면 Kubernetes DNS가 자동 생성된다.

같은 Namespace에서는 다음 주소로 호출할 수 있다.

```text
http://user-service:8080
```

실제 Pod IP를 알 필요가 없으며 Service 이름만으로 통신이 가능하다.

---

### 애플리케이션 간 HTTP 통신

Kubernetes에서는 다른 애플리케이션을 호출할 때 Pod IP를 직접 사용하지 않는다.

또한 localhost도 사용할 수 없다.

localhost는 현재 컨테이너 또는 같은 Pod 내부 컨테이너만 의미한다.

다른 애플리케이션은 반드시 Service를 통해 호출해야 한다.

예시

```java
RestClient httpClient = RestClient.create();

UserInfo userInfo = httpClient
    .get()
    .uri("http://user-service:8080/users/" + userId)
    .retrieve()
    .body(UserInfo.class);
```

요청 흐름

```text
api-app
    │
    ▼
user-service
    │
    ▼
user-app Pod
```

Service는 selector를 이용하여 실제 Pod를 찾고 트래픽을 분산한다.

따라서 애플리케이션은 Pod 수가 증가하거나 감소하는 것을 신경 쓸 필요가 없다.

---

### API Service 생성

Ingress가 연결할 대상 Service 생성

```yaml
apiVersion: v1
kind: Service

metadata:
  name: api-service

spec:
  selector:
    app: api-app

  ports:
    - protocol: TCP
      port: 8080
```

적용

```bash
kubectl apply -f api-service.yaml
```

---

### Ingress 생성

외부 요청을 Service로 연결하기 위한 Ingress 생성

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: api-ingress

spec:
  rules:
    - http:
        paths:
          - path: /api
            pathType: Prefix

            backend:
              service:
                name: api-service
                port:
                  number: 8080
```

적용

```bash
kubectl apply -f ingress.yaml
```

---

### Ingress 요청 흐름

```text
브라우저
    │
    ▼
Ingress
    │
    ▼
api-service
    │
    ▼
api-app Pod
```

Ingress는 Pod가 아니라 Service를 대상으로 동작한다.

따라서 외부에서 호출되는 애플리케이션도 반드시 Service가 필요하다.

---

### 외부 호출 테스트

Ingress를 통해 요청을 전송한다.

```bash
curl http://localhost/api/users/1
```

여기서 localhost는 애플리케이션 내부 주소가 아니라 Kind 클러스터를 실행 중인 로컬 PC를 의미한다.

Ingress가 80 포트로 노출되어 있기 때문에 localhost로 접근할 수 있다.

---

### Path Rewrite 적용

Ingress는 기본적으로 요청 경로를 그대로 전달한다.

예를 들어

```text
/api/users/1
```

요청이 들어오면

```text
/api/users/1
```

그대로 백엔드 애플리케이션에 전달된다.

Prefix를 제거하려면 Rewrite 기능을 사용한다.

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress

metadata:
  name: api-ingress

  annotations:
    nginx.ingress.kubernetes.io/use-regex: "true"
    nginx.ingress.kubernetes.io/rewrite-target: /$2

spec:
  rules:
    - http:
        paths:
          - path: /api(/|$)(.*)
            pathType: ImplementationSpecific

            backend:
              service:
                name: api-service
                port:
                  number: 8080
```

---

### Rewrite 동작 확인

Rewrite 적용 전

```text
외부 요청
/api/users/1

↓

백엔드 전달
/api/users/1
```

Rewrite 적용 후

```text
외부 요청
/api/users/1

↓

백엔드 전달
/users/1
```

애플리케이션 로그를 통해 실제 전달 경로가 변경된 것을 확인할 수 있다.

---

### 실습 정리

* Kind 클러스터를 Ingress 지원 형태로 생성한다.
* NGINX Ingress Controller를 설치한다.
* Deployment를 배포한다.
* ClusterIP Service를 생성한다.
* Service DNS를 이용해 애플리케이션 간 통신을 수행한다.
* Pod IP나 localhost 대신 Service 이름으로 통신한다.
* Ingress를 생성하여 외부 요청을 Service로 연결한다.
* Rewrite 기능을 이용해 URL Prefix를 제거할 수 있다.
* Kubernetes 환경에서는 애플리케이션을 Pod가 아니라 Service를 기준으로 바라보는 것이 중요하다.
