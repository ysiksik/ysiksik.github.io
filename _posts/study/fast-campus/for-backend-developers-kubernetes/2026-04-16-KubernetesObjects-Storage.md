---
layout: post
bigtitle: 'Part 1. 개발자를 위한 Kubernetes 입문'
subtitle: Ch 7. Kubernetes 객체 - Storage
date: '2026-04-16 00:00:03 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 7. Kubernetes 객체 - Storage

# Ch 7. Kubernetes 객체 - Storage
* toc
{:toc}

---

## 01. Volume과 Ephemeral Volume

애플리케이션을 개발할 때
👉 모든 처리를 메모리만으로 해결하는 것은 현실적으로 어렵다.

특히 다음과 같은 경우에는 반드시 **저장소(Storage)** 가 필요하다.

* 로그 저장
* 파일 업로드 / 다운로드
* 임시 데이터 처리
* 캐시 파일

최근에는 Stateless 아키텍처가 트렌드지만,
👉 실제 시스템은 **완전히 상태를 제거할 수 없다**

그래서 Kubernetes는
👉 **저장소도 추상화된 형태(Volume)** 로 제공한다.

---

### Volume

Volume은
👉 **Kubernetes에서 사용하는 저장소 인터페이스**다.

---

### Volume의 특징

Volume은 특정 저장소 기술에 종속되지 않는다.

다음과 같은 모든 것이 Volume이 될 수 있다.

* 로컬 디스크
* 네트워크 스토리지 (NFS)
* 클라우드 스토리지 (EBS, GCP PD 등)
* 파일 시스템 서비스 (EFS 등)

👉 핵심 개념
👉 **“파일을 저장할 수 있으면 모두 Volume”**

---

### Volume Mount

Volume Mount는
👉 **Volume을 컨테이너 내부 경로에 연결하는 것**이다.

구조적으로 보면 다음과 같다.

```
Volume (저장소)
    ↓
Volume Mount
    ↓
Container 내부 경로
```

---

### Volume 설정 예시 (ConfigMap 연동)

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
      - key: "welcome-script"
        path: "welcome.sh"
```

---

### YAML 상세 설명

#### volumes

```yaml
volumes:
```

* Pod 레벨에서 정의되는 저장소
* 컨테이너와 독립적인 객체

👉 **Volume은 컨테이너에 종속되지 않는다**

---

#### configMap volume

```yaml
configMap:
  name: my-config
```

* ConfigMap 데이터를 파일 형태로 사용

---

#### items

```yaml
items:
- key: "welcome-script"
  path: "welcome.sh"
```

* 특정 key만 선택
* 파일 이름 지정 가능

👉 결과

```
/config-files/welcome.sh
```

→ 파일 내용 = ConfigMap 값

---

#### volumeMounts

```yaml
volumeMounts:
```

* 컨테이너에 Volume 연결

---

#### mountPath

```yaml
mountPath: /config-files
```

* 컨테이너 내부에서 접근할 경로

---

### 핵심 구조 정리

* `volumes` → 저장소 정의
* `volumeMounts` → 컨테이너 연결

👉 관계

```
Volume ↔ Container = 다대다
```

---

### emptyDir Volume 예시

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
    - name: upload-volume
      mountPath: /tmp/uploads
  volumes:
  - name: upload-volume
    emptyDir: {}
```

---

### emptyDir 설명

* Pod 생성 시 생성
* Pod 삭제 시 삭제

👉 완전한 임시 저장소

---

### Ephemeral Volume

Ephemeral Volume은
👉 **Pod와 동일한 생명주기를 가지는 Volume**이다.

---

### 특징

* Pod 생성 → Volume 생성
* Pod 삭제 → Volume 삭제

👉 데이터는 유지되지 않음

---

### 종류

* emptyDir
* configMap
* secret
* hostPath


---

### 왜 emptyDir를 많이 사용할까?

실무에서는 대부분:

