---
layout: post
bigtitle: 'Part 3. 실전 Kubernetes 프로젝트'
subtitle: Ch 6. 스케일 가능한 서비스 환경 구성과 성능 테스트
date: '2026-10-13 00:00:10 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 6. 스케일 가능한 서비스 환경 구성과 성능 테스트

# Ch 6. 스케일 가능한 서비스 환경 구성과 성능 테스트
* toc
{:toc}

---

## 01. Prometheus와 Grafana를 이용한 서비스 모니터링

### Metrics Server, Prometheus, Grafana로 Kubernetes 모니터링 구성하기

SNS 백엔드의 기본 기능은 동작하지만, API가 느려지거나 Pod가 종료됐을 때 원인을 찾으려면 실행 상태를 관찰할 수 있어야 한다. 요청량이 늘어날 때 CPU와 메모리가 어떻게 변하는지 확인하는 것도 필요하다.

이번에는 Metrics Server로 현재 자원 사용량을 확인하고, Prometheus와 Grafana로 시간에 따른 변화를 살펴볼 수 있는 모니터링 환경을 구성한다. 이후 성능 테스트에서는 이 대시보드를 기준으로 부하 전후의 상태를 비교한다.

#### 모니터링 구성 요소의 역할

세 도구는 같은 일을 하는 것처럼 보이지만 역할이 다르다.

| 도구 | 역할 | 이번 실습에서의 용도 |
|---|---|---|
| Metrics Server | Node와 Pod의 CPU·메모리 지표 제공 | `kubectl top`, Resource 기반 HPA |
| Prometheus | 지표 수집, 시계열 저장, PromQL 조회 | 컨테이너 자원 사용량 이력 조회 |
| Grafana | 데이터 소스의 지표를 대시보드로 시각화 | CPU·메모리 그래프 구성 |
| Alertmanager | 알림 그룹화, 중복 제거, 전달 | 이번에는 함께 설치하되 알림 연동은 생략 |

Metrics Server는 장기적인 지표 저장소가 아니다. Prometheus가 Metrics Server의 데이터를 받아 저장하는 구조도 아니다. 각각 Kubelet 등의 Endpoint에서 필요한 지표를 수집한다.

```mermaid
flowchart TD
    A["Kubelet과 컨테이너 지표"] --> B["Metrics Server"]
    B --> C["metrics.k8s.io API"]
    C --> D["kubectl top"]
    C --> E["Resource 기반 HPA"]

    A --> F["Prometheus"]
    G["Node Exporter"] --> F
    H["kube-state-metrics"] --> F
    F --> I["시계열 데이터 저장"]
    I --> J["Grafana 대시보드"]
```

