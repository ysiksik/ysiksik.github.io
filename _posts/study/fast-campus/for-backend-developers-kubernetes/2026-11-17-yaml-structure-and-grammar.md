---
layout: post
bigtitle: 'Yaml'
subtitle: Ch 2. Yaml 구조 및 문법 
date: '2026-11-17 00:00:10 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 2. Yaml 구조 및 문법

# Ch 2. Yaml 구조 및 문법
* toc
{:toc}

---

## 01. Dictionary

### YAML의 구조와 문법: Mapping, Dictionary, 문자열, Null, Boolean

YAML은 사람이 쉽게 읽고 작성할 수 있도록 설계된 데이터 직렬화 형식이다.

Kubernetes에서는 Pod, Deployment, Service, ConfigMap 등 다양한 리소스를 YAML 파일로 정의하며, Spring Boot에서도 `application.yml`을 통해 애플리케이션 설정을 관리한다.

YAML의 기본적인 구조는 비교적 간단하다.

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd
```

위 내용을 읽으면 별도의 설명 없이도 다음과 같은 정보를 이해할 수 있다.

- 이름은 홍길동이다.
- 나이는 30세이다.
- 좋아하는 음식은 Steak이다.
- 좋아하는 음악가는 The Weeknd이다.

YAML은 이처럼 데이터를 Key와 Value로 표현하며, 들여쓰기를 통해 데이터 사이의 계층 관계를 나타낸다.

하지만 실제 YAML을 작성하려면 Key-Value 구조 외에도 알아야 할 문법이 있다.

예를 들어 다음과 같은 상황이다.

- 하나의 Key에 또 다른 객체를 저장하고 싶은 경우
- 같은 데이터를 한 줄로 표현하고 싶은 경우
- 하나의 파일에 여러 YAML 문서를 작성하고 싶은 경우
- 긴 문자열을 여러 줄로 표현하고 싶은 경우
- 줄바꿈을 유지하거나 하나의 문장으로 합치고 싶은 경우
- 값이 존재하지 않는 상태를 표현하고 싶은 경우
- Boolean 값을 기준으로 데이터를 필터링하고 싶은 경우

이번에는 YAML의 기본 데이터 구조인 **Mapping(Dictionary)** 을 중심으로 다양한 문법을 살펴보고, `yq`를 사용하여 실제 데이터가 어떻게 해석되는지도 확인한다.

---

### YAML의 기본 데이터 구조

YAML은 크게 세 가지 기본 데이터 구조를 사용한다.

| 데이터 구조 | 의미 | 예시 |
|---|---|---|
| Scalar | 하나의 값 | 문자열, 숫자, Boolean, Null |
| Mapping | Key-Value 관계 | 객체, Dictionary, Map |
| Sequence | 순서가 있는 값의 목록 | 배열, List |

이 세 가지 구조를 조합하면 복잡한 데이터도 표현할 수 있다.

```mermaid
flowchart TD
    A["YAML 데이터 구조"] --> B["Scalar"]
    A --> C["Mapping"]
    A --> D["Sequence"]

    B --> E["String / Number / Boolean / Null"]
    C --> F["Key-Value 구조"]
    D --> G["여러 값을 순서대로 저장"]

    C --> H["중첩 Mapping"]
    D --> I["Mapping 또는 Scalar 목록"]
```

예를 들어 다음 YAML을 살펴보자.

```yaml
person:
  name: 홍길동
  age: 30
  vaccinated: true

  favorite:
    food: Steak
    musician: The Weeknd

  skills:
    - Java
    - Spring Boot
    - Kubernetes
```

이 문서에는 세 가지 구조가 모두 포함되어 있다.

`홍길동`, `30`, `true`는 Scalar에 해당한다.

`person`과 `favorite`는 Mapping을 구성한다.

`skills`는 여러 문자열을 포함하는 Sequence이다.

이를 계층 구조로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["person"] --> B["name: 홍길동"]
    A --> C["age: 30"]
    A --> D["vaccinated: true"]
    A --> E["favorite"]
    A --> F["skills"]

    E --> G["food: Steak"]
    E --> H["musician: The Weeknd"]

    F --> I["Java"]
    F --> J["Spring Boot"]
    F --> K["Kubernetes"]
```

이러한 구조를 이해하면 YAML의 문법이 조금 복잡해지더라도 데이터 사이의 관계를 파악할 수 있다.

---

### Mapping과 Dictionary란?

Mapping은 **Key와 Value를 연결하여 데이터를 표현하는 구조**이다.

프로그래밍 언어에서 사용하는 Map이나 Dictionary와 비슷한 개념이다.

예를 들어 다음 YAML을 살펴보자.

```yaml
name: 홍길동
age: 30
```

여기서 `name`과 `age`는 Key이다.

`홍길동`과 `30`은 각각의 Value이다.

```text
Key    Value
--------------
name   홍길동
age    30
```

Mapping의 기본적인 표현 방식은 다음과 같다.

```yaml
key: value
```

콜론(`:`)을 사용하여 Key와 Value를 구분한다.

일반적인 블록 스타일에서는 콜론 뒤에 공백을 작성한다.

```yaml
name: 홍길동
```

여기서 `name`은 데이터를 구분하기 위한 이름이며, `홍길동`은 해당 이름에 대응하는 값이다.

#### Mapping의 특징

Mapping은 다음과 같은 특징을 가진다.

1. Key와 Value의 관계로 데이터를 표현한다.
2. 하나의 Mapping에 여러 Key-Value 쌍을 포함할 수 있다.
3. Value에는 Scalar뿐 아니라 다른 Mapping이나 Sequence를 사용할 수 있다.
4. 동일한 Mapping 안에서는 Key가 중복되지 않아야 한다.
5. Mapping의 항목 순서는 데이터의 의미를 결정하는 기준으로 사용하지 않는 것이 좋다.

실무에서는 Key를 문자열로 사용하는 경우가 대부분이다.

특히 Kubernetes Manifest에서는 일반적인 JSON 객체와 호환되는 문자열 Key를 사용한다.

다만 YAML 규격 자체는 문자열 외의 값이나 복합 노드를 Key로 표현하는 기능도 지원한다. 따라서 YAML의 모든 Key가 반드시 문자열이어야 하는 것은 아니다.

이러한 고급 기능은 일반적인 Kubernetes 설정에서는 거의 사용하지 않으므로, 우선 문자열 Key를 사용하는 Mapping 구조를 익히는 것이 좋다.

---

### Mapping의 Value에는 어떤 데이터를 사용할 수 있을까?

Mapping의 Value에는 다양한 종류의 데이터를 저장할 수 있다.

대표적으로 다음과 같다.

- String
- Integer
- Float
- Boolean
- Null
- Mapping
- Sequence

예를 들어 다음 YAML을 살펴보자.

```yaml
name: 홍길동
age: 30
height: 175.5
vaccinated: true
experience: null
```

각 항목의 데이터 타입은 다음과 같다.

| Key | Value | 데이터 타입 |
|---|---|---|
| `name` | `홍길동` | String |
| `age` | `30` | Integer |
| `height` | `175.5` | Float |
| `vaccinated` | `true` | Boolean |
| `experience` | `null` | Null |

Value에 문자열이나 숫자만 사용할 수 있는 것은 아니다.

다음과 같이 또 다른 Mapping을 포함할 수도 있다.

```yaml
person:
  name: 홍길동
  age: 30
```

여기서 `person`의 Value는 하나의 문자열이나 숫자가 아니라 Mapping이다.

즉 Mapping 안에 Mapping이 들어 있는 중첩 구조이다.

---

### 중첩 Mapping 표현하기

YAML에서는 들여쓰기를 사용하여 Mapping 내부에 또 다른 Mapping을 표현한다.

예를 들어 사용자에게 좋아하는 음식과 음악가에 대한 정보가 있다고 가정하자.

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd
```

여기서 `favorite`는 Key이다.

하지만 `favorite`의 Value는 단순한 Scalar가 아니다.

다음 두 개의 Key-Value 쌍을 포함하는 Mapping이다.

```yaml
food: Steak
musician: The Weeknd
```

이를 구조적으로 표현하면 다음과 같다.

```text
Root Mapping
│
├── name: 홍길동
├── age: 30
│
└── favorite
    ├── food: Steak
    └── musician: The Weeknd
```

이러한 구조에서는 들여쓰기 수준이 중요하다.

`food`와 `musician`은 `favorite`에 속해 있으므로 한 단계 더 들여쓰기해야 한다.

```yaml
favorite:
  food: Steak
  musician: The Weeknd
```

반대로 다음과 같이 작성하면 데이터의 구조가 달라진다.

```yaml
favorite:
food: Steak
musician: The Weeknd
```

이 설정은 `food`와 `musician`이 `favorite`에 속한 구조가 아니다.

`favorite`, `food`, `musician`이 최상위에 있는 별도의 Key가 된다. 이 경우 `favorite`의 값은 Null로 해석될 수 있다.

따라서 YAML에서는 단순히 문법 오류가 발생하지 않았다는 사실만으로 의도한 데이터 구조가 만들어졌다고 판단해서는 안 된다.

**들여쓰기가 올바른 계층 관계를 표현하고 있는지 확인하는 것이 중요하다.**

---

### YAML의 들여쓰기 규칙

YAML에서는 들여쓰기를 통해 데이터의 계층 구조를 표현한다.

일반적으로 공백 2칸을 사용하는 방식을 많이 사용한다.

```yaml
application:
  name: my-app

  server:
    port: 8080
    host: localhost
```

위 구조를 살펴보면 다음과 같다.

```text
application                 ← 최상위
  name                      ← 1단계
  server                    ← 1단계
    port                    ← 2단계
    host                    ← 2단계
```

들여쓰기의 핵심 규칙은 다음과 같다.

| 규칙 | 설명 |
|---|---|
| 공백 사용 | 들여쓰기에는 Space 사용 |
| Tab 사용 금지 | Tab을 들여쓰기로 사용하지 않음 |
| 같은 계층 | 동일한 수준으로 들여쓰기 |
| 하위 데이터 | 상위 항목보다 깊게 들여쓰기 |
| 일관성 | 파일 전체에서 일정한 들여쓰기 방식 유지 |

YAML이 공백 2칸만 허용하는 것은 아니다.

하지만 같은 계층의 항목은 동일한 들여쓰기 수준을 사용해야 한다.

#### 잘못된 예시

```yaml
application:
  name: my-app
   version: 1.0.0
```

`name`과 `version`의 들여쓰기가 다르다.

#### 올바른 예시

```yaml
application:
  name: my-app
  version: "1.0.0"
```

또한 `version`은 숫자가 아니라 버전 문자열로 관리하는 경우가 많으므로 따옴표로 감싸는 것이 안전하다.

---

### Mapping을 한 줄로 표현하는 Flow Style

YAML은 들여쓰기를 사용하는 Block Style 외에도 중괄호를 사용하는 Flow Style을 지원한다.

예를 들어 다음 Mapping이 있다고 가정하자.

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd
```

이 데이터는 다음과 같이 한 줄로 작성할 수도 있다.

```yaml
{name: 홍길동, age: 30, favorite: {food: Steak, musician: The Weeknd}}
```

두 YAML은 동일한 데이터 구조를 표현한다.

#### Block Style

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd
```

#### Flow Style

```yaml
{name: 홍길동, age: 30, favorite: {food: Steak, musician: The Weeknd}}
```

이러한 표현 방식은 JSON과 유사하다.

JSON에서는 객체를 중괄호로 표현한다.

```json
{
  "name": "홍길동",
  "age": 30,
  "favorite": {
    "food": "Steak",
    "musician": "The Weeknd"
  }
}
```

하지만 YAML의 Flow Style은 JSON과 완전히 동일하지는 않다.

YAML에서는 일반적인 Key와 문자열 값의 따옴표를 생략할 수 있다.

또한 Flow Style에서도 Mapping은 중괄호(`{}`)로 표현하고, Sequence는 대괄호(`[]`)로 표현한다.

#### Block Style과 Flow Style 비교

| 구분 | Block Style | Flow Style |
|---|---|---|
| Mapping 표현 | 들여쓰기 | `{}` |
| 데이터 구분 | 줄바꿈과 들여쓰기 | 쉼표 |
| 가독성 | 중첩 구조에 유리 | 간단한 구조에 유리 |
| 작성 방식 | 여러 줄 | 한 줄 또는 여러 줄 |
| 대표 사용처 | Kubernetes Manifest, 설정 파일 | 짧은 Mapping, 간단한 값 |

실무에서는 계층이 복잡한 Kubernetes Manifest를 작성할 때 Block Style을 주로 사용한다.

반면 단순한 값 목록이나 짧은 Mapping은 Flow Style로 작성해도 무방하다.

예를 들어 다음처럼 사용할 수 있다.

```yaml
labels: {app: nginx, environment: production}
```

이는 다음 구조와 동일하다.

```yaml
labels:
  app: nginx
  environment: production
```

---

### YAML의 Block Style과 Flow Style을 혼합할 수 있을까?

YAML은 두 가지 표현 방식을 혼합해서 사용할 수 있다.

예를 들어 다음과 같이 작성할 수 있다.

```yaml
application:
  name: payment-service

  database:
    host: localhost
    port: 3306

  labels: {team: backend, environment: production}

  profiles: [dev, staging, production]
```

여기서 `application`과 `database`는 Block Style의 Mapping이다.

반면 `labels`는 Flow Style의 Mapping이다.

`profiles`는 대괄호를 사용한 Flow Style의 Sequence이다.

이처럼 YAML은 표현 방식이 달라도 동일한 데이터 모델로 해석할 수 있다.

다만 하나의 파일에서 여러 표현 방식을 지나치게 혼합하면 가독성이 떨어질 수 있다.

따라서 실무에서는 기본적으로 Block Style을 사용하고, 짧은 설정에만 Flow Style을 사용하는 방법이 적절하다.

---

### YAML 문서의 시작을 나타내는 `---`

YAML에서는 하이픈 세 개(`---`)를 사용해 문서의 시작을 나타낼 수 있다.

다음 예시를 살펴보자.

```yaml
---
name: 홍길동
age: 30
```

여기서 `---`는 새로운 YAML 문서가 시작된다는 의미이다.

다만 중요한 점이 있다.

**모든 YAML 파일이 반드시 `---`로 시작해야 하는 것은 아니다.**

다음 YAML도 정상적인 YAML 문서이다.

```yaml
name: 홍길동
age: 30
```

따라서 `---`는 선택적으로 사용할 수 있는 문서 시작 표시이다.

특히 하나의 파일에 여러 YAML 문서를 작성할 때 유용하다.

---

### 하나의 파일에 여러 YAML 문서 작성하기

하나의 YAML 파일에 서로 다른 문서를 작성하려면 `---`를 사용하여 구분할 수 있다.

예를 들어 다음과 같은 YAML 파일을 작성한다고 가정하자.

**people.yaml**

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd

---
name: 김철수
age: 28

favorite:
  food: Pizza
  musician: Coldplay
```

이 파일에는 두 개의 YAML 문서가 들어 있다.

첫 번째 문서는 홍길동에 대한 정보이다.

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd
```

두 번째 문서는 김철수에 대한 정보이다.

```yaml
name: 김철수
age: 28

favorite:
  food: Pizza
  musician: Coldplay
```

두 문서는 같은 파일에 존재하지만 별개의 YAML 문서로 해석된다.

```mermaid
flowchart TD
    A["people.yaml"] --> B["Document 1"]
    A --> C["Document 2"]

    B --> D["name: 홍길동"]
    B --> E["age: 30"]
    B --> F["favorite"]

    C --> G["name: 김철수"]
    C --> H["age: 28"]
    C --> I["favorite"]
```

참고로 YAML은 문서의 끝을 명시하기 위한 `...` 표시도 지원한다.

```yaml
---
name: 홍길동
age: 30
...
```

하지만 일반적인 설정 파일에서는 문서 종료 표시를 생략하는 경우가 많다.

#### Kubernetes에서의 활용

Kubernetes에서는 하나의 파일에 여러 리소스를 정의할 때 `---`를 자주 사용한다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  APP_ENV: production

---
apiVersion: v1
kind: Service
metadata:
  name: app-service
spec:
  selector:
    app: my-app
  ports:
    - port: 80
      targetPort: 8080
```

이 파일에는 ConfigMap과 Service라는 두 개의 Kubernetes 리소스가 정의되어 있다.

다음 명령어를 실행하면 두 리소스를 함께 적용할 수 있다.

```bash
kubectl apply -f application.yaml
```

예상 출력:

```text
configmap/app-config created
service/app-service created
```

이처럼 YAML의 다중 문서 기능은 Kubernetes 리소스들을 하나의 파일로 관리할 때 유용하다.

---

### YAML의 문자열 표현 방식

YAML에서 가장 많이 사용하는 데이터 타입 중 하나는 문자열(String)이다.

문자열은 기본적으로 다음과 같이 작성할 수 있다.

```yaml
name: 홍길동
title: Happy
```

YAML에서는 일반적인 문자열을 작성할 때 큰따옴표나 작은따옴표를 생략할 수 있다.

하지만 필요하다면 다음과 같이 명시적으로 작성할 수도 있다.

```yaml
name: "홍길동"
title: 'Happy'
```

세 가지 표현 방식을 비교하면 다음과 같다.

```yaml
name1: 홍길동
name2: "홍길동"
name3: '홍길동'
```

세 값은 모두 문자열로 해석할 수 있다.

다만 따옴표의 종류에 따라 이스케이프 문자와 특수문자를 처리하는 규칙에는 차이가 있다.

| 표현 방식 | 특징 |
|---|---|
| 따옴표 없음 | 간결하지만 일부 특수문자와 타입 해석에 주의 |
| 큰따옴표 | `\n`, `\"` 등의 이스케이프 표현 지원 |
| 작은따옴표 | 대부분의 문자를 문자 그대로 표현 |

예를 들어 문자열에 `:`과 공백이 포함된다면 다음처럼 따옴표를 사용하는 것이 안전하다.

```yaml
message: "Hello: Kubernetes"
```

반대로 다음과 같이 작성하면 Mapping 구분 기호와 충돌할 수 있다.

```yaml
message: Hello: Kubernetes
```

따라서 문자열에 YAML의 특수문자가 포함되어 있다면 따옴표 사용을 고려해야 한다.

---

### 여러 줄 문자열을 표현하는 Literal Block Scalar

YAML에서는 긴 문자열을 여러 줄로 표현할 수 있다.

대표적으로 파이프(`|`)를 사용하는 방식이 있다.

이를 **Literal Block Scalar**라고 한다.

예를 들어 다음과 같은 문장을 저장한다고 가정하자.

```text
Kubernetes is an open-source system.
It helps manage containerized applications.
It supports automated deployment and scaling.
```

이 문자열을 YAML로 작성하면 다음과 같다.

```yaml
description: |
  Kubernetes is an open-source system.
  It helps manage containerized applications.
  It supports automated deployment and scaling.
```

여기서 `|`는 줄바꿈을 유지하는 여러 줄 문자열을 의미한다.

따라서 파싱된 문자열에도 줄바꿈이 포함된다.

```text
Kubernetes is an open-source system.\n
It helps manage containerized applications.\n
It supports automated deployment and scaling.\n
```

이를 구조적으로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["YAML 문자열"] --> B["Literal Style"]
    B --> C["줄바꿈 유지"]
    C --> D["여러 줄 문자열 생성"]
```

이 방식은 다음과 같은 데이터를 표현할 때 유용하다.

- 긴 설명
- Shell Script
- SQL 문장
- 이메일 본문
- 인증서
- 여러 줄로 구성된 애플리케이션 설정

#### Kubernetes ConfigMap에서 활용하기

예를 들어 ConfigMap에 여러 줄 설정을 저장할 수 있다.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: application-config

data:
  application.yml: |
    server:
      port: 8080

    spring:
      application:
        name: payment-service

    logging:
      level:
        root: INFO
```

여기서 `application.yml`의 Value는 여러 줄로 구성된 문자열이다.

ConfigMap은 이 문자열을 저장하며, 이를 Volume으로 마운트하는 등의 방식으로 애플리케이션에 전달할 수 있다.

이처럼 YAML의 Literal Block Scalar는 Kubernetes에서 여러 줄 설정 파일을 저장할 때 자주 활용된다.

---

### 여러 줄로 작성하지만 하나의 문장으로 해석하는 Folded Block Scalar

YAML에는 여러 줄로 작성한 문자열을 하나의 문장처럼 해석하는 기능도 있다.

이를 **Folded Block Scalar**라고 하며, 꺾쇠(`>`)를 사용한다.

예를 들어 다음과 같이 작성할 수 있다.

```yaml
description: >
  Kubernetes is an open-source system.
  It helps manage containerized applications.
  It supports automated deployment and scaling.
```

이 경우 일반적인 줄바꿈은 공백으로 변환된다.

따라서 최종 문자열은 다음과 같이 해석된다.

```text
Kubernetes is an open-source system. It helps manage containerized applications. It supports automated deployment and scaling.\n
```

파일에서는 여러 줄로 작성했지만 실제 문자열은 하나의 문장처럼 연결된다.

```mermaid
flowchart TD
    A["여러 줄로 작성된 문자열"] --> B["Folded Style"]
    B --> C["일반 줄바꿈을 공백으로 변환"]
    C --> D["하나의 문장처럼 연결"]
```

단, 모든 줄바꿈이 무조건 공백으로 변환되는 것은 아니다.

빈 줄이나 더 깊게 들여쓰기된 줄 등에서는 별도의 규칙이 적용된다.

#### Literal과 Folded 비교

다음 두 YAML을 비교해보자.

**Literal Style**

```yaml
message: |
  Hello
  Kubernetes
  YAML
```

파싱 결과:

```text
Hello\nKubernetes\nYAML\n
```

**Folded Style**

```yaml
message: >
  Hello
  Kubernetes
  YAML
```

파싱 결과:

```text
Hello Kubernetes YAML\n
```

두 방식의 차이는 다음과 같다.

| 구분 | `\|` | `>` |
|---|---|---|
| 명칭 | Literal Block Scalar | Folded Block Scalar |
| 줄바꿈 | 유지 | 일반 줄바꿈을 공백으로 변환 |
| 목적 | 여러 줄 문자열 보존 | 긴 문자열을 읽기 쉽게 나누어 작성 |
| 주요 활용 | Script, 인증서, 설정 파일 | 긴 설명, 문장 |
| 기본 마지막 줄바꿈 | 유지 | 유지 |

---

### `|-`, `>-`와 마지막 줄바꿈 처리

YAML에서 `|`와 `>`를 사용할 때 추가로 알아두면 좋은 문법이 있다.

바로 `-`와 `+`를 이용한 Chomping Indicator이다.

이 기능은 여러 줄 문자열의 마지막 줄바꿈을 어떻게 처리할지 결정한다.

#### 기본 동작

```yaml
message: |
  Hello
  Kubernetes
```

일반적으로 마지막 줄바꿈 하나가 유지된다.

```text
Hello\nKubernetes\n
```

#### `|-`: 마지막 줄바꿈 제거

```yaml
message: |-
  Hello
  Kubernetes
```

파싱 결과:

```text
Hello\nKubernetes
```

마지막 줄바꿈이 제거된다.

#### `|+`: 마지막 빈 줄까지 유지

```yaml
message: |+
  Hello
  Kubernetes


```

마지막에 존재하는 빈 줄과 줄바꿈을 유지한다.

#### `>-`: 줄바꿈을 접고 마지막 줄바꿈 제거

```yaml
message: >-
  Hello
  Kubernetes
```

파싱 결과:

```text
Hello Kubernetes
```

이를 정리하면 다음과 같다.

