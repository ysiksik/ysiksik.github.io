---
layout: post
bigtitle: '대세는 쿠버네티스 [초급~중급]'
subtitle: 기본 오브젝트
date: '2023-12-21 00:00:03 +0900'
categories:
- kubernetes-trending
comments: true

---

# 기본 오브젝트

# 기본 오브젝트

* toc
{:toc}

## Pod - Container, Label, NodeSchedule
+ ![img.png](../../../../assets/img/kubernetes-trending/Pod-Container-Label-NodeSchedule.png)

### Pod
+ Pod의 특징을 보면 Pod 안에는 하나의 독립적인 서비스를 구동할 수 있는 컨테이너들이 있다
+ 그 컨테이너들은 서비스가 연결될 수 있도록 포트를 가지고 있는데 한 컨테이너가 포트를 하나 이상 가질 수는 있지만 한 Pod 내에서 컨테이너들끼리 포트가 중복될 수는 없다.
+ ![img_1.png](../../../../assets/img/kubernetes-trending/Pod-Container-Label-NodeSchedule1.png)
+ Container1 과 Container2 는 하나의 host 로 묶여 있다고 볼 수 있기 때문에, 만약 Container1 에서 Container2 로 접속을 할 때 localhost:8080 으로 접근할 수 있다.
+ 파드가 생성될 때 고유의 IP 주소가 할당이 되는데 Kubernetes 클러스터 내에서만 이 IP를 통해서 이 파드에 접근을 할 수가 있고 외부에서는 이 IP로 접근을 할 수가 없다
+ 만약 파드에 문제가 생기면 시스템이 이걸 감지를 해서 파드를 삭제를 시키고 다시 재생성을 하게 되는데 이때 IP 주소는 변경이 된다. 휘발성이 있는 특징을 가진 IP이다

~~~yaml

# 그림과 같은 Pod 를 생성하기 위한 YAML 파일
apiVersion: v1
kind: Pod                       # Pod 를 생성
metadata:
  name: pod-1                   # Pod 의 이름
spec:
  containers:                   # Container 에 Container1 과 Container2 를 생성
  - name: container1
    image: kubetm/p8000         # Container1 은 이미지의 이름이 p8000
    ports:
    - containerPort: 8000       # Container1 은 8000 번 port 에 노출
  - name: container2
    image: kubetm/p8080         # Container2 는 이미지의 이름이 p8080
    ports:
    - containerPort: 8080       # Container2 는 8080 번 port 에 노출

~~~


### Label
+ Label 은 Pod 뿐만 아니라 모든 오브젝트에 붙일 수 있는데, Pod 에 가장 많이 사용 한다.
+ ![img_2.png](../../../../assets/img/kubernetes-trending/Pod-Container-Label-NodeSchedule2.png)
+ Label 을 사용하는 이유는 목적에 따라 오브젝트들을 분류하고, 분류 된 오브젝트들만 선별하여 연결하기 위함이다.
+ Label 의 구성은 key 와 value 가 한 쌍이고 하나의 Pod 에는 다수의 Label 을 붙일 수 있다. 위와 같이 Label 이 작성 된 상태에서
  + 웹 개발자가 웹 화면만 보고싶은 경우 type 이 web 인 Label 을 가진 Pod 들을 Service 에 연결해서 이 Service 정보를 공유
  + 서비스 운영자에게는 lo 가 production 인 Label 을 가진 Pod 들을 Service 에 연결해서 이 Service 정보를 공유하면 된다
+ 사용 목적에 따라 라벨을 잘 달아 놓으면 우리가 해시태그를 붙여서 검색 용도로 사용하듯이 원하는 파드를 선택을 해서 사용할 수가 있다.

~~~yaml

# Pod 생성시 label 정보 추가
apiVersion: v1
kind: Pod
metadata:
  name: pod-2
  labels:           # label 정보를 추가할 때 k-v 형식을 사용
    type: web
    lo: dev
spec:
  containers:
  - name: container
    image: kubetm/init

~~~

~~~yaml

# 서비스 생성시 연결 할 label 정보 추가
apiVersion: v1
kind: Service
metadata:
  name: svc-1
