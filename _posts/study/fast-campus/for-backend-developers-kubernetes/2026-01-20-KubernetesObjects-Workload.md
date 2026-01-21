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


## 04. Pod Scheduling

Kubernetes 클러스터는 일반적으로 **여러 개의 노드(Node)** 로 구성된다.
Pod가 새로 생성되거나, 재시작·재배치가 필요해지면 Kubernetes는 다음 질문에 답해야 한다.

> “이 Pod를 **어느 노드에 배치할 것인가?**”

이 결정을 담당하는 컴포넌트가 **kube-scheduler**이며,
이 판단 과정 전체를 **Pod Scheduling**이라고 부른다.

---

### Pod Scheduling의 기본 구조

스케줄러는 다음 두 단계를 거쳐 노드를 결정한다.

#### 1️⃣ Filtering

> 이 Pod를 **절대 배치할 수 없는 노드**를 제거

#### 2️⃣ Scoring

> 배치 가능한 노드 중 **가장 적합한 노드**를 선택

즉,

```
불가능한 노드 제거 → 가능한 노드 점수 계산 → 최고 점수 노드 선택
```

---

### 모든 노드는 동일하지 않다

실제 클러스터에서는 다음과 같은 상황이 매우 흔하다.

* 일부 노드에만 GPU가 있음
* 고비용 / 저비용 노드가 섞여 있음
* ARM / x86 아키텍처 혼합

그래서 Kubernetes는
**“Pod를 어디에 배치할지”를 제어할 수 있는 YAML 설정들**을 제공한다.

이제부터 하나씩 본다.

---

### 1. Node Selector

#### 개념

**노드의 label을 기준으로 Pod가 배치될 노드를 제한**하는 가장 단순한 방식이다.

---

#### 노드에 label 추가

```bash
kubectl label node node-02 hw-type=gpu
```

* `hw-type=gpu`
  → node-02에 “GPU 노드”라는 의미의 label 부여

---

#### Pod에 nodeSelector 적용

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  nodeSelector:
    hw-type: gpu
    cost: high
  containers:
  - name: my-container
    image: ai-learning:latest
```

##### YAML 필드 상세 설명

* `apiVersion: v1`
  → Pod 리소스의 API 버전

* `kind: Pod`
  → 생성 대상 객체 타입

* `metadata.name`
  → Pod 이름

* `spec.nodeSelector`
  → **Pod가 배치될 노드 조건**

  * 노드의 label과 **정확히 일치**해야 함
  * 여러 조건은 **AND 조건**

  ```
  hw-type=gpu AND cost=high
  ```

* 조건을 만족하는 노드가 없으면
  → Pod는 `Pending` 상태로 대기

📌 **특징 요약**

* 강제 조건
* 단순하지만 표현력은 낮음

---

### 2. Taint & Toleration

#### 개념

* **Taint**: 노드가 Pod를 밀어내는 장치
* **Toleration**: Pod가 그 거부를 무시하는 허가증

---

#### 노드에 taint 설정

```bash
kubectl taint node node-02 hw-type=gpu:NoSchedule
```

##### 의미 해석

* `hw-type=gpu` → taint의 key/value
* `NoSchedule` → toleration 없는 Pod는 절대 배치 불가

##### Effect 종류

* `NoSchedule` : 새 Pod 스케줄 불가
* `PreferNoSchedule` : 가능하면 피함
* `NoExecute` : 기존 Pod도 제거

---

#### Pod에서 toleration 설정

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  tolerations:
  - key: "hw-type"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  containers:
  - name: my-container
    image: ai-learning:latest
```

##### YAML 필드 상세 설명

* `spec.tolerations`
  → Pod가 감내할 수 있는 taint 정의

* `key`
  → node taint의 key와 일치해야 함

* `operator: Equal`
  → key + value가 정확히 같아야 함
  (`Exists`면 value 비교 생략)

* `value`
  → node taint의 value

* `effect`
  → 허용할 taint effect

📌 **핵심 포인트**

* taint는 **노드 기준**
* toleration은 **Pod 기준**
* 항상 쌍으로 이해해야 한다

---

### 3. Node Affinity

#### 개념

Node Selector보다 **훨씬 표현력이 높은 노드 선택 방식**이다.

---

#### requiredDuringSchedulingIgnoredDuringExecution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
spec:
  affinity:
    nodeAffinity:
      requiredDuringSchedulingIgnoredDuringExecution:
        nodeSelectorTerms:
        - matchExpressions:
          - key: hw-type
            operator: In
            values:
            - gpu
```

##### YAML 구조 해설

```
nodeSelectorTerms  → OR
 └─ matchExpressions → AND
```

##### 필드 설명

* `requiredDuringSchedulingIgnoredDuringExecution`

  * 스케줄 시점에는 **반드시 만족**
  * 실행 중에는 깨져도 Pod 제거 안 함

* `matchExpressions`

  * 실제 조건 집합

* `operator`

  * `In`, `NotIn`
  * `Exists`
  * `Gt`, `Lt` (숫자 비교)

📌 **특징**

* nodeSelector의 상위 호환
* 조건 조합 가능

---

#### preferredDuringSchedulingIgnoredDuringExecution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: another-pod
spec:
  affinity:
    nodeAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 10
        preference:
          matchExpressions:
          - key: cpu-type
            operator: In
            values:
            - arm
```