| 문법 | 동작 |
|---|---|
| `\|` | 내부 줄바꿈 유지, 마지막 줄바꿈 하나 유지 |
| `\|-` | 내부 줄바꿈 유지, 마지막 줄바꿈 제거 |
| `\|+` | 내부 줄바꿈 유지, 마지막 빈 줄들도 보존 |
| `>` | 일반 줄바꿈 접기, 마지막 줄바꿈 하나 유지 |
| `>-` | 일반 줄바꿈 접기, 마지막 줄바꿈 제거 |
| `>+` | 일반 줄바꿈 접기, 마지막 빈 줄들도 보존 |

실무에서는 문자열의 마지막 줄바꿈이 중요하지 않은 경우도 많다.

하지만 Shell Script, 인증서, 특정 문자열 비교처럼 정확한 문자열 내용이 중요한 경우에는 이러한 차이를 알아두는 것이 좋다.

---

### YAML에서 Null 표현하기

프로그램에서 데이터를 처리하다 보면 특정 값이 존재하지 않는 상황이 발생한다.

예를 들어 사용자의 경력 정보가 아직 입력되지 않았다고 가정하자.

```text
name: 홍길동
age: 30
experience: 값 없음
```

이처럼 값이 없다는 사실을 표현할 때 Null을 사용할 수 있다.

YAML에서는 여러 방식으로 Null을 표현할 수 있다.

#### 1. `null` 사용

```yaml
experience: null
```

#### 2. `~` 사용

```yaml
experience: ~
```

#### 3. Value 생략

```yaml
experience:
```

이 세 가지는 일반적인 YAML 해석에서 Null 값을 나타낼 수 있다.

다만 명확한 설정 파일을 작성할 때는 `null`을 명시하는 방식이 이해하기 쉬운 경우가 많다.

---

### Null과 빈 문자열은 다르다

Null과 빈 문자열은 서로 다른 값이다.

다음 YAML을 살펴보자.

```yaml
experience: null
nickname: ""
description: "null"
```

세 값은 서로 다르다.

| Key | Value | 의미 |
|---|---|---|
| `experience` | `null` | 값이 없음 |
| `nickname` | `""` | 길이가 0인 문자열 |
| `description` | `"null"` | null이라는 글자로 이루어진 문자열 |

Java 코드로 표현하면 다음과 비슷하다.

```java
String experience = null;
String nickname = "";
String description = "null";
```

여기서 `experience`는 Null이다.

반면 `nickname`은 비어 있지만 실제로 존재하는 문자열이다.

또한 `description`은 `null`이라는 문자열을 가지고 있다.

이 차이는 애플리케이션의 설정이나 데이터 역직렬화에서 중요하다.

예를 들어 어떤 설정이 Null인지, 빈 문자열인지에 따라 검증 결과나 기본값 적용 방식이 달라질 수 있다.

---

### Null과 Key가 존재하지 않는 상태도 다르다

다음 두 YAML을 비교해보자.

**Key가 존재하지만 Value가 Null인 경우**

```yaml
name: 홍길동
experience: null
```

**Key 자체가 존재하지 않는 경우**

```yaml
name: 홍길동
```

첫 번째 YAML에는 `experience`라는 Key가 존재한다.

하지만 Value는 Null이다.

두 번째 YAML에는 `experience`라는 Key 자체가 존재하지 않는다.

이러한 차이는 설정을 병합하거나 API 요청을 처리할 때 중요할 수 있다.

예를 들어 부분 수정 API에서 다음과 같은 의미를 구분하도록 설계할 수 있다.

```text
experience 필드 없음
→ 기존 값 유지

experience: null
→ 기존 값 제거
```

물론 실제 동작은 애플리케이션의 API 계약과 구현 방식에 따라 달라진다.

YAML 자체가 이러한 비즈니스 규칙을 정의하는 것은 아니다.

하지만 YAML은 두 상태를 서로 다른 데이터 구조로 표현할 수 있다.

---

### YAML의 Boolean 표현 방식

Boolean은 참과 거짓을 나타내는 데이터 타입이다.

YAML에서도 Boolean 값을 표현할 수 있다.

가장 일반적인 표현 방식은 다음과 같다.

```yaml
vaccinated: true
result: false
```

여기서 `vaccinated`는 `true`이다.

`result`는 `false`이다.

이 값들은 문자열이 아니라 Boolean 타입으로 해석할 수 있다.

#### Boolean은 첫 글자를 대문자로 작성해야 할까?

반드시 그렇지는 않다.

YAML 1.2의 Core Schema에서는 다음과 같은 표현을 Boolean으로 인식한다.

```yaml
value1: true
value2: True
value3: TRUE

value4: false
value5: False
value6: FALSE
```

따라서 `True`나 `False`처럼 첫 글자를 대문자로 작성해야만 Boolean이 되는 것은 아니다.

다만 **실무에서는 소문자인 `true`와 `false`를 사용하는 것이 가장 일관되고 안전하다.**

JSON에서도 Boolean은 소문자인 `true`, `false`로 표현하며, Kubernetes Manifest에서도 일반적으로 같은 표기를 사용한다.

```yaml
enabled: true
debug: false
```

또한 다음 값들은 문자열과 구분해야 한다.

```yaml
enabled: "true"
debug: "false"
```

따옴표로 감싸면 Boolean이 아니라 문자열이 된다.

---

### YAML 1.1과 YAML 1.2의 Boolean 차이

YAML의 Boolean을 이해할 때 한 가지 더 주의할 사항이 있다.

YAML 버전과 파서에 따라 특정 값의 해석 방식이 달라질 수 있다.

예를 들어 YAML 1.1 계열에서는 다음과 같은 값을 Boolean으로 해석하는 파서가 있다.

```yaml
enabled: yes
disabled: no

featureOn: on
featureOff: off
```

하지만 YAML 1.2 Core Schema에서는 이러한 값들을 일반적으로 문자열로 해석한다.

| 값 | YAML 1.1 계열의 일부 파서 | YAML 1.2 Core Schema |
|---|---|---|
| `true` | Boolean | Boolean |
| `false` | Boolean | Boolean |
| `yes` | Boolean으로 해석 가능 | String |
| `no` | Boolean으로 해석 가능 | String |
| `on` | Boolean으로 해석 가능 | String |
| `off` | Boolean으로 해석 가능 | String |

이 차이는 실제 설정 오류로 이어질 수 있다.

예를 들어 다음 설정을 작성했다고 가정하자.

```yaml
countryCode: NO
```

개발자의 의도는 노르웨이를 의미하는 국가 코드 `NO`를 문자열로 저장하는 것일 수 있다.

하지만 일부 YAML 1.1 계열 파서는 이를 Boolean으로 해석할 수 있다.

이러한 문제를 방지하려면 다음과 같이 작성하는 것이 안전하다.

```yaml
countryCode: "NO"
```

따라서 문자열과 Boolean이 혼동될 수 있는 값은 명확하게 구분하는 것이 좋다.

---

### yq를 이용해 YAML 데이터 파싱하기

이제 앞에서 작성한 YAML을 실제로 파싱해보자.

여기서는 Mike Farah의 yq v4 계열을 기준으로 사용한다.

yq는 YAML 데이터를 구조적으로 조회하고 수정할 수 있는 CLI 도구이다.

먼저 다음 YAML 파일을 작성한다.

**person.yaml**

```yaml
name: 홍길동
age: 30

favorite:
  food: Steak
  musician: The Weeknd

experience: null
vaccinated: true
result: false
```

파일을 저장한 뒤 yq로 내용을 확인한다.

```bash
yq '.' person.yaml
```

여기서 `.`은 YAML 문서 전체를 선택한다는 의미이다.

예상 출력:

```yaml
name: 홍길동
age: 30
favorite:
  food: Steak
  musician: The Weeknd
experience: null
vaccinated: true
result: false
```

이제 특정 필드를 조회해보자.

---

### yq로 Mapping의 특정 값 조회하기

사용자 이름을 조회하려면 다음 명령어를 사용한다.

```bash
yq '.name' person.yaml
```

출력:

```text
홍길동
```

나이를 조회한다.

```bash
yq '.age' person.yaml
```

출력:

```text
30
```

중첩된 Mapping에 접근하려면 점(`.`)을 사용하여 경로를 이어서 작성한다.

```bash
yq '.favorite.food' person.yaml
```

출력:

```text
Steak
```

좋아하는 음악가를 조회한다.

```bash
yq '.favorite.musician' person.yaml
```

출력:

```text
The Weeknd
```

이러한 경로 표현식은 Java 객체에서 중첩된 필드에 접근하는 개념과 비슷하게 이해할 수 있다.

```text
person.favorite.food
```

YAML에서는 해당 경로를 다음과 같이 표현한다.

```text
.favorite.food
```

중첩 구조가 깊어져도 같은 방식으로 접근할 수 있다.

---

### yq로 데이터 타입 확인하기

yq에서는 `tag` 연산자를 사용해 YAML 값의 타입을 확인할 수 있다.

예를 들어 다음 명령어를 실행한다.

```bash
yq '.name | tag' person.yaml
```

출력:

```text
!!str
```

문자열이라는 의미이다.

나이의 타입을 확인한다.

```bash
yq '.age | tag' person.yaml
```

출력:

```text
!!int
```

정수라는 의미이다.

Boolean 타입을 확인한다.

```bash
yq '.vaccinated | tag' person.yaml
```

출력:

```text
!!bool
```

Null 타입을 확인한다.

```bash
yq '.experience | tag' person.yaml
```

출력:

```text
!!null
```

주요 타입은 다음과 같다.

| 타입 태그 | 의미 |
|---|---|
| `!!str` | 문자열 |
| `!!int` | 정수 |
| `!!float` | 실수 |
| `!!bool` | Boolean |
| `!!null` | Null |
| `!!map` | Mapping |
| `!!seq` | Sequence |

이 기능은 YAML을 작성했을 때 값이 의도한 타입으로 해석되는지 확인하는 데 유용하다.

특히 `true`, `"true"`, `null`, `"null"`처럼 화면에서는 비슷하게 보이는 값의 차이를 확인할 수 있다.

---

### yq의 select를 이용한 조건 검색

yq에서는 `select`를 사용해 특정 조건을 만족하는 데이터만 선택할 수 있다.

예를 들어 다음 YAML을 사용한다고 가정하자.

```yaml
name: 홍길동
age: 30
vaccinated: true
result: false
```

여기서 `result`는 단순한 Boolean 데이터이다.

실제 서비스에서는 `false`가 어떤 업무적 의미를 가지는지 별도로 정의해야 하지만, 여기서는 조건 검색을 위한 값으로 사용한다.

#### result가 false가 아닌 경우

다음 명령어를 실행한다.

```bash
yq 'select(.result != false)' person.yaml
```

이 명령어는 다음 조건을 검사한다.

```text
result != false
```

즉 `result`의 값이 Boolean `false`와 다르면 문서를 출력한다.

하지만 현재 데이터는 다음과 같다.

```yaml
result: false
```

따라서 조건을 만족하지 않는다.

결과적으로 출력되는 내용이 없다.

```text
출력 없음
```

여기서 중요한 점은 **조건에 일치하는 데이터가 없어서 아무것도 출력되지 않았다는 것**이다.

단순히 출력이 비었다는 사실만으로 YAML 파싱에 실패했다고 판단해서는 안 된다.

---

### result가 false인 경우만 조회하기

이번에는 조건을 반대로 변경해보자.

```bash
yq 'select(.result == false)' person.yaml
```

이 명령어는 다음 조건을 검사한다.

```text
result == false
```

현재 YAML에서는 `result`가 `false`이므로 조건을 만족한다.

따라서 문서 전체가 출력된다.

```yaml
name: 홍길동
age: 30
vaccinated: true
result: false
```

`select`는 조건을 만족하는 데이터를 선택하는 역할을 한다.

여기서는 입력 문서의 최상위 Mapping에 조건을 적용했기 때문에 조건을 만족하면 문서 전체가 출력된다.

반대로 조건을 만족하지 않으면 아무것도 출력되지 않는다.

---

### 조건을 만족하는 경우 특정 필드만 출력하기

조건을 만족하는 문서 전체가 아니라 특정 값만 조회하고 싶을 수도 있다.

예를 들어 `result`가 `false`일 때 `vaccinated` 값만 확인한다고 가정하자.

```bash
yq 'select(.result == false) | .vaccinated' person.yaml
```

출력:

```text
true
```

이 명령어는 다음 두 단계를 수행한다.

**첫 번째 단계**

```text
select(.result == false)
```

현재 문서의 `result`가 `false`인지 확인한다.

**두 번째 단계**

```text
.vaccinated
```

조건을 만족하는 문서에서 `vaccinated` 값을 추출한다.

```mermaid
flowchart TD
    A["person.yaml"] --> B["result 값 확인"]
    B --> C{"result == false"}

    C -->|"아니오"| D["출력 없음"]
    C -->|"예"| E["vaccinated 필드 조회"]

    E --> F["true 출력"]
```

이처럼 `select`와 경로 표현식을 조합하면 특정 조건을 만족하는 데이터에서 필요한 값만 추출할 수 있다.

---

### 여러 YAML 문서에서 조건에 맞는 데이터 검색하기

앞에서는 하나의 YAML 문서를 대상으로 조건을 검사했다.

이번에는 여러 YAML 문서를 포함하는 파일에서 조건에 맞는 데이터를 추출해보자.

**people.yaml**

```yaml
---
name: 홍길동
age: 30
vaccinated: true
result: false

---
name: 김철수
age: 28
vaccinated: false
result: true

---
name: 이영희
age: 32
vaccinated: true
result: false
```

이 파일에는 세 개의 YAML 문서가 있다.

각 문서의 값은 다음과 같다.

| 이름 | vaccinated | result |
|---|---|---|
| 홍길동 | true | false |
| 김철수 | false | true |
| 이영희 | true | false |

여기서 `result`가 `false`인 사람의 이름만 조회해보자.

```bash
yq 'select(.result == false) | .name' people.yaml
```

출력:

```text
홍길동
---
이영희
```

yq는 여러 YAML 문서에서 조건에 맞는 결과를 출력할 때 문서 구분 기호를 함께 표시할 수 있다.

이처럼 문서마다 별도의 조건을 검사할 수 있다.

#### vaccinated가 true인 사람 조회

```bash
yq 'select(.vaccinated == true) | .name' people.yaml
```

예상 출력:

```text
홍길동
---
이영희
```

#### 두 조건을 모두 만족하는 경우

이번에는 `result`가 `false`이면서 `vaccinated`가 `true`인 경우만 조회해보자.

```bash
yq 'select(.result == false and .vaccinated == true) | .name' people.yaml
```

예상 출력:

```text
홍길동
---
이영희
```

여기서 `and`는 두 조건을 모두 만족해야 한다는 의미이다.

반대로 둘 중 하나만 만족해도 조회하고 싶다면 `or`를 사용할 수 있다.

```bash
yq 'select(.result == false or .vaccinated == true) | .name' people.yaml
```

이처럼 yq를 활용하면 YAML 파일에서도 조건 검색을 수행할 수 있다.

---

### YAML의 Null을 yq로 검사하기

앞에서 Null을 여러 방식으로 표현할 수 있다는 점을 살펴보았다.

이번에는 yq를 사용해 실제로 Null인지 확인해보자.

**null-example.yaml**

```yaml
name: 홍길동

experience: null
nickname: ""
description: "null"
```

먼저 `experience`가 Null인지 확인한다.

```bash
yq '.experience == null' null-example.yaml
```

출력:

```text
true
```

`nickname`이 Null인지 확인한다.

```bash
yq '.nickname == null' null-example.yaml
```

출력:

```text
false
```

`nickname`은 빈 문자열이기 때문이다.

`description`이 Null인지 확인한다.

```bash
yq '.description == null' null-example.yaml
```

출력:

```text
false
```

`description`에는 `"null"`이라는 문자열이 저장되어 있다.

이처럼 yq를 이용하면 데이터의 타입과 값에 따라 조건을 검사할 수 있다.

다만 존재하지 않는 Key를 조회했을 때도 Null과 유사한 결과가 나타날 수 있다.

따라서 실제 Key의 존재 여부까지 확인하려면 `has` 같은 연산자를 추가로 사용하는 것이 좋다.

```bash
yq 'has("experience")' null-example.yaml
```

출력:

```text
true
```

반면 존재하지 않는 필드를 조회하면 다음과 같다.

```bash
yq 'has("address")' null-example.yaml
```

출력:

```text
false
```

이는 Null 값과 Key의 부재를 구분할 때 유용하다.

---

### yq로 특정 문서만 조회하기

YAML 파일에 여러 문서가 포함되어 있다면 문서의 순서를 기준으로 특정 문서를 조회할 수도 있다.

예를 들어 앞서 작성한 `people.yaml`을 사용한다고 가정하자.

```yaml
---
name: 홍길동
age: 30

---
name: 김철수
age: 28

---
name: 이영희
age: 32
```

문서의 인덱스는 0부터 시작한다.

```text
Document 0 → 홍길동
Document 1 → 김철수
Document 2 → 이영희
```

두 번째 문서를 조회하려면 다음 명령어를 사용한다.

```bash
yq 'select(document_index == 1)' people.yaml
```

출력:

```yaml
name: 김철수
age: 28
```

`document_index`는 현재 YAML 문서의 인덱스를 나타낸다.

`di`라는 축약 표현도 사용할 수 있다.

```bash
yq 'select(di == 1)' people.yaml
```

이를 통해 다중 문서 YAML 파일에서 특정 위치의 문서만 추출할 수 있다.

다만 운영 환경에서 문서 순서가 변경될 가능성이 있다면 인덱스보다 `metadata.name` 같은 명시적인 식별자를 기준으로 검색하는 편이 안정적이다.

---

### YAML 문법이 올바른지 검증하기

YAML은 사람이 읽기 쉬운 형식이지만 들여쓰기나 특수문자 사용이 잘못되면 파싱 오류가 발생할 수 있다.

따라서 작성한 YAML 파일을 실제로 사용하기 전에 문법을 검증하는 것이 좋다.

검증 방법에는 여러 가지가 있다.

#### 1. yq를 이용한 파싱 확인

다음 명령어를 실행한다.

```bash
yq '.' person.yaml
```

문법이 정상적이라면 YAML 내용이 출력된다.

반면 문법이 잘못되었다면 오류가 발생할 수 있다.

예를 들어 다음 YAML은 들여쓰기가 잘못되어 있다.

```yaml
person:
  name: 홍길동
   age: 30
```

이런 경우 yq가 YAML을 파싱하는 과정에서 오류를 반환할 수 있다.

명령어의 종료 코드도 확인할 수 있다.

```bash
yq '.' person.yaml > /dev/null

echo $?
```

정상적으로 파싱되었다면 일반적으로 다음과 같이 출력된다.

```text
0
```

오류가 발생했다면 0이 아닌 종료 코드가 나타난다.

#### 2. yamllint를 이용한 문법과 스타일 검증

`yamllint`는 YAML 파일의 문법과 스타일을 검사하는 도구이다.

설치되어 있다면 다음과 같이 사용할 수 있다.

```bash
yamllint person.yaml
```

문법 오류뿐 아니라 들여쓰기와 같은 스타일 문제도 확인할 수 있다.

다만 yamllint의 규칙은 설정에 따라 달라질 수 있다.

예를 들어 파일 시작 부분에 `---`를 작성하도록 권장하는 규칙이 활성화되어 있을 수 있다.

이 경우 YAML 규격상 `---`가 필수가 아니더라도 스타일 경고가 나타날 수 있다.

따라서 **YAML 문법 자체의 요구사항과 특정 Linter의 스타일 규칙을 구분해야 한다.**

#### 3. Kubernetes API 검증

Kubernetes Manifest라면 YAML 문법만 확인해서는 충분하지 않다.

예를 들어 다음 YAML을 살펴보자.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: nginx
spec:
  containers:
    - name: nginx
      image: nginx:1.27
```

이 파일은 YAML 문법에 맞게 작성되었다.

하지만 실제 Kubernetes에 적용할 때는 Kubernetes API가 요구하는 구조도 올바른지 확인해야 한다.

이를 위해 다음 명령어를 사용할 수 있다.

```bash
kubectl apply --dry-run=server -f pod.yaml
```

이 명령어는 API Server를 통해 적용 가능 여부를 확인하지만 실제로 리소스를 저장하지는 않는다.

단, 서버 측 Dry Run이 지원되는 클러스터 환경과 적절한 권한이 필요하다.

또한 Dry Run이 성공했다고 해서 실제 Pod가 정상적으로 스케줄링되고 컨테이너가 실행된다는 사실까지 보장하는 것은 아니다.

검증 단계는 다음과 같이 구분할 수 있다.

| 검증 단계 | 확인 내용 |
|---|---|
| YAML Parser | YAML 문법이 올바른가? |
| YAML Linter | 들여쓰기와 스타일 규칙을 준수하는가? |
| Kubernetes API 검증 | 리소스의 API 구조와 필드가 유효한가? |
| 실제 배포 검증 | Pod가 정상적으로 생성되고 실행되는가? |

이러한 검증 과정을 분리하면 설정 오류의 원인을 빠르게 파악할 수 있다.

---

### Kubernetes에서 Mapping을 활용하는 방법

지금까지 살펴본 Mapping 구조는 Kubernetes Manifest에서도 매우 중요하다.

예를 들어 다음 Deployment를 살펴보자.

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: payment-service

  labels:
    app: payment-service
    team: backend

spec:
  replicas: 3

  selector:
    matchLabels:
      app: payment-service

  template:
    metadata:
      labels:
        app: payment-service

    spec:
      containers:
        - name: payment-service
          image: nginx:1.27

          ports:
            - containerPort: 80

          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"

            limits:
              cpu: "500m"
              memory: "256Mi"
```

이 YAML에는 Mapping과 Sequence가 함께 사용되고 있다.

먼저 다음 부분을 살펴보자.

```yaml
metadata:
  name: payment-service

  labels:
    app: payment-service
    team: backend
```

`metadata`는 Mapping이다.

`labels`도 Mapping이다.

반면 다음 부분을 살펴보자.

```yaml
containers:
  - name: payment-service
    image: nginx:1.27
```

`containers`는 Sequence이다.

Sequence의 첫 번째 요소는 `name`과 `image`라는 Key를 포함하는 Mapping이다.

```mermaid
flowchart TD
    A["Deployment"] --> B["metadata"]
    A --> C["spec"]

    B --> D["name"]
    B --> E["labels"]

    C --> F["replicas"]
    C --> G["template"]

    G --> H["spec"]
    H --> I["containers"]

    I --> J["Container Mapping"]
    J --> K["name"]
    J --> L["image"]
    J --> M["resources"]
```

이처럼 Kubernetes Manifest는 Mapping 안에 Mapping이 들어가고, 그 안에 Sequence가 포함되는 구조가 반복된다.

따라서 YAML의 Mapping과 Sequence를 정확하게 이해하면 Kubernetes Manifest의 복잡한 구조도 쉽게 분석할 수 있다.

---

### Kubernetes Manifest에서 yq 활용하기

실제 Kubernetes Manifest에서는 특정 설정을 확인하거나 수정할 때 yq를 사용할 수 있다.

예를 들어 앞서 작성한 Deployment를 `deployment.yaml`로 저장했다고 가정하자.

#### Deployment 이름 확인

```bash
yq '.metadata.name' deployment.yaml
```

출력:

```text
payment-service
```

#### replicas 확인

```bash
yq '.spec.replicas' deployment.yaml
```

출력:

```text
3
```

#### 컨테이너 이미지 확인

```bash
yq '.spec.template.spec.containers[0].image' deployment.yaml
```

출력:

```text
nginx:1.27
```

#### CPU requests 확인

```bash
yq '.spec.template.spec.containers[0].resources.requests.cpu' deployment.yaml
```

출력:

```text
100m
```

#### Memory limits 확인

```bash
yq '.spec.template.spec.containers[0].resources.limits.memory' deployment.yaml
```

출력:

```text
256Mi
```

이러한 경로를 보면 Kubernetes Manifest가 얼마나 많은 Mapping과 Sequence로 이루어져 있는지 확인할 수 있다.