spec:
  selector:         # selector 에 label 의 k-v 를 넣으면 매칭되는 Pod 에 연결
    type: web
  ports:
  - port: 8080

~~~

### Node Schedule
+ Pod 는 결국 다수의 Node 중 하나의 Node 에 올라가야 한다. 이 때 사용자가 직접 Node 를 선택하는 방법과 k8s 가 자동으로 선택하는 방법이 있다.
+ ![img_3.png](../../../../assets/img/kubernetes-trending/Pod-Container-Label-NodeSchedule3.png)

#### 직접 선택하는 방법
+ 직접 선택하는 방법을 보면 아까 파드에 라벨을 단 것처럼 이번엔 노드에 라벨을 달고 파드를 만들 때 노드를 지정을 할 수가 있다
+ 파드를 만들 때 노드 셀렉터라는 항목에 노드의 라벨과 매칭되는 Key Value를 넣으면 된다

~~~yaml

# 3-1 Node 를 직접 선택하는 경우
apiVersion: v1
kind: Pod
metadata:
  name: pod-3
spec:
  nodeSelector:    # Pod 생성시 Node 의 Label 과 매칭하는 k-v 를 작성
    hostname: node1
  containers:
  - name: container
    image: kubetm/init

~~~

#### Kubernetes의 스케줄러가 판단
+ Kubernetes의 스케줄러가 판단을 해서 지정을 해주는 경우인데 노드에는 전체 사용 가능한 자원량이 있다. 
+ 메모리와 CPU가 대표적인데 일단 메모리를 예를 들면 현재 이 노드에는 몇몇 파드들이 들어가 있어서 남은 메모리가 1기가, 그리고 이 노드에는 3.7기가의 메모리가 남은 상황
+ 이 때 새로 생성 할 Pod 가 필요한 메모리가 3 기가이기 때문에 k8s 가 Pod 를 Node2 쪽으로 Scheduling 해준다.
+ 추가로 리소스 사용량을 명시하는 이유는 Pod 내의 애플리케이션에 부하가 생길 경우 Node 자원을 무한정 사용하려 하기 때문이다. 이런 경우 같은 Node 의 모든 Pod 가 죽게 된다.

~~~yaml

# Pod 생성시 리소스 사용량 제한 설정
apiVersion: v1
kind: Pod
metadata:
  name: pod-4
spec:
  containers:
  - name: container
    image: kubetm/init
    resources:
      requests:           # Pod 에서 사용 할 리소스는
        memory: 2Gi       # 2 기가의 메모리를 요구하고
      limits:
        memory: 3Gi       # 최대 허용 메모리는 3 기가 이다

~~~

+ limits 설정에 대해 Memory 사용량 초과시 Pod 를 종료시키고, cpu 의 경우 사용량 초과시 request 수치로 리소스 양을 낮추기는 해도 직접 Pod 를 종료 시키지는 않는다. 이렇게 Memory 와 cpu 가 다르게 동작하는 이유는 각 자원에 대한 특성 때문이다. 

## Service - ClusterIP, NodePort, LoadBalancer
+ ![img.png](../../../../assets/img/kubernetes-trending/Service-ClusterIP-NodePort-LoadBalancer4.png)
+ 서비스는 기본적으로 자신의 클러스터 IP를 가지고 있다 
+ 서비스를 파드에 연결을 시켜 놓으면 서비스의 IP를 통해서도 파드에 접근을 할 수 있다
+ 파드에도 똑같이 클러스터 내에서 접근할 수 있는 IP가 있는데 굳이 서비스를 달아서 이걸 통해서 접근을 하지 라고 생각할 수가 있는데 그 이유는 파드라는 존재는 Kubernetes에서 시스템 장애건, 성능 장애건 언제든지 죽을 수가
  있고 그러면 다시 재생성 되도록 설계가 돼 있는 오브젝트이다.
+ 파드의 IP는 재생성이 되면 변한다 그렇기 때문에 이 파드의 IP는 신뢰성이 떨어진다
+ 서비스는 사용자가 직접 지우지 않는 한 삭제되거나 재생성되고 그러지 않는다. 그래서 이 서비스의 IP로 접근을 하면 항상 연결되어 있는 파드에 접근할 수가 있게 된다 그렇기 때문에 서비스를 쓰는 거고 서비스의 종류는 여러 종류가 있고 그 종류에 따라서
  파드의 접근을 도와주는 방식이 틀린데 그 중 가장 기본적인 방식인 클러스터 IP라는 방식이 있다