👉 emptyDir 하나로 충분한 경우가 많다

이유:

* 가장 단순한 구조
* 빠른 성능 (노드 로컬 디스크)
* 설정이 거의 없음

---

### 사용 적합한 경우

* 임시 파일
* 로그 버퍼
* 캐시
* 컨테이너 간 데이터 공유

---

### 사용하면 안 되는 경우

* 데이터베이스
* 영구 저장 필요 데이터
* 장애 복구 필요한 데이터

👉 이런 경우는
→ Persistent Volume 사용

---

### 핵심 비교

| 구분     | Ephemeral Volume | Persistent Volume |
| ------ | ---------------- | ----------------- |
| 생명주기   | Pod와 동일          | 독립적               |
| 데이터 유지 | ❌                | ✅                 |
| 용도     | 임시 데이터           | 영구 데이터            |

---

### 한 줄 핵심 정리

👉 Volume은
**“컨테이너에 저장소를 연결하는 구조”**

👉 Ephemeral Volume은
**“Pod와 함께 사라지는 임시 저장소”**

---

## Kubernetes 객체 PersistentVolume과 PersistentVolumeClaim

앞에서 살펴본 Volume (특히 emptyDir)은
👉 **Pod와 함께 생성되고 사라지는 임시 저장소(Ephemeral Volume)**였다.

하지만 실제 서비스에서는 다음과 같은 요구가 반드시 존재한다.

* Pod가 재시작되어도 데이터가 유지되어야 함
* 노드가 변경되어도 데이터가 유지되어야 함
* 데이터베이스, 파일 저장소처럼 **영구 데이터 관리 필요**

이 요구를 해결하기 위해 Kubernetes는
👉 **PersistentVolume(PV)** 와 **PersistentVolumeClaim(PVC)** 구조를 제공한다.

---

### Persistent Volume (PV)

PersistentVolume은
👉 **Pod의 생명주기와 무관하게 유지되는 영구 저장소**다.

---

### PV의 특징

* Pod 삭제와 관계없이 데이터 유지
* 노드와 독립적으로 동작
* 대부분 네트워크 기반 스토리지 사용

예:

* NFS
* AWS EBS / GCP Persistent Disk
* EFS 같은 파일 스토리지

---

### Static Provisioning vs Dynamic Provisioning

#### Static Provisioning

👉 미리 저장소를 만들어두는 방식

* 관리자가 PV를 사전에 생성
* Pod는 준비된 PV 중 하나를 선택

📌 특징

* 관리 비용 높음
* 유연성 낮음

---

#### Dynamic Provisioning

👉 필요할 때 자동 생성

* PVC 요청 시 PV 자동 생성
* StorageClass 기반 동작

📌 특징

* 클라우드 환경에서 표준
* 확장성 뛰어남

---

### 왜 PV를 직접 사용하지 않을까?

👉 Pod가 직접 PV를 선택하지 않는다

이유:

* Pod 생성 시점에 PV가 없을 수도 있음
* 동적 생성에서는 PV가 나중에 만들어짐
* 저장소 관리와 애플리케이션을 분리하기 위함

---

### PersistentVolumeClaim (PVC)

PVC는
👉 **“이런 저장소를 주세요”라고 요청하는 객체**다.

---

### 구조

```
Pod → PVC → PV
```

* Pod → PVC 사용
* PVC → PV를 할당받음

👉 역할 분리

* Pod = 소비자
* PVC = 요청자
* PV = 실제 저장소

---

### PersistentVolume YAML 예시

```yaml
apiVersion: v1
kind: PersistentVolume
metadata:
  name: my-pv-500
spec:
  capacity:
    storage: 500Mi
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  hostPath:
    path: "/my-pv/data/pv1"
```

---

### PV YAML 상세 설명

#### capacity

```yaml
capacity:
  storage: 500Mi
```

* 저장소 크기 정의
* 실제 스토리지 용량과 일치해야 함

---

#### accessModes

