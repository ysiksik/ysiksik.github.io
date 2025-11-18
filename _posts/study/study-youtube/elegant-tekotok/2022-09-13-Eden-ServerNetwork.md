---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 에덴의 서버 네트워크
date: '2022-09-13 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 에덴의 서버 네트워크
[https://youtu.be/cJ4ZiaKnejQ](https://youtu.be/cJ4ZiaKnejQ)

# 에덴의 서버 네트워크
* toc
{:toc}

## IP
+ 컴퓨터와 컴퓨터간의 식별자
+ Internet Protocol
  + 인터넷 상에서 하나의 컴퓨터에서 다른 컴퓨터로 데이터를 보낼 때의 통신 프로토콜
+ IP address
  + 인터넷 프로토콜이 네트워크 통신을 위해 사용하는 네트워크 주소
  + 컴퓨터의 고유한 주소 
+ 네트워크 계층
  + ![img.png](/assets/img/elegant-tekotok/ip.png)
+ Public IP
  + 외부와 통신하기 위해 사용되는 고유한 주소
  + ![img.png](/assets/img/elegant-tekotok/ip2.png)
  + Dynamic IP - 계속 바뀔 수 있는 Public IP
    + 공유기, InStance 등을 껐다가 키는 경우
    + 오래도록 사용이 되지 않는 경우
  + Static IP
    + 고정된 Public IP
+ Private IP
  + 내부 네트워크의 서버와 통신하기 위한 목적으로 할당된 IP
    + 10.0.0.0 ~ 10.255.255.255 : 대규모, 큰 회사 
    + 172.16.0.0 ~ 172.31.255.255 : 중간 규모
    + 192.168.0.0 ~ 192.168.255.255 : 소규모
  + 하나의 네트워크 대역을 공유하면 해당 네트워크 안에 있는 서버들은 프라이빗 아이피로 통신 가능
  + 각각의 네트워크마다 같은 Private IP 존재 - 고유하지 않다.

## Port
+ 컴퓨터 하나의 내부에서 프로세스와 프로세스 사이의 식별자
+ 프로세스에 데이터가 접근하기 위한 숫자로 된 식별자
+ 전송 계층
  + ![img.png](/assets/img/elegant-tekotok/port.png)
+ 16비트로 되어 있다.
  + 0번부터 65535번까지의 포트를 가질 수 있다.
  + ![img.png](/assets/img/elegant-tekotok/port2.png)

## Port Forwarding
+ 네트워크 상에서 요청이 네트워크 라우터를 통과할때 IP와 Port 번호를 보고 해당 요청을 다른 곳으로 넘겨 주는 기능