특히 다음 부분을 이해하는 것이 중요하다.

```text
.spec.template.spec.containers[0].resources.requests.cpu
```

각 요소의 의미는 다음과 같다.

| 경로 | 의미 |
|---|---|
| `.spec` | Deployment의 원하는 상태 |
| `.template` | Pod Template |
| `.spec` | Pod의 실행 설정 |
| `.containers` | 컨테이너 목록 |
| `[0]` | 첫 번째 컨테이너 |
| `.resources` | 컨테이너 자원 설정 |
| `.requests` | 요청 자원 |
| `.cpu` | CPU requests 값 |

이처럼 YAML의 계층 구조를 이해하면 길고 복잡한 설정도 경로 단위로 분석할 수 있다.

---

### Spring Boot에서 Mapping을 활용하는 방법

Spring Boot에서도 YAML Mapping 구조를 자주 사용한다.

예를 들어 다음과 같은 설정이 있다고 가정하자.

**application.yml**

```yaml
server:
  port: 8080

spring:
  application:
    name: payment-service

  datasource:
    url: jdbc:mysql://localhost:3306/payment
    username: payment_user
    password: ${DB_PASSWORD}

management:
  endpoints:
    web:
      exposure:
        include: health,info

  endpoint:
    health:
      probes:
        enabled: true
```

이 설정은 여러 단계의 Mapping으로 구성되어 있다.

```text
server
 └── port

spring
 ├── application
 │    └── name
 │
 └── datasource
      ├── url
      ├── username
      └── password

management
 ├── endpoints
 │    └── web
 │         └── exposure
 │              └── include
 │
 └── endpoint
      └── health
           └── probes
                └── enabled
```

Spring Boot는 이러한 설정을 읽어 애플리케이션의 실행 환경을 구성한다.

또한 사용자 정의 설정을 `@ConfigurationProperties`로 바인딩할 수도 있다.

예를 들어 다음 YAML이 있다고 가정하자.

```yaml
payment:
  retry:
    enabled: true
    max-attempts: 3
    delay-ms: 1000
```

이에 대응하는 Java 클래스를 정의할 수 있다.

```java
import org.springframework.boot.context.properties.ConfigurationProperties;

@ConfigurationProperties(prefix = "payment.retry")
public record PaymentRetryProperties(
        boolean enabled,
        int maxAttempts,
        long delayMs
) {
}
```

Spring Boot에서 해당 Configuration Properties가 등록되어 있다면 YAML 값을 Java 객체로 바인딩할 수 있다.

이때 다음 Mapping 경로가 Java 객체의 필드와 연결된다.

```text
payment.retry.enabled       → enabled
payment.retry.max-attempts  → maxAttempts
payment.retry.delay-ms      → delayMs
```

이처럼 YAML의 Mapping 구조는 단순한 텍스트 설정을 넘어 실제 애플리케이션 객체와 연결될 수 있다.

---

### 실무에서 YAML을 작성할 때 고려해야 할 사항

YAML은 비교적 읽기 쉬운 형식이지만 운영 환경에서 사용한다면 몇 가지 원칙을 지키는 것이 좋다.

#### 1. 들여쓰기 규칙을 일관되게 유지한다

공백 2칸을 사용한다면 파일 전체에서 동일한 규칙을 유지하는 것이 좋다.

서로 다른 들여쓰기 폭을 혼합하면 코드 리뷰와 수정 과정에서 실수가 발생하기 쉽다.

#### 2. 중첩 구조를 지나치게 깊게 만들지 않는다

다음과 같이 계층이 지나치게 깊어지면 설정을 이해하기 어렵다.

```yaml
application:
  server:
    connection:
      pool:
        settings:
          timeout:
            value: 30
```

설정 구조가 복잡하다면 불필요한 계층을 줄이거나 관련 설정을 분리할 수 있는지 검토해야 한다.

#### 3. 데이터 타입이 중요한 값에는 따옴표를 명시한다

특히 버전 번호, 국가 코드, 식별자처럼 숫자나 Boolean과 혼동될 수 있는 값은 문자열임을 명시하는 것이 좋다.

```yaml
version: "1.0"
countryCode: "NO"
productCode: "00123"
```

#### 4. Boolean은 소문자로 통일한다

```yaml
enabled: true
debug: false
```

YAML 파서 간의 차이를 줄이고 JSON과의 일관성을 유지하는 데 도움이 된다.

#### 5. Null과 빈 문자열을 구분한다

```yaml
experience: null
nickname: ""
```

두 값은 서로 다르므로 애플리케이션의 비즈니스 규칙에 맞게 사용해야 한다.

#### 6. 여러 줄 문자열의 줄바꿈 정책을 이해한다

Shell Script처럼 줄바꿈이 중요한 경우에는 `|`를 사용한다.

반면 긴 설명을 여러 줄로 나누어 작성하고 싶다면 `>`를 고려할 수 있다.

#### 7. YAML 문법과 애플리케이션 설정 검증을 구분한다

YAML 문법이 정상적이어도 Kubernetes나 Spring Boot에서 허용하지 않는 설정일 수 있다.

따라서 파싱 검증뿐 아니라 애플리케이션별 설정 검증도 함께 수행해야 한다.

#### 8. Mapping의 Key를 중복해서 작성하지 않는다

```yaml
port: 8080
port: 9090
```

위 구조는 동일한 Mapping에 같은 Key가 중복되어 있다.

일부 파서는 오류를 반환하고, 일부 파서는 특정 값을 선택할 수 있으므로 중복 Key를 허용하지 않도록 관리하는 것이 안전하다.

#### 9. 민감한 데이터를 외부 검증 사이트에 붙여 넣지 않는다

YAML 문법을 확인하기 위해 온라인 Linter를 사용할 수 있지만, 운영 환경의 설정 파일에는 데이터베이스 비밀번호나 API Key 등의 민감한 정보가 포함될 수 있다.

따라서 실제 운영 설정은 로컬의 yq, yamllint 또는 조직 내부의 검증 환경을 사용하는 것이 안전하다.

#### 10. YAML의 최종 해석 결과를 확인한다

YAML은 사람이 읽기 쉬운 형식이지만 실제 해석 결과가 작성자의 의도와 다를 수 있다.

예를 들어 `null`, `"null"`, `false`, `"false"`는 서로 다른 데이터 타입이다.

따라서 문제가 발생한다면 단순히 YAML 파일의 문자열만 확인하기보다 yq의 `tag` 연산자 등을 이용해 실제로 해석되는 타입까지 확인하는 것이 효과적이다.

---

### 정리

YAML은 Mapping, Sequence, Scalar라는 기본 데이터 구조를 조합하여 복잡한 데이터를 표현한다.

이 중 Mapping은 Key와 Value를 연결하는 가장 기본적인 구조이다.

Mapping의 Value에는 문자열이나 숫자뿐 아니라 다른 Mapping과 Sequence도 포함할 수 있다.

따라서 YAML은 중첩된 데이터 구조를 자연스럽게 표현할 수 있다.

이번에 살펴본 핵심 문법을 정리하면 다음과 같다.

| 문법 | 의미 | 예시 |
|---|---|---|
| `key: value` | Mapping | `name: Hong` |
| 들여쓰기 | 계층 구조 표현 | `favorite` 아래 `food` |
| `{}` | Flow Style Mapping | `{name: Hong, age: 30}` |
| `[]` | Flow Style Sequence | `[Java, Spring]` |
| `---` | YAML 문서 시작 | 다중 문서 구분 |
| `...` | YAML 문서 종료 | 명시적인 문서 종료 |
| `\|` | 줄바꿈 유지 문자열 | Literal Block Scalar |
| `>` | 줄바꿈을 접는 문자열 | Folded Block Scalar |
| `\|-` | 마지막 줄바꿈 제거 | Literal + Strip |
| `>-` | 줄바꿈 접기 및 마지막 줄바꿈 제거 | Folded + Strip |
| `null` | Null 값 | `experience: null` |
| `~` | Null 값 | `experience: ~` |
| `true` | Boolean 참 | `enabled: true` |
| `false` | Boolean 거짓 | `enabled: false` |
| `#` | 주석 | `# 서버 설정` |

또한 yq를 사용하면 YAML 데이터를 구조적으로 조회하거나 조건에 따라 필터링할 수 있다.

대표적인 명령어는 다음과 같다.

| 명령어 | 의미 |
|---|---|
| `yq '.' file.yaml` | 전체 YAML 조회 |
| `yq '.name' file.yaml` | 특정 Key 조회 |
| `yq '.favorite.food' file.yaml` | 중첩 Mapping 조회 |
| `yq '.age \| tag' file.yaml` | 데이터 타입 확인 |
| `yq 'select(.result == false)' file.yaml` | 조건에 맞는 문서 조회 |
| `yq 'select(.result == false) \| .name' file.yaml` | 조건에 맞는 문서에서 특정 필드 조회 |
| `yq 'select(di == 1)' file.yaml` | 두 번째 YAML 문서 조회 |

YAML의 문법을 이해할 때 중요한 것은 기호를 암기하는 것이 아니라 **실제로 어떤 데이터 구조가 만들어지는지 이해하는 것**이다.

예를 들어 Mapping과 Sequence가 어떻게 중첩되는지, Scalar가 어떤 타입으로 해석되는지, 여러 줄 문자열이 최종적으로 어떤 값을 갖는지를 이해하면 Kubernetes Manifest나 Spring Boot 설정 파일도 더 정확하게 작성할 수 있다.

또한 yq와 같은 도구를 사용하면 YAML을 단순히 눈으로 읽는 수준을 넘어, 실제 데이터 구조와 타입을 검증하고 자동화 작업에 활용할 수 있다.

#### 한 줄 요약

> YAML의 Mapping은 Key-Value 관계로 데이터를 표현하는 기본 구조이며, 들여쓰기와 다양한 Scalar 문법을 통해 중첩된 데이터를 표현할 수 있다. 이러한 문법을 이해하면 Kubernetes와 Spring Boot의 복잡한 설정을 정확하게 작성하고, yq를 통해 구조적으로 조회하고 검증할 수 있다.

## 02. Array

### YAML의 Array와 List: Sequence 문법과 중첩 데이터 구조 이해하기

YAML은 Mapping, Sequence, Scalar라는 세 가지 기본 데이터 구조를 사용하여 데이터를 표현한다.

Mapping은 Key와 Value를 연결하는 구조이며, Scalar는 문자열이나 숫자처럼 하나의 값을 나타낸다.

이번에 살펴볼 **Sequence는 여러 개의 데이터를 순서대로 저장하는 구조**이다.

일반적인 프로그래밍 언어에서 사용하는 Array나 List와 비슷한 개념으로 이해할 수 있다.

예를 들어 일주일을 구성하는 요일을 데이터로 표현한다고 가정하자.

```yaml
days:
  - Monday
  - Tuesday
  - Wednesday
  - Thursday
  - Friday
  - Saturday
  - Sunday
```

여기서 `days`는 Key이며, Value는 일곱 개의 문자열을 포함하는 Sequence이다.

각 항목은 하이픈(`-`)으로 구분한다.

동일한 데이터를 다음과 같이 작성할 수도 있다.

```yaml
days: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
```

두 YAML은 표현 방식이 다르지만 동일한 데이터 구조를 가진다.

이처럼 YAML은 Sequence를 여러 줄로 표현하거나 한 줄로 표현할 수 있다.

또한 Sequence에는 문자열과 숫자뿐 아니라 Mapping이나 또 다른 Sequence도 포함할 수 있다.

이러한 특징은 Kubernetes Manifest를 이해할 때 특히 중요하다.

Kubernetes의 Deployment를 살펴보면 다음과 같은 설정이 자주 등장한다.

```yaml
containers:
  - name: application
    image: nginx:1.27
    ports:
      - containerPort: 80
```

여기서 `containers`는 Sequence이고, 각 요소는 Mapping이다.

또한 컨테이너 내부의 `ports` 역시 Sequence이다.

즉 **Kubernetes Manifest는 Mapping과 Sequence를 여러 단계로 조합하여 만들어진 구조**라고 이해할 수 있다.

이번에는 YAML Sequence의 기본 문법부터 중첩 구조를 표현하는 방법, yq를 이용한 데이터 조회와 수정, Kubernetes에서의 활용 방법까지 살펴본다.

---

### YAML의 Sequence란?

Sequence는 여러 개의 값을 순서대로 저장하는 데이터 구조이다.

YAML에서는 일반적으로 하이픈(`-`)이나 대괄호(`[ ]`)를 사용하여 Sequence를 표현한다.

Sequence는 다음과 같은 특징을 가진다.

| 특징 | 설명 |
|---|---|
| 순서 유지 | 작성한 요소의 순서가 유지된다. |
| 인덱스 접근 | 0부터 시작하는 인덱스로 요소에 접근할 수 있다. |
| 다양한 데이터 타입 | 문자열, 숫자, Boolean, Mapping 등을 포함할 수 있다. |
| 중첩 가능 | Sequence 안에 다른 Sequence를 포함할 수 있다. |
| Mapping과 조합 | Sequence의 각 요소를 Mapping으로 구성할 수 있다. |

Java의 `List`와 비슷하게 생각하면 이해하기 쉽다.

예를 들어 Java에서는 다음과 같이 여러 문자열을 하나의 List에 저장할 수 있다.

```java
List<String> days = List.of(
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
);
```

동일한 데이터를 YAML로 표현하면 다음과 같다.

```yaml
days:
  - Monday
  - Tuesday
  - Wednesday
  - Thursday
  - Friday
  - Saturday
  - Sunday
```

YAML은 특정 프로그래밍 언어에 종속되지 않기 때문에 Java뿐 아니라 Python, JavaScript 등에서도 Sequence를 각 언어의 자료구조로 변환할 수 있다.

```mermaid
flowchart TD
    A["YAML Sequence"] --> B["Java"]
    A --> C["Python"]
    A --> D["JavaScript"]

    B --> E["List"]
    C --> F["list"]
    D --> G["Array"]
```

다만 YAML의 Sequence가 Java의 배열과 완전히 동일한 개념은 아니다.

Java 배열은 길이가 고정되어 있고 선언된 타입에 따라 요소의 타입이 제한된다.

반면 YAML Sequence는 데이터 표현 구조이므로 특정 프로그래밍 언어의 배열 크기나 제네릭 타입 같은 제약을 직접 정의하지 않는다.

---

### Sequence의 두 가지 표현 방식

YAML에서는 Sequence를 크게 두 가지 방식으로 표현할 수 있다.

1. Flow Style
2. Block Style

두 방식은 문법이 다르지만 동일한 데이터 구조를 표현한다.

#### Flow Style: 대괄호를 사용하는 방식

Flow Style은 대괄호(`[ ]`)를 사용하여 Sequence를 표현한다.

여러 요소는 쉼표(`,`)로 구분한다.

```yaml
days: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]
```

이 설정은 다음과 같이 해석할 수 있다.

```text
days
 ├── [0] Monday
 ├── [1] Tuesday
 ├── [2] Wednesday
 ├── [3] Thursday
 ├── [4] Friday
 ├── [5] Saturday
 └── [6] Sunday
```

문자열뿐 아니라 숫자도 저장할 수 있다.

```yaml
numbers: [1, 2, 3, 100]
```

Java로 표현하면 다음과 비슷하다.

```java
List<Integer> numbers = List.of(1, 2, 3, 100);
```

Boolean 값도 저장할 수 있다.

```yaml
flags: [true, false, true]
```

Mapping을 Sequence의 요소로 사용할 수도 있다.

```yaml
users: [{name: Hong, age: 30}, {name: Kim, age: 28}]
```

이처럼 Flow Style은 비교적 짧은 데이터를 한 줄로 표현할 때 유용하다.

하지만 요소가 많아지고 중첩 구조가 깊어지면 가독성이 떨어질 수 있다.

---

### Block Style: 하이픈을 사용하는 방식

Block Style은 하이픈(`-`)과 들여쓰기를 사용하여 Sequence를 표현한다.

```yaml
days:
  - Monday
  - Tuesday
  - Wednesday
  - Thursday
  - Friday
  - Saturday
  - Sunday
```

여기서 각 하이픈은 Sequence의 요소 하나를 의미한다.

다음과 같이 숫자 목록도 작성할 수 있다.

```yaml
numbers:
  - 1
  - 2
  - 3
  - 100
```

각 요소는 같은 수준으로 들여쓰기해야 한다.

```text
numbers
  ├── 1
  ├── 2
  ├── 3
  └── 100
```

Block Style은 데이터를 여러 줄에 걸쳐 표현하기 때문에 요소가 많거나 중첩 구조가 복잡할 때 가독성이 좋다.

특히 Kubernetes Manifest에서는 일반적으로 Block Style을 많이 사용한다.

#### Flow Style과 Block Style 비교

| 구분 | Flow Style | Block Style |
|---|---|---|
| 표현 기호 | `[ ]` | `-` |
| 요소 구분 | 쉼표 | 하이픈과 들여쓰기 |
| 여러 줄 작성 | 가능 | 일반적 |
| 간단한 목록 | 간결함 | 읽기 쉬움 |
| 복잡한 중첩 구조 | 가독성이 떨어질 수 있음 | 구조 파악에 유리 |
| Kubernetes 활용 | 짧은 목록 | 일반적인 리소스 설정 |

중요한 점은 **표현 방식이 다르더라도 파싱된 Sequence의 값과 순서는 동일하다는 것**이다.

---

### Flow Style과 Block Style은 정말 같은 데이터일까?

실제로 두 YAML이 같은 데이터 구조로 해석되는지 확인해보자.

먼저 다음 두 파일을 작성한다.

**days-flow.yaml**

```yaml
days: [Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday]

numbers: [1, 2, 3, 100]
```

**days-block.yaml**

```yaml
days:
  - Monday
  - Tuesday
  - Wednesday
  - Thursday
  - Friday
  - Saturday
  - Sunday

numbers:
  - 1
  - 2
  - 3
  - 100
```

이 두 파일의 `days`와 `numbers`는 동일한 Sequence 데이터를 표현한다.

이를 yq를 이용해 확인할 수 있다.

---

### yq를 이용한 Sequence 데이터 조회

yq는 YAML 파일을 구조적으로 조회하거나 수정할 수 있는 CLI 도구이다.

여기서는 Mike Farah의 yq v4 계열을 기준으로 사용한다.

앞서 작성한 파일을 조회해보자.

```bash
yq '.' days-flow.yaml
```

이 명령어에서 `.`은 YAML 문서 전체를 선택한다는 의미이다.

Flow Style로 작성한 파일이 출력된다.

Block Style로 작성한 파일도 조회할 수 있다.

```bash
yq '.' days-block.yaml
```

특정 필드만 조회하려면 다음과 같이 작성한다.

```bash
yq '.days' days-block.yaml
```

예상 출력:

```yaml
- Monday
- Tuesday
- Wednesday
- Thursday
- Friday
- Saturday
- Sunday
```

숫자 목록도 조회할 수 있다.

```bash
yq '.numbers' days-block.yaml
```

출력:

```yaml
- 1
- 2
- 3
- 100
```

두 파일의 데이터 구조가 동일한지 확인하려면 JSON으로 변환하여 비교할 수도 있다.

```bash
yq -o=json '.' days-flow.yaml
```

```bash
yq -o=json '.' days-block.yaml
```

두 명령어는 동일한 JSON 데이터를 출력한다.

```json
{
  "days": [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ],
  "numbers": [
    1,
    2,
    3,
    100
  ]
}
```

이를 통해 YAML의 Flow Style과 Block Style이 동일한 Sequence 구조를 표현한다는 사실을 확인할 수 있다.

---

### Sequence의 인덱스 이해하기

Sequence는 순서가 있는 데이터 구조이므로 인덱스를 사용하여 특정 요소에 접근할 수 있다.

중요한 점은 **인덱스가 0부터 시작한다는 것**이다.

다음 Sequence를 살펴보자.

```yaml
days:
  - Monday
  - Tuesday
  - Wednesday
  - Thursday
  - Friday
  - Saturday
  - Sunday
```

각 요소의 인덱스는 다음과 같다.

| 인덱스 | 값 | 의미 |
|---:|---|---|
| 0 | Monday | 첫 번째 요소 |
| 1 | Tuesday | 두 번째 요소 |
| 2 | Wednesday | 세 번째 요소 |
| 3 | Thursday | 네 번째 요소 |
| 4 | Friday | 다섯 번째 요소 |
| 5 | Saturday | 여섯 번째 요소 |
| 6 | Sunday | 일곱 번째 요소 |

배열이 0부터 시작하기 때문에 세 번째 요소를 조회하려면 인덱스 `2`를 사용해야 한다.

이 점은 Java나 JavaScript의 배열 인덱스와 동일하다.

---

### yq로 Sequence의 특정 인덱스 조회하기

#### 첫 번째 요소 조회

```bash
yq '.days[0]' days-block.yaml
```

출력:

```text
Monday
```

여기서 각 부분의 의미는 다음과 같다.

| 표현식 | 의미 |
|---|---|
| `.days` | days 필드 선택 |
| `[0]` | 첫 번째 요소 선택 |

#### 세 번째 요소 조회

```bash
yq '.days[2]' days-block.yaml
```

출력:

```text
Wednesday
```

#### 다섯 번째 요소 조회

```bash
yq '.days[4]' days-block.yaml
```

출력:

```text
Friday
```

#### 숫자 Sequence의 첫 번째 요소 조회

```bash
yq '.numbers[0]' days-block.yaml
```

출력:

```text
1
```

#### 숫자 Sequence의 마지막 요소 조회

```bash
yq '.numbers[3]' days-block.yaml
```

출력:

```text
100
```

`numbers`에는 네 개의 요소가 있으므로 마지막 요소의 인덱스는 `3`이다.

이처럼 Flow Style과 Block Style 모두 동일한 인덱스 접근 방식을 사용할 수 있다.

---

### yq에서 마지막 요소에 접근하기

Sequence의 마지막 요소를 조회할 때 항상 정확한 인덱스를 알고 있어야 하는 것은 아니다.

yq에서는 음수 인덱스를 사용하여 뒤에서부터 요소에 접근할 수 있다.

예를 들어 다음 명령어를 실행한다.

```bash
yq '.numbers[-1]' days-block.yaml
```

출력:

```text
100
```

`[-1]`은 마지막 요소를 의미한다.

마지막에서 두 번째 요소를 조회하려면 다음과 같이 작성한다.

```bash
yq '.numbers[-2]' days-block.yaml
```

출력:

```text
3
```

이를 정리하면 다음과 같다.

| 인덱스 | 의미 |
|---|---|
| `[0]` | 첫 번째 요소 |
| `[1]` | 두 번째 요소 |
| `[-1]` | 마지막 요소 |
| `[-2]` | 마지막에서 두 번째 요소 |

음수 인덱스는 Sequence의 길이가 변경될 수 있는 설정 파일에서 특히 유용하다.

다만 인덱스가 지원 범위를 벗어나면 기대한 값이 반환되지 않을 수 있으므로 자동화 스크립트에서는 해당 요소가 존재하는지도 검증하는 것이 좋다.

---

### Sequence의 길이 확인하기

yq의 `length` 연산자를 사용하면 Sequence의 요소 개수를 확인할 수 있다.

```bash
yq '.days | length' days-block.yaml
```

출력:

```text
7
```

요일이 일곱 개이기 때문이다.

숫자 목록의 길이도 확인해보자.

```bash
yq '.numbers | length' days-block.yaml
```

출력:

```text
4
```

`length`는 Sequence의 요소 개수를 반환한다.

```mermaid
flowchart TD
    A["numbers Sequence"] --> B["1"]
    A --> C["2"]
    A --> D["3"]
    A --> E["100"]

    A --> F["length = 4"]
```

이 기능은 배열의 크기를 확인하거나 데이터 검증을 수행할 때 사용할 수 있다.

---

### Sequence의 모든 요소를 개별적으로 조회하기

