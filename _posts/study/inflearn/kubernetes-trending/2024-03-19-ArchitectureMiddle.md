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

## Component - kube-apiserver, etcd, kube-schedule, kube-proxy, kube-controller-manager
+ Pod 가 생성되는 과정을 통해 각 Component 들이 어떤 역할을 하는지 살펴 본다.
+ ![img.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager.png)
  + Master Node 에는 Etcd, kube-scheduler, kube-apiserver 가 있다. 일반적인 설치를 했을 때 이 Component 들은 Pod 형태로 띄워져서 구동 된다.
+ ![Networking1.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager1.png)
  + Master Node 에 /etc/kubernetes/manifests 디렉토리를 보면 Component 생성에 대한 yaml 파일들이 있는 것을 볼 수 있다. k8s 가 구동시 이 파일들을 읽고 이 Pod 들을 static 으로 띄운다.
+ ![Networking2.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager2.png)
  + Worker Node 들은 k8s 를 설치할 때 같이 설치한 kubelet 과 Container Runtime 인 Docker 가 구동중인 상태이다.
+ ![Networking3.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager3.png)
  + 이 때 사용자가 kubectl 명령으로 Pod 생성 요청을 했다고 하자. 
  + 먼저 Pod 생성 명령은 kube-apiserver 로 전달 된다.
  + kube-apiserver 는 Etcd 에 있는 Pod 에 대한 입력 정보들을 저장 한다. Etcd 는 k8s 에서 다양한 데이터들을 저장하는 DB 역할을 한다.
+ ![Networking4.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager4.png)
  + kube-scheduler 는 수시로 각 Node 의 자원들을 체크하고 있다.
  + 예를 들어 만약 Node2 에 Container 가 구동중이어서 자원이 사용되고 있다는 것을 알고 있다.
  + 추가로 Watch 라는 기능으로 kube-apiserver 를 통해 Etcd 에 Pod 생성 요청이 들어온 것이 있는지 감시하고 있다.
  + Pod 생성 요청이 있는 것을 발견하면 현재 Node 자원 상태를 확인하고 Pod 가 어느 Node 에 배치되는 것이 좋은지 판단해서 Pod 에 Node 정보를 설정한다.
+ ![Networking5.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager5.png)
  + 각 Node 에 있는 kubelet 들도 kube-apiserver 에 Watch 가 걸려 있고 Pod 에 자신의 Node 정보가 있는지 체크하고 있다가 자신의 Node 정보가 있는 Pod 를 발견하면, 이 정보를 가지고 Pod 를 만들기 시작 한다. 
  + kubelet 이 Pod 를 만들 때 크게 두 가지 일을 한다. 먼저 Docker 에게 Container 를 만들라고 요청하면 Docker 가 바로 Container 를 만들어 준다.
+ ![Networking6.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager6.png)
  + 추가로 /etc/kubernetes/manifests 디렉토리 안에 kube-proxy Controller 를 만드는 kube-proxy.yaml 파일이 있고, 이 yaml 파일은 DaemonSet 이라서 모든 Node 에 kube-proxy Pod 가 생성 되어 있다.
  + 이 상태에서 kubelet 은 kube-proxy 에게 Network 생성 요청을 하고 kube-proxy 가 새로 생성 된 Container 에 통신이 되도록 도와 준다.
+ ![Networking7.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager7.png)
  + Deployment 를 생성하는 과정을 통해 Component 들의 역할을 알아 본다.
  + 다른 Component 들과 마찬가지로 /etc/kubernentes/manifests 디렉토리 안에 kube-controller-manager.yaml 파일이 있어서 Controller Manager Pod 가 띄워져 있다. 그리고 이 안에 여러 Cotroller 들에 대한 기능들이 Thread 형태로 동작 중이다.
+ ![Networking8.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager8.png)
  + 이 상태에서 사용자가 kubectl create 명령으로 Deployment 에 replicas 2 를 설정해서 생성했다고 하자. 
  + 그럼 이 명령은 kube-apiserver 로 전달 되고 Etcd DB 에 정보가 저장 된다.
