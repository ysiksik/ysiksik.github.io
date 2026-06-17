---
layout: post
bigtitle: 'Part 2. 백엔드 개발과 Kubernetes'
subtitle: Ch 4. ConfigMap과 Secret을 이용한 애플리케이션의 설정 외부화
date: '2026-06-15 00:00:00 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 4. ConfigMap과 Secret을 이용한 애플리케이션의 설정 외부화

# Ch 4. ConfigMap과 Secret을 이용한 애플리케이션의 설정 외부화
* toc
{:toc}

---

## 01. ConfigMap과 Secret으로 설정 관리하기 

### ConfigMap과 Secret으로 설정 관리하기

애플리케이션은 실행 환경에 따라 서로 다른 설정값을 필요로 한다. 예를 들어 개발 환경과 운영 환경은 데이터베이스 주소, 비밀번호, API Key 등이 달라질 수 있다.

Kubernetes는 이러한 설정을 코드와 분리하여 관리하기 위해 `ConfigMap`과 `Secret` 객체를 제공한다.

---

#### ConfigMap과 Secret

Kubernetes에서 설정을 저장하기 위해 사용하는 대표적인 객체는 다음과 같다.

* **ConfigMap**: 일반적으로 공개되어도 상관없는 설정 저장
* **Secret**: 외부에 공개되면 안 되는 민감한 정보 저장

대표적인 예시는 다음과 같다.

| 설정 값              | 저장 위치     |
| ----------------- | --------- |
| Database Host     | ConfigMap |
| Database User     | ConfigMap |
| Database Password | Secret    |
| API Key           | Secret    |
| JWT Secret        | Secret    |

일반적으로 비밀번호나 인증 정보는 Secret에 저장하고, 나머지 일반 설정은 ConfigMap에 저장한다.

---

#### 설정값 주입

Kubernetes는 ConfigMap이나 Secret의 값을 컨테이너에 주입할 수 있다.

가장 일반적인 방법은 환경 변수(Environment Variable)를 사용하는 방식이다.

```yaml
containers:
- name: my-container
  image: my-app
  env:
  - name: SPRING_PROFILES_ACTIVE
    value: production

  - name: DB_HOST
    valueFrom:
      configMapKeyRef:
        name: db-config
        key: host

  - name: DB_PASSWORD
    valueFrom:
      secretKeyRef:
        name: db-secret
        key: password
```

---

##### 직접 환경 변수 지정

간단한 설정은 ConfigMap이나 Secret을 사용하지 않고 직접 정의할 수도 있다.

```yaml
env:
- name: SPRING_PROFILES_ACTIVE
  value: production
```

다음과 같은 설정들은 직접 환경 변수로 관리하는 경우가 많다.

* Spring Profile
* Feature Flag
* 로그 레벨
* 특정 애플리케이션 전용 옵션

모든 설정을 ConfigMap으로 분리해야 하는 것은 아니다.

특정 애플리케이션 내부에서만 사용하는 설정이라면 직접 환경 변수로 관리하는 것이 오히려 단순할 수 있다.

---

##### ConfigMap 참조

```yaml
valueFrom:
  configMapKeyRef:
    name: db-config
    key: host
```

위 설정은 다음 의미를 가진다.

1. `db-config`라는 ConfigMap 조회
2. `host` 키 값 조회
3. `DB_HOST` 환경 변수에 주입

예를 들어 ConfigMap이 아래와 같다면

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: db-config

data:
  host: mysql.default.svc.cluster.local
```

컨테이너 내부에서는 다음과 같이 사용된다.

```bash
DB_HOST=mysql.default.svc.cluster.local
```

---

##### Secret 참조

```yaml
valueFrom:
  secretKeyRef:
    name: db-secret
    key: password
```

동작 방식은 ConfigMap과 거의 동일하다.

차이점은 참조 대상이 Secret이라는 점뿐이다.

---

##### Secret과 Base64

Secret은 내부적으로 Base64 형태로 저장된다.

```yaml
data:
  password: cGFzc3dvcmQ=