특정 인덱스가 아니라 모든 요소를 하나씩 출력하고 싶을 수도 있다.

이때는 `[]`를 사용한다.

```bash
yq '.days[]' days-block.yaml
```

출력:

```text
Monday
Tuesday
Wednesday
Thursday
Friday
Saturday
Sunday
```

여기서 `.days[]`는 `days` Sequence의 각 요소를 순서대로 선택한다.

이는 다음과 같이 이해할 수 있다.

```text
days
  ↓
각 요소 순회
  ↓
Monday
Tuesday
Wednesday
...
Sunday
```

이 방식은 Sequence 안에 Mapping이 포함되어 있을 때 더욱 유용하다.

예를 들어 사용자 목록에서 모든 사용자의 이름만 조회하거나, Kubernetes Deployment의 모든 컨테이너 이미지를 조회할 때 사용할 수 있다.

---

### Sequence 안에 Mapping 포함하기

지금까지는 문자열이나 숫자를 Sequence의 요소로 사용했다.

하지만 YAML Sequence에는 Mapping도 포함할 수 있다.

예를 들어 여러 개의 앨범 정보를 저장한다고 가정하자.

각 앨범은 다음 정보를 가진다.

- 앨범 이름
- 타이틀곡

이를 YAML로 표현하면 다음과 같다.

**albums-simple.yaml**

```yaml
albums:
  - name: First Single
    title: Happy

  - name: Second Single
    title: Smile
```

이 구조를 자세히 살펴보자.

```yaml
albums:
```

`albums`는 Key이다.

그 Value는 Sequence이다.

```yaml
  - name: First Single
    title: Happy
```

첫 번째 하이픈은 Sequence의 첫 번째 요소를 의미한다.

그 요소는 `name`과 `title`이라는 두 개의 Key를 포함하는 Mapping이다.

두 번째 요소 역시 Mapping이다.

```yaml
  - name: Second Single
    title: Smile
```

전체 구조를 표현하면 다음과 같다.

```text
albums
│
├── [0] Mapping
│    ├── name: First Single
│    └── title: Happy
│
└── [1] Mapping
     ├── name: Second Single
     └── title: Smile
```

Mermaid로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["albums: Sequence"] --> B["Index 0: Mapping"]
    A --> C["Index 1: Mapping"]

    B --> D["name: First Single"]
    B --> E["title: Happy"]

    C --> F["name: Second Single"]
    C --> G["title: Smile"]
```

이처럼 Sequence 안에 Mapping을 포함하면 여러 객체를 하나의 목록으로 관리할 수 있다.

---

### yq로 Sequence 내부의 Mapping 조회하기

앞서 작성한 `albums-simple.yaml`을 사용해보자.

#### 첫 번째 앨범 조회

```bash
yq '.albums[0]' albums-simple.yaml
```

출력:

```yaml
name: First Single
title: Happy
```

`albums[0]`은 첫 번째 앨범을 의미한다.

첫 번째 앨범은 Mapping이므로 `name`과 `title`이 함께 출력된다.

#### 두 번째 앨범 조회

```bash
yq '.albums[1]' albums-simple.yaml
```

출력:

```yaml
name: Second Single
title: Smile
```

#### 두 번째 앨범의 타이틀 조회

두 번째 앨범에서 타이틀만 조회하려면 다음과 같이 작성한다.

```bash
yq '.albums[1].title' albums-simple.yaml
```

출력:

```text
Smile
```

이 표현식을 단계적으로 해석하면 다음과 같다.

```text
.albums
    ↓
앨범 목록 선택

[1]
    ↓
두 번째 앨범 선택

.title
    ↓
해당 앨범의 title 값 선택
```

즉 다음 경로를 따라 데이터에 접근하는 것이다.

```text
albums → index 1 → title
```

이 방식은 Mapping과 Sequence가 조합된 데이터를 조회할 때 기본적으로 사용하는 방법이다.

---

### Sequence의 모든 Mapping에서 특정 필드 조회하기

앨범이 두 개가 아니라 수십 개라면 모든 앨범의 타이틀을 하나씩 조회하기 번거로울 수 있다.

이때는 `[]`를 사용하면 된다.

```bash
yq '.albums[].title' albums-simple.yaml
```

출력:

```text
Happy
Smile
```

이 명령어는 다음 과정을 수행한다.

1. `albums` Sequence를 선택한다.
2. `[]`를 통해 모든 요소에 접근한다.
3. 각 Mapping에서 `title` 필드를 선택한다.

```mermaid
flowchart TD
    A["albums Sequence"] --> B["첫 번째 Mapping"]
    A --> C["두 번째 Mapping"]

    B --> D["title: Happy"]
    C --> E["title: Smile"]

    D --> F["타이틀 목록 출력"]
    E --> F
```

이처럼 yq에서는 Sequence의 각 요소에 대해 동일한 경로 표현식을 적용할 수 있다.

---

### Mapping 안에 Sequence, Sequence 안에 Mapping 조합하기

실제 데이터는 단순히 Mapping 또는 Sequence 하나만으로 구성되지 않는다.

여러 데이터 구조가 중첩되는 경우가 많다.

예를 들어 앨범 정보를 관리하는 시스템을 생각해보자.

하나의 음악 그룹에는 여러 앨범이 존재한다.

각 앨범에는 앨범명과 타이틀곡이 있다.

또한 하나의 앨범에는 여러 수록곡이 존재한다.

각 수록곡에는 곡명과 작사가 정보가 있다.

이를 구조적으로 표현하면 다음과 같다.

```text
Group
│
└── Albums
     │
     ├── Album 1
     │    ├── Name
     │    ├── Title
     │    │
     │    └── Songs
     │         ├── Song 1
     │         │    ├── Name
     │         │    └── Writer
     │         │
     │         └── Song 2
     │              ├── Name
     │              └── Writer
     │
     └── Album 2
          ├── Name
          ├── Title
          │
          └── Songs
               ├── Song 1
               └── Song 2
```

이 구조에는 다음 데이터가 포함되어 있다.

| 항목 | 데이터 구조 |
|---|---|
| Group | Mapping |
| Albums | Sequence |
| Album | Mapping |
| Name | Scalar |
| Title | Scalar |
| Songs | Sequence |
| Song | Mapping |
| Writer | Scalar 또는 Sequence |

이처럼 Mapping과 Sequence를 자유롭게 조합할 수 있다는 점이 YAML의 중요한 특징이다.

---

### 실제 앨범 정보를 이용한 중첩 YAML 작성

이번에는 TWICE의 앨범 정보를 이용하여 중첩된 YAML을 작성해보자.

예제에서는 다음 두 앨범을 사용한다.

- THE STORY BEGINS
- PAGE TWO

각 앨범에는 타이틀곡과 일부 수록곡을 포함한다.

전체 수록곡을 모두 작성하는 대신, 중첩 구조를 이해하기 쉽도록 일부 곡만 사용한다.

**albums.yaml**

```yaml
group: TWICE

albums:
  - name: THE STORY BEGINS
    title: OOH-AHH하게

    songs:
      - name: OOH-AHH하게
        writer: 블랙아이드필승, Sam Lewis

      - name: 다시 해줘
        writer: 박진영

  - name: PAGE TWO
    title: CHEER UP

    songs:
      - name: CHEER UP
        writer: Sam Lewis

      - name: 소중한 사랑
        writer: 박진영, 채영
```

이 YAML에는 여러 데이터 구조가 중첩되어 있다.

먼저 최상위 데이터를 살펴보자.

```yaml
group: TWICE
```

`group`은 Scalar 문자열을 Value로 가지는 Mapping 항목이다.

다음으로 `albums`를 살펴보자.

```yaml
albums:
```

`albums`의 Value는 Sequence이다.

이 Sequence에는 두 개의 Mapping이 포함되어 있다.

첫 번째 Mapping은 다음과 같다.

```yaml
  - name: THE STORY BEGINS
    title: OOH-AHH하게

    songs:
      - name: OOH-AHH하게
        writer: 블랙아이드필승, Sam Lewis

      - name: 다시 해줘
        writer: 박진영
```

여기서 `name`과 `title`은 Scalar이다.

반면 `songs`는 또 다른 Sequence이다.

`songs`의 각 요소는 곡명과 작사가를 나타내는 Mapping이다.

이 구조는 다음과 같이 표현할 수 있다.

```mermaid
flowchart TD
    A["TWICE"] --> B["albums: Sequence"]

    B --> C["Album 0: THE STORY BEGINS"]
    B --> D["Album 1: PAGE TWO"]

    C --> E["title: OOH-AHH하게"]
    C --> F["songs: Sequence"]

    D --> G["title: CHEER UP"]
    D --> H["songs: Sequence"]

    F --> I["Song 0: OOH-AHH하게"]
    F --> J["Song 1: 다시 해줘"]

    H --> K["Song 0: CHEER UP"]
    H --> L["Song 1: 소중한 사랑"]
```

이처럼 복잡해 보이는 YAML도 Mapping과 Sequence의 관계를 이해하면 구조를 쉽게 파악할 수 있다.

---

### yq로 중첩된 앨범 데이터 조회하기

이제 작성한 `albums.yaml`을 사용하여 중첩된 데이터에 접근해보자.

#### 전체 데이터 조회

```bash
yq '.' albums.yaml
```

문서 전체를 조회한다.

#### 그룹 이름 조회

```bash
yq '.group' albums.yaml
```

출력:

```text
TWICE
```

#### 모든 앨범 조회

```bash
yq '.albums' albums.yaml
```

`albums` Sequence 전체를 조회한다.

#### 첫 번째 앨범 이름 조회

```bash
yq '.albums[0].name' albums.yaml
```

출력:

```text
THE STORY BEGINS
```

#### 두 번째 앨범 이름 조회

```bash
yq '.albums[1].name' albums.yaml
```

출력:

```text
PAGE TWO
```

#### 첫 번째 앨범의 타이틀곡 조회

```bash
yq '.albums[0].title' albums.yaml
```

출력:

```text
OOH-AHH하게
```

#### 두 번째 앨범의 타이틀곡 조회

```bash
yq '.albums[1].title' albums.yaml
```

출력:

```text
CHEER UP
```

이러한 접근 방식은 앞에서 살펴본 Sequence 인덱스 조회와 동일하다.

---

### 중첩 Sequence의 특정 요소 조회하기

이번에는 첫 번째 앨범의 수록곡 목록을 조회해보자.

```bash
yq '.albums[0].songs' albums.yaml
```

출력:

```yaml
- name: OOH-AHH하게
  writer: 블랙아이드필승, Sam Lewis
- name: 다시 해줘
  writer: 박진영
```

여기서 `.albums[0]`은 첫 번째 앨범을 의미한다.

그 뒤의 `.songs`는 해당 앨범에 속한 수록곡 목록이다.

#### 첫 번째 앨범의 첫 번째 수록곡

```bash
yq '.albums[0].songs[0]' albums.yaml
```

출력:

```yaml
name: OOH-AHH하게
writer: 블랙아이드필승, Sam Lewis
```

#### 첫 번째 앨범의 두 번째 수록곡

```bash
yq '.albums[0].songs[1]' albums.yaml
```

출력:

```yaml
name: 다시 해줘
writer: 박진영
```

#### 첫 번째 앨범의 두 번째 수록곡 이름

```bash
yq '.albums[0].songs[1].name' albums.yaml
```

출력:

```text
다시 해줘
```

이 명령어의 동작을 구조적으로 살펴보자.

```mermaid
flowchart TD
    A["albums.yaml"] --> B["albums Sequence"]
    B --> C["Index 0"]
    C --> D["THE STORY BEGINS"]

    D --> E["songs Sequence"]
    E --> F["Index 1"]
    F --> G["다시 해줘"]

    G --> H["name 필드 조회"]
```

각 경로의 의미는 다음과 같다.

| 표현식 | 의미 |
|---|---|
| `.albums` | 앨범 목록 선택 |
| `[0]` | 첫 번째 앨범 선택 |
| `.songs` | 해당 앨범의 수록곡 목록 선택 |
| `[1]` | 두 번째 수록곡 선택 |
| `.name` | 수록곡 이름 선택 |

즉 다음 경로를 따라 데이터에 접근한다.

```text
albums
  → 첫 번째 앨범
    → songs
      → 두 번째 곡
        → name
```

이러한 구조는 Kubernetes Manifest에서 중첩된 배열을 조회할 때도 동일하게 사용된다.

---

### 모든 앨범의 타이틀곡 조회하기

특정 앨범 하나가 아니라 모든 앨범의 타이틀곡을 조회하고 싶을 수 있다.

이때 `[]`를 사용한다.

```bash
yq '.albums[].title' albums.yaml
```

출력:

```text
OOH-AHH하게
CHEER UP
```

`.albums[]`는 앨범 목록의 모든 요소를 의미한다.

각 앨범 Mapping에서 `title`을 조회한다.

이 방식은 앨범 개수가 늘어나더라도 동일하게 사용할 수 있다.

예를 들어 앨범이 2개에서 10개로 증가해도 명령어를 수정할 필요가 없다.

---

### 모든 앨범의 수록곡 이름 조회하기

이번에는 모든 앨범에 포함된 모든 수록곡의 이름을 조회해보자.

```bash
yq '.albums[].songs[].name' albums.yaml
```

출력:

```text
OOH-AHH하게
다시 해줘
CHEER UP
소중한 사랑
```

이 명령어는 두 개의 Sequence를 순회한다.

첫 번째 Sequence는 `albums`이다.

두 번째 Sequence는 각 앨범의 `songs`이다.

```mermaid
flowchart TD
    A["albums"] --> B["Album 0"]
    A --> C["Album 1"]

    B --> D["songs"]
    C --> E["songs"]

    D --> F["OOH-AHH하게"]
    D --> G["다시 해줘"]

    E --> H["CHEER UP"]
    E --> I["소중한 사랑"]
```

이를 단계적으로 해석하면 다음과 같다.

```text
.albums[]
    ↓
모든 앨범을 순회

.songs[]
    ↓
각 앨범의 모든 수록곡을 순회

.name
    ↓
각 수록곡의 이름을 출력
```

즉 `[]`를 여러 번 사용하면 중첩된 Sequence를 순회할 수 있다.

이 기능은 YAML 데이터가 복잡해질수록 활용도가 높아진다.

---

### yq의 select를 이용해 특정 앨범 검색하기

지금까지는 인덱스를 기준으로 특정 앨범에 접근했다.

하지만 실제 데이터에서는 앨범의 순서보다 이름을 기준으로 검색하는 것이 더 적절할 수 있다.

예를 들어 `PAGE TWO` 앨범의 정보를 조회한다고 가정하자.

```bash
yq '.albums[] | select(.name == "PAGE TWO")' albums.yaml
```

이 명령어의 의미는 다음과 같다.

1. 모든 앨범을 순회한다.
2. 앨범 이름이 `PAGE TWO`인지 확인한다.
3. 조건을 만족하는 앨범만 출력한다.

예상 출력:

```yaml
name: PAGE TWO
title: CHEER UP
songs:
  - name: CHEER UP
    writer: Sam Lewis
  - name: 소중한 사랑
    writer: 박진영, 채영
```

이를 Mermaid로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["albums Sequence"] --> B["모든 앨범 순회"]
    B --> C{"name == PAGE TWO"}

    C -->|"일치"| D["해당 앨범 출력"]
    C -->|"불일치"| E["제외"]
```

#### 특정 앨범의 타이틀곡만 조회하기

다음과 같이 조건 검색과 필드 조회를 조합할 수 있다.

```bash
yq '.albums[] | select(.name == "PAGE TWO") | .title' albums.yaml
```

출력:

```text
CHEER UP
```

이 방식은 인덱스를 직접 지정하는 것보다 데이터 순서 변경에 강하다.

예를 들어 앨범 목록의 순서가 바뀌더라도 이름이 동일하다면 같은 데이터를 조회할 수 있다.

다만 이름이 중복될 수 있는 데이터라면 고유 식별자를 별도로 사용하는 것이 더 안전하다.

---

### 특정 조건에 맞는 수록곡 조회하기

이번에는 모든 앨범의 수록곡 중 이름이 `CHEER UP`인 곡을 검색해보자.

```bash
yq '.albums[].songs[] | select(.name == "CHEER UP")' albums.yaml
```

예상 출력:

```yaml
name: CHEER UP
writer: Sam Lewis
```

특정 작사가의 곡을 검색할 수도 있다.

```bash
yq '.albums[].songs[] | select(.writer == "박진영")' albums.yaml
```

예상 출력:

```yaml
name: 다시 해줘
writer: 박진영
```

다만 이 예제의 `writer`는 문자열이므로 완전히 일치하는 값만 검색한다.

```yaml
writer: 박진영, 채영
```

처럼 여러 이름을 하나의 문자열로 저장했다면 `"박진영"`과 정확히 같지 않기 때문에 위 조건에는 포함되지 않는다.

이러한 한계는 실제 데이터 모델을 설계할 때 중요하다.

한 곡에 여러 작사가가 참여할 수 있다면 `writer`를 단일 문자열보다 Sequence로 정의하는 것이 더 적절할 수 있다.

---

### 하나의 Mapping 안에 여러 Sequence 포함하기

YAML에서는 하나의 Mapping에 여러 Sequence를 포함할 수도 있다.

예를 들어 다음과 같은 음악 정보가 있다고 가정하자.

```yaml
song:
  name: CHEER UP

  writers:
    - Sam Lewis

  composers:
    - 블랙아이드필승

  genres:
    - Dance
    - Pop
```

여기서 `song`은 Mapping이다.

그 안에는 다음 필드가 존재한다.

| 필드 | 데이터 타입 |
|---|---|
| `name` | Scalar |
| `writers` | Sequence |
| `composers` | Sequence |
| `genres` | Sequence |

이처럼 Mapping은 하나의 고정된 타입만 Value로 가져야 하는 구조가 아니다.

여러 종류의 데이터 구조를 조합하여 하나의 객체를 표현할 수 있다.

#### 작사가 정보를 Sequence로 표현하는 이유

예를 들어 여러 작사가가 참여한 곡을 다음처럼 표현할 수 있다.

```yaml
song:
  name: Example Song

  writers:
    - Writer A
    - Writer B
    - Writer C
```

이렇게 하면 특정 작사가가 포함되어 있는지 구조적으로 검색할 수 있다.

```bash
yq '.song.writers[]' song.yaml
```

출력:

```text
Writer A
Writer B
Writer C
```

이 구조는 여러 값을 쉼표로 연결한 하나의 문자열보다 프로그램에서 처리하기 쉽다.

예를 들어 다음 값은 하나의 문자열이다.

```yaml
writers: "Writer A, Writer B, Writer C"
```

반면 다음 값은 세 개의 문자열로 이루어진 Sequence이다.

```yaml
writers:
  - Writer A
  - Writer B
  - Writer C
```

데이터의 의미가 여러 독립적인 값이라면 Sequence로 표현하는 것이 적절하다.

---

### Sequence 안에 Sequence 포함하기

Sequence의 요소가 반드시 Scalar나 Mapping일 필요는 없다.

다른 Sequence를 포함할 수도 있다.

예를 들어 좌석 배치를 표현한다고 가정하자.

```yaml
seats:
  - [A1, A2, A3]
  - [B1, B2, B3]
  - [C1, C2, C3]
```

여기서 `seats`는 Sequence이다.

각 요소 역시 Sequence이다.

```text
seats
│
├── [0]
│    ├── [0] A1
│    ├── [1] A2
│    └── [2] A3
│
├── [1]
│    ├── [0] B1
│    ├── [1] B2
│    └── [2] B3
│
└── [2]
     ├── [0] C1
     ├── [1] C2
     └── [2] C3
```

이를 Java의 이차원 배열과 비슷하게 이해할 수 있다.

```java
String[][] seats = {
    {"A1", "A2", "A3"},
    {"B1", "B2", "B3"},
    {"C1", "C2", "C3"}
};
```

#### yq로 중첩 Sequence 조회하기

두 번째 행의 세 번째 좌석을 조회한다고 가정하자.

```bash
yq '.seats[1][2]' seats.yaml
```

출력:

```text
B3
```

첫 번째 인덱스 `[1]`은 두 번째 행을 의미한다.

두 번째 인덱스 `[2]`는 해당 행의 세 번째 요소를 의미한다.

이처럼 YAML에서는 Sequence 안에 Sequence를 포함하여 다차원 구조도 표현할 수 있다.

---

### yq로 Sequence 데이터 수정하기

yq는 데이터를 조회하는 기능뿐 아니라 수정하는 기능도 제공한다.

앞서 작성한 `albums.yaml`을 사용한다고 가정하자.

#### 특정 앨범의 타이틀 변경

다음 명령어는 첫 번째 앨범의 타이틀을 변경한 결과를 출력한다.

```bash
yq '.albums[0].title = "New Title"' albums.yaml
```

하지만 이 명령어만 실행하면 원본 파일은 변경되지 않는다.

실제 파일에 변경 사항을 적용하려면 `-i` 옵션을 사용해야 한다.

```bash
yq -i '.albums[0].title = "New Title"' albums.yaml
```

변경된 값을 확인한다.

```bash
yq '.albums[0].title' albums.yaml
```

출력:

```text
New Title
```

`-i`는 원본 파일을 직접 수정하는 옵션이다.

실제 운영 설정이나 중요한 데이터 파일에 사용하기 전에는 변경 이력을 관리하거나 백업해 두는 것이 좋다.

이후 예제는 수정 이전의 `albums.yaml`을 기준으로 설명한다.

---

### yq로 Sequence에 새로운 요소 추가하기

Sequence에 새로운 요소를 추가할 수도 있다.

예를 들어 다음과 같은 데이터가 있다고 가정하자.

**skills.yaml**

```yaml
skills:
  - Java
  - Spring Boot
```

여기에 `Kubernetes`를 추가하려면 다음과 같이 작성할 수 있다.

```bash
yq -i '.skills += ["Kubernetes"]' skills.yaml
```

변경 후 YAML은 다음과 같다.

```yaml
skills:
  - Java
  - Spring Boot
  - Kubernetes
```

`+=`는 기존 Sequence에 새로운 요소를 추가하는 데 사용할 수 있다.

#### Mapping 요소 추가하기

Sequence에 Mapping을 추가할 수도 있다.

다음과 같은 파일이 있다고 가정하자.

```yaml
albums:
  - name: First Single
    title: Happy
```

여기에 두 번째 앨범을 추가한다.

```bash
yq -i '.albums += [{"name": "Second Single", "title": "Smile"}]' albums-simple.yaml
```

변경 후 다음과 같은 구조가 된다.

```yaml
albums:
  - name: First Single
    title: Happy

  - name: Second Single
    title: Smile
```

실제 파일의 공백이나 줄바꿈 스타일은 yq의 출력 방식에 따라 달라질 수 있지만, 데이터 구조는 동일하다.

---

### yq로 Sequence 요소 삭제하기

Sequence에서 특정 요소를 제거할 수도 있다.

다음 파일을 사용한다고 가정하자.

```yaml
skills:
  - Java
  - Spring Boot
  - Kubernetes
```

두 번째 요소인 `Spring Boot`를 삭제하려면 다음과 같이 작성한다.

```bash
yq -i 'del(.skills[1])' skills.yaml
```

변경 결과:

```yaml
skills:
  - Java
  - Kubernetes
```

이때 인덱스 기반 삭제는 주의해야 한다.

요소를 삭제하면 뒤에 있던 요소의 인덱스가 변경되기 때문이다.

예를 들어 기존에는 `Kubernetes`가 인덱스 `2`였지만, `Spring Boot`를 삭제한 후에는 인덱스 `1`이 된다.

따라서 실제 운영 데이터에서는 고정 인덱스보다 명시적인 Key나 조건을 기준으로 요소를 선택하는 것이 더 안전할 수 있다.

---

### Kubernetes에서 Sequence가 중요한 이유