### ClusterIP
+ ![img_1.png](../../../../assets/img/kubernetes-trending/Service-ClusterIP-NodePort-LoadBalancer1.png)
+ 이 IP는 Kubernetes 클러스터 내에서만 접근이 가능한 IP이다. 파드에 있는 IP와 특징이 똑같다.
+ 이 IP도 클러스터 내에 다른 모든 오브젝트들이 접근을 할 수가 있지만 외부에서는 접근을 할 수가 없다. 파드에 있는 IP와 특징이 똑같다.
+ 파드를 하나만 연결할 수 있는 건 아니고 두 개 내지 여러 개의 파드를 연결시킬 수가 있는데 이렇게 여러 개의 파드를 연결시켰을 때 서비스가 트래픽을 분산을 해서 파드에 전달을 해준다

~~~yaml

apiVersion: v1
kind: Pod
metadata:
  name: pod-1
  labels:         # Service 에 연결하기 위한 lebel
     app: pod
spec:
  nodeSelector:
    kubernetes.io/hostname: k8s-node1
  containers:
  - name: container
    image: kubetm/app
    ports:
    - containerPort: 8080

~~~

~~~yaml

apiVersion: v1
kind: Service
metadata:
  name: svc-1
spec:
  selector:       # Pod 와 연결하기 위한 selector
    app: pod
  ports:
  - port: 9000         # 9000 port 로 Service 에 접근하면
    targetPort: 8080   # 8080 port 의 Pod 로 연결
  type: ClusterIP      # optional 값으로 default(ClusterIP)

~~~

~~~shell

curl 10.104.103.107:9000/hostname

~~~

+ yaml 내용을 보면 서비스와 파드가 연결되기 위한 셀렉터와 라벨이 있고 밑에 서비스의 타입을 보면 클러스터 IP라고 있다. 근데 이 타입은 optional한 값이라서 생략을 할 수가 있는데 생략을 하면 기본 값이 클러스터 IP이기 때문에 클러스터 IP를 사용할 때는 이 타입을 안 넣어도 된다.
+ 포트를 보면 9000번 포트로 이 서비스에 들어오면 타겟이 되는 하드에 8080 포트로 연결이 된다는 내용이다.

### NodePort
+ ![img_2.png](../../../../assets/img/kubernetes-trending/Service-ClusterIP-NodePort-LoadBalancer2.png)
+ NodePort 타입의 Service 에도 기본적으로 ClusterIP 가 할당 되고 ClusterIP 와 같은 기능을 포함하고 있다.
+ 노드 타입만의 큰 특징은 Kubernetes 클러스터에 연결되어 있는 모든 노드한테 똑같은 포트가 할당이 돼서 외부로부터 어느 노드건간에 그 IP의 포트로 접속을 하면 이 서비스에 연결이 된다
+ 그럼 또 서비스는 기본 역할인 자신한테 연결되어 있는 파드의 트래픽을 전달을 해준다
+ 주의할 점은 이 파드가 있는 노드에만 포트가 할당되는 게 아니라 모든 노드에 포트가 만들어진다는 게 큰 특징이다

~~~yaml

apiVersion: v1
kind: Service
metadata:
  name: svc-2
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
    nodePort: 30000    # optional 값으로 30000~32767 값
  type: NodePort       # NodePort 타입의 Service
  externalTrafficPolicy: Local

~~~

+ 포트를 보면 노드 포트를 지정을 할 수가 있다 30,000번대에서 32,767번대 사이에서만 할당을 할 수가 있고 이 값도 옵셔널이기 때문에 안넣으면 자동으로 이 범위 내에서 할당이 된다.
+ 만약 각노드에 파드가 하나씩 올라가져 있을때 이 상태에서 1번 노드의 IP로 접근을 하더라도 이 서비스는 이 노드에 있는 파드한테 트래픽을 전달할 수가 있다 서비스 입장에서는 어떤 노드한테 온 트래픽인지 상관없이 그냥 자신한테 달려있는 파드들한테
  트래픽을 전달해 주기 때문인데 근데 만약에 이 yaml 내용에 External Traffic Policy라고 해서 값을 Local이라고 주면 특정 노드 포트의 IP로 접근을 하는 이 트래픽은 서비스가 해당 노드 위에 올려져 있는 파드한테만 트래픽을 전달을 해준다.

