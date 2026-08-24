---
layout: post
bigtitle: 'Part 2. 백엔드 개발과 Kubernetes'
subtitle: Ch 9. Namespace를 이용한 개발 환경과 운영 환경 분리
date: '2026-08-24 00:00:10 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 9. Namespace를 이용한 개발 환경과 운영 환경 분리

# Ch 9. Namespace를 이용한 개발 환경과 운영 환경 분리
* toc
{:toc}

---

## 01. Namespace를 이용한 개발 환경과 운영 환경 분리

Kubernetes 클러스터에는 여러 애플리케이션과 조직의 워크로드가 함께 배포될 수 있다. 모든 객체를 하나의 공간에서 관리하면 이름 충돌이 발생하기 쉽고, 개발자가 테스트 목적으로 변경한 설정이 운영 워크로드에 영향을 줄 위험도 커진다.

Namespace는 하나의 Kubernetes 클러스터를 조직, 프로젝트, 팀, 환경과 같은 기준으로 논리적으로 구분하는 기능이다. 개발 환경과 운영 환경을 서로 다른 Namespace로 분리하면 객체 이름, 권한, 자원 사용량과 네트워크 정책을 환경별로 관리할 수 있다.

```mermaid
flowchart TD
    A["Kubernetes Cluster"] --> B["project-001-dev"]
    A --> C["project-001-stage"]
    A --> D["project-001-prod"]
    B --> E["개발 및 기능 테스트"]
    C --> F["배포 전 통합 검증"]
    D --> G["운영 서비스"]
```

다만 Namespace는 객체를 분류하는 논리적 경계이지, 그 자체만으로 완전한 보안 격리를 제공하는 기능은 아니다. 운영 환경을 안전하게 분리하려면 RBAC, NetworkPolicy, ResourceQuota, LimitRange와 같은 정책을 함께 적용해야 한다.

#### Namespace가 필요한 이유

개발 환경에서는 기능 변경, 장애 테스트, 이미지 교체, 임시 데이터 생성과 같은 작업이 빈번하게 일어난다. 반면 운영 환경은 안정적인 서비스 제공과 데이터 보호가 우선이다.

두 환경을 하나의 Namespace에서 관리하면 다음과 같은 문제가 발생할 수 있다.

- 같은 이름의 Service나 ConfigMap을 생성할 수 없다.
- 개발용 설정이 운영 Deployment에 연결될 수 있다.
- 잘못된 `kubectl delete` 명령이 운영 객체를 삭제할 수 있다.
- 개발 Pod가 운영 Service를 호출할 수 있다.
- 개발 부하 테스트가 클러스터 자원을 모두 사용할 수 있다.
- 환경별 권한과 배포 정책을 다르게 적용하기 어렵다.

Namespace를 분리하면 같은 이름을 환경마다 독립적으로 사용할 수 있다.

```text
project-001-dev
└── Service: api-service

project-001-prod
└── Service: api-service
```

두 Service는 이름이 같지만 Namespace가 다르므로 서로 다른 객체로 관리된다.

#### Namespace의 기본 구조

Namespace는 대부분의 namespaced 객체가 속하는 논리적 범위다.

대표적인 namespaced 객체는 다음과 같다.

- Pod
- Deployment
- StatefulSet
- DaemonSet
- Job
- CronJob
- Service
- Ingress
- ConfigMap
- Secret
- ServiceAccount
- Role
- RoleBinding
- ResourceQuota
- LimitRange
- NetworkPolicy
- PersistentVolumeClaim

반면 다음 객체는 특정 Namespace에 속하지 않고 클러스터 전체에서 관리된다.

- Node
- Namespace
- PersistentVolume
- StorageClass
- ClusterRole
- ClusterRoleBinding
- CustomResourceDefinition

객체가 Namespace에 속하는지 확인하려면 다음 명령을 사용할 수 있다.

```shell
kubectl api-resources --namespaced=true
kubectl api-resources --namespaced=false
```

Namespace는 모든 Kubernetes 객체에 적용되는 공통 계층이 아니다. 특히 Node, StorageClass, PersistentVolume처럼 클러스터 범위에 존재하는 객체는 여러 Namespace에서 공유될 수 있다.

#### 다른 Namespace의 객체 참조

