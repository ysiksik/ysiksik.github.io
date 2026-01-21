---
layout: post
bigtitle: 'Part 1. 개발자를 위한 Kubernetes 입문'
subtitle: Ch 5. Kubernetes 객체 - Workload
date: '2026-01-20 00:00:03 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 5. Kubernetes 객체 - Workload

# Ch 5. Kubernetes 객체 - Workload
* toc
{:toc}

---

## 01. Pod

### Pod란?

Pod는 Kubernetes에서 **가장 기본적인 배포(실행) 단위**다.

* Kubernetes는 컨테이너를 “그대로” 배포하지 않고 **항상 Pod 단위로 배포**한다.
* 같은 Pod 안의 컨테이너들은 **같은 실행 환경**을 공유한다.

  * **네트워크 네임스페이스 공유**: 같은 IP / 같은 포트 공간(컨테이너끼리 `localhost`로 통신 가능)
  * **볼륨 공유 가능**: 같은 스토리지를 함께 마운트 가능
* 그래서 Pod는 보통 다음 두 경우에 많이 쓴다.

  * 단일 컨테이너(가장 흔함): “앱 컨테이너 1개”
  * 멀티 컨테이너: “앱 + 사이드카(로그 수집, 프록시, 에이전트 등)”

---

### Pod 예시 (nginx)

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-simple-pod
spec:
  containers:
    - name: my-container
      image: nginx:1.24