```yaml
accessModes:
- ReadWriteMany
```

접근 방식 정의

* ReadWriteOnce (RWO) → 하나의 노드에서 읽기/쓰기
* ReadOnlyMany (ROX) → 여러 노드에서 읽기만
* ReadWriteMany (RWX) → 여러 노드에서 읽기/쓰기
* ReadWriteOncePod → 하나의 Pod만 접근

---

#### persistentVolumeReclaimPolicy

```yaml
persistentVolumeReclaimPolicy: Retain
```

* Retain → 데이터 유지 (운영에서 많이 사용)
* Delete → PV와 데이터 삭제
* Recycle → 현재 거의 사용 안 함

---

#### hostPath (주의)

```yaml
hostPath:
  path: "/my-pv/data/pv1"
```

* 노드의 로컬 경로 사용

⚠️ 운영 환경에서는 비추천
👉 노드 변경 시 데이터 유실 위험

👉 개발/테스트 환경에서만 사용

---

### PersistentVolumeClaim YAML 예시

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-pvc-100
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 100Mi
```

---

### PVC 동작 방식

PVC는 다음 조건으로 PV를 찾는다.

1. accessModes 일치
2. 요청 용량 이상
3. selector가 있다면 label 일치

---

### 할당 규칙

* 여러 PV 존재 → 가장 작은 PV 선택
* 적합한 PV 없음 → Pending 상태 유지

---

### Pod에서 PVC 사용

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
    volumeMounts:
    - name: my-storage
      mountPath: /data
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: my-pvc-100
```

---

### YAML 설명

#### persistentVolumeClaim

```yaml
persistentVolumeClaim:
  claimName: my-pvc-100
```

* PVC를 참조
* Pod는 PV를 직접 알지 못함

---

#### mountPath

```yaml
mountPath: /data
```

👉 컨테이너 내부에서 `/data`가 실제 저장소

---

### 정적 프로비저닝 활용 전략

#### 적합한 경우

* 공유 스토리지 (RWX)
* 공통 파일 저장

---

#### 제한적인 경우

* Pod별 독립 스토리지
* 자동 확장 환경

---

### 대안

* 임시 데이터 → emptyDir
* 상태 저장 → StatefulSet + PV
* 일반 서비스 → Stateless + 외부 DB

---

### 핵심 정리

* PV = 실제 저장소
* PVC = 저장소 요청
* Pod = PVC 사용

```
Pod → PVC → PV → Storage
```

---

### 한 줄 핵심 정리

👉 PersistentVolume은
**“Pod와 독립적으로 유지되는 영구 저장소”**

👉 PersistentVolumeClaim은
**“그 저장소를 요청하는 인터페이스”**

---

## Kubernetes 객체 StorageClass와 Dynamic Provisioning

앞에서 살펴본 PersistentVolume(PV)과 PersistentVolumeClaim(PVC)은
👉 **영구 저장소를 사용하는 기본 구조**였다.

하지만 실제 운영 환경에서는 다음과 같은 문제가 발생한다.

* 저장소를 미리 만들어두는 것이 번거롭다
* Pod마다 다른 크기의 스토리지가 필요하다
* 자동 확장 환경에서 수동 관리가 불가능하다

이 문제를 해결하기 위해 Kubernetes는
👉 **Dynamic Provisioning + StorageClass** 구조를 제공한다.

---

### Dynamic Provisioning

Dynamic Provisioning은

> **필요한 시점에 필요한 만큼 저장소를 자동 생성하는 기술**

이다.

---

### 기존 구조 vs Dynamic 구조

기존 (Static):

```id="7n4hff"
Pod → PVC → 미리 만들어둔 PV
```

Dynamic:

```id="79cmxk"
Pod → PVC → StorageClass → PV 자동 생성
```

---

### StorageClass

StorageClass는

👉 **“어떤 방식으로 저장소를 만들 것인지 정의하는 객체”**

다.

즉,