### Load Balancer
+ Load Balancer 타입으로 Service 를 만들면 NodePort 의 성격을 그대로 가지게 된다.
+ ![img_3.png](../../../../assets/img/kubernetes-trending/Service-ClusterIP-NodePort-LoadBalancer.png)
+ 로드 밸런서라는게 생겨서 각각의 로드의 트래픽을 분산시켜주는 역할을 한다 
+ 한가지 문제가 이 로드 밸런서에 접근을 하기 위한 외부 접속 ip 주소는 현재 개별적으로 Kubernetes를 설치를 했을 때 기본적으로 생기지가 않는다 별도로 외부 접속 IP를 할당을 해주는 플러그인이 설치가 되어 있어야 이 IP가 생기고
  구글 클라우드 플랫폼이나 아마존에서 제공하는 Kubernetes 플랫폼을 사용을 할 때는 얘네가 자체적으로 플러그인이 설치가 되어 있어서 로드 밸런서 타입으로 서비스를 만들면 알아서 외부에서 접속할 수 있는 IP를 만들어 준다
  그럼 그 IP를 통해서 외부에서 접근이 가능해진다 

~~~yaml

apiVersion: v1
kind: Service
metadata:
  name: svc-3
spec:
  selector:
    app: pod
  ports:
  - port: 9000
    targetPort: 8080
  type: LoadBalancer     # 특별한 설정 없이 타입만 지정

~~~

~~~shell

kubectl get service svc-3

~~~

+ yaml 내용을 보면 별다른 건 없고 타입의 로드 밸런서를 지정을 하면 된다.

### 정리
+ 첫째로 클러스터 IP는 외부에서 접근할 수가 없고 클러스터 내에서만 사용하는 IP이다 그렇기 때문에 이 IP에 접근할 수 있는 대상은 클러스터 내부에 접근을 할 수 있는 운영자와 같은 인가된 사람일 수밖에 없고
  주된 작업은 Kubernetes 대시보드를 관리를 하거나 각 파드의 서비스 상태를 디버깅하는 작업을 할 때 사용이 된다
+ 두 번째로 NodePort는 특징이 물리적인 호스트의 IP를 통해서 파드에 접근을 할 수가 있다는 건데 대부분 호스트 IP는 보안적으로 내부망에서만 접근을 할 수 있게 네트워크를 구성하기 때문에 이 노드포트는 클러스터 밖에는 있지만 그래도 내부망 안에서 접근을 해야 될
  때 쓰인다. 그리고 일시적인 외부 연동용으로도 사용이 되는데 내부 환경에서 시스템 개발을 하다가 외부에 간단한 데모를 보여줘야 된다고 할 때 종종 네트워크 중계기에 포트포워딩을 해서 외부에서 내부 시스템에 연결을 한다 이럴 때 노드포트를 잠깐 뚫어놓고 쓸 수가 있다
+ 마지막으로 로드 밸런서는 실제적으로 외부의 서비스를 노출시키려면 로드 밸런서를 이용을 해야 한다 그래야 내부 IP가 노출되지 않고 외부 IP를 통해서 안정적으로 서비스를 노출시킬 수가 있다 그렇기 때문에 이 로드밸런서는 외부의 시스템을 노출하는 용으로 쓰인다


### Sample Yaml

~~~yaml

piVersion: v1
kind: Service
metadata:
  name: svc-3
spec:
  selector:             # Pod의 Label과 매칭
    app: pod
  ports:
  - port: 9000          # Service 자체 Port
    targetPort: 8080    # Pod의 Container Port
  type: ClusterIP, NodePort, LoadBalancer  # 생략시 ClusterIP
  externalTrafficPolicy: Local, Cluster    # 트래픽 분배 역할

~~~
