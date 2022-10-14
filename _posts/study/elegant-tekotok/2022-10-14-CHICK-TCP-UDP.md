---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 칙촉의 TCP/UDP
date: '2022-10-14 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 칙촉의 TCP/UDP
[https://youtu.be/ad4AO1shXsY](https://youtu.be/ad4AO1shXsY)

# 칙촉의 TCP/UDP
* toc
{:toc}

## TCP/UDP 를 왜 알아야 할까?
+ 웹 어플리케이션의 신뢰성, 성능 개선을 하는 중요한 역할을 한다
  + ex) 데이터의 소실 방지, 순서 보장
  + ex) HTTP3.0 에서 도입된 QUIC

## TCP/IP 모델
+ Application Layer - HTTP, 브라우저
+ Transport Layer - TCP/UDP
+ Internet Layer - IP
+ Network Access Layer - 인터넷

## TCP 동작 과정

<div class="language-mermaid">
graph LR;
    A[소켓 생성]-->B[3 Way Handshake];
    B-->C[데이터 송신, 수신];
    C-->D[4 Way Handshake]
</div>

### TCP 헤더 

| 컨트롤 비트 |                                                |
|--------|------------------------------------------------|
| SYN    | 송신측과 수신측에서 시퀀스 번호를 공유함을 나타냄                    |
| ACK    | 수신 테이터의 시퀀스 번호가 유효함                            |
| FIN    | 연결 끊기를 나타냄                                     |
| 시퀀스 번호 | 현재 데이터의 첫 번째 위치가 전체 송신 데이터에 몇 번째 인지를 나타내는 일련번호 |
| ACK 번호 | 수신측에 몇 바이트까지 받았는지 송신측으로 보내는 일렬번호               |

### 소켓 생성
+ ![img.png](/assets/img/elegant-tekotok/soketCreate.png)
  + 브라우저에서 소켓을 호출된다. 이때 도메인과 사용할 타입인 TCP를 설정해서 호출하게 되는데 OS의 네트워크 제어용 소프트웨어라고 할 수 있는 프로토콜 스택이 이를 받아서 소켓을 작성하게 되고 
  디스크립터를 반환하게 된다. 
    + 디스크립터는 소켓의 번호표라고 보면 된다.

### 3 Way Handshake
+ ![img.png](/assets/img/elegant-tekotok/3WayHandshake.png)
  + 브라우저에서 받았던 디스크립터와 요청을 보낸 서버 IP 주소, 포트 번호를 넣어서 호출하게 된다. 그렇게 되면 프로토콜 스택이 요청을 받아서 웹 서버로 요청을 보내게 된다.  
+ 좀 더 자세한 3 Way Handshake
  + ![img.png](/assets/img/elegant-tekotok/3WayHandshake2.png)
    + 첫 번째로 클라이언트에서 시퀀스 번호를 초기화하게 된다. 초기화 한 번호를 공유하기 위해서 컨트롤 비트 SYN 을 설정을 해서 서버로 보내준다. 
      + SYN 은 시퀀스 번호를 공유함을 나타내는 컨트롤 비트이다. 
  + ![img.png](/assets/img/elegant-tekotok/3WayHandshake3.png)
    + 마찬가지로 서버에서 시퀀스 번호를 초기화를 해서 서버에서 생성한 시퀀스 번호를 공유하게 되고 클라이언트로 부터 받았던 스쿼스 번호가 잘 도착했다는 것을 알리기 위해서 ACK 번호를 설정을 해서 
    클라이언트로 데이터를 보내게 된다. 
  + ![img.png](/assets/img/elegant-tekotok/3WayHandshake4.png)
    + 서버에서 시퀀스 번호를 잘 받았다는 걸 서버에 알려주기 위해서 ACK 번호를 설정을 해서 서버로 데이터를 보내게 된다.
+ 와이어 샤크를 사용해서 3 Way Handshake를 할 때 어떤 패킷들이 주고받아지는지를 살펴보자
  + ![img.png](/assets/img/elegant-tekotok/3WayHandshake5.png)
    + 먼저 순차적으로 SYN으로 설정된 패킷 그리고 SYN, ACK 로 설정된 패킷 ACK 로 설정된 패킷을 볼 수 있다. 
    + 시퀀스 넘버와, 아크 넘버가 난수로 설정된 이유 
      + 포트는 유한기 때문에 같은 포트가 사용될 가능성이 있다. 그래서 서버와 클라이언트가 각각 같은 포트를 사용하게 되면은 서버에서는 패킷을 구분하기 위해서 시퀀스 넘버를 통해서 구분하게 된다
      그런데 순차적인 시퀀스 넘버를 사용하게 되면은 이전 커넥션으로부터 온 패킷으로 인지를 할 가능성이 있기 때문에 서버에서 인지할 수 있도록 난수를 생성을 해서 패킷을 보내주게 된다.

