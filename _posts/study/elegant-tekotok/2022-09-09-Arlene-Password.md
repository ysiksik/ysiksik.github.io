---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 알린의 암호
date: '2022-09-09 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 알린의 암호
[https://youtu.be/UJDB6e8s1Fg](https://youtu.be/UJDB6e8s1Fg)

# 알린의 암호
* toc
{:toc}

## 암호의 정의
+ 중요한 정보를 읽기 어려운 값으로 변환하여 제 3자가 볼 수 없도록 하는 기술
+ 수학적인 원리에 기반
+ 보안에 기초가 되는 원천 기술

## 암호의 구성요소
+ 평문
+ 암호문
+ 암호화 알고리즘
+ 키

<div class="language-mermaid">
graph LR;
    평문-->A[암호화 알고리즘];
    A-->암호문;
    키-->A;
</div>

## 암호가 제공하는 기능
+ 기밀성
  + 노출이나 유출의 위험으로부터 데이터를 안전하게 보호하는 방법
  + 공격자기 읽기 어렵게해서 기밀성을 유지
+ 무결성
  + 변조 위험으로부터 데이터를 안전하게 보호
+ 인증
  + 안전한 사용자인지 확인
+ 부인 방지
  + 메시지를 송/수신 한 사실을 부인할 수 없도록 확인

## 암호 분류 
+ 단방향 암호
  + 암호화만 되는 해시 함수가 있다.
+ 양방향 암호
  + 암호 복호화가 다되는 대칭키 암호, 비대칭키 암호가 있다.

## 대칭키 암호
+ 하나의 키를 공유하여 사용하는 방식
+ 암호화와 복호화의 같은 키를 사용하는 방식
+ 블록 암호, 스트림 암호

<div class="language-mermaid">
graph LR;
    평문-->A[암호화 알고리즘];
    A-->평문;
    A-->암호문;
    암호문-->A;
    키-->A;
</div>

+ 장점
  + 비대칭키 암호보다 연산량이 적고 빠름
  + 대용량 데이터 암호화 가능
+ 단점 
  + 기밀성 외 기능 제공이 어려움
  + 통신하는 수 만큼의 키가 필요하기 때문에 키 관리가 어려움

### 블록 암호 
+ 블록 길이 단위로 암호하 -> 128bit. 192bit, 256bit
+ 블록 길이를 맞추기 위해 패딩 추가 -> 블록 길이의 배수
+ ![예제](/assets/img/elegant-tekotok/password.png)
+ Feistel, SPN 구조
+ SEED, HIGHT, ARIA, LEA : 국산 암호
+ DES. AES : 외산 암호

### 스트림 암호
+ 보통 1bit 단위로 암호화 특별한 상황 일때 1byte 혹은 1word 정도의 길이로 암호화를 하기도 한다.
+ XOR 을 사용하여 암호화
+ 블록 암호보다 빠르지만 안전하지 않음
+ 무선 환경에서 주로 사용

## 비대칭키 암호
+ 암호화, 복호화 시 사용하는 키가 다른 방식
+ 사용 방향에 따라 공개키 암호, 전자 서명 방식으로 구분
+ 연산량이 많아 느림
+ RSA, EIGamal, ECC
+ ![예제](/assets/img/elegant-tekotok/password2.png)
+ 장점
  + 기밀성, 무결성, 인증, 부인 방지 모두 만족 가능
  + 활용도 높음
  + 키 관리가 편함
+ 단점 
  + 느리기 때문에 적은 데이터 암호화에 적합

### 비대칭키 암호 - 공개키 암호
+ 공개키로 암호화 -> 비밀키로 복호화
+ 비밀키가 있어야 데이터를 읽을 수 있다.
+ 대칭키 분배
  + SSL 인증서
  + SSH 접속

### 비대칭키 암호 - 전자 서명
+ 비밀키로 암호화 -> 공개키로 복호화
+ 내가 암호화했다는 것을 증명할 수 있다.
+ 무결성, 인증, 부인방지
+ SSL 인증서 -> 인증기관 서명
+ ![img.png](/assets/img/elegant-tekotok/password3.png)

## 해시 함수
+ 언제나 고정된 길이의 해시 값을 출력해주는 함수
+ ![img.png](/assets/img/elegant-tekotok/password4.png)
+ 입력이 1bit만 수정되어도 전혀 다른 해시 값 출력(눈덩이 효과)
+ 단방향
+ 빠름
+ 무결성
+ HAS-160, LSM : 국내 해시 함수
+ MD5, SHA-1, SHA-2, SHA-3 : 외산 해시 함수
+ 장점
  + 매우 빠르다
  + 대규모 데이터 암호화 가능
+ 단점
+ 복호화가 안됨

### 메시지인증코드(MAC, Message Authentication Code )
+ 메시지의 해시 함수 결과 값(MAC)을 메시지와 함께 전송
+ 수신자는 메시지의 해시 결과 값과 MAC 을 비교하여 무결성 확인
+ ![img.png](/assets/img/elegant-tekotok/password5.png)
+ JWT 토큰 에서 사용
+ ![img.png](/assets/img/elegant-tekotok/password6.png)

### 전자 성명(feat.비대칭키 암호)
+ 대규모 데이터를 직접 비대칭키로 암호화하기 어려움
+ 데이터를 해시 값으로 만들고 해시 값을 전자 서명
+ ![img.png](/assets/img/elegant-tekotok/password7.png)