지금까지 살펴본 Sequence와 Mapping의 조합은 Kubernetes Manifest에서 반복적으로 사용된다.

특히 다음 필드에서 자주 등장한다.

- `containers`
- `initContainers`
- `ports`
- `env`
- `volumeMounts`
- `volumes`
- `imagePullSecrets`
- `tolerations`

이러한 필드는 대부분 여러 개의 요소를 저장할 수 있는 Sequence 구조이다.

예를 들어 Deployment에는 하나 이상의 컨테이너를 정의할 수 있다.

각 컨테이너는 환경 변수 목록, 포트 목록, Volume Mount 목록 등을 가질 수 있다.

이 때문에 Kubernetes YAML을 처음 접하면 들여쓰기가 복잡하게 느껴질 수 있다.

하지만 각 필드가 Mapping인지 Sequence인지 구분하면 구조를 훨씬 쉽게 이해할 수 있다.

---

### Kubernetes Deployment에서 Sequence 활용하기

다음은 Nginx 컨테이너를 실행하는 Deployment 예제이다.

**deployment.yaml**

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: web-app

  labels:
    app: web-app

spec:
  replicas: 2

  selector:
    matchLabels:
      app: web-app

  template:
    metadata:
      labels:
        app: web-app

    spec:
      containers:
        - name: web
          image: nginx:1.27

          ports:
            - name: http
              containerPort: 80

          env:
            - name: APP_ENV
              value: "production"

            - name: LOG_LEVEL
              value: "INFO"

          resources:
            requests:
              cpu: "100m"
              memory: "128Mi"

            limits:
              cpu: "500m"
              memory: "256Mi"
```

이 Manifest에는 Mapping과 Sequence가 함께 사용된다.

#### containers는 Sequence이다

다음 설정을 살펴보자.

```yaml
containers:
  - name: web
    image: nginx:1.27
```

`containers`는 Sequence이다.

그 안에는 `name`과 `image`를 포함하는 Mapping이 존재한다.

컨테이너가 하나만 있더라도 `containers`는 Sequence이므로 하이픈을 사용해야 한다.

#### ports도 Sequence이다

```yaml
ports:
  - name: http
    containerPort: 80
```

컨테이너는 여러 포트를 선언할 수 있으므로 `ports` 역시 Sequence이다.

각 요소는 포트에 대한 정보를 담은 Mapping이다.

#### env도 Sequence이다

```yaml
env:
  - name: APP_ENV
    value: "production"

  - name: LOG_LEVEL
    value: "INFO"
```

`env`는 환경 변수 목록이다.

각 요소는 환경 변수 이름과 값을 포함하는 Mapping이다.

#### resources는 Mapping이다

반면 다음 설정을 살펴보자.

```yaml
resources:
  requests:
    cpu: "100m"
    memory: "128Mi"

  limits:
    cpu: "500m"
    memory: "256Mi"
```

`resources`는 Sequence가 아니라 Mapping이다.

`requests`와 `limits` 역시 Mapping이다.

여기서는 하이픈을 사용하지 않는다.

이처럼 Kubernetes Manifest에서는 필드가 의미하는 데이터 구조에 따라 하이픈 사용 여부가 달라진다.

---

### Kubernetes Deployment의 YAML 구조 분석

앞서 작성한 Deployment를 계층적으로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["Deployment"] --> B["metadata: Mapping"]
    A --> C["spec: Mapping"]

    C --> D["replicas: Scalar"]
    C --> E["selector: Mapping"]
    C --> F["template: Mapping"]

    F --> G["spec: Mapping"]
    G --> H["containers: Sequence"]

    H --> I["Container 0: Mapping"]

    I --> J["name: Scalar"]
    I --> K["image: Scalar"]
    I --> L["ports: Sequence"]
    I --> M["env: Sequence"]
    I --> N["resources: Mapping"]

    L --> O["Port 0: Mapping"]
    M --> P["Environment Variable 0"]
    M --> Q["Environment Variable 1"]

    N --> R["requests: Mapping"]
    N --> S["limits: Mapping"]
```

이 구조를 보면 Kubernetes Manifest가 특별한 데이터 구조를 사용하는 것은 아니라는 사실을 알 수 있다.

결국 YAML의 기본 구성 요소인 Mapping, Sequence, Scalar를 조합한 것이다.

Kubernetes API는 각 필드에 어떤 타입의 데이터가 들어가야 하는지를 정의한다.

따라서 YAML 문법이 올바르더라도 API에서 Mapping을 기대하는 위치에 Sequence를 작성하면 오류가 발생할 수 있다.

---

### yq로 Kubernetes Sequence 조회하기

앞서 작성한 `deployment.yaml`을 이용해보자.

#### 첫 번째 컨테이너 이름 조회

```bash
yq '.spec.template.spec.containers[0].name' deployment.yaml
```

출력:

```text
web
```

#### 첫 번째 컨테이너 이미지 조회

```bash
yq '.spec.template.spec.containers[0].image' deployment.yaml
```

출력:

```text
nginx:1.27
```

#### 첫 번째 컨테이너 포트 조회

```bash
yq '.spec.template.spec.containers[0].ports[0].containerPort' deployment.yaml
```

출력:

```text
80
```

#### 첫 번째 환경 변수 이름 조회

```bash
yq '.spec.template.spec.containers[0].env[0].name' deployment.yaml
```

출력:

```text
APP_ENV
```

#### 두 번째 환경 변수 값 조회

```bash
yq '.spec.template.spec.containers[0].env[1].value' deployment.yaml
```

출력:

```text
INFO
```

#### 모든 환경 변수 이름 조회

```bash
yq '.spec.template.spec.containers[0].env[].name' deployment.yaml
```

출력:

```text
APP_ENV
LOG_LEVEL
```

이처럼 중첩된 Kubernetes Manifest에서도 Sequence의 인덱스를 사용하거나 모든 요소를 순회할 수 있다.

---

### 컨테이너 이름을 기준으로 이미지 조회하기

컨테이너가 여러 개 존재하는 Pod에서는 인덱스를 이용해 이미지를 조회하는 것보다 이름을 기준으로 검색하는 것이 더 안전할 수 있다.

예를 들어 다음과 같이 두 개의 컨테이너가 있다고 가정하자.

```yaml
containers:
  - name: web
    image: nginx:1.27

  - name: redis
    image: redis:7
```

첫 번째 컨테이너 이미지는 다음과 같이 조회할 수 있다.

```bash
yq '.spec.template.spec.containers[0].image' deployment.yaml
```

하지만 컨테이너의 순서가 변경되면 다른 이미지가 조회될 수 있다.

따라서 다음처럼 이름을 기준으로 검색하는 방법을 사용할 수 있다.

```bash
yq '.spec.template.spec.containers[] | select(.name == "web") | .image' deployment.yaml
```

예상 출력:

```text
nginx:1.27
```

`select`는 조건을 만족하는 요소를 선택한다.

이 명령어의 실행 흐름은 다음과 같다.

```mermaid
flowchart TD
    A["containers Sequence"] --> B["모든 컨테이너 순회"]
    B --> C{"name == web"}

    C -->|"예"| D["image 필드 조회"]
    C -->|"아니오"| E["제외"]

    D --> F["nginx:1.27"]
```

이러한 방식은 실제 운영 환경에서 컨테이너 이미지 버전을 확인하거나 수정하는 자동화 스크립트를 작성할 때 유용하다.

---

### Kubernetes Manifest에서 자주 발생하는 Sequence 오류

YAML의 Mapping과 Sequence를 혼동하면 문법 오류 또는 Kubernetes API 검증 오류가 발생할 수 있다.

대표적인 사례를 살펴보자.

#### 1. Sequence에서 하이픈을 빠뜨린 경우

다음 설정은 잘못된 예시이다.

```yaml
containers:
  name: nginx
  image: nginx:1.27
```

YAML 문법만 보면 `containers`의 Value는 Mapping이다.

하지만 Kubernetes의 Pod Spec에서 `containers`는 Sequence를 기대한다.

따라서 Kubernetes API 검증에서 오류가 발생할 수 있다.

올바른 구조는 다음과 같다.

```yaml
containers:
  - name: nginx
    image: nginx:1.27
```

하이픈을 추가함으로써 하나의 컨테이너 Mapping을 Sequence의 요소로 표현한다.

#### 2. 같은 Mapping의 Key를 다른 요소처럼 작성하는 경우

다음 설정도 주의해야 한다.

```yaml
containers:
  - name: nginx
  - image: nginx:1.27
```

이 YAML은 Sequence에 두 개의 Mapping을 정의한 것이다.

첫 번째 Mapping에는 `name`만 존재한다.

두 번째 Mapping에는 `image`만 존재한다.

즉 다음과 같이 해석된다.

```text
containers
│
├── [0]
│    └── name: nginx
│
└── [1]
     └── image: nginx:1.27
```

하지만 의도한 구조는 하나의 컨테이너에 이름과 이미지를 함께 정의하는 것이다.

따라서 다음과 같이 작성해야 한다.

```yaml
containers:
  - name: nginx
    image: nginx:1.27
```

이 차이는 Kubernetes Manifest에서 매우 자주 발생하는 실수이다.

**하이픈 하나는 새로운 Sequence 요소가 시작된다는 의미이므로, 같은 객체에 속한 필드마다 하이픈을 붙이면 안 된다.**

#### 3. 들여쓰기가 잘못된 경우

다음 예시는 잘못된 YAML이다.

```yaml
containers:
  - name: nginx
    image: nginx:1.27
     ports:
       - containerPort: 80
```

`ports`의 들여쓰기 수준이 잘못되어 있다.

올바른 설정은 다음과 같다.

```yaml
containers:
  - name: nginx
    image: nginx:1.27

    ports:
      - containerPort: 80
```

같은 Mapping에 속하는 `name`, `image`, `ports`는 동일한 계층에 있어야 한다.

---

### YAML 문법 검증과 Kubernetes API 검증은 다르다

앞에서 살펴본 다음 YAML은 문법적으로 유효할 수 있다.

```yaml
containers:
  name: nginx
  image: nginx:1.27
```

하지만 Kubernetes는 `containers`에 Sequence가 들어오기를 기대한다.

따라서 실제 Kubernetes Manifest를 작성할 때는 두 가지를 모두 검증해야 한다.

첫 번째는 YAML 문법이다.

두 번째는 Kubernetes 리소스의 API 구조이다.

#### yq로 YAML 문법 확인

```bash
yq '.' deployment.yaml
```

YAML 파싱에 성공하면 내용을 출력한다.

#### kubectl로 Kubernetes API 검증

```bash
kubectl apply --dry-run=server -f deployment.yaml
```

서버 측 Dry Run은 실제 리소스를 저장하지 않고 Kubernetes API Server에서 설정을 검증한다.

예를 들어 `containers`를 Mapping으로 잘못 작성했다면 Kubernetes API가 요구하는 데이터 구조와 일치하지 않아 오류가 발생할 수 있다.

다만 서버 측 Dry Run은 리소스가 실제로 실행될 때 발생할 수 있는 모든 장애를 검증하는 것은 아니다.

예를 들어 Node 리소스 부족이나 이미지 다운로드 실패는 실제 배포 단계에서 나타날 수 있다.

---

### 실무에서 Sequence를 사용할 때 고려해야 할 사항

#### 1. 순서가 의미 있는 데이터에 Sequence를 사용한다

Sequence는 순서를 유지하는 데이터 구조이다.

따라서 순서가 중요한 목록이나 여러 값을 저장하는 용도로 적합하다.

예를 들어 다음과 같은 데이터가 있다.

```yaml
processingSteps:
  - validate
  - authorize
  - execute
  - notify
```

이 구조는 작업 단계의 순서를 표현한다.

단, 이 YAML 자체가 작업을 실행하는 것은 아니다.

해당 설정을 읽는 애플리케이션이 순서에 따라 작업을 처리하도록 구현되어 있어야 한다.

#### 2. 객체가 여러 개라면 Sequence 안에 Mapping을 사용한다

예를 들어 여러 데이터베이스 연결 정보를 관리한다고 가정하자.

```yaml
databases:
  - name: primary
    host: primary-db
    port: 3306

  - name: replica
    host: replica-db
    port: 3306
```

`databases`는 Sequence이다.

각 데이터베이스는 Mapping이다.

이렇게 표현하면 하나의 데이터베이스에 여러 속성을 부여할 수 있다.

#### 3. 인덱스보다 고유한 Key를 활용하는 것이 안전할 수 있다

예를 들어 `containers[0]`에 접근하면 첫 번째 컨테이너를 선택할 수 있다.

하지만 컨테이너 순서가 바뀌면 다른 컨테이너가 선택된다.

따라서 운영 자동화에서는 다음처럼 이름을 기준으로 검색하는 방식을 고려할 수 있다.

```bash
yq '.spec.template.spec.containers[] | select(.name == "web")' deployment.yaml
```

특히 여러 컨테이너가 존재하는 Pod에서는 이러한 접근 방식이 유용하다.

#### 4. 데이터 타입을 일관되게 관리한다

YAML은 하나의 Sequence에 서로 다른 타입의 값을 포함할 수 있다.

```yaml
values:
  - 100
  - "hello"
  - true
```

YAML 문법상 허용되는 구조이다.

하지만 이를 Java의 `List<Integer>`와 같은 타입으로 바인딩하려고 하면 문제가 발생할 수 있다.

따라서 실제 애플리케이션에서 사용할 데이터라면 Sequence 요소의 타입을 일관되게 설계하는 것이 좋다.

#### 5. Mapping과 Sequence를 지나치게 깊게 중첩하지 않는다

YAML은 여러 단계의 중첩 구조를 지원한다.

하지만 중첩이 지나치게 깊어지면 읽기와 수정이 어려워진다.

특히 Kubernetes Manifest에서는 Pod Template 내부에 여러 Mapping과 Sequence가 반복되므로 데이터 구조를 이해한 후 수정하는 것이 중요하다.

#### 6. yq로 파일을 직접 수정할 때 주의한다

`yq -i`는 원본 YAML 파일을 변경한다.

따라서 운영 설정 파일에 사용하기 전에는 변경 사항을 검증하고 Git으로 이력을 관리하는 것이 좋다.

또한 특정 인덱스에 의존한 수정은 배열 요소의 순서가 변경될 때 잘못된 데이터를 수정할 가능성이 있다.

---

### Sequence와 Mapping을 구분하는 방법

YAML을 읽을 때 특정 필드가 Mapping인지 Sequence인지 빠르게 구분하는 방법을 정리해보자.

다음 YAML을 살펴보자.

```yaml
application:
  name: payment-service

  servers:
    - name: server-1
      port: 8080

    - name: server-2
      port: 8081

  database:
    host: mysql
    port: 3306
```

여기서 `application`은 Mapping이다.

`name`은 Scalar 문자열이다.

`servers`는 Sequence이다.

`servers`의 각 요소는 Mapping이다.

`database`는 Mapping이다.

이를 정리하면 다음과 같다.

| 필드 | 데이터 구조 | 이유 |
|---|---|---|
| `application` | Mapping | 여러 Key-Value 포함 |
| `name` | Scalar | 하나의 문자열 값 |
| `servers` | Sequence | 하이픈으로 여러 요소 정의 |
| `servers[0]` | Mapping | name과 port 포함 |
| `servers[1]` | Mapping | name과 port 포함 |
| `database` | Mapping | host와 port 포함 |
| `database.host` | Scalar | 하나의 문자열 값 |

이러한 구분을 반복해서 연습하면 복잡한 YAML도 구조적으로 이해할 수 있다.

---

### 정리

YAML의 Sequence는 여러 개의 값을 순서대로 저장하는 데이터 구조이다.

일반적인 프로그래밍 언어의 Array나 List와 비슷한 개념이며, 하이픈 또는 대괄호를 사용하여 표현할 수 있다.

Sequence의 핵심적인 특징은 다음과 같다.

| 항목 | 핵심 내용 |
|---|---|
| Sequence | 여러 값을 순서대로 저장하는 구조 |
| Flow Style | `[ ]`를 사용한 표현 |
| Block Style | `-`를 사용한 표현 |
| 인덱스 | 0부터 시작 |
| `[0]` | 첫 번째 요소 |
| `[-1]` | 마지막 요소 |
| `[]` | 모든 요소 순회 |
| `length` | Sequence의 요소 개수 조회 |
| Sequence 안의 Mapping | 여러 객체를 목록으로 저장 |
| Mapping 안의 Sequence | 하나의 객체에 여러 값을 포함 |
| 중첩 Sequence | Sequence 안에 다른 Sequence 포함 |

또한 yq를 이용하면 Sequence의 특정 요소를 조회하거나 조건을 만족하는 데이터를 검색할 수 있다.

대표적인 명령어는 다음과 같다.


| 명령어 | 의미 |
|---|---|
| `yq '.days' days.yaml` | days Sequence 전체 조회 |
| `yq '.days[0]' days.yaml` | 첫 번째 요소 조회 |
| `yq '.days[-1]' days.yaml` | 마지막 요소 조회 |
| `yq '.days[]' days.yaml` | 모든 요소 순회 |
| `yq '.days \| length' days.yaml` | 요소 개수 조회 |
| `yq '.albums[0].name' albums.yaml` | 첫 번째 앨범 이름 조회 |
| `yq '.albums[1].title' albums.yaml` | 두 번째 앨범 타이틀 조회 |
| `yq '.albums[0].songs[1].name' albums.yaml` | 첫 번째 앨범의 두 번째 곡 조회 |
| `yq '.albums[].title' albums.yaml` | 모든 앨범의 타이틀 조회 |
| `yq '.albums[].songs[].name' albums.yaml` | 모든 앨범의 수록곡 이름 조회 |

YAML에서 가장 중요한 것은 각 기호가 의미하는 데이터 구조를 정확하게 이해하는 것이다.

콜론(`:`)은 Mapping의 Key와 Value를 구분한다.

하이픈(`-`)은 Block Style Sequence의 새로운 요소를 나타낸다.

대괄호(`[ ]`)는 Flow Style Sequence를 나타낸다.

중괄호(`{ }`)는 Flow Style Mapping을 나타낸다.

그리고 들여쓰기는 데이터 사이의 계층 관계를 결정한다.

이러한 기본 문법을 이해하면 Mapping 안에 Sequence가 포함되거나, Sequence 안에 또 다른 Mapping과 Sequence가 중첩된 복잡한 구조도 읽을 수 있다.

특히 Kubernetes Manifest에서는 `containers`, `ports`, `env`, `volumes` 등 많은 필드가 Sequence로 구성되어 있다.

따라서 Mapping과 Sequence의 관계를 이해하는 것은 Kubernetes YAML을 정확하게 작성하고 분석하기 위한 핵심적인 기초 지식이다.

#### 한 줄 요약

> YAML의 Sequence는 여러 값을 순서대로 저장하는 데이터 구조로, 대괄호나 하이픈을 사용해 표현한다. Mapping과 Sequence를 조합하면 복잡한 중첩 데이터를 구성할 수 있으며, yq를 활용하면 특정 인덱스에 접근하거나 조건에 맞는 데이터를 구조적으로 조회하고 수정할 수 있다.

## 03. Yaml using Dictionary and Array

### Kubernetes YAML의 Mapping과 Sequence 활용: ConfigMap과 Pod를 이용한 환경 변수 및 설정 파일 관리

Kubernetes에서는 Pod, Deployment, Service, ConfigMap 등 다양한 리소스를 YAML 파일로 정의하고 관리한다.

이러한 YAML 파일을 살펴보면 Mapping과 Sequence가 여러 단계로 중첩되어 있는 것을 확인할 수 있다.

Mapping은 Key-Value 구조로 데이터를 표현하고, Sequence는 여러 개의 데이터를 순서대로 나열하는 구조이다.

예를 들어 다음과 같은 YAML이 있다고 가정하자.

```yaml
application:
  name: payment-service

  environments:
    - name: development
      port: 8080

    - name: production
      port: 9090
```

이 YAML은 다음과 같이 구성되어 있다.

- `application`은 Mapping이다.
- `name`은 문자열을 Value로 가지는 Mapping의 항목이다.
- `environments`는 Sequence이다.
- `environments`의 각 요소는 Mapping이다.
- 각 Mapping에는 `name`과 `port`가 포함되어 있다.

이처럼 Mapping과 Sequence를 조합하면 복잡한 계층 구조도 표현할 수 있다.

Kubernetes Manifest 역시 이러한 방식으로 구성된다.

특히 ConfigMap은 Mapping과 Sequence의 관계를 이해하기 좋은 리소스이다.

ConfigMap에는 애플리케이션 설정을 Key-Value 형태로 저장하고, Pod에서는 이를 환경 변수나 파일로 사용할 수 있다.

이 과정에서 다음과 같은 YAML 구조가 활용된다.

- ConfigMap의 `metadata`와 `data`는 Mapping이다.
- Pod의 `containers`는 Sequence이다.
- `env`는 환경 변수 목록을 표현하는 Sequence이다.
- `valueFrom`과 `configMapKeyRef`는 중첩된 Mapping이다.
- `volumeMounts`는 Sequence이다.
- `volumes`는 Sequence이다.
- `items`는 ConfigMap에서 파일로 사용할 항목을 정의하는 Sequence이다.

이번에는 ConfigMap과 Pod를 실제로 생성하고, **Mapping과 Sequence가 Kubernetes에서 어떻게 해석되는지, ConfigMap의 값이 컨테이너 내부에 어떻게 전달되는지**를 살펴본다.

---

### ConfigMap이란?

ConfigMap은 Kubernetes에서 애플리케이션의 일반 설정 데이터를 저장하고 관리하기 위한 리소스이다.

애플리케이션을 개발하다 보면 실행 환경에 따라 변경되는 설정들이 존재한다.

예를 들어 다음과 같은 항목이 있다.

- 애플리케이션 실행 환경
- 로그 레벨
- 기능 활성화 여부
- 외부 서비스 주소
- 파일 이름
- 사용자에게 표시할 메시지
- 애플리케이션에서 사용하는 일반 설정값

이러한 설정을 컨테이너 이미지 내부에 직접 포함하면 설정이 변경될 때마다 이미지를 다시 빌드해야 할 수 있다.

예를 들어 다음과 같은 구조를 생각해보자.

```text
Application Image
├── Application
└── Configuration
```

애플리케이션 코드에는 변경이 없지만 설정값만 변경된 상황에서도 새로운 이미지를 생성해야 한다면 운영 과정이 불필요하게 복잡해진다.

이를 개선하기 위해 애플리케이션 실행 파일과 설정 데이터를 분리할 수 있다.

```mermaid
flowchart TD
    A["Container Image"] --> B["Application"]

    C["ConfigMap"] --> D["Configuration Data"]

    B --> E["Running Container"]
    D --> E
```

컨테이너 이미지는 애플리케이션 실행에 필요한 코드와 의존성을 제공한다.

ConfigMap은 실행 환경에 필요한 설정을 제공한다.

이렇게 구성하면 동일한 컨테이너 이미지를 사용하면서도 환경에 따라 서로 다른 설정을 주입할 수 있다.

#### ConfigMap의 주요 특징

| 특징 | 설명 |
|---|---|
| Key-Value 구조 | 설정 데이터를 이름과 값으로 관리 |
| 설정 분리 | 애플리케이션 이미지와 설정 데이터 분리 |
| 환경 변수 지원 | ConfigMap의 값을 컨테이너 환경 변수로 전달 |
| Volume 지원 | ConfigMap 데이터를 파일로 마운트 |
| 선언형 관리 | YAML을 통해 생성 및 수정 |
| Namespace 범위 | 같은 Namespace의 Pod에서 참조 |
| 일반 설정 관리 | 민감하지 않은 설정 데이터 저장 |

ConfigMap의 `data` 필드에 저장하는 값은 문자열이다.

숫자나 Boolean처럼 보이는 값도 문자열 형태로 저장해야 한다.