```

적용:

```bash
kubectl apply -f my-simple-pod.yaml
```

상태 확인(실습에 자주 씀):

```bash
kubectl get pod my-simple-pod
kubectl describe pod my-simple-pod
kubectl logs my-simple-pod
```

---

### 02. Pod Phase

Pod Phase는 Pod의 **큰 흐름(생애주기 상태)** 을 나타내는 상위 상태값이다.

#### Pod Phase - Pending

* Pod가 생성되었지만 아직 **노드에 스케줄링되지 않았거나**,
  이미지 풀/볼륨 마운트 등 준비 단계에서 대기 중인 상태

#### Pod Phase - Running

* Pod가 노드에 배치되고, **컨테이너가 실행 중이거나 실행을 시작한 상태**
* 보통 “서비스가 동작 중”이라고 기대하는 상태지만, 실제 트래픽 수신 여부는 **readiness**로 최종 결정된다(아래 Probe 참고).

#### Pod Phase - Succeeded

* Pod 내 컨테이너들이 **정상 종료(Exit 0)** 했고, 더 이상 재시작하지 않는 상태
* 배치/잡(Job) 성격의 작업에서 자주 보는 상태

#### Pod Phase - Failed

* Pod 내 컨테이너들이 종료되었고, 그 중 **하나 이상이 비정상 종료**(Exit code != 0) 했으며, 더 이상 복구되지 않는 상태

#### Pod Phase - Unknown

* 노드/네트워크 문제 등으로 kube-apiserver가 **Pod 상태를 확정할 수 없는 상태**

---

### 03. Restart Policy (재시작 정책)

컨테이너가 종료되었을 때 Kubernetes가 재시작을 어떻게 처리할지 결정한다.

* `Always` : 종료되면 항상 재시작 (일반적인 서버/서비스 Pod에서 기본값에 가까운 감각)
* `OnFailure` : 실패(비정상 종료)한 경우에만 재시작
* `Never` : 재시작하지 않음

> Pod의 “Phase”와 컨테이너의 “Restart”는 자주 섞여서 헷갈리는데,
> Pod는 살아있어 보이는데 컨테이너는 계속 재시작(CrashLoopBackOff)하는 상황도 흔하다.

---

### 04. 멀티 컨테이너 Pod에서 Phase가 헷갈리는 이유

멀티 컨테이너 Pod에서는 컨테이너 상태가 섞이기 때문에 단순히 “하나 실패=Pod 실패”처럼 단정하기가 어렵다. 실무적으로는 이렇게 이해하면 안전하다.

* **하나 이상 컨테이너가 실행 중이고**, 실패한 컨테이너가 **재시작 정책에 의해 복구 시도 중**이면 보통 `Running`으로 보인다.
* 모든 컨테이너가 종료되었고

  * 전부 정상 종료면 `Succeeded`
  * 하나라도 비정상 종료고 더 이상 복구되지 않으면 `Failed`

즉, “일부 실패”는 상황에 따라 `Running`일 수도 있고, 결국 `Failed`로 굳어질 수도 있다.
(실제로는 `describe`에서 Events와 컨테이너별 상태를 같이 보는 게 정답이다.)

---

### 05. Container Status (컨테이너 단위 상태)

Pod Phase와 별개로, 각 컨테이너는 다음 상태를 가진다.

#### Waiting

* 컨테이너가 실행을 준비 중인 상태
* 이미지 Pull, 볼륨 마운트 대기, 설정 오류 등 다양한 이유가 여기에 걸린다.

#### Running

* 컨테이너가 실행 중인 상태

#### Terminated

* 컨테이너가 종료된 상태(정상/비정상 모두 포함)
* 종료 원인(Exit code, Signal 등)은 `describe`에서 확인하는 편이 빠르다.

---

### 06. Container Restart with Backoff (CrashLoopBackOff)

컨테이너가 계속 실패하면 Kubernetes는 무한정 같은 간격으로 때려 박지 않는다.
대신 **재시작 간격을 점점 늘리는(backoff)** 방식으로 재시작한다.

* 결과적으로 `CrashLoopBackOff`는 “영원히 죽어있음”이 아니라
  “살려보려고 반복 시도 중인데, 너무 자주 죽어서 간격을 늘리는 중”이라는 뜻에 가깝다.

---

### 07. Probe (readiness / liveness / startup)

Probe는 “이 컨테이너를 어떻게 다뤄야 하는가?”를 Kubernetes에 알려주는 장치다.

* **readinessProbe**: 트래픽을 받을 준비가 되었는가?

  * 실패하면 Service 엔드포인트에서 빠져서 **요청을 받지 않게** 된다.
* **livenessProbe**: 살아있는가?

  * 실패하면 컨테이너를 **재시작**한다.
* **startupProbe**: 기동이 느린 앱을 위한 “워밍업 보호막”

  * startupProbe가 통과되기 전까지 liveness/readiness를 본격 적용하지 않게 설계할 수 있다.

요약하면:

* readiness = “연결해도 돼?”
* liveness = “죽었으니 갈아 끼울까?”
* startup = “아직 예열 중이니 좀 봐줘”

---

### 08. Graceful Shutdown (우아한 종료)

Pod를 종료할 때 Kubernetes는 바로 죽이지 않고 **유예 기간**을 준다.

* 이 시간 동안 앱은

  * 요청을 마무리하거나
  * 커넥션을 정리하거나
  * 종료 신호(SIGTERM)에 반응해 안전하게 내려갈 수 있다.

---

### 09. Container Lifecycle Hook

컨테이너의 시작/종료 시점에 특정 동작을 실행할 수 있다.

* 시작 시점: `postStart`
* 종료 시점: `preStop`

예를 들면:

* preStop에서 “더 이상 트래픽 받지 않도록 표시 → 짧게 대기 → 종료” 같은 패턴을 넣어
  실제 무중단 종료 품질을 높이기도 한다.

---

## 02. Multi Container Pod와 Init Container

Kubernetes에서 Pod는 단순히 “컨테이너 묶음”이 아니라
**하나의 애플리케이션 실행 단위**에 가깝다.
이 개념을 가장 잘 드러내는 구성이 바로 *Multi Container Pod*와 *Init Container*다.

---

### Multi Container Pod

#### Multi Container Pod의 개념

* 하나의 Pod 안에 여러 컨테이너가 함께 포함된 구성
* Pod 내 컨테이너들은 **같은 실행 환경을 공유**한다.

  * 같은 IP / 같은 포트 공간
  * 같은 볼륨을 마운트 가능
* 가상 머신 하나에 여러 프로세스를 실행하는 구조와 유사하다.

로컬 환경에서 Docker로 여러 컨테이너를 띄우고
포트나 저장소를 호스트에 공유해 컨테이너끼리 서로 접근하는 구조와도 비슷하다.
다만 Kubernetes에서는 이 개념을 **Pod라는 명확한 단위**로 관리한다는 점이 다르다.

---

### Pod는 “애플리케이션 단위”

일반적으로 Kubernetes에서는 다음과 같은 기준으로 Pod를 구성한다.

* **하나의 Pod = 하나의 애플리케이션**
* 또는 **하나의 마이크로서비스**

즉, Pod는 “컨테이너 단위”라기보다는
**운영과 배포의 최소 단위**로 보는 편이 정확하다.

---

### 왜 Multi Container Pod가 필요한가?

현실의 애플리케이션은 단일 프로세스만으로 구성된 경우보다
여러 프로세스가 긴밀하게 협력하며 동작하는 경우가 많다.

예를 들면:

* 웹 서버 + 애플리케이션 서버
* 애플리케이션 + 로그 수집 에이전트
* 애플리케이션 + 프록시 / 사이드카

이런 구조에서는 프로세스들이 다음과 같은 특성을 가진다.

* 같은 파일 시스템을 공유한다
* 서로의 상태를 빠르게 확인한다
* IPC(Inter-Process Communication)처럼 **로컬 통신**을 전제로 동작한다

만약 이런 구성 요소들을 **각각 다른 Pod로 분리**해버리면:

* 프로세스 간 통신이 네트워크 통신으로 바뀐다
* 공유 스토리지 구성이 복잡해진다
* 배포와 라이프사이클 관리가 오히려 어려워진다

이런 경우 **하나의 Pod 안에 여러 컨테이너를 넣는 것이 더 자연스럽다.**

---

### 컨테이너는 하나의 프로세스를 가진다

Kubernetes 철학에서 중요한 전제 중 하나는 다음이다.

> 하나의 컨테이너는 하나의 주요 프로세스를 가진다.

그래서:

* “여러 프로세스”가 필요할 때
* “강하게 결합된 구성 요소”가 있을 때

→ **멀티 컨테이너 Pod**라는 선택지가 등장한다.

---

### Multi Container Pod 예시

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-web-application
spec:
  containers:
    - name: nginx-container
      image: nginx
    - name: django-container
      image: backend
```