+ ![Networking9.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager9.png)
  + 한편 Controller Manager 에 있는 Deployment Thread 는 kube-apiserver 에게 Deployment 관련 정보가 수신 되면 알려달라는 Watch 가 걸려있는 상태이다.
  + 그리고 Deployment 가 들어왔기 때문에 Deployment Thread 가 이 내용을 읽고 ReplicaSet 을 만들라고 요청 한다.
+ ![Networking10.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager10.png)
  + 그리고 나면 ReplicaSet 이 관련된 오브젝트가 있는지 Watch 를 걸어둔 상태라 이것을 감지해서 ReplicaSet 안에 Replicas 가 몇 개가 있는지 확인한 다음에 그만큼 Pod 를 만들어 달라고 요청 한다.
+ ![Networking11.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager11.png)
  + 이 상황에서 kube-scheduler 는 Node 가 할당 되지 않은 Pod 를 감지하고, 현재 Node 들의 자원을 고려해서 Pod 들에게 Scheduling 된 Node 를 할당 해준다.
+ ![Networking12.png](../../../../assets/img/kubernetes-trending/Component-kube-apiserver-etcd-kube-schedule-kube-proxy-kube-controller-manager12.png)
  + 그리고 각 Node 에 있는 kubelet 은 자신에게 할당 된 Pod 들을 감지하고 Pod 안의 Container 내용을 Docker 에게 생성 하게 한다.
  + 그럼 Docker 가 Container 를 만들고 kubelet 이 kube-proxy 를 통해 네트워크를 연결 해준다.

## Networking - Pod / Service Network (Calico), Pause Container
+ k8s 가 네트워크를 다루는 전반적인 흐름에 대한 아키택처를 중심으로 정리 한다.
+ ![Networking.png](../../../../assets/img/kubernetes-trending/Networking.png)
  + k8s 를 이루는 Master 와 Worker Node 들이 있고, Pod Network 에 대한 영역이 있다. Cluster 를 설치할 때 pod-network-cidr 로 이 네트워크 대역에 대한 설정을 한 부분이다.
+ ![Networking1.png](../../../../assets/img/kubernetes-trending/Networking1.png)
  + Pod 네트워크 첫 번째는 Pod 안에 있는 Container 간의 통신에 대한 부분 이다. 
  + 크 범위 내에서 고유 ip 를 가지고 있는 인터페이스가 생긴다. 이것을 통해 Container 간 통신이 되는지 알아 본다.
+ ![Networking2.png](../../../../assets/img/kubernetes-trending/Networking2.png)
  + 두 번째는 또 다른 Pod 가 생성 되었을 때, 이 두 Pod 간의 통신에 대한 것으로 k8s 에서 Node 마다 설치 하는 Network Plugin 을 통해서 이루어 진다.
+ ![Networking3.png](../../../../assets/img/kubernetes-trending/Networking3.png)
  + k8s 에서 기본적으로 제공하는 kubenet 이라는 Network Plugin 이 있는데, 네트워크 기능이 많이 제한적이기 때문에 잘 사용하지 않는다.
  + 대신 CNI 라고 하는 Container Network Interface 를 통해 다양한 오픈 소스 Network Plugin 들을 설치할 수 있다.
+ ![Networking4.png](../../../../assets/img/kubernetes-trending/Networking4.png)
  + Network Plugin 마다 네트워크를 제공하는 방법과 기능이 상이하기 때문에 스펙을 잘 알고 사용해야 한다.
  + 본 내용은 대부분의 기능을 지원하는 Calico Network Plugin 을 사용 한다.
  + 만약 GCP, AWS, Azure 등 Cloud 서비스 환경을 사용 한다면 같은 Calico Network Plugin 을 사용한다 하더라도 강의의 실습 환경과는 다르게 동작할 수 있다.
+ ![Networking5.png](../../../../assets/img/kubernetes-trending/Networking5.png)
  + Network Plugin 의 역할은 같은 Node 간의 통신과 외부 네트워크를 통한 타 Node 위에 있는 Pod 간 통신을 담당 한다.