또한 ConfigMap은 비밀번호나 인증 토큰을 안전하게 보관하기 위한 리소스가 아니다. 민감한 데이터는 Secret이나 별도의 Secret 관리 시스템을 사용해야 한다.

---

### ConfigMap과 Pod의 관계

ConfigMap은 설정 데이터를 보관하는 리소스이지만, ConfigMap을 생성했다고 해서 모든 Pod에 해당 설정이 자동으로 적용되는 것은 아니다.

Pod가 ConfigMap을 사용하려면 Pod Manifest에서 어떤 ConfigMap의 어떤 데이터를 사용할 것인지 명시해야 한다.

ConfigMap의 값을 컨테이너에 전달하는 대표적인 방법은 다음 두 가지이다.

**첫 번째는 환경 변수로 전달하는 방법이다.**

```text
ConfigMap
    ↓
Key-Value 조회
    ↓
Pod Environment Variable
    ↓
Application
```

**두 번째는 Volume을 통해 파일로 전달하는 방법이다.**

```text
ConfigMap
    ↓
Volume
    ↓
Container File System
    ↓
Application
```

두 방법을 함께 사용할 수도 있다.

```mermaid
flowchart TD
    A["ConfigMap: game-demo"] --> B["Environment Variables"]
    A --> C["ConfigMap Volume"]

    B --> D["Pod"]
    C --> D

    D --> E["Container: demo"]

    E --> F["PLAYER_INITIAL_LIVES"]
    E --> G["UI_PROPERTIES_FILE_NAME"]
    E --> H["/config/game.properties"]
    E --> I["/config/user-interface.properties"]
```

여기서 중요한 것은 **ConfigMap에 저장된 데이터와 컨테이너에서 해당 데이터를 사용하는 방식은 서로 다른 개념**이라는 점이다.

ConfigMap은 단순히 설정값을 저장한다.

실제로 환경 변수로 사용할지, 파일로 사용할지는 Pod의 설정에서 결정한다.

---

### ConfigMap과 Pod를 이용한 전체 구성

이번에는 게임 애플리케이션의 설정을 ConfigMap에 저장하고, 이를 사용하는 Pod를 생성해보자.

ConfigMap에는 다음 정보를 저장한다.

| 설정 | 값 | 용도 |
|---|---|---|
| `player_initial_lives` | `"3"` | 플레이어 초기 생명 수 |
| `ui_properties_file_name` | `"user-interface.properties"` | UI 설정 파일 이름 |
| `game.properties` | 여러 줄 문자열 | 게임 관련 설정 |
| `user-interface.properties` | 여러 줄 문자열 | UI 관련 설정 |

Pod에서는 다음과 같이 설정을 사용한다.

| ConfigMap 데이터 | Pod에서 사용하는 방식 | 결과 |
|---|---|---|
| `player_initial_lives` | 환경 변수 | `PLAYER_INITIAL_LIVES=3` |
| `ui_properties_file_name` | 환경 변수 | `UI_PROPERTIES_FILE_NAME=user-interface.properties` |
| `game.properties` | Volume Mount | `/config/game.properties` |
| `user-interface.properties` | Volume Mount | `/config/user-interface.properties` |

전체 구조는 다음과 같다.

```mermaid
flowchart TD
    A["ConfigMap: game-demo"] --> B["data: Mapping"]

    B --> C["player_initial_lives"]
    B --> D["ui_properties_file_name"]
    B --> E["game.properties"]
    B --> F["user-interface.properties"]

    C --> G["Environment Variable"]
    D --> G

    E --> H["ConfigMap Volume"]
    F --> H

    G --> I["Pod: configmap-demo-pod"]
    H --> I

    I --> J["Container: demo"]
```

이번 예제에서 가장 중요한 부분은 ConfigMap 하나의 데이터를 서로 다른 방식으로 사용하는 것이다.

단순한 설정값은 환경 변수로 전달하고, 여러 줄로 구성된 설정은 파일 형태로 마운트한다.

---

### 실습 환경 구성

다음 환경을 기준으로 진행한다.

| 항목 | 환경 |
|---|---|
| 운영체제 | Ubuntu Linux 또는 macOS |
| Kubernetes | K3s, Minikube, Kind 또는 일반 Kubernetes 클러스터 |
| CLI | kubectl |
| YAML 처리 도구 | yq v4 계열 |
| Container Image | Alpine Linux |
| 리소스 | ConfigMap, Pod |

이미 Kubernetes 클러스터가 있다면 별도의 클러스터를 설치할 필요는 없다.

먼저 클러스터에 연결할 수 있는지 확인한다.

```bash
kubectl get nodes
```

정상적으로 연결되었다면 다음과 같은 결과가 출력된다.

```text
NAME       STATUS   ROLES           AGE   VERSION
worker-1   Ready    <none>          10d   v1.xx.x
```

`STATUS`가 `Ready`라면 해당 Node가 정상적으로 동작하고 있다는 의미이다.

현재 작업 중인 Namespace도 확인한다.

```bash
kubectl config view --minify \
  -o jsonpath='{..namespace}{"\n"}'
```

Namespace가 지정되어 있지 않다면 일반적으로 `default` Namespace가 사용된다.

이번 예제에서는 ConfigMap과 Pod를 같은 Namespace에 생성한다.

ConfigMap을 참조하는 Pod는 해당 ConfigMap과 동일한 Namespace에 있어야 한다.

---

### ConfigMap YAML 작성하기

먼저 다음 파일을 작성한다.

**game-demo-configmap.yaml**

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: game-demo

data:
  # 단일 문자열 값
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  # 게임 설정 파일
  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5

  # 사용자 인터페이스 설정 파일
  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
```

이 YAML은 `game-demo`라는 이름의 ConfigMap을 정의한다.

전체 구조를 살펴보면 다음과 같다.

```text
ConfigMap
│
├── apiVersion: v1
├── kind: ConfigMap
│
├── metadata
│   └── name: game-demo
│
└── data
    ├── player_initial_lives: "3"
    ├── ui_properties_file_name: "user-interface.properties"
    ├── game.properties
    │   ├── enemy.types=aliens,monsters
    │   └── player.maximum-lives=5
    │
    └── user-interface.properties
        ├── color.good=purple
        ├── color.bad=yellow
        └── allow.textmode=true
```

이제 각 항목을 자세히 살펴보자.

---

### ConfigMap의 apiVersion과 kind

먼저 다음 부분을 살펴보자.

```yaml
apiVersion: v1
kind: ConfigMap
```

`apiVersion`은 해당 리소스를 처리하는 Kubernetes API 버전을 의미한다.

ConfigMap은 Kubernetes의 Core API Group에 속하므로 `v1`을 사용한다.

`kind`는 생성할 리소스의 종류를 나타낸다.

```yaml
kind: ConfigMap
```

이 설정을 통해 Kubernetes는 해당 Manifest가 ConfigMap을 생성하거나 수정하기 위한 설정이라는 사실을 알 수 있다.

여기서 주의할 점은 리소스 이름을 `ConfigMaps`라고 작성하는 것이 아니라 **`ConfigMap`이라고 작성해야 한다는 것**이다.

```yaml
kind: ConfigMap
```

Kubernetes 리소스의 `kind`는 API에서 정의된 정확한 이름을 사용해야 한다.

---

### metadata: 리소스의 이름 정의

다음은 `metadata`이다.

```yaml
metadata:
  name: game-demo
```

`metadata`는 Mapping이다.

그 안에는 `name`이라는 Key가 존재한다.

`name`의 Value는 `game-demo`이다.

즉 이 YAML은 다음과 같은 의미를 가진다.

```text
리소스 종류: ConfigMap
리소스 이름: game-demo
```

Kubernetes에서 Pod가 이 ConfigMap을 사용하려면 이름을 정확하게 참조해야 한다.

예를 들어 다음과 같이 작성한다.

```yaml
configMapKeyRef:
  name: game-demo
```

여기서 `game-demo`가 앞서 생성한 ConfigMap의 이름과 일치해야 한다.

---

### data: ConfigMap 설정 데이터

다음 부분이 핵심이다.

```yaml
data:
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"
```

`data`는 Mapping이다.

그 안에는 두 개의 Key-Value 쌍이 존재한다.

| Key | Value |
|---|---|
| `player_initial_lives` | `"3"` |
| `ui_properties_file_name` | `"user-interface.properties"` |

여기서 `player_initial_lives`는 플레이어의 초기 생명 수를 의미한다.

그 값은 3이다.

그런데 YAML에서는 숫자를 그대로 작성하지 않고 큰따옴표로 감싸고 있다.

```yaml
player_initial_lives: "3"
```

이유는 ConfigMap의 `data` 필드가 문자열 값을 저장하기 때문이다.

다음과 같이 작성하면 YAML 파서는 `3`을 숫자로 해석할 수 있다.

```yaml
player_initial_lives: 3
```

하지만 Kubernetes ConfigMap의 `data`는 문자열 값을 기대한다.

따라서 다음처럼 작성하는 것이 올바르다.

```yaml
player_initial_lives: "3"
```

#### ConfigMap data의 값은 문자열이다

예를 들어 다음과 같은 값들이 있다고 가정하자.

```yaml
data:
  server_port: "8080"
  debug_enabled: "true"
  max_connections: "100"
```

각 값은 화면상으로 숫자나 Boolean처럼 보일 수 있다.

하지만 ConfigMap의 `data`에서는 모두 문자열이다.

```text
"8080" → String
"true" → String
"100"  → String
```

애플리케이션에서 숫자나 Boolean으로 사용해야 한다면 해당 값을 읽은 후 적절한 타입으로 변환해야 한다.

---

### ConfigMap에 여러 줄 문자열 저장하기

이번에는 다음 부분을 살펴보자.

```yaml
game.properties: |
  enemy.types=aliens,monsters
  player.maximum-lives=5
```

여기서는 `game.properties`라는 Key를 사용한다.

Value는 여러 줄로 구성된 문자열이다.

파이프(`|`)는 YAML의 Literal Block Scalar 문법이다.

이 문법을 사용하면 여러 줄의 문자열을 줄바꿈을 유지한 상태로 표현할 수 있다.

실제 값은 다음과 같다.

```properties
enemy.types=aliens,monsters
player.maximum-lives=5
```

다음 부분도 같은 방식이다.

```yaml
user-interface.properties: |
  color.good=purple
  color.bad=yellow
  allow.textmode=true
```

실제 값은 다음과 같다.

```properties
color.good=purple
color.bad=yellow
allow.textmode=true
```

여기서 중요한 점이 있다.

**ConfigMap에 `game.properties`라는 Key를 작성했다고 해서 Kubernetes가 즉시 파일을 생성하는 것은 아니다.**

ConfigMap의 `data`에 저장된 값은 단순한 문자열이다.

이 문자열을 파일로 사용할지, 환경 변수로 사용할지는 해당 ConfigMap을 참조하는 Pod의 설정에 따라 결정된다.

예를 들어 `game.properties`라는 Key를 환경 변수로 사용하도록 설정할 수도 있다.

반대로 `player_initial_lives`라는 Key를 파일로 마운트하도록 설정할 수도 있다.

ConfigMap 자체는 단일 문자열과 여러 줄 문자열을 특별히 구분하여 처리하지 않는다. Pod가 어떤 방식으로 데이터를 사용하는지가 중요하다.

---

### ConfigMap에서 Mapping 구조 분석하기

이제 ConfigMap의 전체 YAML 구조를 데이터 타입 관점에서 살펴보자.

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: game-demo

data:
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"

  game.properties: |
    enemy.types=aliens,monsters
    player.maximum-lives=5

  user-interface.properties: |
    color.good=purple
    color.bad=yellow
    allow.textmode=true
```

각 항목의 데이터 타입은 다음과 같다.

| 필드 | 데이터 타입 | 설명 |
|---|---|---|
| `apiVersion` | Scalar | API 버전 |
| `kind` | Scalar | 리소스 종류 |
| `metadata` | Mapping | 메타데이터 |
| `metadata.name` | Scalar | ConfigMap 이름 |
| `data` | Mapping | 설정 데이터 |
| `data.player_initial_lives` | Scalar | 문자열 `"3"` |
| `data.ui_properties_file_name` | Scalar | 설정 파일 이름 |
| `data.game.properties` | Scalar | 여러 줄 문자열 |
| `data.user-interface.properties` | Scalar | 여러 줄 문자열 |

여기서 `game.properties`는 하나의 Key이다.

`game`이라는 Mapping 안에 `properties`라는 Key가 존재하는 구조가 아니다.

따라서 yq로 접근할 때는 이 차이를 이해해야 한다.

예를 들어 다음 표현은 의도한 Key에 접근하는 방법이 아니다.

```bash
yq '.data.game.properties' game-demo-configmap.yaml
```

이 표현은 `data` 아래의 `game`이라는 Mapping에서 `properties`를 찾으려고 한다.

하지만 실제 Key는 `game.properties`라는 하나의 문자열이다.

따라서 다음과 같이 작성해야 한다.

```bash
yq '.data["game.properties"]' game-demo-configmap.yaml
```

이렇게 하면 정확한 Key를 기준으로 값을 조회할 수 있다.

---

### yq로 ConfigMap 구조 확인하기

작성한 ConfigMap을 Kubernetes에 적용하기 전에 yq로 데이터 구조를 확인해보자.

#### 전체 YAML 조회

```bash
yq '.' game-demo-configmap.yaml
```

이 명령어는 전체 YAML 문서를 조회한다.

#### ConfigMap 이름 조회

```bash
yq '.metadata.name' game-demo-configmap.yaml
```

출력:

```text
game-demo
```

#### player_initial_lives 조회

```bash
yq '.data.player_initial_lives' game-demo-configmap.yaml
```

출력:

```text
3
```

여기서 출력이 `3`이라고 해서 실제 데이터 타입이 숫자인 것은 아니다.

데이터 타입을 확인하면 다음과 같다.

```bash
yq '.data.player_initial_lives | tag' game-demo-configmap.yaml
```

출력:

```text
!!str
```

`!!str`은 문자열 타입을 의미한다.

#### game.properties 조회

```bash
yq '.data["game.properties"]' game-demo-configmap.yaml
```

출력되는 문자열의 내용은 다음과 같다.

```properties
enemy.types=aliens,monsters
player.maximum-lives=5
```

#### user-interface.properties 조회

```bash
yq '.data["user-interface.properties"]' game-demo-configmap.yaml
```

출력되는 문자열의 내용은 다음과 같다.

```properties
color.good=purple
color.bad=yellow
allow.textmode=true
```

이처럼 yq를 사용하면 YAML의 중첩된 Mapping에서 원하는 값을 정확하게 추출할 수 있다.

---

### ConfigMap 생성하기

이제 작성한 YAML을 Kubernetes에 적용해보자.

```bash
kubectl apply -f game-demo-configmap.yaml
```

정상적으로 적용되면 다음과 같은 메시지가 출력된다.

```text
configmap/game-demo created
```

이 명령어는 Kubernetes API Server에 `game-demo`라는 ConfigMap을 생성한다.

전체 과정을 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["game-demo-configmap.yaml"] --> B["kubectl apply"]
    B --> C["Kubernetes API Server"]
    C --> D["ConfigMap: game-demo"]
    D --> E["data 필드 저장"]
```

#### ConfigMap 목록 확인

```bash
kubectl get configmaps
```

예상 출력:

```text
NAME               DATA   AGE
game-demo          4      10s
kube-root-ca.crt   1      10d
```

`game-demo`의 `DATA`는 4이다.

이는 ConfigMap의 `data`에 네 개의 Key가 존재하기 때문이다.

```text
1. player_initial_lives
2. ui_properties_file_name
3. game.properties
4. user-interface.properties
```

#### 특정 ConfigMap 확인

```bash
kubectl get configmap game-demo
```

출력 예시:

```text
NAME        DATA   AGE
game-demo   4      20s
```

#### ConfigMap 상세 정보 확인

```bash
kubectl describe configmap game-demo
```

이 명령어는 ConfigMap의 이름과 데이터 항목을 확인하는 데 사용한다.

또는 다음 명령어를 사용할 수 있다.

```bash
kubectl get configmap game-demo -o yaml
```

이 명령어는 Kubernetes API Server에 저장된 ConfigMap 객체를 YAML 형식으로 출력한다.

---

### ConfigMap을 사용하는 Pod 작성하기

이제 앞에서 생성한 ConfigMap을 사용하는 Pod를 작성해보자.

Pod에서는 다음 두 가지 방식으로 ConfigMap을 사용한다.

1. ConfigMap의 특정 Key를 환경 변수로 주입한다.
2. ConfigMap의 특정 Key를 파일로 마운트한다.

이를 하나의 Pod에서 모두 사용한다.

**configmap-demo-pod.yaml**

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: configmap-demo-pod

spec:
  containers:
    - name: demo
      image: alpine:3.21

      command:
        - sleep
        - "3600"

      env:
        - name: PLAYER_INITIAL_LIVES
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: player_initial_lives

        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name

      volumeMounts:
        - name: config
          mountPath: /config
          readOnly: true

  volumes:
    - name: config
      configMap:
        name: game-demo

        items:
          - key: game.properties
            path: game.properties

          - key: user-interface.properties
            path: user-interface.properties
```

이 YAML은 `configmap-demo-pod`라는 Pod를 생성한다.

Pod 내부에는 `demo`라는 컨테이너가 하나 존재한다.

컨테이너는 Alpine Linux 이미지를 사용하고, `sleep 3600` 명령을 실행한다.

또한 ConfigMap의 값을 환경 변수와 파일로 전달받도록 설정되어 있다.

이 YAML은 Mapping과 Sequence가 여러 단계로 중첩된 구조이므로 각 항목을 하나씩 분석해보자.

---

### Pod YAML의 기본 구조

먼저 다음 부분을 살펴보자.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: configmap-demo-pod
```

이 설정의 의미는 다음과 같다.

| 필드 | 값 | 의미 |
|---|---|---|
| `apiVersion` | `v1` | Pod API 버전 |
| `kind` | `Pod` | 생성할 리소스 종류 |
| `metadata.name` | `configmap-demo-pod` | Pod 이름 |

다음으로 `spec`이 등장한다.

```yaml
spec:
```

`spec`은 Pod의 원하는 상태를 정의하는 Mapping이다.

그 아래에는 다음 설정들이 포함된다.

```text
spec
│
├── containers
│
└── volumes
```

여기서 `containers`와 `volumes`는 같은 계층에 존재한다.

다만 두 항목의 Value는 모두 Sequence이다.

---

### containers: 컨테이너 목록

다음 설정을 살펴보자.

```yaml
containers:
  - name: demo
    image: alpine:3.21
```

`containers`는 Sequence이다.

하이픈(`-`)을 사용하여 첫 번째 컨테이너를 정의한다.

첫 번째 요소는 다음 Mapping을 포함한다.

```yaml
name: demo
image: alpine:3.21
```

이를 구조적으로 표현하면 다음과 같다.

```text
containers
│
└── [0]
     ├── name: demo
     └── image: alpine:3.21
```

여기서 `containers`가 Sequence인 이유는 하나의 Pod에 여러 컨테이너를 포함할 수 있기 때문이다.

예를 들어 다음과 같이 작성할 수도 있다.

```yaml
containers:
  - name: application
    image: nginx:1.27

  - name: sidecar
    image: alpine:3.21
    command: ["sleep", "3600"]
```

이 경우 Pod에는 두 개의 일반 컨테이너가 정의된다.

하지만 이번 예제에서는 `demo` 컨테이너 하나만 사용한다.

---

### command: Sequence를 이용한 실행 명령 정의

다음 설정을 살펴보자.

```yaml
command:
  - sleep
  - "3600"
```

`command`는 Sequence이다.

각 요소는 실행할 프로그램과 인자를 나타내는 문자열이다.

이 설정은 다음 명령을 실행하는 것과 비슷하다.

```bash
sleep 3600
```

즉 컨테이너가 시작된 후 3,600초 동안 대기한다.

3,600초는 1시간이다.

여기서 `sleep`을 사용하는 이유는 컨테이너가 바로 종료되지 않도록 하기 위해서이다.

실제로 게임 애플리케이션을 실행하는 것이 아니라 ConfigMap이 컨테이너 내부에 어떻게 전달되었는지 확인하기 위한 구조이다.

#### command를 Flow Style로 작성하기

YAML의 Sequence는 대괄호를 사용하여 한 줄로 작성할 수도 있다.

```yaml
command: ["sleep", "3600"]
```

이 설정은 앞에서 작성한 Block Style과 동일한 구조이다.

**Block Style**

```yaml
command:
  - sleep
  - "3600"
```

**Flow Style**

```yaml
command: ["sleep", "3600"]
```

두 방식 모두 Sequence에 두 개의 문자열을 저장한다.

여기서 `"3600"`을 문자열로 작성했다는 점도 중요하다.

Kubernetes의 `command` 필드는 문자열 목록을 기대하기 때문이다.

따라서 다음처럼 숫자로 작성하는 것은 올바르지 않다.

```yaml
command:
  - sleep
  - 3600
```

YAML 문법 자체는 유효할 수 있지만 Kubernetes API에서 기대하는 데이터 타입과 일치하지 않는다.

---

### env: 컨테이너 환경 변수 설정

이제 ConfigMap을 사용하는 핵심 부분을 살펴보자.

```yaml
env:
  - name: PLAYER_INITIAL_LIVES
    valueFrom:
      configMapKeyRef:
        name: game-demo
        key: player_initial_lives

  - name: UI_PROPERTIES_FILE_NAME
    valueFrom:
      configMapKeyRef:
        name: game-demo
        key: ui_properties_file_name
```

`env`는 Sequence이다.

그 안에 두 개의 Mapping이 존재한다.

첫 번째 Mapping은 `PLAYER_INITIAL_LIVES`라는 환경 변수를 정의한다.

두 번째 Mapping은 `UI_PROPERTIES_FILE_NAME`이라는 환경 변수를 정의한다.

```mermaid
flowchart TD
    A["env: Sequence"] --> B["Environment 0"]
    A --> C["Environment 1"]

    B --> D["name: PLAYER_INITIAL_LIVES"]
    B --> E["valueFrom"]

    C --> F["name: UI_PROPERTIES_FILE_NAME"]
    C --> G["valueFrom"]

    E --> H["configMapKeyRef"]
    G --> I["configMapKeyRef"]
```

이 부분을 이해하려면 `name`, `valueFrom`, `configMapKeyRef`의 역할을 구분해야 한다.

---

### name: 컨테이너에서 사용할 환경 변수 이름

다음 설정을 살펴보자.

```yaml
- name: PLAYER_INITIAL_LIVES
```

이 값은 컨테이너 내부에 생성할 환경 변수의 이름이다.

즉 컨테이너 내부에서는 다음과 같은 환경 변수를 사용할 수 있다.

```text
PLAYER_INITIAL_LIVES
```

여기서 중요한 점은 환경 변수 이름과 ConfigMap의 Key 이름이 반드시 같을 필요는 없다는 것이다.

ConfigMap에서는 다음 이름을 사용한다.

```yaml
player_initial_lives: "3"
```

하지만 Pod에서는 다음 이름으로 환경 변수를 생성한다.

```yaml
name: PLAYER_INITIAL_LIVES
```

따라서 다음과 같이 연결된다.

```text
ConfigMap Key
player_initial_lives
        ↓
Pod Environment Variable
PLAYER_INITIAL_LIVES
```

이러한 방식으로 ConfigMap의 Key 이름과 실제 애플리케이션에서 사용하는 환경 변수 이름을 분리할 수 있다.

---

### valueFrom: 다른 리소스에서 값 가져오기

다음 부분을 살펴보자.

```yaml
valueFrom:
  configMapKeyRef:
    name: game-demo
    key: player_initial_lives