“다른 Namespace의 객체를 참조할 수 없다”는 설명은 객체 종류에 따라 구분해서 이해해야 한다.

Deployment에서 참조하는 ConfigMap, Secret, PersistentVolumeClaim, ServiceAccount는 일반적으로 해당 Pod와 같은 Namespace에 있어야 한다.

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api
  namespace: project-001-dev
spec:
  replicas: 1
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api
    spec:
      serviceAccountName: api-service-account
      containers:
        - name: api
          image: nginx:1.27
          envFrom:
            - configMapRef:
                name: api-config
            - secretRef:
                name: api-secret
          volumeMounts:
            - name: data
              mountPath: /data
      volumes:
        - name: data
          persistentVolumeClaim:
            claimName: api-pvc
```

위 Deployment가 `project-001-dev`에 있다면 `api-service-account`, `api-config`, `api-secret`, `api-pvc`도 같은 Namespace에 있어야 한다. 필드에 다른 Namespace를 지정하는 구조가 제공되지 않기 때문이다.

하지만 모든 객체 참조가 이런 방식으로 제한되는 것은 아니다.

- Service는 클러스터 DNS를 이용해 다른 Namespace에서도 호출할 수 있다.
- PersistentVolume은 클러스터 범위 객체이며 PVC를 통해 연결된다.
- ClusterRole은 여러 Namespace에서 재사용할 수 있다.
- RoleBinding의 Subject는 다른 Namespace의 ServiceAccount를 지정할 수 있다.
- Kubernetes API 접근 권한이 있다면 다른 Namespace의 객체를 조회하거나 변경할 수 있다.

따라서 Namespace는 기본적인 객체 범위를 제공하지만 완전한 접근 차단 경계는 아니다.

#### Namespace는 계층 구조를 지원하지 않는다

Kubernetes의 Namespace는 상위와 하위 관계가 없는 평면 구조다.

다음과 같은 계층 구조를 기본 기능으로 만들 수는 없다.

```text
organization
└── project-001
    ├── dev
    ├── stage
    └── prod
```

`organization`, `project-001`, `dev`를 각각 Namespace로 생성해도 Kubernetes는 이들 사이의 부모와 자식 관계를 인식하지 않는다.

이 구조는 단순하고 직관적이라는 장점이 있지만, 조직과 프로젝트와 환경을 동시에 표현해야 할 때 불편할 수 있다.

현실적인 대안은 이름 규칙과 Label을 함께 사용하는 것이다.

```text
<조직>-<프로젝트>-<환경>
```

예를 들면 다음과 같다.

```text
backend-project-001-dev
backend-project-001-stage
backend-project-001-prod
```

이름만으로도 의미를 파악할 수 있어야 하며, 지나치게 긴 약어나 모호한 표현은 피하는 것이 좋다.

#### Namespace 이름과 Label 설계

환경별 Namespace를 다음과 같이 생성할 수 있다.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: project-001-dev
  labels:
    organization: backend
    project: project-001
    environment: dev
---
apiVersion: v1
kind: Namespace
metadata:
  name: project-001-stage
  labels:
    organization: backend
    project: project-001
    environment: stage
---
apiVersion: v1
kind: Namespace
metadata:
  name: project-001-prod
  labels:
    organization: backend
    project: project-001
    environment: prod
```

Namespace 이름은 사람이 명령을 입력할 때 사용하고, Label은 정책과 자동화 도구가 Namespace를 선택할 때 사용한다.

```shell
kubectl apply -f namespaces.yaml
kubectl get namespaces --show-labels
```

Label을 이용하면 특정 환경에 속한 Namespace만 조회할 수 있다.

```shell
kubectl get namespaces -l environment=prod
kubectl get namespaces -l project=project-001
```

Label은 이름 규칙을 대체하는 것이 아니라 보완하는 수단이다. 이름에는 환경이 표시되지 않고 Label만으로 환경을 구분하면 사람이 명령을 실행할 때 실수하기 쉽다.

#### Label만으로 환경을 분리하면 안 되는 이유

하나의 Namespace 안에 개발과 운영 객체를 함께 배포한 뒤 Label과 Selector만으로 구분할 수도 있다.

```text
Namespace: project-001

Deployment: api-dev
labels:
  environment: dev

Deployment: api-prod
labels:
  environment: prod
```

