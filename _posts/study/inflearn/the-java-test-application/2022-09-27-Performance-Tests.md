---
layout: post
bigtitle: '더 자바, 애플리케이션을 테스트하는 다양한 방법'
subtitle: 성능 테스트
date: '2022-09-27 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java-test-application
comments: true
---

# 성능 테스트

# 성능 테스트
* toc
{:toc}

## JMeter 소개
+ [https://jmeter.apache.org/](https://jmeter.apache.org/)
+ 성능 측정 및 부하 (load) 테스트 기능을 제공하는 오픈 소스 자바 애플리케이션
+ 다양한 형태의 애플리케이션 테스트 지원
  + 웹 - HTTP, HTTPS
  + SOAP / REST 웹 서비스
  + FTP
  + 데이터베이스 (JDBC) 사용
  + Mail (SMTP, POP3, IMAP)
  + ...
+ CLI 지원
  + CI 또는 CD 툴과 연동할 때 편리하다.
  + UI 사용하는 것보다 메모리 등 시스템 리소스를 적게 사용한다.
+ 주요 개념
  + Thread Group: 한 쓰레드 당 유저 한명
  + Sampler: 어떤 유저가 해야하는 액션
  + Listener: 응답을 받았을 때 할 일   
  + Configuration: Sampler 또는 Listener가 사용할 설정 값 (쿠키, JDBC 커넥션 등)
  + Assertion: 응답이 성공적인지 확인하는 방법 (응답 코드, 본문 내용 등)
+ 대체제
  + [Gatling](https://gatling.io/)
  + [nGrinder](http://naver.github.io/ngrinder/)

## JMeter 설치
+ [https://jmeter.apache.org/download_jmeter.cgi](https://jmeter.apache.org/download_jmeter.cgi)
+ 압축 파일 받고 압축 파일 풀기, 원한다면 PATH 에 bin 디렉토리 추가
+ bin/jmeter 실행하기
+ ![img.png](/assets/img/the-java-test-application/JMeter.png)

## JMeter 사용하기