```

`valueFrom`은 환경 변수의 값을 다른 곳에서 가져오겠다는 설정이다.

여기서는 ConfigMap에서 값을 가져온다.

각 필드의 의미는 다음과 같다.

| 필드 | 의미 |
|---|---|
| `valueFrom` | 외부 참조를 통해 환경 변수 값 설정 |
| `configMapKeyRef` | ConfigMap의 특정 Key 참조 |
| `name` | 참조할 ConfigMap 이름 |
| `key` | ConfigMap에서 가져올 Key |

이 설정은 다음 의미를 가진다.

```text
ConfigMap 이름: game-demo
Key 이름: player_initial_lives
```

앞서 작성한 ConfigMap에는 다음 값이 존재한다.

```yaml
player_initial_lives: "3"
```

따라서 Pod의 환경 변수에는 다음 값이 전달된다.

```text
PLAYER_INITIAL_LIVES=3
```

전체 과정을 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["ConfigMap: game-demo"] --> B["data"]
    B --> C["player_initial_lives: 3"]

    C --> D["configMapKeyRef"]
    D --> E["Environment Variable"]
    E --> F["PLAYER_INITIAL_LIVES=3"]
```

두 번째 환경 변수도 동일한 방식으로 동작한다.

```yaml
- name: UI_PROPERTIES_FILE_NAME
  valueFrom:
    configMapKeyRef:
      name: game-demo
      key: ui_properties_file_name
```

ConfigMap에는 다음 값이 존재한다.

```yaml
ui_properties_file_name: "user-interface.properties"
```

따라서 컨테이너 내부에는 다음 환경 변수가 생성된다.

```text
UI_PROPERTIES_FILE_NAME=user-interface.properties
```

---

### 환경 변수를 직접 지정하는 방법과 ConfigMap을 참조하는 방법

Kubernetes에서는 환경 변수를 직접 지정할 수도 있다.

예를 들어 다음과 같다.

```yaml
env:
  - name: PLAYER_INITIAL_LIVES
    value: "3"
```

이 방식은 환경 변수 값을 Pod Manifest에 직접 작성한다.

반면 ConfigMap을 사용하면 다음처럼 작성할 수 있다.

```yaml
env:
  - name: PLAYER_INITIAL_LIVES
    valueFrom:
      configMapKeyRef:
        name: game-demo
        key: player_initial_lives
```

두 설정은 컨테이너 내부에서 동일한 환경 변수 값을 만들 수 있다.

하지만 설정을 관리하는 방식에는 차이가 있다.

| 구분 | 직접 지정 | ConfigMap 참조 |
|---|---|---|
| 설정 위치 | Pod Manifest | ConfigMap |
| 주요 필드 | `value` | `valueFrom` |
| 설정 재사용 | Pod마다 직접 정의 | 여러 Pod에서 참조 가능 |
| 환경별 설정 분리 | 상대적으로 불편 | 비교적 편리 |
| 변경 관리 | Pod Template 변경 필요 | ConfigMap을 별도로 관리 가능 |

ConfigMap을 사용하면 공통 설정을 여러 Pod에서 재사용할 수 있다.

다만 ConfigMap을 변경했다고 해서 실행 중인 컨테이너의 환경 변수가 자동으로 변경되는 것은 아니다.

이 부분은 실제 운영에서 중요하므로 뒤에서 자세히 살펴본다.

---

### volumeMounts: 컨테이너 내부에 Volume 연결하기

다음 설정을 살펴보자.

```yaml
volumeMounts:
  - name: config
    mountPath: /config
    readOnly: true
```

`volumeMounts`는 Sequence이다.

그 안에는 하나의 Mapping이 존재한다.

각 필드의 의미는 다음과 같다.

| 필드 | 의미 |
|---|---|
| `name` | 마운트할 Volume의 이름 |
| `mountPath` | 컨테이너 내부의 마운트 경로 |
| `readOnly` | 해당 마운트를 읽기 전용으로 지정 |

여기서 중요한 값은 다음 두 가지이다.

```yaml
name: config
mountPath: /config
```

`name: config`는 Pod에 정의된 Volume 중 `config`라는 이름의 Volume을 사용하겠다는 의미이다.

`mountPath: /config`는 해당 Volume을 컨테이너 내부의 `/config` 경로에 연결하겠다는 의미이다.

```mermaid
flowchart LR
    A["Pod Volume: config"] --> B["volumeMounts"]
    B --> C["Container"]
    C --> D["/config"]
```

여기서 `readOnly: true`를 설정했기 때문에 컨테이너에서는 해당 경로를 읽기 전용으로 사용한다.

ConfigMap Volume은 Kubernetes에서 기본적으로 읽기 전용으로 제공되므로, `readOnly: true`는 의도를 명시하는 역할도 한다.

---

### volumes: Pod에서 사용할 Volume 정의

다음 설정을 살펴보자.

```yaml
volumes:
  - name: config
    configMap:
      name: game-demo
```

`volumes`는 Pod Spec에 존재한다.

`containers`와 같은 계층이다.

이 점이 중요하다.

```yaml
spec:
  containers:
    - name: demo
      image: alpine:3.21

  volumes:
    - name: config
      configMap:
        name: game-demo
```

`volumes`는 특정 컨테이너 내부에 정의하는 것이 아니다.

Pod에서 사용할 Volume을 정의하는 영역이다.

반면 `volumeMounts`는 각 컨테이너 내부에 정의한다.

따라서 다음처럼 이해할 수 있다.

**volumes**

Pod에서 사용할 Volume 자체를 정의한다.

**volumeMounts**

Pod에 정의된 Volume을 특정 컨테이너의 어느 경로에 연결할지 정의한다.

```mermaid
flowchart TD
    A["Pod"] --> B["volumes"]
    A --> C["containers"]

    B --> D["Volume: config"]

    C --> E["Container: demo"]
    E --> F["volumeMounts"]

    F --> G["name: config"]
    F --> H["mountPath: /config"]

    D --> G
```

여기서 `volumes.name`과 `volumeMounts.name`은 일치해야 한다.

예를 들어 다음과 같이 작성하면 연결할 Volume을 찾을 수 없다.

```yaml
volumeMounts:
  - name: config-volume
    mountPath: /config

volumes:
  - name: config
    configMap:
      name: game-demo
```

`volumeMounts`에서는 `config-volume`을 참조하지만 실제 Volume 이름은 `config`이기 때문이다.

올바른 설정은 다음과 같다.

```yaml
volumeMounts:
  - name: config
    mountPath: /config

volumes:
  - name: config
    configMap:
      name: game-demo
```

---

### configMap: Volume의 데이터 원본 지정

이번에는 다음 부분을 살펴보자.

```yaml
volumes:
  - name: config
    configMap:
      name: game-demo
```

이 설정은 `config`라는 이름의 Volume이 `game-demo` ConfigMap을 데이터 원본으로 사용하도록 지정한다.

```mermaid
flowchart TD
    A["ConfigMap: game-demo"] --> B["Pod Volume: config"]
    B --> C["Container Mount: /config"]
```

이렇게 하면 ConfigMap의 데이터를 컨테이너 파일 시스템에 제공할 수 있다.

다만 ConfigMap의 모든 Key를 파일로 마운트할지, 일부 Key만 사용할지는 `items` 설정으로 제어할 수 있다.

---

### items: ConfigMap에서 사용할 Key 선택하기

다음 설정을 살펴보자.

```yaml
items:
  - key: game.properties
    path: game.properties

  - key: user-interface.properties
    path: user-interface.properties
```

`items`는 Sequence이다.

두 개의 Mapping이 포함되어 있다.

첫 번째 Mapping은 다음과 같다.

```yaml
- key: game.properties
  path: game.properties
```

두 번째 Mapping은 다음과 같다.

```yaml
- key: user-interface.properties
  path: user-interface.properties
```

각 필드의 의미는 다음과 같다.

| 필드 | 의미 |
|---|---|
| `key` | ConfigMap에서 가져올 데이터의 Key |
| `path` | Volume 내부에서 생성할 상대 파일 경로 |

앞서 작성한 ConfigMap에는 네 개의 Key가 존재한다.

```text
player_initial_lives
ui_properties_file_name
game.properties
user-interface.properties
```

하지만 `items`에서는 두 개의 Key만 선택했다.

따라서 Volume에는 다음 두 파일만 생성된다.

```text
game.properties
user-interface.properties
```

이렇게 선택한 파일은 `mountPath`와 결합되어 최종 경로가 결정된다.

```yaml
mountPath: /config
```

따라서 다음 경로에 파일이 제공된다.

```text
/config/game.properties
/config/user-interface.properties
```

이를 구조적으로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["ConfigMap: game-demo"] --> B["game.properties"]
    A --> C["user-interface.properties"]

    B --> D["items"]
    C --> D

    D --> E["Volume: config"]
    E --> F["mountPath: /config"]

    F --> G["/config/game.properties"]
    F --> H["/config/user-interface.properties"]
```

여기서 `path`는 컨테이너의 절대 경로가 아니라 Volume 내부의 상대 경로이다.

예를 들어 다음과 같이 작성할 수도 있다.

```yaml
items:
  - key: game.properties
    path: settings/game.properties
```

`mountPath`가 `/config`라면 최종 경로는 다음과 같다.

```text
/config/settings/game.properties
```

이처럼 ConfigMap의 Key와 컨테이너 내부의 파일 이름 및 경로를 분리할 수 있다.

---

### items를 생략하면 어떻게 될까?

이번 예제에서는 `items`를 사용하여 두 개의 Key만 선택했다.

그렇다면 `items`를 작성하지 않으면 어떻게 될까?

다음 설정을 살펴보자.

```yaml
volumes:
  - name: config
    configMap:
      name: game-demo
```

이 경우 ConfigMap의 모든 `data` Key가 파일로 제공된다.

앞서 작성한 ConfigMap에는 네 개의 Key가 있으므로 다음 파일들이 생성된다.

```text
/config/
├── player_initial_lives
├── ui_properties_file_name
├── game.properties
└── user-interface.properties
```

반면 `items`를 명시하면 선택된 Key만 파일로 제공된다.

```yaml
items:
  - key: game.properties
    path: game.properties

  - key: user-interface.properties
    path: user-interface.properties
```

결과는 다음과 같다.

```text
/config/
├── game.properties
└── user-interface.properties
```

즉 `items`는 ConfigMap의 데이터 중 파일로 제공할 항목을 선택하는 역할을 한다.

---

### ConfigMap과 Pod YAML의 Mapping·Sequence 구조 분석

지금까지 살펴본 Pod YAML을 전체적으로 분석해보자.

```yaml
apiVersion: v1
kind: Pod

metadata:
  name: configmap-demo-pod

spec:
  containers:
    - name: demo
      image: alpine:3.21

      command:
        - sleep
        - "3600"

      env:
        - name: PLAYER_INITIAL_LIVES
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: player_initial_lives

        - name: UI_PROPERTIES_FILE_NAME
          valueFrom:
            configMapKeyRef:
              name: game-demo
              key: ui_properties_file_name

      volumeMounts:
        - name: config
          mountPath: /config
          readOnly: true

  volumes:
    - name: config
      configMap:
        name: game-demo

        items:
          - key: game.properties
            path: game.properties

          - key: user-interface.properties
            path: user-interface.properties
```

각 항목의 데이터 타입은 다음과 같다.

| 필드 | 데이터 타입 | 설명 |
|---|---|---|
| `spec` | Mapping | Pod 실행 설정 |
| `spec.containers` | Sequence | 컨테이너 목록 |
| `containers[0]` | Mapping | 첫 번째 컨테이너 정보 |
| `command` | Sequence | 실행 명령 및 인자 |
| `env` | Sequence | 환경 변수 목록 |
| `env[0]` | Mapping | 첫 번째 환경 변수 |
| `valueFrom` | Mapping | 값의 참조 정보 |
| `configMapKeyRef` | Mapping | ConfigMap 참조 정보 |
| `volumeMounts` | Sequence | Volume 마운트 목록 |
| `volumeMounts[0]` | Mapping | 첫 번째 마운트 정보 |
| `volumes` | Sequence | Pod Volume 목록 |
| `volumes[0]` | Mapping | 첫 번째 Volume |
| `configMap` | Mapping | ConfigMap Volume 설정 |
| `items` | Sequence | 파일로 사용할 ConfigMap Key 목록 |
| `items[0]` | Mapping | 첫 번째 파일 매핑 |

이 구조를 Mermaid로 표현하면 다음과 같다.

```mermaid
flowchart TD
    A["Pod"] --> B["spec: Mapping"]

    B --> C["containers: Sequence"]
    B --> D["volumes: Sequence"]

    C --> E["Container 0: Mapping"]

    E --> F["command: Sequence"]
    E --> G["env: Sequence"]
    E --> H["volumeMounts: Sequence"]

    G --> I["Environment 0: Mapping"]
    G --> J["Environment 1: Mapping"]

    I --> K["valueFrom: Mapping"]
    K --> L["configMapKeyRef: Mapping"]

    H --> M["Mount 0: Mapping"]

    D --> N["Volume 0: Mapping"]
    N --> O["configMap: Mapping"]
    O --> P["items: Sequence"]

    P --> Q["File Mapping 0"]
    P --> R["File Mapping 1"]
```

처음에는 복잡해 보일 수 있지만, 실제로는 Mapping과 Sequence가 반복적으로 등장하는 구조이다.

이 두 가지를 정확하게 구분하면 Kubernetes Manifest의 계층 관계를 이해할 수 있다.

---

### Pod 생성하기

이제 작성한 Pod Manifest를 Kubernetes에 적용해보자.

먼저 ConfigMap이 존재하는지 확인한다.

```bash
kubectl get configmap game-demo
```

예상 출력:

```text
NAME        DATA   AGE
game-demo   4      5m
```

ConfigMap이 정상적으로 생성되었다면 Pod를 생성한다.

```bash
kubectl apply -f configmap-demo-pod.yaml
```

정상적으로 적용되면 다음과 같은 메시지가 출력된다.

```text
pod/configmap-demo-pod created
```

Pod 상태를 확인한다.

```bash
kubectl get pods
```

예상 출력:

```text
NAME                 READY   STATUS    RESTARTS   AGE
configmap-demo-pod   1/1     Running   0          15s
```

처음에는 이미지 다운로드와 컨테이너 생성 때문에 `Pending` 또는 `ContainerCreating` 상태가 나타날 수 있다.

정상적으로 준비될 때까지 기다리려면 다음 명령어를 사용할 수 있다.

```bash
kubectl wait \
  --for=condition=Ready \
  pod/configmap-demo-pod \
  --timeout=120s
```

정상적으로 Ready 상태가 되면 다음과 같은 메시지가 출력된다.

```text
pod/configmap-demo-pod condition met
```

---

### kubectl describe로 Pod 설정 확인하기

Pod가 생성되었다면 상세 정보를 확인해보자.

```bash
kubectl describe pod configmap-demo-pod
```

이 명령어는 Pod의 실행 상태와 설정 정보를 확인하는 데 사용한다.

출력에는 다음 항목들이 포함될 수 있다.

```text
Containers:
  demo:
    Image: alpine:3.21

    Command:
      sleep
      3600

    Environment:
      PLAYER_INITIAL_LIVES:
        <set to the key 'player_initial_lives'
         of config map 'game-demo'>

      UI_PROPERTIES_FILE_NAME:
        <set to the key 'ui_properties_file_name'
         of config map 'game-demo'>

    Mounts:
      /config from config (ro)
```

실제 출력 형식은 Kubernetes 버전에 따라 조금씩 다를 수 있다.

여기서 중요한 부분은 다음과 같다.

**첫 번째는 컨테이너 실행 명령이다.**

```text
Command:
  sleep
  3600
```

YAML에서 Sequence로 작성한 명령이 컨테이너 실행 설정으로 전달되었다.

**두 번째는 환경 변수이다.**

```text
PLAYER_INITIAL_LIVES
UI_PROPERTIES_FILE_NAME
```

이 환경 변수들은 `game-demo` ConfigMap에서 값을 가져오도록 구성되어 있다.

**세 번째는 Volume Mount이다.**

```text
/config from config (ro)
```

`config`라는 Volume이 컨테이너의 `/config` 경로에 읽기 전용으로 마운트되었다.

다만 `kubectl describe pod`에 표시되는 환경 변수 정보는 ConfigMap 참조 관계를 중심으로 보여줄 수 있다.

따라서 실제 값이 컨테이너 내부에 어떻게 적용되었는지 확인하려면 컨테이너 내부에서 직접 조회하는 것이 좋다.

---

### kubectl exec로 컨테이너 내부 접속하기

실행 중인 컨테이너 내부에서 환경 변수와 파일을 확인해보자.

```bash
kubectl exec -it configmap-demo-pod -- sh
```

각 옵션의 의미는 다음과 같다.

| 옵션 | 의미 |
|---|---|
| `exec` | 실행 중인 컨테이너에서 명령 실행 |
| `-i` | 표준 입력 유지 |
| `-t` | 터미널 할당 |
| `configmap-demo-pod` | 대상 Pod |
| `--` | kubectl 옵션과 컨테이너 명령 구분 |
| `sh` | 컨테이너 내부 Shell 실행 |

이번 Pod에는 컨테이너가 하나뿐이므로 컨테이너 이름을 생략할 수 있다.

여러 컨테이너가 있다면 다음과 같이 컨테이너를 명시하는 것이 좋다.

```bash
kubectl exec -it configmap-demo-pod \
  -c demo \
  -- sh
```

정상적으로 실행되면 Alpine 컨테이너 내부의 Shell에 접근할 수 있다.

```text
/ #
```

이제 ConfigMap의 데이터가 어떻게 적용되었는지 확인해보자.

---

### 컨테이너 내부 환경 변수 확인하기

컨테이너 내부에서 다음 명령어를 실행한다.

```bash
env
```

이 명령어는 현재 프로세스의 환경 변수를 출력한다.

여러 환경 변수가 출력되지만, 그중 다음 값들이 존재하는지 확인한다.

```text
PLAYER_INITIAL_LIVES=3
UI_PROPERTIES_FILE_NAME=user-interface.properties
```

이 값들은 ConfigMap에서 가져온 데이터이다.

```yaml
data:
  player_initial_lives: "3"
  ui_properties_file_name: "user-interface.properties"
```

Pod에서는 다음과 같이 설정했다.

```yaml
env:
  - name: PLAYER_INITIAL_LIVES
    valueFrom:
      configMapKeyRef:
        name: game-demo
        key: player_initial_lives

  - name: UI_PROPERTIES_FILE_NAME
    valueFrom:
      configMapKeyRef:
        name: game-demo
        key: ui_properties_file_name
```

따라서 다음과 같은 연결 관계가 만들어진다.

```mermaid
flowchart TD
    A["ConfigMap: game-demo"] --> B["player_initial_lives: 3"]
    A --> C["ui_properties_file_name"]

    B --> D["configMapKeyRef"]
    C --> D

    D --> E["Container Environment"]

    E --> F["PLAYER_INITIAL_LIVES=3"]
    E --> G["UI_PROPERTIES_FILE_NAME=user-interface.properties"]
```

이처럼 ConfigMap의 Key 이름과 환경 변수 이름이 달라도 정상적으로 값을 전달할 수 있다.

---

### 특정 환경 변수만 조회하기

모든 환경 변수를 출력하는 대신 특정 환경 변수만 확인할 수도 있다.

컨테이너 내부에서 다음 명령어를 실행한다.

```bash
echo "$PLAYER_INITIAL_LIVES"
```

출력:

```text
3
```

두 번째 환경 변수도 확인한다.

```bash
echo "$UI_PROPERTIES_FILE_NAME"
```

출력:

```text
user-interface.properties
```

컨테이너 내부에 들어가지 않고 바로 조회할 수도 있다.

```bash
kubectl exec configmap-demo-pod \
  -- printenv PLAYER_INITIAL_LIVES
```

출력:

```text
3
```

두 번째 환경 변수를 확인한다.

```bash
kubectl exec configmap-demo-pod \
  -- printenv UI_PROPERTIES_FILE_NAME
```

출력:

```text
user-interface.properties
```

실무에서는 `kubectl exec`를 이용해 컨테이너 내부에 진입하지 않고 특정 설정만 확인하는 방식도 자주 활용한다.

---

### ConfigMap Volume이 실제로 생성되었는지 확인하기

이번에는 환경 변수가 아니라 파일로 마운트한 설정을 확인해보자.

Pod YAML에서는 다음과 같이 설정했다.

```yaml
volumeMounts:
  - name: config
    mountPath: /config
    readOnly: true
```

따라서 컨테이너 내부의 `/config` 경로를 확인하면 된다.

컨테이너 내부에서 다음 명령어를 실행한다.

```bash
ls /config
```

예상 출력:

```text
game.properties
user-interface.properties
```

ConfigMap에는 네 개의 Key가 있었지만 두 개의 파일만 생성되었다.

그 이유는 Pod YAML의 `items`에서 두 개의 Key만 선택했기 때문이다.

```yaml
items:
  - key: game.properties
    path: game.properties

  - key: user-interface.properties
    path: user-interface.properties
```

따라서 최종 파일 구조는 다음과 같다.

```text
/config/
├── game.properties
└── user-interface.properties
```

이처럼 ConfigMap의 여러 Key 중 필요한 항목만 파일로 사용할 수 있다.

---

### game.properties 파일 확인하기

이제 첫 번째 설정 파일의 내용을 확인해보자.

컨테이너 내부에서 다음 명령어를 실행한다.

```bash
cat /config/game.properties
```

출력:

```properties
enemy.types=aliens,monsters
player.maximum-lives=5
```

이 데이터는 ConfigMap에 정의했던 내용과 동일하다.

```yaml
game.properties: |
  enemy.types=aliens,monsters
  player.maximum-lives=5
```

즉 ConfigMap에 저장된 여러 줄 문자열이 파일 내용으로 제공된 것이다.

여기서 YAML의 Literal Block Scalar인 `|`가 중요한 역할을 한다.

문자열의 줄바꿈이 유지되기 때문에 `.properties` 형식의 설정 파일을 그대로 표현할 수 있다.

---

### user-interface.properties 파일 확인하기

두 번째 파일도 확인해보자.

```bash
cat /config/user-interface.properties
```

출력:

```properties
color.good=purple
color.bad=yellow
allow.textmode=true
```

이 값 역시 ConfigMap에 저장한 내용과 동일하다.

```yaml
user-interface.properties: |
  color.good=purple
  color.bad=yellow
  allow.textmode=true
```

이렇게 하면 애플리케이션은 컨테이너 이미지 내부에 설정 파일을 포함하지 않아도 `/config` 경로에서 설정 파일을 읽을 수 있다.

예를 들어 애플리케이션이 다음 파일을 읽도록 구현할 수 있다.

```text
/config/game.properties
```

또는 다음 파일을 읽도록 구현할 수 있다.

```text
/config/user-interface.properties
```

다만 이번 예제에서는 `sleep 3600`만 실행하므로 해당 설정 파일을 실제로 읽어 처리하는 애플리케이션은 존재하지 않는다.

이번 구성은 ConfigMap의 데이터가 환경 변수와 파일로 올바르게 전달되는지 확인하는 데 목적이 있다.

---

### ConfigMap이 환경 변수와 파일로 전달되는 전체 과정

지금까지 확인한 과정을 하나의 흐름으로 정리해보자.

```mermaid
flowchart TD
    A["game-demo-configmap.yaml"] --> B["ConfigMap 생성"]
    C["configmap-demo-pod.yaml"] --> D["Pod 생성"]

    B --> E["ConfigMap: game-demo"]
    D --> F["Pod: configmap-demo-pod"]

    E --> G["Key-Value Data"]

    G --> H["configMapKeyRef"]
    G --> I["ConfigMap Volume"]

    H --> J["Environment Variables"]
    I --> K["/config"]

    J --> F
    K --> F

    F --> L["Container: demo"]

    L --> M["PLAYER_INITIAL_LIVES=3"]
    L --> N["UI_PROPERTIES_FILE_NAME"]
    L --> O["game.properties"]
    L --> P["user-interface.properties"]