* 어떤 스토리지를 사용할지
* 어떤 옵션으로 생성할지

를 정의한다.

---

### StorageClass YAML (클라우드 스토리지 예시)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: ebs-storage
provisioner: kubernetes.io/aws-ebs
parameters:
  type: gp3
```

---

### YAML 필드 설명

#### provisioner

```yaml
provisioner: kubernetes.io/aws-ebs
```

* 어떤 스토리지 제공자를 사용할지 정의
* 예:

    * AWS EBS
    * GCE PD
    * Azure Disk

---

#### parameters

```yaml
parameters:
  type: gp3
```

* 스토리지 생성 시 필요한 옵션
* 스토리지 종류 / 성능 설정 등

---

### StorageClass (로컬 스토리지 예시)

```yaml
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage
provisioner: rancher.io/local-path
volumeBindingMode: WaitForFirstConsumer
```

---

### volumeBindingMode

```yaml
volumeBindingMode: WaitForFirstConsumer
```

👉 볼륨이 실제로 생성되는 시점 정의

---

#### Immediate

* PVC 생성 즉시 볼륨 생성

---

#### WaitForFirstConsumer

* Pod가 실제로 스케줄될 때 생성

👉 왜 필요할까?

* 노드 위치 고려 필요
* 잘못된 노드에 볼륨 생성 방지

👉 특히 local storage에서 매우 중요

---

### PVC에서 StorageClass 사용

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: my-dynamic-pvc
spec:
  storageClassName: local-storage
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 100Mi
```

---

### 핵심 포인트

```yaml
storageClassName: local-storage
```

👉 이 한 줄이 Dynamic Provisioning을 트리거한다

---

### 동작 흐름

```id="pfk1nm"
1. PVC 생성
2. StorageClass 확인
3. PV 자동 생성
4. PVC와 바인딩
5. Pod에서 사용
```

---

### Pod에서 사용

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: my-pod
spec:
  containers:
  - name: my-container
    image: nginx
    volumeMounts:
    - name: my-storage
      mountPath: /data
  volumes:
  - name: my-storage
    persistentVolumeClaim:
      claimName: my-dynamic-pvc
```

---

### StatefulSet + Dynamic Provisioning

```yaml
apiVersion: apps/v1
kind: StatefulSet
spec:
  containers:
  - name: redis
    image: redis
    volumeMounts:
    - name: dynamic-volume
      mountPath: /tmp/dynamic
  volumeClaimTemplates:
  - metadata:
      name: dynamic-volume
    spec:
      accessModes: [ "ReadWriteOnce" ]
      storageClassName: local-storage
      resources:
        requests:
          storage: 100Gi
```

---

### volumeClaimTemplates 핵심

👉 StatefulSet에서 매우 중요한 기능

* Pod 생성 시마다 PVC 자동 생성
* 각 Pod마다 독립적인 저장소 제공

---

### 실제 동작 구조

```id="7pph2u"
StatefulSet-0 → PVC-0 → PV-0
StatefulSet-1 → PVC-1 → PV-1
```

---

### 왜 이 구조가 중요한가?

👉 Stateful 서비스에서 핵심

* DB
* Kafka
* Redis Cluster

각 Pod는:

* 서로 다른 데이터
* 독립적인 스토리지 필요

---

### 핵심 정리

* StorageClass = “스토리지 생성 방법 정의”
* Dynamic Provisioning = “필요할 때 자동 생성”
* PVC = “요청 트리거”
* StatefulSet = “Pod별 스토리지 자동 생성”

---

### 한 줄 핵심 정리

👉 StorageClass는
**“스토리지를 자동으로 생성하는 규칙”**

👉 Dynamic Provisioning은
**“PVC 요청 시 자동으로 PV를 생성하는 구조”**

---

### 전체 흐름 정리

지금까지 스토리지 흐름은 이렇게 완성된다:

```id="6y8bcz"
Pod → PVC → StorageClass → PV → Storage
```

---
