---
layout: post
bigtitle: '대세는 쿠버네티스 [초급~중급]'
subtitle: 아키택쳐 - 중급
date: '2024-03-19 00:00:03 +0900'
categories:
- kubernetes-trending
comments: true

---

# 아키택쳐 - 중급

# 아키택쳐 - 중급

* toc
{:toc}

## Kubernetes Architecture 개요
+ 전체적인 범위는 Components, Networking, Storage 그리고 Logging 이다.
+ ![KubernetesArchitecture.png](../../../../assets/img/kubernetes-trending/KubernetesArchitecture.png)
  + k8s 는 하나의 Master 와 다수의 Worker Node 들로 구성 된다.
+ ![KubernetesArchitecture_1.png](../../../../assets/img/kubernetes-trending/KubernetesArchitecture_1.png)
  + Master 에는 Control plane Component 라고 하는 k8s 주요 기능들을 담당하는 Component 들이 있고, 각 Worker Node 에는 Worker Component 라고 하는 Container 를 관리하기 위한 기능들이 있다.
+ ![KubernetesArchitecture_2.png](../../../../assets/img/kubernetes-trending/KubernetesArchitecture_2.png)
  + k8s 에는 크게 Service 와 Pod 에 대한 Network 영역이 있다. 
  + Pod Network 에서 Pod 내의 Container 간 통신에 대해 알아본다. 그리고 Pod 간 통신인데 현재 강의 실습에서는 Calico 플러그인을 설치 했기 때문에 이 플러그인을 사용해서 어떻게 통신 하는지 알아 본다.
  + 그리고 Service 를 Pod 에 연결 했을 때, Service 를 통해 Pod 와 통신할 수 있다. 이 부분이 Service Network 에 대한 부분이고 k8s 를 설치할 때, 설정 모드에 따라 내부적으로 어떻게 동작 하는지에 대해서도 알아 본다.
+ ![KubernetesArchitecture_3.png](../../../../assets/img/kubernetes-trending/KubernetesArchitecture_3.png)
  + Storage 는 Pod 에서 데이터를 안정적으로 저장하는 방법에 대한 내용으로 그 방법에는 hostPath 를 사용하는 방법, 외부 Cloud Service 에서 제공하는 Storage 를 사용하는 방법, 그리고 Cluster 내부에 3rd party 에서 제공하는 Storage Solution 을 설치하는 방법에 대해 알아 본다.
  + 그리고 어떤 방식의 Storage 를 사용하더라도 Volume Type 에는 FileStorage, BlockStorage, ObjectStorage 등 크게 세 가지 종류가 있다. k8s 에서는 이런 type 들에 대한 특징을 잘 알고 사용해야 한다.
+ ![KubernetesArchitecture_4.png](../../../../assets/img/kubernetes-trending/KubernetesArchitecture_4.png)
  + Logging 은 k8s 내에 동작중인 Application 에서 출력되는 log 들을 어떻게 관리하느냐에 대한 부분이다. 크게 Service Pipeline 과 Core Pipeline 이 있다. Core Pipeline 에서는 Pod 에서 생성 된 Log 가 어떤 구조로 쌓이는지 그리고 쌓인 로그를 어떻게 보는지에 대해 알아본다.
  + Service Pipeline 은 별도의 플러그인을 설치하면 Monitoring 에 대한 Pod 들이 생기고, 이 Pod 들이 각 Node 에서 Log 를 가져다 수집 서버에 모으고 이것을 ui 를 통해 사용자에게 보여 준다.



