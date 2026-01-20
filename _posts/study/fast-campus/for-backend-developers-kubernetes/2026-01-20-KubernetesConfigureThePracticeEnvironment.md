---
layout: post
bigtitle: 'Part 1. 개발자를 위한 Kubernetes 입문'
subtitle: Ch 4. Kubernetes 실습 환경 구성
date: '2026-01-20 00:00:02 +0900'
categories:
    - for-backend-developers-kubernetes
comments: true
---

# Ch 4. Kubernetes 실습 환경 구성

# Ch 4. Kubernetes 실습 환경 구성
* toc
{:toc}

---

## 01. Kubernetes 실습 환경 개요

Kubernetes를 학습할 때 가장 먼저 부딪히는 문제는 **실습 환경 구성**이다.
실제 운영 환경처럼 AWS나 GCP에 클러스터를 구성할 수도 있지만, 학습 단계에서는 비용과 설정 부담이 크다.

이 챕터에서는 **로컬 머신에서 Kubernetes 클러스터를 실행하는 환경**을 구성한다.
이를 통해 인프라 비용 없이 Kubernetes의 핵심 개념과 동작 방식을 실습할 수 있다.

실습 환경은 다음 세 가지 도구로 구성된다.

1. Docker Desktop
2. kind (Kubernetes IN Docker)
3. kubectl

---

## 02. Docker Desktop 설치

Docker Desktop은 로컬 머신에서 컨테이너를 실행하기 위한 기본 환경이다.
kind는 내부적으로 Docker 컨테이너를 사용해 Kubernetes 노드를 구성하므로, Docker Desktop이 먼저 설치되어 있어야 한다.

* 운영체제에 맞는 Docker Desktop 설치
* 설치 후 Docker 데몬이 정상적으로 실행되는지 확인

Docker가 정상 동작한다면 Kubernetes 실습을 위한 기반은 준비된 셈이다.

---

## 03. kind 설치

kind는 **로컬 머신에서 Kubernetes 클러스터를 실행할 수 있도록 도와주는 도구**다.
클라우드 환경 없이도 Kubernetes를 사용할 수 있게 해주기 때문에 학습과 테스트에 매우 적합하다.

### kind의 특징

* 로컬 환경에서 Kubernetes 클러스터 생성
* Docker 컨테이너 기반으로 Kubernetes 노드 구성
* AWS, GCP 없이도 Kubernetes 실습 가능
* 빠른 생성과 삭제로 반복 실습에 유리

### 설치 방법

* 공식 사이트: [https://kind.sigs.k8s.io/](https://kind.sigs.k8s.io/)
* Quick Start 메뉴에서 운영체제에 맞는 설치 방법 선택
* 바이너리 설치 또는 패키지 매니저를 통해 설치

### 클러스터 생성

설치가 완료되면 아래 명령어로 Kubernetes 클러스터를 생성할 수 있다.

```
kind create cluster
```

이 명령어를 실행하면 로컬 머신에 Kubernetes 클러스터가 자동으로 구성된다.

---

## 04. kubectl 설치

kubectl은 Kubernetes 클러스터를 제어하기 위한 **CLI(Command Line Interface)** 도구다.
클러스터에 리소스를 생성하거나 상태를 확인할 때 필수적으로 사용된다.

### kubectl 설치 경로

* [https://kubernetes.io/](https://kubernetes.io/)
* Documentation → Tasks → Install Tools

운영체제에 맞는 설치 방법을 선택해 kubectl을 설치한다.

### 설치 확인

설치가 완료되면 다음 명령어로 정상 설치 여부를 확인한다.

```
kubectl version
```

kind로 생성한 클러스터와 kubectl이 정상적으로 연결되면,
이제 Kubernetes 리소스를 직접 다뤄볼 수 있는 실습 환경이 완성된다.

---