하지만 이 구성은 다음과 같은 문제를 가진다.

- 모든 객체가 Label Selector로 서로를 찾는 것은 아니다.
- ConfigMap과 Secret은 주로 이름으로 참조한다.
- PVC와 ServiceAccount도 이름으로 참조한다.
- 잘못된 Selector가 다른 환경의 Pod를 선택할 수 있다.
- RBAC와 ResourceQuota를 환경별로 분리하기 어렵다.
- 환경별 일괄 삭제와 조회가 복잡해진다.
- 객체 이름마다 환경 접두사나 접미사가 필요해진다.

따라서 개발, Stage, 운영처럼 수명 주기와 권한이 다른 환경은 별도 Namespace로 분리하고, Label은 Namespace 내부 객체의 애플리케이션과 역할을 구분하는 데 사용하는 것이 적합하다.

#### kubectl에서 Namespace 지정하기

Namespace를 지정하지 않으면 현재 Context에 설정된 기본 Namespace가 사용된다. 기본값은 일반적으로 `default`다.

```shell
kubectl get pods
kubectl get pods -n project-001-dev
kubectl get pods --namespace=project-001-prod
```

현재 Context의 기본 Namespace를 변경할 수도 있다.

```shell
kubectl config set-context \
  --current \
  --namespace=project-001-dev
```

현재 설정을 확인한다.

```shell
kubectl config view --minify \
  --output='jsonpath={..namespace}'
```

운영 작업에서는 Namespace를 명령에 명시하는 습관이 안전하다.

```shell
kubectl get deployments -n project-001-prod
kubectl rollout status deployment/api -n project-001-prod
```

현재 Context가 개발 환경이라고 생각하고 명령을 실행했지만 실제로는 운영 Namespace가 설정되어 있다면 심각한 장애가 발생할 수 있다. 프롬프트에 현재 Context와 Namespace를 표시하는 도구를 사용하는 것도 실수를 줄이는 데 도움이 된다.

#### 프로젝트 중심과 환경 중심의 분리

Namespace를 설계할 때는 프로젝트와 환경 중 어떤 축을 우선할지 결정해야 한다.

##### 프로젝트와 환경을 이름에 함께 표현

하나의 클러스터에서 여러 프로젝트와 환경을 모두 관리한다면 다음 구조를 사용할 수 있다.

```text
project-001-dev
project-001-stage
project-001-prod
project-002-dev
project-002-stage
project-002-prod
```

이 방식은 Namespace 이름만으로 프로젝트와 환경을 확인할 수 있다. 중소 규모의 공유 클러스터에서 적용하기 쉽다.

##### 환경별로 클러스터 분리

운영 환경과 비운영 환경의 보안 및 네트워크 요구사항이 크게 다르다면 클러스터 자체를 분리할 수 있다.

```mermaid
flowchart TD
    A["Development Cluster"] --> B["project-001"]
    A --> C["project-002"]
    D["Production Cluster"] --> E["project-001"]
    D --> F["project-002"]
```

각 클러스터 안에서는 프로젝트별 Namespace만 사용하고, 개발과 운영의 물리적인 경계는 클러스터로 구분한다.

| 구분 | 하나의 클러스터와 Namespace 분리 | 환경별 클러스터 분리 |
|---|---|---|
| 격리 수준 | 논리적 격리 | Control Plane을 포함한 강한 격리 |
| 운영 비용 | 비교적 낮음 | 상대적으로 높음 |
| 자원 공유 | 가능 | 클러스터 사이 공유 불가 |
| 장애 영향 범위 | 클러스터 전체로 확산 가능 | 해당 클러스터로 제한 |
| 네트워크 구성 | 정책으로 분리 | 네트워크 자체를 별도로 구성 가능 |
| 권한 실수 | 다른 Namespace에 영향을 줄 수 있음 | 다른 클러스터에는 직접 영향 없음 |
| 적합한 환경 | 소규모 및 내부 개발 환경 | 중요 운영 환경과 강한 보안 경계 |

클러스터를 추가하면 Control Plane, Node, 네트워크, 모니터링, 보안 정책, 업그레이드와 비용 관리 대상도 함께 늘어난다. 따라서 프로젝트 하나마다 클러스터를 만드는 방식은 규모에 따라 비효율적일 수 있다.

