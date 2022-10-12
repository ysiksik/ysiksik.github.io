---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 록바의 웹 성능 개선하기 - 이미지
date: '2022-10-11 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 록바의 웹 성능 개선하기 - 이미지
[https://youtu.be/INPldifIEXE](https://youtu.be/INPldifIEXE)

# 록바의 웹 성능 개선하기 - 이미지
* toc
{:toc}

## 구글의 Lighthouse 테스트
+ ![img.png](/assets/img/elegant-tekotok/Lighthouse.png)

## 차세대 이미지 형식 결정하기
+ Lighthouse
  + ![img.png](/assets/img/elegant-tekotok/Lighthouse2.png)
    + PNG: 무손실 압축을 사용하여, 최고의 품질 이미지를 제공하지만 다른 형식에 비해 크기가 훨씬 크다.
    + JPEG: 손실 압축을 사용하여, PNG에 비해 용량이 작다
    + WebP: __구글에서 2010년 발표__ , JPEG 보다 더 나은 압축과 더많은 기능을 제공하는 형식이다.
    + AVIF: __AOMedia에서 2019년 발표__ ,WebP와 유사하게 높은 압축률을 자랑한다.
+ WebP 모든 브라우저에서 지원하지 않음
  + picture 태그와 source 태그 사용
    + ![img.png](/assets/img/elegant-tekotok/picture.png)
    + WebP를 지원하지 않는 브라우저 -> JPEG
    + WebP를 지원한느 브라우저 -> WebP

## 적절한 크기의 이미지 사용하기 
+ Lighthouse
  + ![img.png](/assets/img/elegant-tekotok/Lighthouse3.png)
  + 렌더링 크기에 알맞게 자체적으로 슬라이스하는 작업이 필요하다. 
+ 화면의 크기에 따라 렌더링하는 이미지의 크기가 달라진다면, 이미지의 크기는 어디에 맞춰야 할까요?
  + 반응형 이미지 제공하기 
    + Before
      + ![img.png](/assets/img/elegant-tekotok/Before.png)
    + After
      + ![img.png](/assets/img/elegant-tekotok/After.png)
      + srcset: 브라우저에게 제시할 이미지 목록과 크기를 정의한다.
      + size: 화면 크기에 따른 어떤 이미지 크기가 최적인지 정의한다.
    + Image CDN 사용하기
      + CDN: 콘텐츠를 효율적으로 전달하기 위해 전세계적으로 분산된 서버이다.
      + Image CDN: 기본 CDN 기능에서 이미지를 제공하는데 특화된 CDN이다. 이미지 압축, 최적화 기능이 탑재되어 있다.

## CLS(누적 레이아웃 변경) 개선하기
+ Lighthouse
  + ![img.png](/assets/img/elegant-tekotok/Lighthouse4.png)
+ CLS(누적 레이아웃 변경)? 
  +  사용자가 예상치 못한 레이아웃 이동을 경험하는 빈도를 수량화하고, 시각적 안정성을 나타내는 지표
+ width 및 height 명시 또는 img 에 aspect-ratio 설정
  + aspect-ratio 가로 대 세로의 비율을 가르쳐 준다.
+ 브라우저에게 이미지의 공간을 알려, 레이아웃이 바뀌는 상황을 막자

## 이미지 Lazy Loading 왜 필요한가?
+ 네트워크 대역폭을 효율적으로 사용하기 위해 Lazy Loading 사용
+ Lazy Loading 적용방법
  + img 로딩 속성 사용
    + Loading = "lazy" 
    + 모든 브라우저가 Loading 속성을 지원하지는 않는다.
  + Intersection Observer API 사용하기 
    + ![img.png](/assets/img/elegant-tekotok/Observer.png)

## 이미지 Pre Loading 왜 필요할까?
+ 용량이 큰 이미지를 동적으로 호출시 버벅이는 현상 발생
+ 로드되는 시점을 미리 앞당기는 기법
+ 마우스 커서를 버튼 위에 올렸을 경우, 이미지 Preload 하기
  + ![img.png](/assets/img/elegant-tekotok/Preload.png)