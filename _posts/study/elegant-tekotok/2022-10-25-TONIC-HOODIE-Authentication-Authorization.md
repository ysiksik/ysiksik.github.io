---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 토닉, 후디의 인증과 인가 - 부족사회부터 소셜로그인까지
date: '2022-10-25 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 토닉, 후디의 인증과 인가 - 부족사회부터 소셜로그인까지
[https://youtu.be/BotXDfBPvDA](https://youtu.be/BotXDfBPvDA)

# 토닉, 후디의 인증과 인가 - 부족사회부터 소셜로그인까지
* toc
{:toc}

## 인증과 인가란?
+ 인증(Authentication)
  + 사용자의 신원을 확인하는 절차
+ 인가(Authorization)
  + 사용자의 권한을 확인하고 허가하는 절차
  + 인가는 인증 절차를 거치 후에 진행된다

## 아날로그 방식의 인증, 인가 
+ 부족 사회에서는 인증과 인가를 얼굴로 식별했다.
+ 조선시대는 인구수를 파악하고 신부을 증명하기 위한 도구로 호패를 사용했다.
+ 현대에서는 출입증을 예로 들 수 있다.

## 인터넷 환경의 인증, 인가 

### HTTP 
  + 인터넷에서 데이터를 주고 받을 수 있는 프로토콜 
  + ![img.png](/assets/img/elegant-tekotok/HTTP.png)
  + 무상태성 (Stateless)
    + HTTP 통신에서 서버는 현재요청과 이전요청의 맥락을 기억하지 못한다.

### 뚱뚱한 URL 방식 
+ URL에 인증 정보를 담는 방식 
  + 문제점
    + 개인 정보가 담긴 URL
    + 서버 부하 가중(각 URL에 해당하는 HTML 페이지 생성)
    + 다른 사이트 이동, 로그아웃 시 기존의 데이터 삭제

### IP주소 식별 방식 
+ 요청을 보낼때 IP 주소를 같이 보낸다 Client-ip 헤더에 아이피 정보를 담는다.
+ 서버는 IP를 보고 식별한다. 
+ 서버는 클라이언트 IP를 TCP 커넥션 또는 HTTP 헤더를 통해 알 수 있다. 
+ 서버에서는 사용자가 변경되어도 아이피가 같은면 서버는 이를 알아차리지 못한다. 
+ 문제점
  + 클라이언트 IP는 사람이 아닌 컴퓨터의 식별자.
  + 많은 인터넷 서비스 제공자(ISP)는 동적으로 IP주소를 할당하여 IP주소는 바뀔 수 있다.
  + 방화벽, 프록시, 게이트웨이 등으로 인해 실제 클라이언트의 IP 주소를 알기 어렵다. 

### HTTP 기본 인증 방식 
+ 사용자에 대한 정보를 전달하는 헤더 
  + From: 사용자의 이메일 주소
  + User-Agent: 사용자의 브라우저
  + Referer: 사용자가 현재 링크를 타고 온 근원 페이지
  + Authorization: 사용자 이름과 비밀번호 
+ 인증시 사용자 이름과 비밀번호를 입력하고 BASE64로 인코딩하여 인코딩 값을 Authorization 헤더에 담아서 요청을 보낸다.
+ 서버에서는 해당 Authorization 안에 담긴 인코딩된 값을 디코딩하여 누구인지 인증을 하고 인증이 된 회원이라면 요청 페이지를 응답을 한다. 
+ 문제점
  + 사용자 이름과 비밀번호를 쉽게 디코딩할 수 있는 형식
  + 재전송 공격을 예방하지 못한다.
  + 가짜 서버의 위장에 취약하다.

### 쿠키 with 세션 방식 
+ 쿠키
  + 브라우저에 저장되는 키와 값이 들어있는 데이터 파일
  + 클라이언트의 상태 정보를 저장
  + 사용자가 따로 요청하지 않아도 Request시 Header에 담겨 서버에 전송
+ 세션
  + 쿠키와 달리 서버 측에서 관리
  + 클라이언트를 구분하기 위해 세션 ID 부여 
  + 세션 ID를 통해 클라이언트 식별
+ 로그인 요청을 하면 서버는 해당 username과 password로 서버에 인증된 회원인지 확인하고 세션 ID를 생성한다. 그리고 해당 세션 ID를 쿠키에 담아서 클라이언트에게 보낸다. 그럼 클라이언트는 쿠키를 가지고 있다가 다음 요청 때 쿠키와 함께 다시 요청이
가게 된다. 이때 서버는 쿠키에 담기 세션 ID와 세션 저장소에 담긴 세션 ID를 비교해서 사용자 인가 여부를 결정하게 된다. 
+ 문제점
  + 하나의 서버, 하나의 세션 저장소라면 괜찮겠지만 만약 다중 서버 환경이라면 하나의 서버에서 인증이 되었고 다른 서버에서는 인증 되지 않았다면 세션 불일치 문제가 발생할 수 있다. 
    + 해결방법
      + Sticky Session
        + 로드밸런서가 클라이언트의 요청을 세션을 생성한 서버로만 전달.
      + Session Clustering
        + 모든 서버의 세션 동기화
      + 별도의 세션 저장소 생성
        + Redis, Memcached 등 
      + 위와 같이 해결 방법들이 있지만 근본적으로 확장성이 떨어진다는 문제는 해결하지 못했다. 

### 토큰 기반 인증 방식 - JWT
+ JWT
  + JSON 포맷을 이용하여 사용자에 대한 속성을 저장하는 Claim 기반의 Web Token
  + 인증에 필요한 정보들을 암호화시킨 JSON 토큰 
+ 구조 
  + ![img.png](/assets/img/elegant-tekotok/JWT.png)
  + Claims에는 어떤 사용자의 정보가 담겨 있다고 보면된다.
+ ![img.png](/assets/img/elegant-tekotok/JWT2.png)
+ 서버 기반 인증 시스템과 달리 상태를 유지하지 않는다 (Stateless)
+ DB를 조회하지 않고 인증된 회원이지 식별할 수 있다. 
+ 문제점
  + 쿠키, 세션과 다르게 토큰 자체의 데이터 길이가 길다.
  + payload는 암호화되지 않기 때문에 유저의 중요한 정보를 담을 수 없다.
  + 토큰을 탈취 당하면 대처하기 어렵다.

### OAuth, OpenID
+ OAuth
  + 인가(Authorization)는 인가에 대한 기술이다.
+ OpenID
  + 인증(Authentication)는 인증에 대한 기술이다.

#### OAuth 2.0 이전 
+ ![img.png](/assets/img/elegant-tekotok/OAuth.png)
+ 이런 문제를 해결하기 위해 여러 기업들이 독자적으로 기술을 개발 
  + 구글 - AuthSub
  + 야후 - BBAuth
  + 표준화가 되어있지 않다는 한계이 존재한다. 

#### 시작된 OAuth 표준화 
+ 웹, 모바일, 데스크톱 어플리케이션에서의 간단하고 표준적인 방법으로 보안 인가를 허용하기 위한 개방형 표준 프로토콜 
+ 1.0 버전과 2.0버전은 호환되지 않는다.
+ ![img.png](/assets/img/elegant-tekotok/OAuth2.png)
  + Resource Owner 
    + 리소스를 소유하며 접근할 권할을 가지고 있고, 클라이언트에게 그 권한을 위임하는 주체 
  + Client
    + 리소스 소유자 대신 위임 받은 권한으로 리소스를 요청하는 주체 
  + Authorization Server
    + 리소스 소유자를 인증하고 클라이언트에 엑세스 토큰을 발급하는 서버 
  + Resource Server 
    + 엑세스 토큰을 사용하여 리소스 요청을 수락하고 응답할 수 있는 리소스를 가지고 있는 서버
+ Resource Owner가 로그인을 요청
  + ![img.png](/assets/img/elegant-tekotok/OAuth3.png)
+ Resource Owner가 서비스를 요청
  + ![img.png](/assets/img/elegant-tekotok/OAuth4.png)
+ Scope 란?
  + 클라이언트에게 허용된 리소스 접근 범위 

#### OpenID
+ OpenID 개요
  + ![img.png](/assets/img/elegant-tekotok/OpenID.png)
    + 일반적으로 직접 인증 기능을 구축하기 위해서는 사용자로부터 아이디 그리고 패스워드 개인정보를 직접 제공받아야 된다.
    그런데 만약 보안 사고라도 터지면 큰 문제가 생긴다.
  + 사용자도 굉장히 많은 서비스가 존재하는 시대에서 서비스마다 모든 아이디와 패스워드를 외우고 있어야된다. 
  + 신뢰할 수 있는 서비스(구글, 페이스북, 트위터 등)에 사용자 절차를 위임하고 사용자는 자신이 신뢰할 수 있는 서비스의 인증 정보 하나로 여러 서비스에서 인증할 수는 없을까? 
    + 이런 아이디어에서 OpenID가 시작 된다. 
+ OpenID는 OpenID Foundation에서 추진중인 개방형 표준 및 분산 인증 프로토콜이다.
+ OpenID를 사용하면 새 빌밀번호를 만들 필요 없이 기존 계정을 사용하여 여러 웹사이트에 로그인할 수 있다.
+ OpenID 주체
  + OpenID도 크게 두 가지 주체로 나눠 볼 수 있다.
    + IdP(Identity Provider)
      + 구글, 카카오와 같이 OpenID 서비스를 제공하는 당사자 
    + RP(Relying Party)
      + 사용자를 인증하기 위해 IdP에 의존하는 주체 
      + 우리가 만든 서비스가 대부분 해당된다.
+ OpenID Connect 정의
  + OpenID Connect 1.0은 OAuth 2.0 프로토콜 위에 있는 간단한 ID 계층이다. 이를 통해 클라이언트는 REST와 유사한 방식으로 최종 사용자의 신원과 기본적인 프로필 정보를 얻을 수 있다.
+ OpenID Connect 와 OAuth 2.0
  + OAuth 2.0은 Access Token을 발급 받고 Access Token을 통해서 리소스에 접근하기 위해서 사용이된다. 
  + OpenID Connect는 ID Token을 발급 받고 ID Token으로 부터 사용자 식별 정보를 얻기 위해서 사용이 된다. 
    + ID Token
      + 사용자 식별 정보를 담고 있는 토큰
      + JWT 형식으로 표현 
      + ID Token의 페이로드에는 기본 클레임외에 사용자를 식별 할 수 있는 클레임이 추가적으로 들어 있다. 
+ ID Token
  + ID Token 발급 방법 
    + ![img.png](/assets/img/elegant-tekotok/IDToken.png)
      + Client가 Authorization Server로 OAuth 2.0 인증 요청을 할때 Scope에 openid를 추가하면, ID Token을 받을 수 있다. 
+ OAuth 2.0 단독 유저 식별의 문제점
  + OAuth 2.0 만으로 인증을 구현하고 사용자 정보를 가져올 수 있지 않나? 왜 굳이 OpenID Connect를 사용하는 걸까?
    + OAuth 2.0은 사용자에 대한 정보를 명시적으로 제공하지 않는다.
      + ![img.png](/assets/img/elegant-tekotok/OAuth5.png)
    + 유저 프로필을 가져올 때 OAuth 2.0만을 사용하면 통신이 두번 발생 
      + ![img.png](/assets/img/elegant-tekotok/OAuth6.png)
    + 유저 프로필을 가져올 때 OpenID Connect를 사용하면 한번의 통신으로 유저 프로필 정보 획득 가능하다. 
      + ![img.png](/assets/img/elegant-tekotok/OpenID2.png)
