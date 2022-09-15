---
layout: post
bigtitle: '더 자바, 애플리케이션을 테스트하는 다양한 방법'
subtitle: 도커와 테스트
date: '2022-09-14 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java-test-application
comments: true
---

# 도커와 테스트

# 도커와 테스트
* toc
{:toc}

## Testcontainers 소개
+ 테스트에서 도커 컨테이너를 실행할 수 있는 라이브러리
  + [https://www.testcontainers.org/](https://www.testcontainers.org/)
  + 테스트 실행시 DB를 설정하거나 별도의 프로그램 또는 스크립트를 실행할 필요 없다.
  + 보다 Production 에 가까운 테스트를 만들 수 있다.
  + 테스트가 느려진다.
    