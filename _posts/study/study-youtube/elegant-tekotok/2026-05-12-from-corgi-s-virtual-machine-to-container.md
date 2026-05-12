---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 코기의 가상머신에서 컨테이너까지
date: '2026-05-12 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 코기의 가상머신에서 컨테이너까지
[https://youtu.be/RhoeOT75hC0?si=Fs3qzDURHXJBMpBp](https://youtu.be/RhoeOT75hC0?si=Fs3qzDURHXJBMpBp)

# 코기의 가상머신에서 컨테이너까지
* toc
{:toc}

---

# 가상 머신(VM)과 컨테이너(Container): 왜 Docker가 등장했을까

현대 백엔드 개발에서는:

* Docker
* Kubernetes
* ECS
* EKS
* 컨테이너 배포

같은 개념이 거의 필수처럼 사용된다.

그런데 중요한 건:

```text
"왜 컨테이너가 필요했는가"
```

를 이해하는 것이다.

이걸 이해하려면 먼저 가상화(Virtualization)부터 이해해야 한다.

---

# 가상화(Virtualization)란 무엇인가

가상화는:

```text
하나의 물리 컴퓨터 위에서
여러 개의 독립 실행 환경을 만드는 기술
```

이다.

---

# 왜 가상화가 필요했을까

발표에서는 방탈출 서비스와 블랙잭 서비스 예시를 사용한다.

상황은 이렇다.

```text
방탈출 서비스:
- Java 21 사용
- MySQL 3306 사용

블랙잭 서비스:
- Java 17 사용
- 역시 3306 사용
```

즉 하나의 서버에서 여러 서비스를 같이 실행하려고 하자:

* Java 버전 충돌
* 포트 충돌
* 라이브러리 충돌

문제가 발생한다.

---

# 직접 운영하면 생기는 진짜 문제

처음에는:

```text
"포트만 바꾸면 되잖아?"
```

라고 생각할 수 있다.

하지만 실제 운영에서는:

* 환경 변수 충돌
* 라이브러리 버전 충돌
* 런타임 충돌
* 프로세스 간 영향
* 장애 전파

문제가 계속 발생한다.

즉:

```text
서비스끼리 서로 격리된 환경 필요
```

가 생긴다.

이걸 해결하기 위해 등장한 것이 가상화다.

---

# 가상화의 종류

가상화는 크게 두 가지로 나뉜다.

| 종류          | 방식     |
| ----------- | ------ |
| VM 기반 가상화   | 가상 머신  |
| 컨테이너 기반 가상화 | Docker |

---

# 가상 머신(VM)이란 무엇인가

가상 머신은:

```text
컴퓨터 안에 또 다른 컴퓨터를 만드는 기술
```

이다.

즉:

* CPU
* 메모리
* 디스크
* 네트워크
* 운영체제

전부 독립된 환경처럼 동작한다.

---

# 프로세스의 기본 구조부터 이해하기

발표에서는 먼저 OS 구조를 설명한다.

구조는 크게:

```text
User Mode
↓
Kernel Mode
↓
Driver
↓
Hardware
```

로 구성된다.

---

# 예를 들어 파일 저장 시

애플리케이션이 파일 저장 요청을 하면:

```text
App
→ Kernel
→ HDD Driver
→ 실제 디스크
```

흐름으로 동작한다.

---

# VM 내부에서는 어떻게 동작할까

VM에서는 구조가 하나 더 생긴다.

```text
Guest App
→ Guest OS
→ Virtual Driver
→ Hypervisor
→ Host OS
→ 실제 Hardware
```

즉 중간 계층이 매우 많아진다.

---

# Host와 Guest 개념

## Host

실제 물리 컴퓨터

```text
내 맥북
내 EC2 서버
```

같은 것이다.

---

## Guest

VM 내부에서 실행되는 가상 컴퓨터다.

즉:

```text
Ubuntu VM
Windows VM
```

같은 것들이다.

---

# Hypervisor란 무엇인가

VM의 핵심은 Hypervisor다.

Hypervisor는:

```text
가상 하드웨어를 만들어주는 관리자
```

다.

즉 Guest OS는:

```text
"내가 진짜 컴퓨터 위에서 실행 중이다"
```

라고 착각한다.

하지만 실제로는:

```text
Hypervisor가 가상 CPU,
가상 디스크,
가상 네트워크를 흉내냄
```

구조다.

---

# VM의 가장 큰 문제점

문제는:

```text
OS가 중복 실행된다
```

는 것이다.

예를 들어:

```text
Host OS = macOS
Guest OS = macOS
```

인데도 Guest OS 전체가 또 실행된다.

즉:

```text
OS를 또 띄움
커널도 또 띄움
드라이버도 또 띄움
```

상황이 발생한다.

---

# 결국 VM은 매우 무겁다

서비스 하나 실행하려고:

* Guest OS
* Virtual Driver
* Virtual Hardware

전부 같이 실행된다.

즉:

```text
실제 관심은 App인데
OS 전체가 추가로 실행됨
```

상황이다.

---

# 서비스가 많아지면 더 심각해진다

예를 들어:

```text
서비스 4개
→ Guest OS 4개
→ Virtual Hardware 4개
```

즉 시스템 전체가 점점 무거워진다.

이게 VM의 가장 큰 한계였다.

---

# 그래서 등장한 것이 Docker다

Docker의 핵심 철학은 단순하다.

```text
"OS를 매번 띄우지 말자"
```

이다.

---

# 컨테이너(Container)란 무엇인가

컨테이너는:

```text
애플리케이션 실행에 필요한 것만 격리
```

한다.

즉:

* App
* 라이브러리
* 실행 환경

만 포함한다.

OS 전체는 포함하지 않는다.

---

# 컨테이너는 OS 없이 실행될까?

많은 사람들이 오해하는 부분이다.

정답은:

```text
아니다
```

다.

컨테이너도 결국 OS 커널이 필요하다.

다만:

```text
Host OS의 커널을 공유
```

한다.

이게 핵심이다.

---

# Docker Engine의 역할

Docker Engine은:

```text
컨테이너 ↔ Host OS
```

사이의 중간 관리자 역할을 한다.

즉 컨테이너가 시스템 콜을 요청하면:

```text
Container
→ Docker Engine
→ Host Kernel
```

방식으로 처리된다.

---

# VM과 Docker 구조 비교

# VM 구조

```text
App
→ Guest OS
→ Virtual Driver
→ Hypervisor
→ Host OS
→ Hardware
```

---

# Docker 구조

```text
App
→ Docker Engine
→ Host OS
→ Hardware
```

중간 계층이 훨씬 적다.

---

# 그래서 Docker가 빠른 이유

Docker는:

* Guest OS 없음
* Hypervisor 없음
* Virtual Hardware 없음

즉:

```text
커널 공유
```

를 통해 훨씬 가볍고 빠르게 동작한다.

---

# Docker가 빠른 진짜 이유

많은 사람들이:

```text
"Docker는 가볍다"
```

만 기억한다.

하지만 본질은:

```text
불필요한 OS 계층 제거
```

다.

즉:

* 메모리 사용 감소
* 부팅 속도 감소
* 디스크 사용 감소
* CPU 오버헤드 감소

효과가 발생한다.

---

# 그렇다면 Docker는 완벽할까?

아니다.

가장 큰 한계는:

```text
Host OS 커널 의존성
```

이다.

즉:

```text
Linux Host
→ Windows Container 실행 어려움
```

상황이 생긴다.

---

# 왜 Linux 컨테이너가 기본일까

Docker는 원래 Linux 기반 기술이다.

핵심 기능:

* namespace
* cgroup

모두 Linux 커널 기능이다.

그래서 Docker는 Linux 환경에서 가장 자연스럽게 동작한다.

---

# Windows에서 Docker는 어떻게 동작할까

발표에서 중요한 포인트가 나온다.

Windows에서 Docker를 설치하면:

```text
WSL2
```

라는 경량 VM이 함께 실행된다.

구조는:

```text
Windows
→ WSL2 Linux VM
→ Linux Kernel
→ Docker Engine
→ Container
```

이다.

즉 사실 Windows에서도 내부적으로는 Linux VM 위에서 Docker가 실행된다.

---

# macOS도 비슷하다

macOS 역시 내부적으로 Linux VM을 띄운다.

즉 Docker Desktop 내부에는:

```text
숨겨진 Linux VM
```

이 존재한다.

---

# VM vs Container 핵심 비교

| 항목       | VM       | Container |
| -------- | -------- | --------- |
| OS 포함 여부 | 포함       | 미포함       |
| 커널       | 독립       | 공유        |
| 속도       | 상대적으로 느림 | 빠름        |
| 메모리 사용   | 큼        | 작음        |
| 부팅 속도    | 느림       | 빠름        |
| 격리 수준    | 매우 강함    | 상대적으로 약함  |
| OS 독립성   | 높음       | 낮음        |

---

# 실제 운영에서의 차이

## VM이 적합한 경우

* 완전한 OS 격리 필요
* 서로 다른 OS 실행 필요
* 강한 보안 격리 필요

예:

* Windows VM
* Linux VM
* 보안 샌드박스

---

## Container가 적합한 경우

* MSA
* CI/CD
* 빠른 배포
* 확장성
* 클라우드 환경

즉 현대 백엔드 대부분은 컨테이너 기반이다.

---

# 핵심 정리

VM과 Container의 차이는 단순히:

```text
"무겁다 vs 가볍다"
```

가 아니다.

본질은:

```text
OS를 어디까지 가상화할 것인가
```

차이다.

* VM → OS 전체 가상화
* Container → 프로세스 수준 격리

다.

---

# 마무리

Docker와 Kubernetes를 제대로 이해하려면:

```text
"컨테이너가 왜 VM보다 효율적인가"
```

를 먼저 이해해야 한다.

그리고 그 핵심은 결국:

```text
커널 공유
```

다.

---