+ ![Networking6.png](../../../../assets/img/kubernetes-trending/Networking6.png)
  + 네트워크 아키택처의 두 번째 내용은 Service Network 에 대한 것이다. 
  + 이것은 k8s 를 설치할 때 별도 옵션을 주지 않아 default 값으로 ip 대역이 설정 되어 있다. 
  + Pod 에 Service 를 연결하면, Service 도 고유 ip 가 만들어지고 동시에 kube-dns 에는 Service 의 이름과 ip 에 대한 도메인이 등록 된다.
  + api-server 가 Worker Node 마다 Pod 형태로 띄워져 있는 kube-proxy 에 Service 의 ip 가 어느 ip 에 연결 되어 있는지에 대한 정보를 보내 준다.
  + 여기서 Service ip 를 Pod ip 로 바꾸는 NAT 기능이 필요한데, kube-proxy 가 iptables 나 IPVS 를 어떻게 사용 하냐에 따라 작동 방식이 나뉜다.
  + 작동 방식은 Proxy-Mode 라고 하고, user space, iptables, ipvs 등 크게 세 가지 방식으로 구분 한다.
+ ![Networking7.png](../../../../assets/img/kubernetes-trending/Networking7.png)
  + 이렇게 구성 된 상태에서 Pod 가 Service 이름을 호출하면 kube-dns 를 통해 ip 를 알아내고, 얻어낸 Service 의 ip 를 NAT 영역으로 호출 한다.
  + 여기에 Service 에 대한 Pod 매핑 정보가 있기 때문에 Network Plugin 을 통해 트래픽을 해당 Pod 로 보낼 수 있게 된다.
  + 즉 Service 네트워크는 NAT 영역 내의 설정이고 Service 를 삭제 하면 api-server 가 이것을 감지하고 kube-proxy 에게 설정을 삭제 하도록 한다.

### Pause Container → Pod Network 담당
+ ![Networking8.png](../../../../assets/img/kubernetes-trending/Networking8.png)
  + Pod 를 만들면 직접 생성한 Container 도 있지만, Pause Container 라고 해서 네트워킹을 담당하는 Container 가 자동으로 생긴다.
  + 이 Container 에 인터페이스가 정의되어 있고, ip 도 할당 된다. 
  + k8s 는 이 Pause Container 에 Network Namespace 를 Pod 내의 모든 Container 가 같이 사용 하도록 구성 해준다. 그래서 할당 받은 ip 에 대한 네트워크를 같이 공유하고 Container 구분은 포트를 통해 하게 된다.
+ ![Networking9.png](../../../../assets/img/kubernetes-trending/Networking9.png)
  + Worker Node 에 Host Network Namespace 와 Host ip 인터페이스가 있다.
  + Pause Container 가 생기면 Host Network Namespace 에 가상 인터페이스가 하나 생기면서 Pause Container 의 인터페이스와 연결 된다.
  + Pod 를 만들 때마다 가상 인터페이스가 생겨서 1:1로 매칭 된다.
+ ![Networking10.png](../../../../assets/img/kubernetes-trending/Networking10.png)
  + Worker Node 에서 20.111.156.66:8000 으로 요청을 보내면 위와 같이 트래픽이 전달 된다. 
  + 이렇게 외부에서 Pod 로 들어오는 트래픽을 받는 것과 특정 Container 로 트래픽을 전달하는 것은 Pause Container 가 리눅스에 Network Namespace 를 별도로 생성해서 가상의 인터페이스를 만들고, 관련된 Container 들에게 공유하고 있기 때문에 가능한 것이다.

### Network Plugin (kubenet, cni) → Cluster Network 담당
+ 먼저 CNI 를 설치 하지 않고, k8s 기본 네트워크인 kubenet 을 사용했을 경우 구성에 대한 내용이다. 잘 사용하지는 않지만 기본적인 네트워크 구성 이해에 도움이 된다.
+ ![Networking11.png](../../../../assets/img/kubernetes-trending/Networking11.png)
  + Pod 를 생성하면 새로운 네트워크 인터페이스를 만드는데, Pod 의 인터페이스와 Host Network 의 가상인터페이스가 연결 된다.
+ ![Networking12.png](../../../../assets/img/kubernetes-trending/Networking12.png)
  + 여기서 kubenet 의 역할은 이 가상 네트워크를 cbr0 이라는 Container Bridge 에 포함 시켜 준다.
  + Bridge 네트워크의 대역은 Pod 네트워크 대역을 참고해서 이것보다 낮은 단계의 대역으로 설정 된다.
  + Bridge 내에서 생성 되는 Pod 의 ip 는 Bridge 의 CIDR 범위 내에서 만들어 진다.
  + Bridge 에 설정 된 CIDR 을 보면, 20.96.1.0 ~ 20.96.1.255 까지 Pod ip 를 할당할 수 있다고 보면 된다.
  + 하나의 Node 위에는 이 개수 이상의 Pod 는 생성되지 않는다. 이 부분이 kubenet 의 단점 중 하나이다.