```

하지만 Base64는 암호화가 아니라 단순 인코딩이다.

따라서 Secret만으로 완전한 보안이 제공되는 것은 아니다.

실제 운영 환경에서는 다음과 같은 보안 설정을 함께 적용한다.

* etcd 암호화
* RBAC 권한 관리
* Secret 접근 제한

중요한 점은 컨테이너 내부에서는 자동으로 디코딩된 값이 주입된다는 것이다.

즉 개발자가 직접 Base64 디코딩을 수행할 필요는 없다.

---

#### 다른 설정 주입 방식

환경 변수 외에도 다양한 방식이 존재한다.

##### Volume Mount 방식

설정을 파일 형태로 마운트할 수 있다.

```yaml
volumes:
- name: config-volume
  configMap:
    name: my-config
```

주로 다음과 같은 경우 사용한다.

* Nginx 설정 파일
* 인증서 파일
* YAML 설정 파일

---

##### Kubernetes API 호출 방식

ServiceAccount 권한을 부여한 뒤 Kubernetes API를 직접 호출하여 ConfigMap이나 Secret을 조회할 수도 있다.

다만 구현 복잡도가 높기 때문에 일반적인 애플리케이션에서는 환경 변수 방식을 가장 많이 사용한다.

---

#### 설정값 사용

주입된 환경 변수는 애플리케이션에서 사용할 수 있다.

Spring Boot에서는 다음과 같이 참조한다.

```yaml
spring:
  datasource:
    url: ${DB_HOST}
    username: ${DB_USER}
    password: ${DB_PASSWORD}

app:
  api-key: ${API_KEY}
```

애플리케이션 시작 시 Spring이 환경 변수를 읽어서 설정값으로 변환한다.

---

##### @Value 사용

```java
@Value("${app.api-key}")
private String apiKey;
```

Spring이 자동으로 설정값을 주입한다.

실무에서는 타입 안정성을 위해 `@ConfigurationProperties`를 사용하는 경우도 많다.

```java
@ConfigurationProperties(prefix = "app")
public record AppProperties(
        String apiKey
) {
}
```

---

#### Application 설정 관리 전략

##### 환경 변수를 기본으로 사용

현대적인 애플리케이션은 환경 변수를 기반으로 동작하도록 설계한다.

이를 통해 코드 수정 없이 설정만 변경할 수 있다.

---

##### 환경 구분은 Namespace 기반

실무에서는 설정 키 이름을 바꾸기보다 Namespace를 분리하는 경우가 많다.

예를 들어 다음과 같이 구성할 수 있다.

```text
dev namespace
 └── db-config

staging namespace
 └── db-config

production namespace
 └── db-config
```

ConfigMap 이름은 동일하지만 Namespace가 다르므로 환경이 분리된다.

---

##### 설정 객체는 설정 기준으로 공통화

설정을 사용하는 애플리케이션 기준이 아니라 설정의 성격에 따라 분리한다.

예를 들어

```text
db-config
redis-config
payment-config
mail-config
```

처럼 관리하면 여러 애플리케이션이 동일한 설정을 재사용할 수 있다.

---

#### 설정 변경 시 주의사항

ConfigMap이나 Secret이 수정되더라도 이미 실행 중인 Pod에는 자동으로 반영되지 않는다.

설정 변경 후에는 일반적으로 Pod 재시작이 필요하다.

예를 들어 다음 상황을 생각해보자.

1. Deployment가 2개의 Pod 실행 중
2. ConfigMap 수정
3. Pod 재시작 없이 Scale Out 수행
4. Pod 개수를 4개로 증가

그러면

```text
기존 Pod 2개
→ 이전 설정 사용

