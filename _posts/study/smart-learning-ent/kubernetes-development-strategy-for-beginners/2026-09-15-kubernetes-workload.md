---
layout: post
bigtitle: '처음 배우는 쿠버네티스 개발 전략'
subtitle: Kubernetes Workload
date: '2026-09-15 00:00:00 +0900'
categories:
    - kubernetes-development-strategy-for-beginners
comments: true

---

# Kubernetes Workload

# Kubernetes Workload

* toc
{:toc}

---

## 워크로드(Workload)
+ 애플리케이션을 실행하는 기본적인 단위
+ Process, Instance, Job 등을 포괄하는 의미 
+ 쿠버네티스
  + 컨테이너를 이용해 애플리케이션 실행
  + 실행된 컨테이너들을 관리해주고 환경을 만들어주는 역할 수행 
  + 워커로드 역시 다양한 형태로 만들어서 제공 

## Kubernetes Workload 객체들
+ 독립적으로 사용되는 것이 아니라 서로 연과성을 가지고 있음
+ pod를 기본으로 애플리케이션을 어떤 성격으로 사용할 것인가에 따라서 종류가 달라짐
+ 워크로드의 개념을 포함하는 상위 개념의 워크로드가 존재하는 경우가 있음
+ pod
  + 쿠버네티스의 가장 기본적이고 작은 구성요소
  + 애플리케이션을 java, python, node 등의 명령어로 실행하면 하나의 프로세스가 실행됨
    + 컨테이너로 만들어서 실행하면 pod 단위가 됨
    + 일반적인 인스턴스보다 살짝 큰 단위
    + 많은 경우 하나의 파드는 하나의 어플리케이션을 의미 
    + 파드는 애플리케이션 인스턴스와 비슷한 범위를 가진 워크로드 객체
  + replicaset
    + 같은 파드를 여러 개 실행할 수 있도록 도와주는 단위
      + 파드의 수량 관리, 동일한 스펙의 파드 다수 실행
      + 서버 이중화 -> 같은 프로세스를 다른 머신에 하나씩 실행 
      + 스케일 아웃 -> 많은 수의 인스턴스를 만들어 냄
      + replicaset을 통해 pod의 수량을 조정할 수 있음
      + 서로 다른 파드들을 묶어서 관리하는 개념이 아님
    + Deployment
      + replicaset의 버전 관리, 업데이트 수행
      + 롤링 업데이트 기능 수행
        + 서비스 중단을 최소화하여 순차적 업데이트
      + 배포 오류 시 롤백 작업 수행
      + pod, replicaset 보다 많은 기능을 수행함
      + 수량 조절, 버전 관리 등을 위해 deployment를 사용하여 pod와 replicaset을 관리하는 경우가 많음 
    + StatefulSet
      + 다수의 파드를 실행하고 관리해줌
      + replicaset은 파드를 임의로 생성하고 종료
      + StatefulSet 파드를 순차적으로 생성하고 종료
      + replicaset과 deployment는 상태가 없는 애플리케이션(스테이트리스 애플리케이션) 개발에 특화되어 있음
      + 쿠버네티스에서 데이터를 저장 관리 하는 애플리케이션이 실행해야 한다면?
        + 해당 파드가 종료후 재실행되었을때 완전히 초기화 되면 안됨
        + StatefulSet은 파드가 실행되거나 종료될때 번호를 붙여서 식별할 수 있게 해준다 