+ ![Networking13.png](../../../../assets/img/kubernetes-trending/Networking13.png)
  + Network Plugin 에 Router 기능도 있다. 이것은 NAT 를 통해 제공 되며, ip 가 Pod 의 ip 대역이면 해당 트래픽을 Bridge 쪽으로 내려주고 그 외의 ip 에 대해서는 위로 되돌려 보낸다. 
  + 여기까지가 Network Plugin 이 담당하는 네트워크의 기본 구조라고 생각하면 된다.
+ ![Networking14.png](../../../../assets/img/kubernetes-trending/Networking14.png)
  + Calico CNI 를 사용 할 경우, Host Network 에 생성 된 가상 인터페이스가 Router 에 바로 연결 된 구조를 가진다. 
  + 그렇게 때문에 두 Pod 간 통신은 이 Router 가 담당 해준다.
  + 여기에 CIDR 은 kubenet 보다 더 넓은 범위를 가지고 있어서 하나의 Node 에서 Pod 에게 더 많은 ip 를 할당할 수 있다.
  + Calico Plugin 에서 제공하는 보안 요소가 많은데 방화벽 과 같은 것들이 있다.
+ ![Networking15.png](../../../../assets/img/kubernetes-trending/Networking15.png)
  + Router 윗단에는 Overlay 네트워크를 지원해주는 계층이 있다. 그 종류에는 IPIP 방식과 VXLAN 방식이 있고, Overlay 네트워크가 하는 일은 Node 안에 있는 Pod 가 다른 Node 의 Pod 와 통신할 수 있도록 해주는 것이다.
  + Calico Plugin 을 사용했을 때, 각 Worker Node 의 Pod 들이 어떻게 통신 되는지 살펴 본다.
+ ![Networking16.png](../../../../assets/img/kubernetes-trending/Networking16.png)
  + Pod D 에서 Pod B 로 트래픽을 전송 한다고 했을 때, Pod D 에서는 Pod B 의 ip 인 20.111.156.7 로 호출 한다.
  + Router 의 가상 인터페이스를 지나는데, 이 ip 는 Worker Node2 의 Router 에 정보가 없기 때문에 Overlay 계층까지 올라 간다.
+ ![Networking17.png](../../../../assets/img/kubernetes-trending/Networking17.png)
  + Calico 는 이 Pod 의 ip 대역이 어느 Node 에 있는지 알고 있기 때문에, 패킷에 실제 Pod 의 ip 를 해당 Node 의 ip 로 감싼다.
+ ![Networking18.png](../../../../assets/img/kubernetes-trending/Networking18.png)
  + 이 트래픽은 192.168.59.22 ip 를 갖는 Host 인터페이스로 전달 된다.
  + Worker Node1 로 들어온 트래픽은 Overlay 계층에서 내부에 있는 Pod 의 IP 로 변환 된다. 리고 이 ip 대역이 있는 Router 로 트래픽이 전달 되고 Router 안에서 ip 와 일치하는 가상 인터페이스를 지나 Pod B 에 도착하게 된다.

### Service Network / Proxy Mode
+ k8s 가 제공하는 Service Network 의 Proxy Mode 에는 세 가지 종류가 있다. 각 모드에 대해 알아보기 위한 전제 상황을 먼저 설명 한다.
+ ![Networking19.png](../../../../assets/img/kubernetes-trending/Networking19.png)
  + Pod 를 만들고 Service 를 연결 하는데, Pod 가 정상 구동 된 상태라면, 중간에 EndPoint 오브젝트가 만들어져 실제 연결 상태를 담당 한다.
  + Service 의 ip 는 Service Network CIDR 범위 내에서 생성 된다.
  + 이 때 api-server 는 EndPoint 를 감시하고 있다가 모든 Node 위에 DaemonSet 으로 설치 되어 있는 kube-proxy 에게 이 Service 의 ip 가 Pod 의 ip 로 포워딩 된다는 정보를 준다.