### 데이터 송신, 수신
+ ![img.png](/assets/img/elegant-tekotok/dataSendRecive.png)
  + 클라이언트에서 write 를 호출하게 되고 브라우저에서 받은 Http request 메세지를 받아서 패킷으로 만들어 서버에  전달하게 된다. 
+ ![img.png](/assets/img/elegant-tekotok/dataSendRecive2.png)
  + 이걸 받은 서버는 응답을 하기 위해서 데이터를 만들고 패킷을 만들어서 클라이언트에 보내게 되면 클라이언트는 read를 호출해서 데이터를 읽게 된다.
+ ![img.png](/assets/img/elegant-tekotok/dataSendRecive3.png)
  + 만약 중간에 패킷이 이렇게 소실되게 되면은 클라이언트는 서버로부터 일정 시간 동안 응답이 오지 않으면 이전 패킷을 다시 재전송해서 요청을 하게 된다. 이랬는데도 요청에 응답이 오지 않는다면
  클라이언트에서는 데이터 송신작업을 강제로 종료하고 어플리케이션에 오류를 반환하게 된다. 
+ 데이터 송수신에서 주고 받은 패킷
  + ![img.png](/assets/img/elegant-tekotok/dataSendRecive4.png)
    + TCP Segment Length - 세그먼트같은 경우는 TCP 헤더와 데이터를 나타낸다. 그래서 보낸 데이터가 557bytes 라는 걸 의미한다. 수신 측 에서는 받았다는 의미로 ACK 번호를 558로 설정되어 있는데 
    보내는 데이터는 557인데 받은 데이터가 558 인 이유는 3 Way Handshake 과정에서 이미 한번 시퀀스 번호를 주고 받았기 때문에 +1 이 되어서 558이 설정된 것이다. 

### 4 Way Handshake
+ 연결 끊기 동작을 위한 4 Way Handshake
+ ![img.png](/assets/img/elegant-tekotok/4WayHandshake.png)
   + 클라이언트에서는 close 를 호출하게 되면 TCP 헤더에 연결 끊기를 나타내는 컨트롤 비트 FIN 을 설정을 해서 서버로 보내주게 된다.
+ ![img.png](/assets/img/elegant-tekotok/4WayHandshake2.png)
   + 서버는 이 FIN 에 대한 응답으로 ACK 를 설정을 해서 응답을 하게 된다. 클라이언트는 서버로부터 FIN 응답이 올 때 까지 기다리는 상태가 된다. 
+ ![img.png](/assets/img/elegant-tekotok/4WayHandshake3.png)
   + 서버에 보낼 데이터가 없다면 바로 close 를 호출해서 마찬가지로 컨트롤 비트 FIN 을 설정을 해서 클라이어트로 보내게 된다. 
+ ![img.png](/assets/img/elegant-tekotok/4WayHandshake4.png)
   + 클라이언트에서는 잘 받았다는 의미로 ACK 번호를 설정을 해서 서버로 전송을 하게 되면 클라이언트의 소캣이 말소되고 연결이 끊기게된다. 
   + 소켓이 말소될 때는 바로 말소되는 게 아니라 일정 시간 뒤에 말소가 되는데 그 이유는 서버가 ACK 패킷을 받지 못했을 경우에 다시 재용청르 할 수 있기 때문에 일정 시간 뒤에 소켓을 말소하게 된다.  

## UDP 동작 과정
+ ![img.png](/assets/img/elegant-tekotok/UDP.png)
  + TCP와 동일하게 소켓을 호출하게 되는데 이때 도메인과 사용할 타입인 UDP 를 설정해서 호출하게 된다. 프로토콜 스택이 소켓을 작성하게 되고 디스크립터를 반환하게 된다.
+ ![img.png](/assets/img/elegant-tekotok/UDP2.png)
   + sendto 를 호출하고 브라우저로부터 받은 Http 메시지를 넣어서 패킷으로 만들어 서버로 전송을 하게 된다.
+ ![img.png](/assets/img/elegant-tekotok/UDP3.png)
   + 서버에서는 응답을 하기 위해서 sendto 를 호출하게 되고 이때 패킷이 소실되게 되더라도 다음 데이터를 바로 전송하게 된다. 클라이언트는 이걸 신경 쓰지 않고 recvfrom 을 호출해서  
   데이터를 5bytes 받게 된다. 

## 정리 

|        | TCP                          | UDP                |
|--------|------------------------------|--------------------|
| 신뢰성    | 높음                           | 낮음                 |
| 전송속도   | 느림                           | 빠름                 |
| 사용되는 곳 | HTTP2.0 이하의 버전대부분에서 사용 된다.   | DNS, 동영상, 음성 데이터   |  

+ UDP 가 DNS 서버와 통실할 때 사용될 수 있는 이유는 하나의 패킷에 요청, 응답 값이 담길 수 있기 때문에 중간에 패킷이 소실되더라도 한 번 더 요청을 보내기 때문에 UDP 를 사용한다.
그리고 하나의 패키지 때문에 순서가 보장될 필요가 없어서 UDP를 사용하게 된다. 