일반적으로 전체 개발 환경과 전체 운영 환경처럼 큰 경계를 클러스터로 나누고, 각 클러스터 내부를 프로젝트 Namespace로 분리하는 구조를 검토할 수 있다.

#### Namespace 간 Service 호출

Namespace가 다르더라도 Service는 Kubernetes DNS를 통해 호출할 수 있다.

같은 Namespace에서는 Service 이름만 사용한다.

```text
http://my-service:8080
```

다른 Namespace의 Service를 호출할 때는 Namespace를 포함한다.

```text
http://my-service.project-001-prod:8080
```

전체 도메인은 다음과 같다.

```text
http://my-service.project-001-prod.svc.cluster.local:8080
```

```mermaid
flowchart LR
    A["개발 Pod<br/>project-001-dev"] --> B["운영 Service DNS<br/>my-service.project-001-prod.svc.cluster.local"]
    B --> C["운영 Pod<br/>project-001-prod"]
```

이 호출 경로가 존재한다는 것은 Namespace만 분리해도 개발과 운영의 네트워크가 자동으로 차단되는 것은 아니라는 뜻이다.

다음과 같은 호출은 모두 장애를 만들 수 있다.

- 개발 애플리케이션이 운영 데이터베이스 API를 호출
- 운영 애플리케이션이 개발용 Service를 호출
- 개발 부하 테스트가 운영 Service로 전송
- 잘못된 환경 변수가 다른 Namespace의 Service DNS를 참조
- 테스트 메시지가 운영 메시지 처리기로 전달

Namespace 간 통신이 필요한 경우도 있다. 인증 서비스나 공용 모니터링 시스템처럼 여러 프로젝트에서 공유하는 Service가 있을 수 있기 때문이다. 따라서 모든 통신을 무조건 허용하거나 차단하기보다 NetworkPolicy로 필요한 경로만 명시적으로 허용해야 한다.

#### NetworkPolicy를 이용한 네트워크 격리

NetworkPolicy를 적용하지 않은 Kubernetes 네트워크는 일반적으로 Namespace가 다르더라도 Pod 간 통신을 허용한다.

다음 정책은 개발과 운영 Namespace의 모든 Pod에 대해 외부 Namespace에서 들어오는 Ingress를 기본적으로 차단한다.

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace-only
  namespace: project-001-dev
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
---
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: allow-same-namespace-only
  namespace: project-001-prod
spec:
  podSelector: {}
  policyTypes:
    - Ingress
  ingress:
    - from:
        - podSelector: {}
```

빈 `podSelector`는 해당 Namespace의 모든 Pod를 선택한다. `ingress.from.podSelector`에 `namespaceSelector`가 없으면 같은 Namespace에 있는 Pod만 선택한다.

따라서 다음 통신은 허용된다.

```text
project-001-dev Pod -> project-001-dev Pod
project-001-prod Pod -> project-001-prod Pod
```

다음 통신은 차단된다.

```text
project-001-dev Pod -> project-001-prod Pod
project-001-prod Pod -> project-001-dev Pod
```

외부 Ingress Controller, 모니터링 시스템, 공용 인증 서비스가 접근해야 한다면 해당 Namespace나 Pod를 선택하는 허용 규칙을 추가해야 한다.

NetworkPolicy를 사용할 때는 다음 사항에 주의해야 한다.

- 클러스터의 CNI Plugin이 NetworkPolicy를 지원해야 한다.
- 여러 NetworkPolicy의 허용 규칙은 합산된다.
- 기본 거부 정책 이후 필요한 통신을 명시적으로 허용해야 한다.
- Ingress와 Egress는 별도로 제어된다.
- DNS, 모니터링, 이미지 Registry, 외부 API 접근 경로를 확인해야 한다.
- NetworkPolicy는 HTTP 경로나 사용자 권한을 제어하지 않는다.

Namespace를 보안 경계로 사용하려면 NetworkPolicy뿐 아니라 RBAC와 Pod 보안 정책도 함께 적용해야 한다.

#### ResourceQuota

여러 Namespace가 하나의 클러스터를 공유하면 CPU, Memory, Storage와 같은 실제 Node 자원도 공유한다.

특정 Namespace가 지나치게 많은 Pod를 생성하거나 자원을 요청하면 다른 Namespace의 워크로드가 스케줄링되지 못할 수 있다. 논리적으로 분리된 Namespace라도 클러스터 자원 고갈을 통해 서로 영향을 줄 수 있는 것이다.

ResourceQuota는 Namespace 전체에서 사용할 수 있는 자원과 생성할 수 있는 객체 수의 상한을 설정한다.

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: project-001-dev-quota
  namespace: project-001-dev
spec:
  hard:
    requests.cpu: "8"
    requests.memory: 16Gi
    limits.cpu: "16"
    limits.memory: 32Gi
    pods: "50"
    services: "20"
    persistentvolumeclaims: "10"
    requests.storage: 200Gi
```

