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

자료에서도
👉 container ↔ volume 연결 구조로 표현되어 있다

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

자료에서도 동일하게 정의됨

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