새로운 Pod 2개
→ 변경된 설정 사용
```

결과적으로 동일한 애플리케이션이 서로 다른 설정으로 동작하게 된다.

이 경우 API 호출 결과가 달라지거나 장애가 발생할 수 있다.

따라서 ConfigMap이나 Secret 변경 후에는 Deployment 재시작을 수행하는 것이 일반적이다.

```bash
kubectl rollout restart deployment my-app
```

---

#### 정리

* ConfigMap은 일반 설정 저장
* Secret은 민감한 정보 저장
* 환경 변수 방식이 가장 널리 사용됨
* Secret 값은 컨테이너에서 자동 디코딩됨
* 환경 구분은 Namespace를 기준으로 수행
* 설정 변경 후에는 Pod 재시작이 필요함
* 실무에서는 `ConfigMap + Secret + Environment Variable` 조합이 가장 많이 사용됨


## 02. ConfigMap과 Secret을 이용한 설정 관리 실습

### ConfigMap과 Secret을 이용한 설정 관리 실습

이번 실습에서는 Spring Boot 애플리케이션을 컨테이너 이미지로 빌드한 뒤, Kubernetes의 ConfigMap과 Secret을 이용하여 설정을 외부화하고 애플리케이션에 주입하는 과정을 진행한다.

---

#### 실습 준비

##### Docker Hub 저장소 생성

애플리케이션 이미지를 저장하기 위한 컨테이너 레지스트리가 필요하다.

가장 일반적인 방법은 Docker Hub 저장소를 사용하는 것이다.

```text
Docker Hub
 └── Repository
      └── my-spring-app
```

일반적으로 애플리케이션이 새로 추가되면 해당 애플리케이션 전용 저장소를 새로 생성하여 관리한다.

---

#### Spring Boot 애플리케이션 생성

간단한 Spring Boot 프로젝트를 생성한다.

예제 기능

* Health Check API
* 설정값 조회 API

---

##### Health Check Controller 생성

프로브 설정과 실습을 위해 간단한 Health Check API를 만든다.

프로브는 응답 본문보다 HTTP 상태 코드가 중요하다.

```java
@RestController
public class HealthController {

    @GetMapping("/health")
    public String health() {
        return "OK";
    }
}
```

HTTP 200을 반환하면 정상 상태로 판단한다.

---

#### Gradle Jib 설정

컨테이너 이미지를 생성하기 위해 Jib 플러그인을 사용한다.

```groovy
plugins {
    id 'com.google.cloud.tools.jib' version '3.4.0'
}

jib {
    from {
        image = "eclipse-temurin:21-jre"
    }

    to {
        image = "dockerhub-id/my-app"
        tags = ["0.0.1"]
    }

    container {
        creationTime = "USE_CURRENT_TIMESTAMP"
    }
}
```

##### creationTime 설정

Jib는 기본적으로 고정된 생성 시간을 사용한다.

```groovy
creationTime = "USE_CURRENT_TIMESTAMP"
```

설정하면 현재 시간을 기준으로 이미지가 생성된다.

---

##### 이미지 빌드 및 Push

```bash
./gradlew jib
```

Jib는 다음 작업을 한 번에 수행한다.

1. 애플리케이션 빌드
2. 컨테이너 이미지 생성
3. Docker Hub Push

Docker가 로컬에 설치되지 않아도 동작할 수 있다는 장점이 있다.

---

#### ConfigMap 생성

애플리케이션에서 사용할 언어 코드를 ConfigMap으로 관리한다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config

data:
  language: ko
```

ConfigMap은 공개되어도 문제가 없는 설정을 저장한다.

예시

* 언어 코드
* Feature Flag
* API URL
* 로그 레벨

---

#### Secret 생성

민감한 API Key는 Secret으로 관리한다.

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret

type: Opaque

data:
  api-key: QUJDREVGRw==
```

---

##### Base64 인코딩

Secret은 Base64 형태로 저장한다.

인코딩 시에는 `echo -n` 옵션을 사용하는 것이 좋다.

```bash
echo -n "ABCDEFG" | base64
```

`-n` 옵션이 없으면 개행 문자(`\n`)가 함께 인코딩될 수 있다.

예상하지 못한 인증 오류의 원인이 되기도 한다.

---

##### Secret 관리 전략

Secret은 Git 저장소에 올라갈 경우 민감 정보가 노출될 수 있다.

따라서 실무에서는 다음과 같은 방식도 자주 사용한다.

* `kubectl create secret` 사용
* External Secret 사용
* Vault 연동
* 클라우드 Secret Manager 사용

---

#### ConfigMap 관리 전략

ConfigMap은 여러 애플리케이션이 공통으로 사용할 수도 있다.

예를 들어 공통 설정이라면 별도 저장소에서 관리하기도 한다.

```text
config-repository
 ├── common-config
 ├── database-config
 └── payment-config