각 필드는 다음을 의미한다.

| 필드 | 의미 |
|---|---|
| `requests.cpu` | Namespace 전체 CPU Request 합계 |
| `requests.memory` | Namespace 전체 Memory Request 합계 |
| `limits.cpu` | Namespace 전체 CPU Limit 합계 |
| `limits.memory` | Namespace 전체 Memory Limit 합계 |
| `pods` | 생성할 수 있는 Pod 수 |
| `services` | 생성할 수 있는 Service 수 |
| `persistentvolumeclaims` | 생성할 수 있는 PVC 수 |
| `requests.storage` | PVC가 요청할 수 있는 전체 Storage 용량 |

ResourceQuota는 실제 순간 사용량보다 객체에 설정된 `requests`와 `limits`의 합을 기준으로 판단한다.

예를 들어 CPU를 거의 사용하지 않는 Pod라도 `requests.cpu: "2"`로 설정되어 있다면 ResourceQuota에서는 CPU 2개를 요청한 것으로 계산한다.

ResourceQuota를 적용한 후 상태를 확인한다.

```shell
kubectl apply -f resource-quota.yaml
kubectl get resourcequota -n project-001-dev
kubectl describe resourcequota project-001-dev-quota \
  -n project-001-dev
```

할당량을 초과하는 객체를 생성하면 API Server가 요청을 거부한다.

```text
exceeded quota
```

#### LimitRange

ResourceQuota가 Namespace 전체 합계를 제한한다면 LimitRange는 Namespace 내부의 개별 Container, Pod 또는 PVC에 적용할 기본값과 최소 및 최대 범위를 설정한다.

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: project-001-dev-limit-range
  namespace: project-001-dev
spec:
  limits:
    - type: Container
      defaultRequest:
        cpu: 100m
        memory: 128Mi
      default:
        cpu: 500m
        memory: 512Mi
      min:
        cpu: 50m
        memory: 64Mi
      max:
        cpu: "2"
        memory: 2Gi
      maxLimitRequestRatio:
        cpu: "4"
        memory: "4"
    - type: PersistentVolumeClaim
      min:
        storage: 1Gi
      max:
        storage: 50Gi
```

`defaultRequest`는 Container에 Request가 없을 때 적용되는 기본값이다.

`default`는 Container에 Limit이 없을 때 적용되는 기본 Limit이다.

`min`과 `max`는 개별 객체가 설정할 수 있는 최소 및 최대 자원이다.

`maxLimitRequestRatio`는 Limit이 Request보다 지나치게 크게 설정되는 것을 제한한다.

PVC에 대한 `min`과 `max`는 개별 PVC가 요청할 수 있는 Storage 크기를 제한한다.

```shell
kubectl apply -f limit-range.yaml
kubectl get limitrange -n project-001-dev
kubectl describe limitrange project-001-dev-limit-range \
  -n project-001-dev
```

LimitRange가 적용된 Namespace에서 Resource 설정 없이 Pod를 생성하면 기본 Request와 Limit이 자동으로 적용될 수 있다.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: quota-test
  namespace: project-001-dev
spec:
  containers:
    - name: nginx
      image: nginx:1.27
```

생성된 Pod의 Resource 설정을 확인한다.

```shell
kubectl apply -f quota-test-pod.yaml
kubectl get pod quota-test \
  -n project-001-dev \
  -o jsonpath='{.spec.containers[0].resources}'
```

#### ResourceQuota와 LimitRange 비교

