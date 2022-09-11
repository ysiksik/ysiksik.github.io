---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 호프의 프론트엔드에서 컴포넌트
date: '2022-09-11 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 호프의 프론트엔드에서 컴포넌트
[https://youtu.be/aAs36UeLnTg](https://youtu.be/aAs36UeLnTg)

# 호프의 프론트엔드에서 컴포넌트
* toc
{:toc}

## 컴포넌트란?
+ 컴포넌트(Component) 사전적 정의 - 요소, 부품, 부분
+ 컴포넌트(Component) 엔지니어링 측면 - 전체 시스템을 구성하는 하나의 부품 혹은 모듈
+ 컴포넌트(Component) 프론트 엔지니어링 측면 - UI를 구성하는 UI 요소

## 프론트엔드에서 컴포넌트 의미
+ 컴포넌트를 잘만든다 -> 유지보수를 용이하게 한다.

### 과거의 웹페이지
+ 사용자가 요청을 보내면 그때마다 매 번 서버에서 HTML 페이지를 새로 생성 해서 받아왔어야 했다.
  + 그래서 마치 웹 하나가 전체의 덩어리처럼 움직이게 된다 그래서 부분만 수정하면 될텐데 그때마다 계속해서 서버에서 HTML 전체를 받아와서 클라이언트에서 보여줘야했기 때문에 매우 불편했다.
+ ![img.png](/assets/img/elegant-tekotok/component.png)
+ 문제점
  + 사용자 측면에서 웹 복잡도가 높아지고 사용자 인터랙션이 점점 증가함에 따라서 사용자 경험이 떨어진다. 
    + HTML을 계속해서 새로 받아옴으로써 화면 깜빡임이 생기고 속도도 느리다
  + 개발자 측면에서 재사용이 어렵다
    + HTML 페이지마다 중복되는 코드들이 계속 분산이 되어 있어서 유지보수에 매우 취약했다.
  + 문제점을 AJAX 방식으로 해결할 수 있었다.

### AJAX 방식의 등장
+ 클라이언트에서는 이제 HTML의 자바스크립트를 통해서 일부분만 수정할 수 있게 되었다.
+ 하나의 웹은 덩어리처럼 존재하지 않고 마치 부분 컴포넌트 조각 처럼 존재할 수 있게 되었다.
+ 웹을 하나의 컴포넌트 단위로 구분할 수 있게 되었다.
+ ![img.png](/assets/img/elegant-tekotok/component2.png)

## 컴포넌트 잘 만들기 

### 해결하고고자 하는 문제
+ 재사용 가능한 컴포넌트 만들기
+ 변경에 따른 부수효과 최소화 하기 

### 목표
+ 관심사가 분리 된 , 재사용성이 높고 유지보수하기 용이한 컴포넌트 만들기

### 컴포넌트 만들어보기 
+ INPUT 
  + ![img.png](/assets/img/elegant-tekotok/component3.png)
+ 새로운 INPUT 요구사항이 등장
  + UI가 달라져서 재사용이 애매하다.
  + INPUT 자체의 데이터 로직은 똑같다.
  + 요구 사항을 해결하기 위해서 
    + 다른 컴포넌트를 만들기
      + 재사용이 불가능하다는 것을 입증한 거다.
    + props 로 스타일링 옵션을 줘서 분기처리
      + 사이트 이펙트를 초래하게 된다. 
    + 이런 문제가 발생한 원인
      + 데이터를 다루는 로직과 UI로직이 하나의 컴포넌트에 뭉쳐있기 때문이다.
      + INPUT의 데이터로직은 계속해서 반복이 되는데 UI 만 변경이 된다.
        + 하나의 컴포넌트에 뭉쳐있다?
          + 하나의 컴포넌트에 두개의 관심사 뭉쳐있다

### Headless 란?
+ 머리가 없다는 뜻
+ 머리 -> 컨텐츠를 보여주는 방법 -> UI
+ 몸통 -> 컨텐츠 자체 -> 데이터 
+ 데이터만 남긴 컴포넌트가 바로 Headless 컴포넌트이다. 

### Headless 의 예시
+ Headless 브라우저
  + GUI 환경이 아닌 CLI 으로 실행되는 브라우저
+ Headless 커머스
  + 프론트엔드 (고객이 대면하는 UI) 백엔드 (결제 시스템, 재고관리 기능) 를 분리하는 아커머스 시스템 기능 

### Headless Input Component
+ 남길 부분
  + Input 의 Value 상태
  + onChange Handler
  + 그 외의 Input Attributes
+ 남기지 않을 부분
  + Input 이 어떻게 보여질지(UI)

### Headless 컴포넌트 만들기 

#### 1.Compound Component 패턴
+ Component 만들기
  + ![img.png](/assets/img/elegant-tekotok/component4.png)
+ 사용처
  + ![img.png](/assets/img/elegant-tekotok/component5.png)

### 2.Function as Children Component 패턴
+ Component 만들기
  + ![img.png](/assets/img/elegant-tekotok/component6.png)
+ 사용처
  + ![img.png](/assets/img/elegant-tekotok/component7.png)

### 3.Custom Hook 패턴
+ ![img.png](/assets/img/elegant-tekotok/component8.png)