##### 필드 설명

* `preferredDuringSchedulingIgnoredDuringExecution`

  * 만족하면 좋지만 **필수는 아님**

* `weight`

  * 선호도 점수 (1~100)
  * 여러 조건이면 합산

📌 **의미**

> “가능하면 이런 노드면 좋겠다”

---

### 4. Pod Affinity / Anti-Affinity

#### 개념

Pod의 배치를 **다른 Pod의 위치 기준으로 제어**한다.

---

#### Pod Anti-Affinity 예시

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  affinity:
    podAntiAffinity:
      preferredDuringSchedulingIgnoredDuringExecution:
      - weight: 100
        podAffinityTerm:
          labelSelector:
            matchExpressions:
            - key: type
              operator: In
              values:
              - frontend
          topologyKey: "kubernetes.io/hostname"
```

#### YAML 필드 상세 설명

* `labelSelector`
  → 비교 대상 Pod (`type=frontend`)

* `topologyKey`
  → 같은 노드 기준 (`hostname`)
  → zone, region도 가능

* `weight`
  → 강하게 피하려는 정도

📌 **주 용도**

* 고가용성(HA)
* 장애 전파 방지

---

### 5. Pod Disruption Budget (PDB)

#### 개념

**자발적인 종료 상황에서도 반드시 유지할 Pod 수**를 정의한다.

---

#### PDB YAML

```yaml
apiVersion: policy/v1beta1
kind: PodDisruptionBudget
metadata:
  name: my-pdb
spec:
  minAvailable: 2
  selector:
    matchLabels:
      app: my-app
```

##### 필드 설명

* `minAvailable`

  * 항상 살아 있어야 하는 Pod 수
  * 숫자 / 퍼센트 가능

* `selector`

  * 적용 대상 Pod 집합
  * Deployment와 label 일치 필수

📌 `minAvailable: 100%`

* 노드 드레인 불가
* 매우 강력하지만 운영 리스크 큼

---

#### 최종 정리

| 기능               | 역할           |
| ---------------- | ------------ |
| nodeSelector     | 가장 단순한 노드 제한 |
| taint/toleration | 노드 출입 통제     |
| nodeAffinity     | 조건 기반 노드 선택  |
| podAffinity      | Pod 간 거리 조절  |
| PDB              | 운영 중 가용성 보호  |

Pod Scheduling은 단순히
**“Pod를 어디에 올릴까?”** 가 아니라,

> **“이 시스템을 어떤 철학으로 운영할 것인가”**

를 YAML로 표현하는 영역이다.

---


## Ch 5. Kubernetes 객체 – Workload

### 05. ReplicaSet과 Deployment

Kubernetes를 처음 접하면 가장 먼저 이런 실습을 하게 된다.

```bash
kubectl apply -f my-simple-pod.yaml
```

그리고 Pod가 하나 생성된다.

```bash
pod/my-simple-pod created
```

다시 같은 명령을 실행하면:

```bash
pod/my-simple-pod unchanged
```

이 지점에서 중요한 사실 하나가 드러난다.

> **Pod는 “한 번 만들어지면 그대로인 객체”**
> → 스케일링, 업데이트, 복구를 직접 관리해야 한다

---

### Pod를 직접 여러 개 만들면 생기는 문제

Pod를 여러 개 실행하고 싶다면 다음처럼 만들 수도 있다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-simple-pod-01
spec:
  containers:
  - name: my-container
    image: nginx:1.24
---
apiVersion: v1
kind: Pod
metadata:
  name: my-simple-pod-02
spec:
  containers:
  - name: my-container
    image: nginx:1.24
---
apiVersion: v1
kind: Pod
metadata:
  name: my-simple-pod-03
spec:
  containers:
  - name: my-container
    image: nginx:1.24
```

하지만 이 방식에는 치명적인 한계가 있다.

* Pod 하나가 죽어도 자동 복구되지 않는다
* Pod 개수를 늘리거나 줄이기 어렵다
* 이미지 버전을 바꿔도 자동으로 업데이트되지 않는다

그래서 Kubernetes는 **Pod를 직접 관리하지 말라고** 말한다.
그 역할을 대신하는 객체가 바로 **ReplicaSet과 Deployment**다.

---

### ReplicaSet

#### ReplicaSet이란?

ReplicaSet은
**“지정한 개수만큼 Pod를 항상 유지해주는 객체”** 다.

> Pod가 줄어들면 다시 만들고
> Pod가 많아지면 제거한다

---

#### ReplicaSet YAML 예시

```yaml
apiVersion: apps/v1
kind: ReplicaSet
metadata:
  name: nginx-replicaset
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.17
```

---

#### YAML 필드 상세 설명

##### ReplicaSet 자체 정보

* `apiVersion: apps/v1`
  → ReplicaSet이 속한 API 그룹