| 구분 | ResourceQuota | LimitRange |
|---|---|---|
| 적용 범위 | Namespace 전체 | 개별 Container, Pod, PVC |
| 주요 목적 | 전체 자원 및 객체 수 제한 | 기본값과 최소 및 최대 범위 설정 |
| CPU와 Memory | 전체 Request와 Limit 합계 제한 | 개별 객체의 Request와 Limit 제한 |
| Storage | 전체 요청량과 PVC 개수 제한 | 개별 PVC 크기 제한 |
| 기본값 적용 | 하지 않음 | Request와 Limit 기본값 적용 가능 |
| 대표 사례 | 개발 Namespace의 전체 CPU를 8개로 제한 | Container Memory를 최대 2Gi로 제한 |

ResourceQuota만 설정하고 개별 Container에 Request와 Limit을 지정하지 않으면 객체 생성이 거부될 수 있다. LimitRange로 기본값을 제공하거나 모든 워크로드 YAML에 Resource를 명시해야 한다.

두 객체는 경쟁 관계가 아니라 함께 사용하는 보완적인 정책이다.

```mermaid
flowchart TD
    A["Pod 생성 요청"] --> B["LimitRange 검사"]
    B --> C["기본 Request와 Limit 적용"]
    C --> D["개별 최소 및 최대 범위 검사"]
    D --> E["ResourceQuota 검사"]
    E --> F{"Namespace 전체 할당량 이내"}
    F -->|"예"| G["Pod 생성 허용"]
    F -->|"아니오"| H["API 요청 거부"]
```

#### Namespace 생성과 삭제 권한 제한

Namespace는 클러스터 범위 객체다. 일반적인 namespaced Role만으로 Namespace 생성과 삭제 권한을 관리할 수 없으며 ClusterRole과 ClusterRoleBinding 수준의 권한이 필요하다.

일반 개발자에게 Namespace 생성 권한을 무제한으로 부여하면 다음과 같은 문제가 발생할 수 있다.

- ResourceQuota가 없는 Namespace 생성
- NetworkPolicy가 없는 Namespace 생성
- 조직의 보안 정책을 우회하는 워크로드 배포
- 관리되지 않는 Secret과 ServiceAccount 생성
- 비용과 자원 사용량 추적 누락

사용자의 Namespace 권한은 다음과 같이 확인할 수 있다.

```shell
kubectl auth can-i create namespaces
kubectl auth can-i delete namespaces
```

특정 사용자 권한을 확인할 수 있는 권한이 있다면 다음과 같이 검사한다.

```shell
kubectl auth can-i create namespaces \
  --as=developer@example.com
```

Namespace 삭제 권한은 특히 주의해야 한다.

```shell
kubectl delete namespace project-001-prod
```

Namespace를 삭제하면 해당 Namespace에 속한 Deployment, Pod, Service, Secret, ConfigMap, PVC와 같은 객체가 함께 삭제된다. 일부 객체의 Finalizer 처리에 따라 삭제가 즉시 끝나지 않고 `Terminating` 상태에 머물 수도 있다.

운영 Namespace의 삭제 권한은 최소 인원에게만 부여하고, GitOps나 승인된 자동화 경로를 통해 생성과 변경을 수행하는 것이 안전하다.

#### Namespace를 지나치게 세분화하지 않기

Namespace를 세밀하게 나눌수록 모든 환경을 명확하게 분리할 수 있을 것처럼 보이지만 관리 대상도 함께 증가한다.

Namespace마다 다음 설정이 필요할 수 있다.

- RBAC
- ResourceQuota
- LimitRange
- NetworkPolicy
- Secret
- ServiceAccount
- 모니터링 설정
- 로그 수집 설정
- 배포 파이프라인
- 비용 태그와 Label

기능 하나나 개발자 한 명을 기준으로 Namespace를 생성하면 정책이 중복되고 관리가 복잡해질 수 있다.

Namespace 분리 기준은 다음과 같이 운영 경계가 실제로 달라지는지를 중심으로 판단하는 것이 좋다.

- 접근 권한이 다른가
- 배포 주기가 다른가
- 자원 할당량이 다른가
- 네트워크 정책이 다른가
- 장애 영향 범위를 분리해야 하는가
- 객체의 수명 주기가 다른가
- 비용을 별도로 추적해야 하는가