```

설정의 변경 주기와 재사용성을 기준으로 분리하는 경우가 많다.

---

#### Deployment에 설정 연결

ConfigMap과 Secret을 환경 변수로 주입한다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-app

spec:
  replicas: 1

  selector:
    matchLabels:
      app: my-app

  template:
    metadata:
      labels:
        app: my-app

    spec:
      containers:
      - name: my-app
        image: dockerhub-id/my-app:0.0.1

        env:
        - name: LANGUAGE
          valueFrom:
            configMapKeyRef:
              name: app-config
              key: language

        - name: API_KEY
          valueFrom:
            secretKeyRef:
              name: app-secret
              key: api-key
```

---

##### imagePullPolicy 설정

```yaml
imagePullPolicy: Always
```

설정하면 Pod 생성 시 항상 이미지를 다시 다운로드한다.

개발 환경에서는 최신 이미지를 즉시 반영할 수 있다.

```yaml
imagePullPolicy: IfNotPresent
```

운영 환경에서는 일반적으로 `IfNotPresent`를 사용한다.

매번 이미지를 내려받으면 배포 시간이 증가하고 레지스트리 의존성이 커질 수 있기 때문이다.

---

#### Spring 설정 적용

환경 변수를 Spring 설정에 연결한다.

```yaml
app:
  language: ${LANGUAGE}
  api-key: ${API_KEY}
```

---

#### 설정값 사용

컨트롤러에서 설정값을 읽어본다.

```java
@RestController
@RequiredArgsConstructor
public class ConfigController {

    @Value("${app.language}")
    private String language;

    @Value("${app.api-key}")
    private String apiKey;

    @GetMapping("/config")
    public String config() {
        return language + " : " + apiKey;
    }
}
```

실행 후 API를 호출하여 설정값이 정상적으로 주입되었는지 확인한다.

---

#### Kubernetes 적용

##### ConfigMap 생성

```bash
kubectl apply -f configmap.yaml
```

##### Secret 생성

```bash
kubectl apply -f secret.yaml
```

##### Deployment 생성

```bash
kubectl apply -f deployment.yaml
```

---

#### Pod 내부 확인

Pod 내부로 접속하여 환경 변수를 확인할 수 있다.

```bash
kubectl exec -it my-pod -- sh
```

```bash
env
```

또는

```bash
echo $LANGUAGE
echo $API_KEY
```

를 통해 실제 주입 여부를 확인할 수 있다.

---

#### ConfigMap 수정

설정 변경은 다음 명령으로 가능하다.

```bash
kubectl edit configmap app-config
```

예를 들어

```yaml
language: ko
```

를

```yaml
language: en
```

으로 수정할 수 있다.

---

#### 설정 변경 시 주의사항

ConfigMap이나 Secret을 수정해도 이미 실행 중인 Pod에는 자동 반영되지 않는다.

기존 Pod는 이전 설정을 유지한다.

변경 사항을 적용하려면 Pod 재시작이 필요하다.

```bash
kubectl rollout restart deployment my-app
```

실무에서는 설정 변경 후 Deployment를 재시작하는 작업을 함께 수행하는 경우가 많다.

---

#### 정리

* ConfigMap은 일반 설정 관리
* Secret은 민감 정보 관리
* 가장 일반적인 주입 방식은 환경 변수
* Secret 값은 자동으로 Base64 디코딩됨
* ConfigMap은 공통 저장소로 분리 가능
* Secret은 Git 저장 시 보안에 주의
* 설정 변경 후에는 Pod 재시작 필요
* 운영 환경에서는 `latest` 대신 명시적인 버전 사용 권장