```

여기서 ConfigMap과 Pod의 역할을 구분하면 다음과 같다.

| 구분 | 역할 |
|---|---|
| ConfigMap | 설정 데이터 저장 |
| `configMapKeyRef` | 특정 Key의 값을 환경 변수로 전달 |
| `volumes` | ConfigMap을 Volume 데이터 원본으로 지정 |
| `items` | 파일로 사용할 Key 선택 |
| `volumeMounts` | Volume을 컨테이너 경로에 연결 |
| Container | 환경 변수와 파일을 사용 |

결국 ConfigMap 자체는 설정을 저장하고, Pod는 해당 설정을 어떤 형태로 사용할지 결정한다.

---

### yq를 이용한 Pod YAML 구조 분석

이번에는 yq로 Pod YAML의 Mapping과 Sequence를 분석해보자.

먼저 컨테이너의 이름을 조회한다.

```bash
yq '.spec.containers[0].name' configmap-demo-pod.yaml
```

출력:

```text
demo
```

컨테이너 이미지를 조회한다.

```bash
yq '.spec.containers[0].image' configmap-demo-pod.yaml
```

출력:

```text
alpine:3.21
```

#### 첫 번째 환경 변수 이름 조회

```bash
yq '.spec.containers[0].env[0].name' configmap-demo-pod.yaml
```

출력:

```text
PLAYER_INITIAL_LIVES
```

#### 첫 번째 환경 변수가 참조하는 ConfigMap 조회

```bash
yq '.spec.containers[0].env[0].valueFrom.configMapKeyRef.name' \
  configmap-demo-pod.yaml
```

출력:

```text
game-demo
```

#### 첫 번째 환경 변수가 참조하는 Key 조회

```bash
yq '.spec.containers[0].env[0].valueFrom.configMapKeyRef.key' \
  configmap-demo-pod.yaml
```

출력:

```text
player_initial_lives
```

#### 모든 환경 변수 이름 조회

```bash
yq '.spec.containers[0].env[].name' configmap-demo-pod.yaml
```

출력:

```text
PLAYER_INITIAL_LIVES
UI_PROPERTIES_FILE_NAME
```

#### Volume Mount 경로 조회

```bash
yq '.spec.containers[0].volumeMounts[0].mountPath' \
  configmap-demo-pod.yaml
```

출력:

```text
/config
```

#### Volume이 참조하는 ConfigMap 이름 조회

```bash
yq '.spec.volumes[0].configMap.name' configmap-demo-pod.yaml
```

출력:

```text
game-demo
```

#### 파일로 선택된 모든 Key 조회

```bash
yq '.spec.volumes[0].configMap.items[].key' \
  configmap-demo-pod.yaml
```

출력:

```text
game.properties
user-interface.properties
```

이처럼 yq를 활용하면 Kubernetes Manifest의 복잡한 계층 구조도 경로 표현식을 이용해 분석할 수 있다.

---

### Mapping과 Sequence의 데이터 타입 확인하기

yq의 `kind` 연산자를 사용하면 각 노드가 Scalar, Mapping, Sequence 중 어떤 구조인지 확인할 수 있다.

예를 들어 다음 명령어를 실행한다.

```bash
yq '.spec | kind' configmap-demo-pod.yaml
```

출력:

```text
map
```

`spec`은 Mapping이다.

컨테이너 목록의 타입을 확인한다.

```bash
yq '.spec.containers | kind' configmap-demo-pod.yaml
```

출력:

```text
seq
```

`containers`는 Sequence이다.

첫 번째 컨테이너의 타입을 확인한다.

```bash
yq '.spec.containers[0] | kind' configmap-demo-pod.yaml
```

출력:

```text
map
```

첫 번째 컨테이너는 Mapping이다.

환경 변수 목록도 확인해보자.

```bash
yq '.spec.containers[0].env | kind' configmap-demo-pod.yaml
```

출력:

```text
seq
```

이러한 결과를 정리하면 다음과 같다.

| 경로 | kind |
|---|---|
| `.spec` | `map` |
| `.spec.containers` | `seq` |
| `.spec.containers[0]` | `map` |
| `.spec.containers[0].env` | `seq` |
| `.spec.containers[0].env[0]` | `map` |
| `.spec.containers[0].env[0].valueFrom` | `map` |
| `.spec.volumes` | `seq` |
| `.spec.volumes[0].configMap.items` | `seq` |

이 방법은 복잡한 Kubernetes YAML을 분석할 때 특히 유용하다.

어떤 필드가 배열인지 객체인지 혼동된다면 yq로 실제 데이터 구조를 확인할 수 있다.

---

### ConfigMap을 변경하면 컨테이너에도 자동으로 반영될까?

ConfigMap을 사용하는 환경에서 중요한 운영상의 특징이 있다.

ConfigMap의 값을 변경했을 때 컨테이너 내부에 반영되는 방식은 **환경 변수와 Volume Mount에서 서로 다르다.**

#### 환경 변수로 전달한 경우

환경 변수는 컨테이너가 시작될 때 설정된다.

따라서 ConfigMap의 값이 변경되더라도 이미 실행 중인 컨테이너의 환경 변수가 자동으로 변경되지는 않는다.

예를 들어 다음 값이 있다고 가정하자.

```yaml
player_initial_lives: "3"
```

컨테이너 내부에는 다음 환경 변수가 존재한다.

```text
PLAYER_INITIAL_LIVES=3
```

이후 ConfigMap을 다음과 같이 변경했다고 가정하자.

```yaml
player_initial_lives: "5"
```

ConfigMap은 변경되었지만 실행 중인 컨테이너에서는 여전히 다음 값이 유지될 수 있다.

```text
PLAYER_INITIAL_LIVES=3
```

새로운 값을 적용하려면 Pod를 다시 생성해야 한다.

Deployment가 관리하는 Pod라면 Rolling Update를 수행하여 새로운 Pod가 생성되도록 할 수 있다.

예를 들어 다음 명령어를 사용할 수 있다.

```bash
kubectl rollout restart deployment/<deployment-name>
```

하지만 이번 예제는 Deployment가 아니라 Pod를 직접 생성했으므로 이 명령어를 사용할 수 없다.

이번 예제에서는 Pod를 삭제한 후 다시 생성하면 변경된 환경 변수를 확인할 수 있다.

```bash
kubectl delete -f configmap-demo-pod.yaml
```

```bash
kubectl apply -f configmap-demo-pod.yaml
```

새로운 Pod에서는 변경된 값을 사용할 수 있다.

---

### Volume Mount로 전달한 경우

ConfigMap을 Volume으로 마운트했다면 동작이 다르다.

ConfigMap의 데이터가 변경되면 Kubernetes는 변경된 내용을 Volume에 반영할 수 있다.

예를 들어 다음 설정을 변경했다고 가정하자.

**변경 전**

```properties
enemy.types=aliens,monsters
```

**변경 후**

```properties
enemy.types=aliens,monsters,robots
```

ConfigMap을 다시 적용한다.

```bash
kubectl apply -f game-demo-configmap.yaml
```

이후 Kubernetes의 ConfigMap Volume 갱신 과정을 거쳐 컨테이너의 파일 내용이 변경될 수 있다.

```mermaid
flowchart TD
    A["ConfigMap 데이터 변경"] --> B["kubectl apply"]
    B --> C["Kubernetes API Server"]
    C --> D["ConfigMap 갱신"]

    D --> E["kubelet이 변경 감지"]
    E --> F["ConfigMap Volume 갱신"]

    F --> G["/config/game.properties"]
```

다만 ConfigMap Volume의 변경 사항이 항상 즉시 반영되는 것은 아니다.

kubelet의 동기화 주기와 캐시 전파 시간 등에 따라 지연될 수 있다.

또한 Volume에 변경 내용이 반영되더라도 애플리케이션이 해당 파일을 다시 읽지 않으면 실제 동작에는 반영되지 않을 수 있다.

따라서 설정 파일의 변경 사항을 즉시 적용해야 하는 애플리케이션이라면 별도의 설정 재로딩 구조가 필요할 수 있다.

---

### 환경 변수와 Volume Mount의 변경 반영 차이

| 구분 | 환경 변수 | ConfigMap Volume |
|---|---|---|
| 설정 전달 시점 | 컨테이너 시작 시 | Volume 마운트 및 갱신 시 |
| ConfigMap 변경 감지 | 실행 중인 환경 변수는 자동 변경되지 않음 | 변경 내용이 Volume에 반영될 수 있음 |
| Pod 재생성 | 새로운 값 적용에 필요 | 일반적인 Volume 갱신에는 불필요 |
| 애플리케이션 재로딩 | 새 Pod에서 환경 변수 사용 | 애플리케이션의 파일 재로딩 동작 필요 |
| 대표 사용처 | 단순 설정값 | 설정 파일, 여러 줄 문자열 |
| 주의사항 | 구버전과 신버전 값이 혼재할 수 있음 | 동기화 지연 발생 가능 |

또한 `subPath`로 ConfigMap의 특정 파일만 마운트한 경우에는 ConfigMap 변경 사항이 자동으로 반영되지 않는다.

따라서 실무에서는 단순히 ConfigMap을 사용한다는 사실뿐 아니라 **어떤 방식으로 Pod에 전달했는지**까지 확인해야 한다.

---

### ConfigMap을 사용할 때 발생할 수 있는 오류

ConfigMap과 Pod는 서로 다른 Kubernetes 리소스이다.

따라서 두 리소스 사이의 참조 관계가 잘못되면 Pod가 정상적으로 실행되지 않을 수 있다.

#### 1. ConfigMap이 존재하지 않는 경우

다음 설정을 살펴보자.

```yaml
valueFrom:
  configMapKeyRef:
    name: game-demo
    key: player_initial_lives
```

Pod는 `game-demo`라는 ConfigMap을 참조한다.

하지만 해당 ConfigMap이 존재하지 않는다면 환경 변수의 값을 가져올 수 없다.

이 경우 컨테이너가 정상적으로 시작되지 못할 수 있다.

다음 명령어로 확인한다.

```bash
kubectl describe pod configmap-demo-pod
```

이벤트나 컨테이너 상태에서 ConfigMap 관련 오류를 확인할 수 있다.

#### 2. ConfigMap의 Key가 잘못된 경우

다음 설정을 살펴보자.

```yaml
configMapKeyRef:
  name: game-demo
  key: player_initial_life
```

실제 ConfigMap에는 다음 Key가 존재한다.

```yaml
player_initial_lives: "3"
```

하지만 Pod에서는 `player_initial_life`를 참조하고 있다.

이름이 다르기 때문에 값을 가져올 수 없다.

따라서 ConfigMap을 참조할 때는 Key 이름을 정확하게 작성해야 한다.

#### 3. ConfigMap과 Pod의 Namespace가 다른 경우

Pod가 ConfigMap을 참조하려면 두 리소스가 같은 Namespace에 있어야 한다.

예를 들어 다음과 같은 상황을 생각해보자.

```text
Namespace: development
 └── ConfigMap: game-demo

Namespace: production
 └── Pod: configmap-demo-pod
```

`production`의 Pod는 `development` Namespace에 존재하는 ConfigMap을 `configMapKeyRef`로 직접 참조할 수 없다.

따라서 ConfigMap과 Pod의 Namespace를 확인해야 한다.

#### 4. Volume 이름이 일치하지 않는 경우

다음 설정은 잘못된 예시이다.

```yaml
volumeMounts:
  - name: application-config
    mountPath: /config

volumes:
  - name: config
    configMap:
      name: game-demo
```

`volumeMounts`에서는 `application-config`를 참조하지만 `volumes`에는 `config`라는 이름의 Volume만 존재한다.

이 경우 Kubernetes의 Pod 설정 검증에서 오류가 발생할 수 있다.

따라서 다음 두 값이 일치해야 한다.

```text
volumeMounts.name
        =
volumes.name
```

---

### kubectl로 ConfigMap 관련 오류 확인하기

Pod가 정상적으로 생성되지 않는다면 다음 명령어를 순서대로 확인할 수 있다.

#### Pod 상태 확인

```bash
kubectl get pods
```

#### Pod 상세 정보 확인

```bash
kubectl describe pod configmap-demo-pod
```

#### ConfigMap 존재 여부 확인

```bash
kubectl get configmap game-demo
```

#### ConfigMap 데이터 확인

```bash
kubectl get configmap game-demo -o yaml
```

#### Pod의 ConfigMap 참조 설정 확인

```bash
kubectl get pod configmap-demo-pod -o yaml
```

이러한 명령어를 이용하면 다음 문제를 구분할 수 있다.

```mermaid
flowchart TD
    A["Pod 실행 실패"] --> B["Pod 상태 확인"]
    B --> C["Events 확인"]

    C --> D{"ConfigMap 존재?"}

    D -->|"아니오"| E["ConfigMap 생성"]
    D -->|"예"| F{"Key 이름 일치?"}

    F -->|"아니오"| G["Key 수정"]
    F -->|"예"| H{"Namespace 일치?"}

    H -->|"아니오"| I["Namespace 확인"]
    H -->|"예"| J["Volume 및 Pod 설정 확인"]
```

이때 애플리케이션 로그만 확인해서는 원인을 파악하기 어려울 수 있다.

ConfigMap 참조 오류는 컨테이너가 실행되기 전에 발생할 수 있기 때문이다.

따라서 `kubectl describe pod`의 이벤트를 함께 확인하는 것이 좋다.

---

### 실무에서 ConfigMap을 활용하는 방법

실제 백엔드 서비스에서는 ConfigMap을 통해 애플리케이션 설정을 관리할 수 있다.

예를 들어 Spring Boot 애플리케이션을 Kubernetes에 배포한다고 가정하자.

애플리케이션 설정을 다음과 같이 ConfigMap으로 정의할 수 있다.

```yaml
apiVersion: v1
kind: ConfigMap

metadata:
  name: payment-service-config

data:
  application.yml: |
    server:
      port: 8080

    payment:
      retry:
        enabled: true
        max-attempts: 3

    logging:
      level:
        root: INFO
```

이 ConfigMap에는 Spring Boot의 `application.yml` 내용이 문자열로 저장되어 있다.

이를 Volume으로 마운트하면 컨테이너 내부에서 설정 파일을 읽을 수 있다.

예를 들어 Deployment에서 다음과 같이 설정할 수 있다.

```yaml
apiVersion: apps/v1
kind: Deployment

metadata:
  name: payment-service

spec:
  replicas: 2

  selector:
    matchLabels:
      app: payment-service

  template:
    metadata:
      labels:
        app: payment-service

    spec:
      containers:
        - name: payment-service
          image: example/payment-service:1.0.0

          ports:
            - containerPort: 8080

          volumeMounts:
            - name: application-config
              mountPath: /config
              readOnly: true

      volumes:
        - name: application-config
          configMap:
            name: payment-service-config

            items:
              - key: application.yml
                path: application.yml
```

이 설정은 컨테이너 내부에 다음 파일을 제공한다.

```text
/config/application.yml
```

Spring Boot는 실행 환경과 설정에 따라 외부 설정 파일을 읽을 수 있으므로, 이러한 구조를 활용해 애플리케이션 이미지와 설정을 분리할 수 있다.

다만 실제 운영에서는 기존 설정과의 우선순위, 설정 파일 로딩 경로, 환경 변수 재정의 여부 등을 함께 고려해야 한다.

또한 단순히 파일을 마운트했다고 해서 실행 중인 Spring Boot의 모든 설정이 자동으로 갱신되는 것은 아니다.

설정 변경을 반영하려면 애플리케이션의 설정 로딩 방식과 재시작 또는 재로딩 정책을 함께 설계해야 한다.

---

### ConfigMap과 Secret의 역할 구분

ConfigMap은 일반 설정을 저장하기 위한 리소스이다.

비밀번호나 토큰 같은 민감한 정보를 ConfigMap에 직접 저장하는 것은 피해야 한다.

예를 들어 다음과 같은 설정은 주의가 필요하다.

```yaml
data:
  DB_PASSWORD: "my-password"
```

이 값은 일반 문자열로 저장된다.

따라서 ConfigMap에 접근할 수 있는 사용자나 시스템이 값을 조회할 수 있다.

민감한 데이터는 Secret 또는 별도의 Secret 관리 시스템을 사용하는 것이 좋다.

| 구분 | ConfigMap | Secret |
|---|---|---|
| 주요 용도 | 일반 설정 | 민감한 데이터 |
| 데이터 표현 | 문자열 및 바이너리 데이터 | 문자열 또는 바이너리 데이터 |
| 환경 변수 주입 | 가능 | 가능 |
| Volume Mount | 가능 | 가능 |
| 데이터 보호 | 별도 보안 설정 필요 | 별도 보안 설정 필요 |
| 대표 예시 | 로그 레벨, 서버 주소 | 비밀번호, API Key, 인증서 |

단, Secret도 기본적으로 완전한 보안을 보장하는 것은 아니다.

Kubernetes Secret을 안전하게 사용하려면 RBAC, 저장 시 암호화, 접근 통제 등의 보안 설정이 필요하다.

---

### 실무에서 YAML의 Mapping과 Sequence를 이해해야 하는 이유

Kubernetes Manifest는 여러 개의 Mapping과 Sequence를 조합하여 구성된다.

앞서 살펴본 ConfigMap과 Pod만 하더라도 다음과 같은 구조가 등장한다.

```text
ConfigMap
 └── data
      ├── Key: Value
      ├── Key: Value
      └── Key: Multi-line String

Pod
 └── spec
      ├── containers[]
      │    ├── command[]
      │    ├── env[]
      │    │    └── valueFrom
      │    │         └── configMapKeyRef
      │    │
      │    └── volumeMounts[]
      │
      └── volumes[]
           └── configMap
                └── items[]
```

이러한 구조를 처음부터 외우기는 쉽지 않다.

하지만 각 필드가 Mapping인지 Sequence인지 구분하면 YAML을 이해하는 과정이 훨씬 단순해진다.

예를 들어 다음 세 가지를 기억하면 된다.

**첫째, Mapping은 Key와 Value의 관계를 표현한다.**

```yaml
metadata:
  name: game-demo
```

**둘째, Sequence는 여러 개의 요소를 표현한다.**

```yaml
containers:
  - name: demo
    image: alpine:3.21
```

**셋째, Mapping과 Sequence는 서로 중첩될 수 있다.**

```yaml
env:
  - name: PLAYER_INITIAL_LIVES
    valueFrom:
      configMapKeyRef:
        name: game-demo
        key: player_initial_lives
```

이 세 가지 구조를 이해하면 Deployment, StatefulSet, Service, Volume 등 다른 Kubernetes 리소스의 YAML도 같은 방식으로 분석할 수 있다.

---

### 실습 리소스 정리하기

모든 확인을 마쳤다면 생성한 리소스를 삭제한다.

먼저 Pod를 삭제한다.

```bash
kubectl delete -f configmap-demo-pod.yaml
```

정상적으로 삭제되면 다음과 같은 메시지가 출력된다.

```text
pod "configmap-demo-pod" deleted
```

이후 ConfigMap을 삭제한다.

```bash
kubectl delete -f game-demo-configmap.yaml
```

출력:

```text
configmap "game-demo" deleted
```

리소스가 삭제되었는지 확인한다.

```bash
kubectl get pods
```

```bash
kubectl get configmaps
```

`configmap-demo-pod`와 `game-demo`가 더 이상 목록에 나타나지 않는지 확인한다.

실무에서는 ConfigMap을 사용하는 Pod가 존재하는 상태에서 ConfigMap을 삭제하면 애플리케이션에 영향을 줄 수 있으므로, 참조 관계를 확인하고 삭제해야 한다.

---

### 정리

Kubernetes Manifest는 YAML의 Mapping과 Sequence를 조합하여 구성된다.

Mapping은 Key와 Value의 관계로 데이터를 표현하며, Sequence는 여러 개의 데이터를 순서대로 표현한다.

ConfigMap과 Pod는 이러한 구조를 이해하기 좋은 예제이다.

ConfigMap은 설정 데이터를 Key-Value 형태로 저장한다.

Pod는 ConfigMap의 데이터를 환경 변수 또는 파일 형태로 사용할 수 있다.

이번에 살펴본 핵심 내용을 정리하면 다음과 같다.

| 항목 | 핵심 내용 |
|---|---|
| Mapping | Key-Value 구조 |
| Sequence | 여러 요소를 순서대로 저장하는 구조 |
| ConfigMap | 애플리케이션 일반 설정 데이터 저장 |
| `data` | ConfigMap의 설정값을 저장하는 Mapping |
| `containers` | 컨테이너 목록을 정의하는 Sequence |
| `command` | 실행 명령을 정의하는 문자열 Sequence |
| `env` | 환경 변수 목록을 정의하는 Sequence |
| `valueFrom` | 환경 변수 값을 외부 참조에서 가져오는 설정 |
| `configMapKeyRef` | ConfigMap의 특정 Key를 참조 |
| `volumeMounts` | 컨테이너에 연결할 Volume Mount 목록 |
| `volumes` | Pod에서 사용할 Volume 목록 |
| `configMap.name` | 참조할 ConfigMap 이름 |
| `items` | 파일로 사용할 ConfigMap Key 선택 |
| `mountPath` | 컨테이너 내부의 마운트 경로 |
| `readOnly` | 읽기 전용 마운트 지정 |

또한 ConfigMap의 설정을 컨테이너에 전달하는 방식에 따라 변경 사항이 반영되는 동작도 달라진다.

**환경 변수로 전달한 ConfigMap 값은 실행 중인 컨테이너에 자동으로 갱신되지 않는다.**

반면 **Volume으로 마운트한 ConfigMap 데이터는 Kubernetes의 동기화 과정을 통해 파일에 반영될 수 있다.**

하지만 애플리케이션이 파일의 변경 사항을 자동으로 읽는 것은 아니므로 실제 운영에서는 설정 재로딩 정책까지 고려해야 한다.

이번에 사용한 주요 명령어는 다음과 같다.

| 명령어 | 목적 |
|---|---|
| `kubectl apply -f game-demo-configmap.yaml` | ConfigMap 생성 |
| `kubectl get configmaps` | ConfigMap 목록 확인 |
| `kubectl describe configmap game-demo` | ConfigMap 상세 정보 확인 |
| `kubectl apply -f configmap-demo-pod.yaml` | Pod 생성 |
| `kubectl get pods` | Pod 상태 확인 |
| `kubectl describe pod configmap-demo-pod` | Pod 설정 및 이벤트 확인 |
| `kubectl exec -it configmap-demo-pod -- sh` | 컨테이너 내부 접속 |
| `env` | 환경 변수 확인 |
| `ls /config` | 마운트된 파일 목록 확인 |
| `cat /config/game.properties` | 설정 파일 내용 확인 |
| `yq '.data \| kind' game-demo-configmap.yaml` | Mapping 여부 확인 |
| `yq '.spec.containers \| kind' configmap-demo-pod.yaml` | Sequence 여부 확인 |

결국 Kubernetes YAML의 구조를 이해하는 핵심은 복잡한 필드 이름을 암기하는 것이 아니다.

**각 필드가 Mapping인지 Sequence인지 구분하고, 데이터가 어떤 계층 관계를 통해 연결되는지 이해하는 것**이다.

이를 이해하면 ConfigMap뿐 아니라 Deployment, StatefulSet, Service 등 다양한 Kubernetes 리소스의 Manifest를 읽고 작성하는 과정도 훨씬 수월해진다.

#### 한 줄 요약

> Kubernetes Manifest는 YAML의 Mapping과 Sequence를 중첩하여 구성되며, ConfigMap은 Key-Value 형태로 저장된 설정 데이터를 Pod에 환경 변수 또는 파일로 전달하는 리소스이다. `env`, `volumeMounts`, `volumes`, `items`의 구조를 이해하면 Kubernetes 설정이 실제 컨테이너에 적용되는 과정을 정확하게 파악할 수 있다.
