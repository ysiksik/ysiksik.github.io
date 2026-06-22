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


