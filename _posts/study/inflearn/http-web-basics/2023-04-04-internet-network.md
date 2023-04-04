---
layout: post
bigtitle: '모든 개발자를 위한 HTTP 웹 기본 지식'
subtitle: 인터넷 네트워크
date: '2023-04-04 00:00:00 +0900'
categories:
- http-web-basics
comments: true

---

# 인터넷 네트워크

# 인터넷 네트워크
* toc
{:toc}

## 인터넷 통신
+ 인터넷에서 컴퓨터 둘 통신
  + ![img.png](../../../../assets/img/elegant-tekotok/internet-network.png)
+ 인터넷
  + ![img_1.png](../../../../assets/img/elegant-tekotok/internet-network.png1.png)
+ 복잡한 인터넷 망
  + ![img_2.png](../../../../assets/img/elegant-tekotok/internet-network.png2.png)

## IP(인터넷 프로토콜)
+ 인터넷 프로토콜 역할
  + 지정한 IP 주소(IP Address)에 데이터 전달
  + 패킷(Packet)이라는 통신 단위로 데이터 전달
+ IP 패킷 정보
  + ![img_3.png](../../../../assets/img/elegant-tekotok/internet-network.png3.png)
+ 클라이언트 패킷 전달
  + ![img_4.png](../../../../assets/img/elegant-tekotok/internet-network.png4.png)
+ 서버 패킷 전달
  + ![img_5.png](../../../../assets/img/elegant-tekotok/internet-network.png5.png)
+ IP 프로토콜의 한계
  + 비연결성
    + 패킷을 받을 대상이 없거나 서비스 불능 상태여도 패킷 전송
  + 비신뢰성
    + 중간에 패킷이 사라지면?
    + 패킷이 순서대로 안오면?
  + 프로그램 구분
    + 같은 IP를 사용하는 서버에서 통신하는 애플리케이션이 둘 이상이면?
+ 대상이 서비스 불능, 패킷 전송
  + ![img_6.png](../../../../assets/img/elegant-tekotok/internet-network.png6.png)
+ 패킷 소실
  + ![img_7.png](../../../../assets/img/elegant-tekotok/internet-network.png7.png)
+ 패킷 전달 순서 문제 발생
  + ![img_8.png](../../../../assets/img/elegant-tekotok/internet-network.png8.png)
  
## TCP UDP
+ 인터넷 프로토콜 스택의 4계층
  + ![img_9.png](../../../../assets/img/elegant-tekotok/internet-network.png9.png)
+ 프로토콜 계층
  + ![img_10.png](../../../../assets/img/elegant-tekotok/internet-network.png10.png)
  + ![img_11.png](../../../../assets/img/elegant-tekotok/internet-network.png11.png)
+ IP 패킷 정보
  + ![img_12.png](../../../../assets/img/elegant-tekotok/internet-network.png12.png)
+ TCP/IP 패킷 정보
  + ![img_13.png](../../../../assets/img/elegant-tekotok/internet-network.png13.png)
+ TCP 특징
  + 전송 제어 프로토콜(Transmission Control Protocol)
  + 연결지향 - TCP 3 way handshake (가상 연결)
  + 데이터 전달 보증
  + 순서 보장
  + 신뢰할 수 있는 프로토콜
  + 현재는 대부분 TCP 사용
+ TCP 3 way handshake
  + ![img_14.png](../../../../assets/img/elegant-tekotok/internet-network.png14.png)
  + SYN: 접속 요청
  + ACK: 요청 수락
  + 참고: 3. ACK와 함께 데이터 전송 가능
+ 데이터 전달 보증
  + ![img_15.png](../../../../assets/img/elegant-tekotok/internet-network.png15.png)
+ 순서 보장
  + ![img_16.png](../../../../assets/img/elegant-tekotok/internet-network.png16.png)
+ UDP 특징
  + 사용자 데이터그램 프로토콜(User Datagram Protocol)
  + 하얀 도화지에 비유(기능이 거의 없다)
  + 연결지향 - TCP 3 way handshake X
  + 데이터 전달 보증 X
  + 순서 보장 X
  + 데이터 전달 및 순서가 보장되지 않지만, 단순하고 빠름
  + 정리
    + IP와 거의 같다. +PORT +체크섬 정도만 추가
    + 애플리케이션에서 추가 작업 필요

## PORT
+ 한번에 둘 이상 연결해야 하면?
  + ![img_17.png](../../../../assets/img/elegant-tekotok/internet-network.png17.png)
+ TCP/IP 패킷 정보
  + ![img_13.png](../../../../assets/img/elegant-tekotok/internet-network.png13.png)
+ 패킷 정보
  + ![img_18.png](../../../../assets/img/elegant-tekotok/internet-network.png18.png)
+ PORT - 같은 IP 내에서 프로세스 구분
  + ![img_19.png](../../../../assets/img/elegant-tekotok/internet-network.png19.png)
+ PORT
  + 0 ~ 65535 할당 가능
  + 0 ~ 1023: 잘 알려진 포트, 사용하지 않는 것이 좋다
    + FTP - 20, 21
    + TELNET - 23
    + HTTP - 80
    + HTTPS - 443

## DNS
+ IP는 기억하기 어렵다.
+ IP는 변경될 수 있다.
+ DNS 도메인 네임 시스템(Domain Name System)
  + 전화번호부
  + 도메인 명을 IP 주소로 변환
+ DNS 사용
  + ![img_20.png](../../../../assets/img/elegant-tekotok/internet-network.png20.png)