이 구조에서는:

* nginx는 프록시 역할
* django 컨테이너는 애플리케이션 서버 역할
* 같은 Pod 안이므로 `localhost`로 직접 통신 가능

예를 들어 nginx 설정은 다음과 같이 구성할 수 있다.

```nginx
server {
  listen 80;

  location / {
    proxy_pass http://127.0.0.1:8000;
    proxy_set_header Host $host;
    proxy_set_header X-Remote $remote_addr;
  }
}
```

---

### Restart Policy (멀티 컨테이너 관점)

Pod의 Restart Policy는 **Pod 전체에 적용**된다.

* `Always`

  * 모든 컨테이너가 상시 실행되어야 하는 서버형 Pod
* `OnFailure`

  * 일부 컨테이너는 작업 후 종료가 허용되는 경우
* `Never`

  * 종료 상태를 외부에서 감지해 별도로 처리하는 경우

멀티 컨테이너 Pod에서는
“한 컨테이너의 실패가 전체 Pod에 어떤 영향을 주는지”를
항상 같이 고려해야 한다.

---

### Init Container

#### Init Container란?

Init Container는 **Pod가 본격적으로 실행되기 전에 수행되는 준비 작업용 컨테이너**다.

* 일반 컨테이너보다 먼저 실행된다
* **순서대로 하나씩 실행**된다
* 모든 Init Container가 성공해야만 메인 컨테이너가 시작된다

---

### Init Container가 필요한 이유

Init Container는 다음과 같은 작업에 적합하다.

* 설정 파일 생성
* 초기 데이터 다운로드
* 외부 시스템 준비 여부 체크
* 권한 설정, 디렉터리 생성

이런 작업을 메인 컨테이너에 넣으면:

* 컨테이너 시작 로직이 복잡해지고
* 실패 시 원인 파악이 어려워진다

Init Container로 분리하면:

* 역할이 명확해지고
* 실패 지점이 분리되며
* Pod 시작 흐름이 훨씬 읽기 쉬워진다

---

### Init Container 예시

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-example
spec:
  initContainers:
    - name: my-initializer
      image: app-initializer
  containers:
    - name: main-container
      image: my-server
    - name: second-container
      image: another-server
    - name: last-container
      image: sub-server
```

이 Pod의 실행 순서는 다음과 같다.

1. `my-initializer` 실행
2. 성공하면 종료
3. 그 다음에 main / second / last 컨테이너들이 함께 시작

---

### 핵심 정리

* **Multi Container Pod**

  * 하나의 애플리케이션을 구성하는 여러 컨테이너를 묶는 구조
  * 강하게 결합된 구성 요소에 적합
* **Init Container**

  * 애플리케이션 실행 전에 반드시 필요한 준비 단계를 분리
  * 실패를 조기에 드러내고, 구조를 단순하게 만든다

---

