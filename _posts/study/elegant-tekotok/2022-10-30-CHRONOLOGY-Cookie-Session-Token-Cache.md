---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 연로그의 쿠키 vs 세션 vs 토큰 vs 캐시
date: '2022-10-30 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 연로그의 쿠키 vs 세션 vs 토큰 vs 캐시 
[https://youtu.be/gA1KsJ2ak10](https://youtu.be/gA1KsJ2ak10)

# 연로그의 쿠키 vs 세션 vs 토큰 vs 캐시
* toc
{:toc}

## 쿠키
+ 수정이 불가능한 중요한 정보들은 쿠키에 저장하기에는 부적절하다. 
+ 사용자에 의해 조작되어도 크게 문제되지 않을 정보를 브라우저에 저장.

## 세션 
+ 중요한 보는 세션에서 관리
+ SessionID 로 식별 
+ 인증에 대한 정보를 서버가 저장

## 토큰 
+ 사용자의 정보를 비밀키를 통해서 토큰을 발급 이토큰은 사용자가 가지고 있다가 요청을 하면 비밀 키를 이용해서 토큰을 읽어 들인다. 
토큰이 유효한지 토큰에 있는 데이터를 판별해서 사용자를 식별한다.
+ 인증에 대한 정보를 사용자가 저장

## 캐시 
+ 가져오는데 비용이 드는 데이터를 임시로 저장
+ 한 번 전송 받은 데이터를 저장해 놨다가 필요할 때 꺼내 쓰기 가능 