단순히 객체를 분류하려는 목적이라면 새로운 Namespace보다 Label을 사용하는 것이 적합할 수 있다.

#### Namespace만으로 충분하지 않은 경우

Namespace는 유용한 분리 단위지만 다음 영역은 클러스터 전체에서 공유된다.

- Control Plane
- Node와 컨테이너 Runtime
- CNI 네트워크
- StorageClass와 일부 Storage 인프라
- CustomResourceDefinition
- Admission Webhook
- 클러스터 범위 권한
- 클러스터 전체 장애와 업그레이드 영향

또한 RBAC가 잘못 설정되거나 권한이 높은 Pod가 생성되면 Namespace 경계를 넘어 클러스터 전체에 영향을 줄 수 있다.

중요한 운영 환경에서는 다음 계층을 함께 적용해야 한다.

```mermaid
flowchart TD
    A["환경 분리"] --> B["Namespace"]
    A --> C["RBAC"]
    A --> D["NetworkPolicy"]
    A --> E["ResourceQuota와 LimitRange"]
    A --> F["Pod Security"]
    A --> G["배포 승인과 정책 검사"]
    A --> H["필요한 경우 별도 Cluster"]
```

규제가 적용되는 시스템, 민감한 운영 데이터, 서로 신뢰할 수 없는 조직이 사용하는 환경처럼 강한 격리가 필요하다면 Namespace만으로는 부족할 수 있다. 이 경우 운영 클러스터를 별도로 구성하는 것이 더 명확한 선택이다.

#### 실무적인 Namespace 설계 기준

Namespace를 설계할 때는 다음 원칙을 적용할 수 있다.

- 이름만 보고 프로젝트와 환경을 구분할 수 있게 한다.
- `dev`, `stage`, `prod`처럼 짧고 명확한 환경 이름을 사용한다.
- 프로젝트와 환경을 Namespace 이름에 함께 표현한다.
- 조직, 프로젝트, 환경을 Namespace Label로도 기록한다.
- 개발과 운영을 하나의 Namespace에 혼합하지 않는다.
- Namespace 간 통신을 기본 허용 상태로 방치하지 않는다.
- ResourceQuota와 LimitRange를 함께 적용한다.
- Namespace 생성과 삭제 권한을 제한한다.
- 운영 Namespace 변경은 승인된 배포 절차를 사용한다.
- 강한 보안 경계가 필요하면 클러스터 분리를 검토한다.

### 정리

Namespace는 하나의 Kubernetes 클러스터를 조직, 프로젝트, 환경 단위로 논리적으로 구분하는 기능이다. 개발, Stage, 운영 환경을 별도 Namespace로 나누면 객체 이름, 권한, 자원 정책과 배포 수명 주기를 독립적으로 관리할 수 있다.

하지만 Namespace는 계층 구조를 지원하지 않는다. 조직, 프로젝트, 환경과 같은 여러 단계의 정보를 표현하려면 `project-001-dev`와 같은 이름 규칙과 Label을 함께 사용해야 한다.

또한 Namespace가 다르다고 해서 모든 접근이 자동으로 차단되는 것은 아니다. ConfigMap, Secret, PVC처럼 같은 Namespace에서만 직접 참조할 수 있는 객체도 있지만, Service는 Namespace를 포함한 DNS 이름으로 다른 Namespace에서 호출할 수 있다. 개발과 운영 사이의 잘못된 호출을 방지하려면 NetworkPolicy가 필요하다.

ResourceQuota는 Namespace 전체의 CPU, Memory, Storage와 객체 수를 제한하고, LimitRange는 개별 Container, Pod, PVC의 기본값과 최소 및 최대 범위를 제한한다. 두 정책을 함께 사용하면 하나의 Namespace가 클러스터 자원을 과도하게 점유하는 문제를 줄일 수 있다.

최종적으로 Namespace는 환경 분리의 출발점이지 완전한 보안 경계는 아니다. 안정적인 환경 분리를 위해서는 RBAC, NetworkPolicy, ResourceQuota, LimitRange, Pod 보안 정책을 함께 적용하고, 운영 환경에 더 강한 격리가 필요하다면 클러스터 자체를 분리해야 한다.