Metrics Server는 자원 기반 자동 확장에 필요한 지표 제공에 초점을 둔다. 자원 사용량 이력과 상세 분석에는 Prometheus 같은 모니터링 시스템을 사용한다. [Metrics Server의 용도와 요구사항](https://github.com/kubernetes-sigs/metrics-server)

#### 설치 전에 Node 자원 확인하기

현재 클러스터에는 User Server, Feed Server, Image Server와 Notification Batch가 실행되고 있다. 모니터링 도구도 Pod로 실행되므로 추가 CPU와 메모리가 필요하다.

먼저 Node와 Pod 배치를 확인한다.

```shell
kubectl get nodes
kubectl get pods -A -o wide
```

특정 Node에 예약된 자원은 다음 명령으로 확인한다.

```shell
kubectl describe node <NODE_NAME>
```

`Allocated resources`에는 Pod의 `requests`와 `limits` 합계가 표시된다. 실제 사용량과 다른 값이라는 점에 주의해야 한다.

- 실제 CPU 사용량이 낮아도 `requests` 합계가 크면 새 Pod가 배치되지 않을 수 있다.
- Node 전체 메모리 중 일부는 운영체제와 Kubernetes 구성 요소가 사용한다.
- Pod를 배치할 수 있는 기준은 전체 용량보다 `Allocatable`에 가깝다.

이번 환경에서는 Node를 2개에서 3개로 늘린다. 다만 Node 3개가 모든 환경에 필요한 고정 조건은 아니다. 인스턴스 사양과 기존 Workload의 자원 설정에 따라 판단한다.

#### EKS Managed Node Group 증설

AWS Console에서 다음 순서로 Node Group 설정을 변경한다.

1. EKS에서 대상 클러스터를 선택한다.
2. **Compute**에서 Managed Node Group을 선택한다.
3. **Edit**에서 Scaling 설정을 연다.
4. Desired Size, Minimum Size, Maximum Size를 각각 `3`으로 지정한다.
5. 변경 내용을 저장한다.

| 항목 | 설정값 | 의미 |
|---|---:|---|
| Desired Size | 3 | 유지하려는 Node 수 |
| Minimum Size | 3 | 최소 Node 수 |
| Maximum Size | 3 | 최대 Node 수 |

이 구성은 Node 수를 3개로 고정하는 실습용 설정이다. Cluster Autoscaler를 사용 중이라면 Desired Size를 직접 변경하기 전에 자동 확장 정책을 확인해야 한다. [EKS Node Group Scaling 설정](https://docs.aws.amazon.com/eks/latest/APIReference/API_NodegroupScalingConfig.html)

CLI로 변경할 수도 있다.

```shell
aws eks update-nodegroup-config \
  --cluster-name <CLUSTER_NAME> \
  --nodegroup-name <NODE_GROUP_NAME> \
  --region <REGION> \
  --scaling-config minSize=3,maxSize=3,desiredSize=3
```

새 EC2 인스턴스가 생성되고 클러스터에 등록되기까지 시간이 필요하다.

```shell
kubectl get nodes -w
```

새 Node가 `Ready` 상태인지 확인한다. Node가 늘어나더라도 기존 Pod가 자동으로 균등하게 재배치되는 것은 아니다. 새로 생성되는 Pod부터 추가 Node에 배치될 수 있다.

#### 증설에 따른 비용

같은 사양의 Node를 2개에서 3개로 늘리면 해당 Node들의 EC2 사용 비용도 증가한다. 동일한 사용 시간과 구매 조건이라면 인스턴스 수에 따른 EC2 비용은 약 1.5배가 되지만, 클러스터 전체 비용이 정확히 1.5배가 되는 것은 아니다.

EKS Control Plane, RDS, EFS, EBS, NAT Gateway, Load Balancer 등은 별도로 비용이 발생할 수 있다. 영구 저장을 끄더라도 모니터링 Pod가 사용하는 컴퓨팅 자원은 계속 필요하다.

실습이 끝난 뒤에는 사용하지 않는 자원을 정리하되, 보존할 데이터와 다른 서비스의 의존성을 먼저 확인한다. 클러스터를 삭제했다고 해서 RDS나 EFS 같은 외부 자원까지 모두 삭제되는 것은 아니다.

#### Metrics Server 설치

먼저 이미 설치되어 있는지 확인한다.

```shell
kubectl get deployment metrics-server -n kube-system
kubectl get apiservice v1beta1.metrics.k8s.io
```

기존 Helm Release나 EKS Add-on으로 관리 중이라면 설치 방식을 유지한다. 다른 방식으로 중복 설치하면 관리 객체가 충돌할 수 있다.

설치되지 않았다면 공식 Manifest를 적용한다.

```shell
kubectl apply -f \
  https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

실습에서는 최신 Manifest를 사용할 수 있지만, 반복해서 같은 환경을 만들려면 클러스터와 호환되는 Release를 선택하고 URL의 버전을 고정하는 것이 좋다.

```shell
kubectl rollout status deployment/metrics-server -n kube-system
kubectl get apiservice v1beta1.metrics.k8s.io
```

APIService의 `AVAILABLE`이 `True`인지 확인한다.

EKS에서도 인증서나 네트워크 구성에 따라 설치 후 문제가 발생할 수 있다. 오류가 난다고 곧바로 `--kubelet-insecure-tls`를 추가하기보다 로그와 Kubelet 연결 경로를 먼저 확인한다. 해당 옵션은 Kubelet 인증서 검증을 생략한다.

#### 현재 CPU와 메모리 사용량 확인

지표가 수집되면 다음 명령을 사용할 수 있다.

```shell
kubectl top nodes
```

예상 출력 형태는 다음과 같다. 값은 실제 환경에 따라 달라진다.

```text
NAME             CPU(cores)   CPU%   MEMORY(bytes)   MEMORY%
node-a           120m         6%     1450Mi          38%
node-b           180m         9%     1680Mi          44%
node-c           90m          4%     980Mi           26%
```

SNS Namespace의 Pod 사용량을 확인한다.

```shell
kubectl top pods -n sns
```

컨테이너 단위로 보고 싶다면 다음 옵션을 사용한다.

```shell
kubectl top pods -n sns --containers
```

CPU의 `100m`은 평균적으로 0.1 Core에 해당하는 사용량이다. Memory는 JVM Heap만 의미하지 않는다. Java 애플리케이션에서는 Heap 외에도 Metaspace, Thread Stack, Direct Buffer와 Native Memory 등이 포함된다.

이 명령은 현재 상태를 빠르게 확인하기에 좋지만, 어제와 오늘의 사용량을 비교하거나 장애 직전의 변화를 분석하기에는 한계가 있다.

#### Prometheus와 Grafana의 데이터 흐름

Prometheus는 정해진 주기에 대상 Endpoint를 호출하는 Pull 방식으로 지표를 수집한다. Grafana는 Prometheus에 PromQL을 보내고 조회 결과를 그래프로 표시한다.

```mermaid
sequenceDiagram
    participant P as "Prometheus"
    participant K as "Kubelet과 Exporter"
    participant G as "Grafana"
    participant U as "사용자"

    P->>K: "주기적으로 지표 요청"
    K-->>P: "지표 반환"
    P->>P: "시계열 데이터 저장"
    U->>G: "대시보드 조회"
    G->>P: "PromQL 요청"
    P-->>G: "조회 결과"
    G-->>U: "CPU와 메모리 그래프"
```

이번에는 Prometheus와 Grafana를 각각 Helm Chart로 설치한다. Prometheus Operator를 포함한 `kube-prometheus-stack`과는 다른 구성이다.

#### Helm Repository 추가

```shell
helm repo add prometheus-community \
  https://prometheus-community.github.io/helm-charts

helm repo add grafana-community \
  https://grafana-community.github.io/helm-charts

helm repo update
helm repo list
```

Grafana는 현재 설치 안내에서 사용하는 Community Repository를 기준으로 구성한다. Repository의 로컬 이름과 Chart 경로는 설치 명령에서도 동일하게 사용해야 한다. [Grafana Helm 설치](https://grafana.com/docs/grafana/latest/setup-grafana/installation/helm/)

설치할 Chart를 확인한다.

```shell
helm search repo prometheus-community/prometheus
helm search repo grafana-community/grafana
```

Chart Version과 Application Version은 다르다. 재현 가능한 설치가 필요하다면 조회한 Chart Version을 기록하고 설치 명령에 `--version`으로 지정한다.

#### 모니터링 Namespace 생성

`monitoring-namespace.yaml`을 작성한다.

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: monitoring
```

```shell
kubectl apply -f monitoring-namespace.yaml
```

애플리케이션과 모니터링 구성 요소를 Namespace로 구분하면 객체와 권한을 관리하기 편하다. 다만 Prometheus는 다른 Namespace의 Workload도 관찰하므로 Chart에서 Cluster 범위의 RBAC 객체를 생성할 수 있다.

#### 이번 실습의 저장소 정책

Prometheus는 수집한 시계열 데이터를 저장하고, Grafana는 Dashboard와 사용자 설정 등을 저장한다. 이번에는 설치와 지표 확인에 집중하기 위해 Persistent Volume 사용을 끈다.

| 대상 | 임시 저장 시 잃을 수 있는 데이터 |
|---|---|
| Prometheus | 수집한 지표 이력 |
| Grafana | UI에서 저장한 Dashboard와 설정 |
| Alertmanager | Silence와 일부 알림 상태 |

`emptyDir`는 같은 Pod 안에서 컨테이너가 재시작되는 동안에는 유지될 수 있지만, Pod가 삭제되거나 교체되면 사라진다.

StorageClass의 기본값도 확인한다.

```shell
kubectl get storageclass
```

기본 StorageClass가 EBS를 가리키는데 EBS CSI Driver나 권한이 준비되지 않았다면 PVC가 `Pending`에 머물 수 있다. 기본 StorageClass가 언제나 `gp2`라고 가정해서는 안 된다.

특히 Prometheus의 로컬 시계열 저장소에는 EFS 같은 NFS 파일 시스템을 사용하지 않는다. 운영 저장소는 EBS 등 적합한 디스크나 Remote Storage 구성을 검토해야 한다. [Prometheus 저장소 요구사항](https://prometheus.io/docs/prometheus/latest/storage/)

#### Prometheus Values 작성

`prometheus-values.yaml`을 작성한다.

```yaml
server:
  persistentVolume:
    enabled: false
  retention: 6h
  global:
    scrape_interval: 30s
    evaluation_interval: 30s
  resources:
    requests:
      cpu: 250m
      memory: 512Mi
    limits:
      cpu: "1"
      memory: 2Gi

alertmanager:
  enabled: true
  persistence:
    enabled: false

kube-state-metrics:
  enabled: true

prometheus-node-exporter:
  enabled: true

prometheus-pushgateway:
  enabled: false
```

주요 설정은 다음과 같다.

| 설정 | 의미 |
|---|---|
| `server.persistentVolume.enabled: false` | Prometheus 데이터를 임시 Volume에 저장 |
| `server.retention: 6h` | 지표 보관 기간을 6시간으로 설정 |
| `scrape_interval: 30s` | 기본 지표 수집 주기 |
| `evaluation_interval: 30s` | Rule 평가 주기 |
| `alertmanager.persistence.enabled: false` | Alertmanager 영구 저장 비활성화 |
| `kube-state-metrics` | Deployment, Pod 등 Kubernetes 객체 상태 제공 |
| `prometheus-node-exporter` | Node 운영체제 수준 지표 제공 |

Node Exporter는 일반적으로 DaemonSet으로 설치되므로 Node 수가 늘어나면 Pod 수도 늘어난다. Chart가 제공하는 부가 구성 요소까지 포함해 자원을 계산해야 한다.

Values 키는 Chart 버전에 따라 달라질 수 있다. 설치 전에 해당 버전의 기본 설정과 비교한다.

```shell
helm show values prometheus-community/prometheus
```

위 예제는 `server.persistentVolume`과 하위 Alertmanager Chart의 `persistence` 설정을 사용한다. [Prometheus Chart 설정](https://github.com/prometheus-community/helm-charts/blob/main/charts/prometheus/values.yaml)

#### Prometheus 설치

```shell
helm upgrade --install prometheus \
  prometheus-community/prometheus \
  --namespace monitoring \
  --values prometheus-values.yaml \
  --wait \
  --timeout 10m
```

설치 상태를 확인한다.

```shell
helm list -n monitoring
kubectl get pods,service,pvc -n monitoring
```

이번 설정에서는 Prometheus와 Alertmanager의 PVC가 생성되지 않아야 한다. 예상하지 못한 PVC가 있다면 Chart 버전과 적용된 Values를 확인한다.

```shell
helm get values prometheus -n monitoring
```

#### Grafana Values 작성

`grafana-values.yaml`을 작성한다.

```yaml
persistence:
  enabled: false

adminUser: admin

service:
  type: ClusterIP

resources:
  requests:
    cpu: 100m
    memory: 256Mi
  limits:
    cpu: 500m
    memory: 512Mi

datasources:
  datasources.yaml:
    apiVersion: 1
    datasources:
      - name: Prometheus
        uid: prometheus
        type: prometheus
        access: proxy
        url: http://prometheus-server.monitoring.svc.cluster.local
        isDefault: true
        editable: false
```

`datasources.yaml`은 Grafana의 Data Source Provisioning 설정이다. 여기의 `apiVersion: 1`은 Kubernetes API Version이 아니라 Grafana 설정 형식의 버전이다.

`access: proxy`는 브라우저 대신 Grafana 서버가 Prometheus를 조회한다는 의미다. 따라서 로컬 브라우저가 `*.svc.cluster.local` 주소를 직접 해석할 필요는 없다.

```mermaid
flowchart LR
    A["로컬 브라우저"] --> B["Grafana"]
    B -->|"클러스터 내부 DNS"| C["prometheus-server"]
    C -->|"지표 반환"| B
```

`prometheus-server`는 이번 Release 이름을 기준으로 생성될 Service 이름이다. 실제 Service와 Port는 설치 결과에서 확인한다.

```shell
kubectl get service -n monitoring
```

Chart 기본 구성에서 Prometheus Server Service가 80 포트를 제공하면 URL에 Port를 생략할 수 있다. 다른 Port를 사용한다면 URL에도 반영한다.

#### Grafana 설치와 로그인 정보

```shell
helm upgrade --install grafana \
  grafana-community/grafana \
  --namespace monitoring \
  --values grafana-values.yaml \
  --wait \
  --timeout 10m
```

이번에는 고정된 쉬운 관리자 비밀번호를 Values나 명령행에 넣지 않고 Chart가 생성하는 Secret을 사용한다.

로컬 PowerShell에서 비밀번호를 화면에 출력하지 않고 Clipboard에 복사할 수 있다.

```powershell
$grafanaPasswordBase64 = kubectl get secret grafana `
  -n monitoring `
  -o jsonpath="{.data.admin-password}"

$grafanaPassword = [Text.Encoding]::UTF8.GetString(
    [Convert]::FromBase64String(
        $grafanaPasswordBase64
    )
)

Set-Clipboard -Value $grafanaPassword

Remove-Variable grafanaPassword
Remove-Variable grafanaPasswordBase64
```

로그인할 때 사용자 이름은 `admin`, 비밀번호는 복사한 값을 사용한다. 로그인 후 Clipboard는 비워 둔다.

```powershell
Set-Clipboard -Value ""
```

#### Grafana 접속

Grafana의 컨테이너 Port는 기본적으로 3000이다. 로컬 3000 포트로 연결한다.

```shell
kubectl port-forward \
  deployment/grafana \
  3000:3000 \
  -n monitoring
```

브라우저에서 [Grafana](http://localhost:3000)에 접속한다. Port Forward를 실행한 Terminal은 접속하는 동안 열어 두어야 한다.

로컬에서 3000 포트를 이미 사용 중이라면 다음과 같이 변경한다.

```shell
kubectl port-forward \
  deployment/grafana \
  3001:3000 \
  -n monitoring
```

이 경우 접속 주소는 `http://localhost:3001`이다. 설치 확인을 위해 별도 LoadBalancer나 Ingress를 만들 필요는 없다.

#### Data Source와 수집 상태 확인

Grafana에서 Prometheus Data Source가 등록되어 있는지 확인한다. UI 위치는 버전에 따라 다를 수 있지만, Data Source 설정의 연결 테스트 또는 Explore에서 조회할 수 있다.

먼저 다음 PromQL을 실행한다.

```promql
up
```

`up`은 각 수집 대상의 최근 Scrape 성공 여부를 나타낸다.

- `1`: 지표 수집 성공
- `0`: 지표 수집 실패

Prometheus 화면에서 상세 상태를 보고 싶다면 별도 Terminal에서 Port Forward를 실행한다.

```shell
kubectl port-forward \
  service/prometheus-server \
  9090:80 \
  -n monitoring
```

[Prometheus](http://localhost:9090)의 Targets 화면에서 Kubelet과 cAdvisor 대상이 정상인지 확인한다.

Pod가 Running이고 Ready라는 사실만으로 필요한 지표가 수집된다고 판단해서는 안 된다. Grafana 연결과 Prometheus Target 상태까지 확인해야 한다.

#### 컨테이너 CPU 패널 만들기

Grafana에서 Dashboard를 만들고 Visualization을 추가한다. Data Source로 Prometheus를 선택한 뒤 다음 Query를 입력한다.

```promql
sum by (namespace, pod, container) (
  rate(
    container_cpu_usage_seconds_total{
      namespace="sns",
      container!="",
      container!="POD"
    }[5m]
  )
)
```

`container=""`인 집계 항목과 `container="POD"`인 인프라 컨테이너를 제외해 애플리케이션 컨테이너를 중심으로 표시한다. 실제 Label은 수집 환경에서 확인한다.

##### 누적 CPU 시간에 `rate()`를 적용하는 이유

`container_cpu_usage_seconds_total`은 컨테이너가 사용한 CPU 시간의 누적값이다. 그대로 표시하면 현재 부하보다 컨테이너가 얼마나 오래 실행됐는지에 영향을 받는다.

`rate(...[5m])`는 최근 5분 동안의 초당 평균 증가량을 계산한다. 이 결과는 평균적으로 사용한 CPU Core 수로 해석할 수 있다. `rate()`를 먼저 적용한 뒤 합산해야 개별 컨테이너의 Counter Reset을 처리할 수 있다. [Prometheus rate 함수](https://prometheus.io/docs/prometheus/latest/querying/functions/)

| Query 결과 | CPU 사용량 해석 |
|---:|---|
| `0.05` | 약 0.05 Core, 50m |
| `0.5` | 약 0.5 Core, 500m |
| `1.0` | 약 1 Core |
| `2.0` | 약 2 Core |

CPU Core 값에 Grafana의 Percent Unit을 지정하면 의미가 달라진다. 이번 패널은 단위를 `cores`로 표시하거나 사용자 정의 단위로 지정한다.

##### 패널 설정

| 항목 | 설정 |
|---|---|
| Title | Container CPU |
| Visualization | Time series |
| Query | 최근 5분 CPU 사용량 |
| Min | 0 |
| Legend | Pod와 Container를 함께 표시 |

컨테이너 이름만 표시하면 Feed Server의 두 Replica가 같은 이름으로 보인다. Pod 이름도 포함하면 Replica별 차이를 확인하기 쉽다.

5분 범위는 값을 부드럽게 보여주지만 짧은 순간의 급증은 완만하게 나타날 수 있다. 이후 부하 테스트에서는 Query Window와 수집 주기를 함께 고려한다.

#### 컨테이너 메모리 패널 만들기

두 번째 Visualization을 추가하고 다음 Query를 입력한다.

```promql
sum by (namespace, pod, container) (
  container_memory_usage_bytes{
    namespace="sns",
    container!="",
    container!="POD"
  }
)
```

메모리 사용량은 현재 값이 증가하거나 감소하는 Gauge다. CPU의 누적 시간처럼 `rate()`로 변환할 필요가 없다.

| 항목 | 설정 |
|---|---|
| Title | Container Memory |
| Visualization | Time series |
| Unit | Bytes IEC |
| Min | 0 |
| Legend | Pod와 Container를 함께 표시 |

##### SI와 IEC 단위

| 단위 | 크기 |
|---|---:|
| 1 MB | 1,000,000 bytes |
| 1 MiB | 1,048,576 bytes |
| 1 GB | 1,000,000,000 bytes |
| 1 GiB | 1,073,741,824 bytes |

Kubernetes에서 `512Mi`, `1Gi`처럼 Resource를 설정했다면 Grafana도 Bytes IEC로 표시하는 편이 비교하기 쉽다. 이는 표시 단위를 바꾸는 것이며 수집한 byte 값 자체가 달라지는 것은 아니다.

##### Working Set도 함께 보기

`container_memory_usage_bytes`에는 Cache 등이 포함될 수 있다. 실제 상태를 판단할 때는 Working Set도 같이 살펴본다.

```promql
sum by (namespace, pod, container) (
  container_memory_working_set_bytes{
    namespace="sns",
    container!="",
    container!="POD"
  }
)
```

Working Set도 JVM Heap과 같은 값은 아니며, 이 지표 하나만으로 OOM 여부를 단정할 수 없다. 재시작 상태, Memory Limit, JVM 지표를 함께 확인한다.

#### Dashboard 저장

CPU와 메모리 패널을 배치하고 `SNS Resource Monitoring` 같은 이름으로 저장한다.

- 시간 범위는 우선 최근 15분 또는 30분으로 설정한다.
- 자동 새로고침은 수집 주기와 비슷하게 30초 정도로 설정한다.
- CPU와 메모리 패널의 Pod 이름을 맞춰 비교한다.

Prometheus를 설치하기 전의 지표는 조회할 수 없다. 설치 직후에는 `rate()` 계산에 필요한 Sample도 부족할 수 있으므로 여러 번 수집될 때까지 기다린다.

Grafana 영구 저장을 껐기 때문에 UI에서 저장한 Dashboard는 Pod 교체 후 사라질 수 있다. 계속 사용할 Dashboard는 JSON으로 Export하거나 Provisioning 설정으로 관리한다.

#### 현재 그래프를 해석하는 방법

요청이 없는 상태에서는 CPU 사용량이 낮게 나타나는 것이 자연스럽다. 반면 Java 애플리케이션은 요청이 없어도 Heap과 JVM 실행 공간을 사용하므로 메모리가 0에 가깝게 내려가지는 않는다.

설치 후 다음 항목을 먼저 확인한다.

- 예상한 User, Feed, Image 컨테이너가 보이는가
- 같은 Deployment의 Replica를 구분할 수 있는가
- CPU와 메모리 값이 지속해서 갱신되는가
- `kubectl top`과 크게 다른 값이라면 시간 범위와 지표 정의가 다른가
- Prometheus Target이 정상인가

`kubectl top`과 Grafana의 값은 완전히 일치하지 않을 수 있다. 수집 시점, CPU 평균 구간, 메모리 지표가 다르기 때문이다.

#### CPU와 메모리만으로 알 수 없는 것

이 구성은 Kubernetes 자원 관찰의 시작점이다. Spring Boot의 요청 지연, 오류율, JVM GC까지 자동으로 수집하는 것은 아니다.

애플리케이션 Monitoring에는 별도 Micrometer Prometheus 연동과 Scrape 설정이 필요하다. 이후에는 다음 지표를 추가한다.

| 영역 | 확인할 지표 |
|---|---|
| HTTP | 요청 수, 오류율, 응답 시간 |
| JVM | Heap, GC 시간, Thread 수 |
| Database | Connection Pool, Query 지연 |
| 서비스 간 호출 | User Server 호출 횟수, 지연, 실패율 |
| Batch | 실행 성공 여부, 처리 건수, 미처리 데이터, 처리 지연 |
| Kubernetes | Pod 재시작, Pending, CPU Throttling, Memory 압박 |

Notification Batch처럼 짧게 실행되는 Pod는 종료되기 전에 Scrape되지 않을 수 있다. `kubectl top`에 보이지 않는다는 이유로 실행되지 않았다고 판단하지 말고 Job 상태와 실행 이력도 확인한다.

#### 자주 발생하는 문제

##### Metrics API를 사용할 수 없는 경우

```text
Metrics API not available
```

```shell
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl describe apiservice v1beta1.metrics.k8s.io
kubectl logs deployment/metrics-server -n kube-system
```

APIService 상태, 인증서 오류, Metrics Server에서 Kubelet로 접근 가능한지를 확인한다.

##### 모니터링 Pod가 Pending인 경우

```shell
kubectl describe pod <POD_NAME> -n monitoring
kubectl get events -n monitoring --sort-by=.lastTimestamp
```

| Event | 확인할 내용 |
|---|---|
| Insufficient cpu | Node의 남은 CPU requests |
| Insufficient memory | Node의 남은 Memory requests |
| Unbound PersistentVolumeClaims | PVC와 StorageClass |
| Too many pods | Node의 Pod 수 제한 |
| Taint 관련 오류 | Node Taint와 Toleration |

영구 저장을 껐는데 PVC가 생성됐다면 Values 키가 설치한 Chart에서 적용되는지 확인한다.

##### Grafana에서 Prometheus 연결이 실패하는 경우

```shell
kubectl get service,endpointslice -n monitoring
kubectl logs deployment/grafana -n monitoring
```

Data Source URL의 Service 이름, Namespace, Port를 확인한다. `access: proxy`에서 `localhost`는 로컬 PC가 아니라 Grafana Pod를 가리킨다.

##### CPU 패널에 No data가 표시되는 경우

먼저 Metric 자체가 있는지 확인한다.

```promql
container_cpu_usage_seconds_total
```

그다음 Namespace 조건을 추가한다.

```promql
container_cpu_usage_seconds_total{namespace="sns"}
```

전체 Metric은 있지만 Filter 적용 후 없어지면 Label이 다를 수 있다. Metric 자체가 없다면 cAdvisor 수집 대상과 RBAC, 네트워크를 확인한다. 설치 직후에는 `rate()` 계산에 필요한 Sample이 부족한 경우도 있다.

##### 값이 두 배로 집계되는 경우

같은 Endpoint를 두 Scrape Job이 수집하면 `sum()`이 중복 데이터를 합산할 수 있다.

```promql
count by (job) (
  container_memory_usage_bytes{
    namespace="sns",
    container!="",
    container!="POD"
  }
)
```

수집 경로를 확인한 뒤 Query에 해당 `job`을 지정하거나 중복 Scrape 설정을 제거한다.

##### Dashboard가 사라진 경우

Grafana Pod가 교체됐는지 확인한다. `persistence.enabled: false`에서 UI 저장은 영구 보존을 의미하지 않는다. Dashboard JSON이나 Provisioning 설정으로 복구한다.

### 정리

Node 자원을 확인하고 Metrics Server, Prometheus, Grafana를 설치해 SNS 컨테이너의 CPU와 메모리를 관찰할 수 있게 구성했다.

Metrics Server는 현재 자원 조회와 자동 확장에 사용하고, Prometheus는 지표 이력을 저장하며, Grafana는 이를 그래프로 보여준다. CPU는 누적 CPU 시간에 `rate()`를 적용해 Core 사용량으로 해석하고, 메모리는 현재 byte 값을 IEC 단위로 표시한다.

이번 환경은 영구 저장을 비활성화한 실습용 구성이다. Pod 교체 시 지표 이력과 UI에서 저장한 Dashboard가 사라질 수 있으며, 운영에서는 저장소와 보존 정책을 별도로 설계해야 한다.

이제 성능 테스트를 실행하면서 요청량 증가가 자원 사용량에 어떤 영향을 주는지 확인할 수 있다. 자원 그래프와 함께 응답 시간, 오류율, Database와 서비스 간 호출 지표까지 연결하면 병목을 더 정확하게 찾을 수 있다.