* `kind: ReplicaSet`
  → 생성할 객체 타입

* `metadata.name`
  → ReplicaSet 이름

---

##### spec.replicas

```yaml
replicas: 3
```

* **항상 유지해야 할 Pod 개수**
* 하나라도 줄어들면 즉시 다시 생성됨

---

##### selector.matchLabels

```yaml
selector:
  matchLabels:
    app: nginx
```

* **ReplicaSet이 관리할 Pod를 식별하는 기준**
* 이 label을 가진 Pod는 모두 관리 대상

⚠️ 매우 중요
ReplicaSet은 “자기가 만든 Pod”를 따로 기억하지 않는다.
**label로만 판단한다.**

그래서 만약:

* 다른 Pod가 우연히 `app: nginx` 라벨을 가지면
* ReplicaSet은 그 Pod까지 **자기 관리 대상**으로 인식한다

👉 실무에서는 **ReplicaSet 전용 고유 label 규칙**을 반드시 사용한다.

---

##### template (Pod 템플릿)

```yaml
template:
  metadata:
    labels:
      app: nginx
  spec:
    containers:
    - name: nginx
      image: nginx:1.17
```

* ReplicaSet이 **새로운 Pod를 만들 때 사용하는 설계도**
* 여기서 정의한 내용이 Pod spec이 된다

---

#### ReplicaSet의 한계

ReplicaSet은 **Pod 개수 유지**에는 매우 충실하지만,
다음 상황에서는 우리가 기대하는 동작을 하지 않는다.

##### ❌ 이미지 버전 변경

* `nginx:1.17` → `nginx:1.18`로 수정
* `kubectl apply`

👉 이미 실행 중인 Pod는 **전혀 바뀌지 않는다**

ReplicaSet은:

* Pod 수만 맞추지
* **Pod spec 변경에 따른 업데이트는 책임지지 않는다**

단,

* 기존 Pod를 수동으로 삭제하면
* 새 Pod를 만들 때는 **변경된 템플릿을 사용**한다

---

### Deployment

#### Deployment란?

Deployment는
**ReplicaSet의 “버전 관리 + 업데이트 전략”을 담당하는 상위 객체**다.

> 실무에서는 **ReplicaSet을 직접 쓰지 않고 Deployment만 사용**한다

---

#### Deployment YAML 예시

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: my-deployment
spec:
  replicas: 3
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
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
        image: nginx:1.17
```

---

#### YAML 필드 설명

##### replicas / selector / template

* 구조는 **ReplicaSet과 거의 동일**
* Deployment가 내부적으로 ReplicaSet을 생성하고 관리한다

---

### Deployment 전략 (strategy)

Deployment의 핵심은 **업데이트 전략**이다.

```yaml
strategy:
  type: RollingUpdate
```

---

### Recreate 전략

```yaml
strategy:
  type: Recreate
```

* 모든 기존 Pod를 **한 번에 종료**
* 새 Pod를 다시 생성
* **서비스 다운타임 발생 가능**

👉 내부 서비스, 배치 작업에는 가능
👉 외부 트래픽 서비스에는 거의 사용하지 않음

---

#### RollingUpdate 전략 (기본값)

```yaml
strategy:
  type: RollingUpdate
  rollingUpdate:
    maxSurge: 1
    maxUnavailable: 1
```

##### 필드 설명

* `maxSurge`

  * 업데이트 중 **추가로 생성 가능한 Pod 수**
* `maxUnavailable`

  * 업데이트 중 **일시적으로 줄어들 수 있는 Pod 수**

##### 업데이트 중 Pod 개수 범위

```
replicas - maxUnavailable
~
replicas + maxSurge
```

이 설정 덕분에:

* 무중단 배포
* 점진적 트래픽 전환
  이 가능해진다.

---

### Deployment Rollout 명령어

#### 배포 상태 확인

```bash
kubectl rollout status deployment/my-deployment
```

* 현재 배포가 진행 중인지
* 완료되었는지 확인

---

#### 배포 이력 확인

```bash
kubectl rollout history deployment/my-deployment
```

* Revision 번호
* 과거 배포 기록 확인

---

#### 특정 Revision으로 롤백

```bash
kubectl rollout undo deployment/my-deployment --to-revision=2
```

* 이전 버전으로 즉시 되돌림
* 운영 안정성에서 매우 중요한 기능

---

#### 동일 버전으로 재시작

```bash
kubectl rollout restart deployment/my-deployment
```

* 이미지 변경 없이 Pod 전체 재시작
* 설정 변경 반영, 캐시 초기화 등에 자주 사용

---

### 핵심 정리

* **Pod**

  * 실행 단위
  * 직접 관리 대상 ❌

* **ReplicaSet**

  * Pod 개수 유지
  * 스케일링 담당
  * 업데이트 기능 부족

* **Deployment**

  * ReplicaSet 관리
  * 버전 관리
  * 무중단 배포
  * 롤백 지원

👉 **실무에서 Pod나 ReplicaSet을 직접 다루는 일은 거의 없다**
👉 Deployment가 Kubernetes 애플리케이션 배포의 표준이다.

---