+ ![Networking20.png](../../../../assets/img/kubernetes-trending/Networking20.png)
  + Userspace 모드는 리눅스 Worker Node 에 기본적으로 설치 되어 있는 iptables 에 Service CIDR 로 들어오는 트래픽은 모두 kube-proxy 에게 전달 하도록 설정 되어 있다. 그래서 만약 Pod 에서 Service ip 를 호출 할 경우 이 트래픽은 iptables 를 지나 kube-proxy 로 전달 된다.
  + kube-proxy 는 자신이 가지고 있는 매핑 정보를 참고해서 이 트래픽을 Pod ip 로 바꿔 준다. 이렇게 Pod ip 로 바뀐 트래픽은 Pod Network 통신 영역으로 전달 되어 목적 Pod 로 트래픽이 전달 된다.
  + 이 방법의 단점은 모든 트래픽이 kube-proxy 를 지나는 구조인데, 이 모든 트래픽을 감당하기에는 kube-proxy 자체의 성능이나 안정성이 좋지 않다. 그래서 많이 사용하는 방식은 아니다.
+ ![Networking21.png](../../../../assets/img/kubernetes-trending/Networking21.png)
  + iptables 모드는 kube-proxy 가 ip 매핑 정보를 iptables 에 직접 등록하는 방식으로 Pod 에서 보내는 Service ip 는 iptables 에서 직접 Pod ip 로 변환 된다. 
  + 이 방식이 k8s 를 설치 했을 때 기본 모드이기도 하고 성능이나 안정성이 훨씬 좋다.
+ ![Networking22.png](../../../../assets/img/kubernetes-trending/Networking22.png)
  + 리눅스 에서는 IPVS 라는 L4 Loadbalance 라는 것을 제공 한다. 
  + Service Mode 를 IPVS 로 설정 하면, IPVS 가 iptables 와 같은 역할을 해준다. 
  + 성능 테스트 결과를 보면 낮은 트래픽 에서는 둘의 네트워크 성능은 비슷하지만 부하가 커질수록 IPVS 의 성능이 더 좋다.

### Service network / Service Type (ClusterIp)
+ Service 를 만들 때 ClusterIP 나 NodeIp 타입에 따라 트래픽 흐름이 달라진다.
+ ![Networking23.png](../../../../assets/img/kubernetes-trending/Networking23.png)
  + Calico 의 Pod Network 구조.
+ ![Networking24.png](../../../../assets/img/kubernetes-trending/Networking24.png)
  + Router 부분에서 Service ip 를 Pod ip 로 변환 해주는 NAT 역할을 하는 기능이 있다.
+ ![Networking25.png](../../../../assets/img/kubernetes-trending/Networking25.png)
  + Pod D 에서 Pod B 로 트래픽을 전송 한다고 했을 때, Pod B 에 ClusterIP 타입의 Service 를 연결 한다.
  + Pod D 에서 Service ip 로 트래픽을 전송하면, NAT 에서 해당 Service ip 와 매칭하는 Pod ip 로 변환 된다. 
  + 다음부터는 Overlay 계층에서 ip 가 감싸지고, 앞서 본 Pod Network 단의 통신을 하게 된다.
  + 이것이 Calico 에서 ClusterIP 에 대한 트래픽 흐름 이다.
+ ![Networking26.png](../../../../assets/img/kubernetes-trending/Networking26.png)
  + Pod 에 ClusterIP 타입이 아닌 NodePort 타입의 Service 를 연결하면, 모든 Node 에 있는 kube-proxy 가 자신의 Node 에 30,000 번대 포트를 열어준다. 
  + 외부에서 이 Host ip 의 포트로 트래픽이 들어오면, iptables 에서 이 트래픽을 Calico Network Plugin 으로 보내 준다.
+ ![Networking27.png](../../../../assets/img/kubernetes-trending/Networking27.png)
  + 이후 부터는 ClusterIP 와 같이 NAT 기능을 통해 해당 ip 로 변환 되면서 Pod Network 영역으로 들어가게 된다.

### 실습
+ [https://kubetm.github.io/k8s/09-intermediate-architecture/networking/](https://kubetm.github.io/k8s/09-intermediate-architecture/networking/)
