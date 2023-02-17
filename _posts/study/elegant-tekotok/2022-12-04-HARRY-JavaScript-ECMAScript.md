---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 해리의 JavaScript와 ECMAScript의 탄생
date: '2022-12-04 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 해리의 JavaScript와 ECMAScript의 탄생
[https://youtu.be/uyt-B_SDo9k](https://youtu.be/uyt-B_SDo9k)

# 해리의 JavaScript와 ECMAScript의 탄생
* toc
{:toc}

## 1993
+ MOSAIC
  + 최초로 널리 인기를 얻은 브라우저

## 1994 
+ Netscape Navigator
  + MOSAIC의 개발자 중 한 명인 마크 앤드리슨은 Netscape를 공동 창립하고 Netscape Navigator를 공개  
+ 마크 앤트리슨은 동적인 웹사이트를 위한 스크립트 언어가 필요하다고 생각했고 브랜든 아이크를 고용해 스크립트 언어의 제작을 요청했다. 

## 1995 
+ 여러가지 언어에서 아이디어를 언어 시제품 완성 
+ 이게 10일 안에 만들어진 Mocha라는 언어이다.
+ Mocha는 LiveScript라는 이름을 거쳐 현재까지 사용되고 있는 JavaScript라는 이름을 가지게 되었다. 

## 1995 ~ 2001
+ Netscape는 Netscape Navigator 2.0 버전의 JavaScript를 지원하기 시작 했고 이 JavaScript를 본 Internet Explorer도 JavaScript와 적당히 호환되는 JScript를 Internet Explorer 3.0 부터  지원하기 시작했다. 
+ 적당히 JavaScript 호환되는 JScript 문제 때문에 이 시기에는 Netscape에서 가장 잘 표시됨 혹은 Internet Explorer에서 가장 잘 표시됨 이라는 로고를 웹사이트에 박는게 일반적이게 되었다. 
+ 1996
  + 이러한 문제를 해결하기 위해서 Netscape는 표준화 단체인 Ecma International에 JavaScript의 표준화를 요청하게 된다.
+ 1997, ECMAScript의 탄생
  + ECMAScript
    + ECMA-262 명세에 의해 표준화된 언어
  + 그 당시에 썬 지금의 오라클이 Java라는 이름의 상표를 소유하고 있었기 때문에 JavaScript라는 이름을 사용할 수 없었다.
+ 1차 브라우저 전쟁
  + Internet Explorer가 승리하게 되었다.
    + Window OS에 기본적으로 Internet Explorer를 탑재
    + Netscape와 달리 Internet Explorer는 브라우저를 전면 무료화 선언을 했다.
    + 비표준 Internet Explorer 전용 웹 규격을 사용해서 다른 브라우저에서는 웹사이트가 제대로 보여지지 않도록 했다. 
    + 이러한 결과로 2001년 브라우저 점유율 96%를 달성하며 Internet Explorer와 1차 브라우저 전쟁이 막을 내리게 된다. 

## Internet Explorer 점유율 유지 
+ Internet Explorer는 점유율 유지하기 위해서 웹 표준을 무시하고 active X와 같은 Internet Explorer에서만 호환되는 비표준 웹 기술들을 적극적으로 사용하게 된다.  
+ 개발자들은 각각의 다른 브라우저에서 동작하는 코드를 다 따로 작성을 해야 했다. 

## 2006
+ 존 레식이란 개발자가 jQuery를 발표
+ jQuery API를 통해서 작성한 코드들을 모든 브라우저에서 분석할 수 있도록 해서 크로스 브라우징 이슈를 해결했다. 
+ 그 당시 조잡하게 작성해야 됐던 Vanilla Javascript 코드를 DOM 조작이나 Ajax를 더 편하게 작성할 수 있도록 해 주었다. 

## 2008, IE에 대항할 Chrome의 등장 
+ Chrome 브라우저에는 Just In Time 컴파일러가 포함된 V8 엔진이 탑재 되어 있었고 이로 인해서 다른 브라우저들 보다 훨씬 빠른 성능을 갖게 되었다. 
+ 빠른 성능에도 불구하고 마이크로소프트와 달리 google은 웹 표준을 준수 했고 그다음해 ECMAScript 5의 표준화가 진행이 되었다. 
+ Chrome 등장 이후 많은 웹 기술의 표준화로 크로스 브라우징 이슈가 많이 해결되었다.
  + 그럼 크로스 브라우징 이슈 해결이 주요 목표 중 하나였던 jQuery는 어떻게 되었을까?
    + 그 이후에 많은 다른 라이브러리들과 프레임워크들이 등장

## 2018, jQuery에서 React로 
+ jQuery는 React에게 점유율을 추월 당하게 된다. 
+ 왜 jQuery에서 React로 대세가 변하게 되었을까?
  + 모던 자바스크립트 (ES6+) 환경
    + ES5~6, HTML5 등 웹 표준의 발전을 통한 크로스 브라우징 이슈 해결 - 더이상 jQuery를 사용하지 않아도 될 이유 중에 하나
    + 바닐라 자바스크립트로도 쉬운 DOM 조작과 Ajax 요청 
  + 성능상의 문제 
    + 모든 브라우저에서 동작하게 하기 위해 여로 코드로 wrapping 
      + 그래서 개발자가 원하는 동작을 하기 위해서는 굉장히 오래 걸리게 되었다
      + 실제로 JavaScript보다도 훨씬 느린 성능이었다, 그래서 DOM 조작을 할 때는 JavaScript보다도 수십 배 느린 성능을 보여줬다.  
    + 그에 비해 현재의 웹사이트는 jQuery의 등장 시점보다 훨씬 복잡해 졌고 많은 데이터를 빠르게 처리해야 하도록 바뀌었다. 
  + 복잡한 웹피이지와 DOM API
    + 현대의 웹페이지는 이전보다 복잡해 졌고, 다루어야 할 데이터가 많아 졌다. 
    + 다루어야 할 데이터가 많아질수록 더 많은 DOM을 선택해야 한다.
    + 이는 코드의 증가, 코드 관리의 어려움, 에러 핸들링과 유지 보수의 어려움으로 이어진다. 
    + React는 선언적은 Virtual DOM을 통해서 이를 해결
      + React는 개발자가 DOM API를 사용해 직접 DOM을 조작하지 않아도 되도록 만들었다.
      + 개발자는 변하는 state만 관리하면 React가 알아서 처리해 DOM을 렌더링 
      + DOM 조작의 최소화롤 성능 상승
  + 정리 
    + 웹 개발 환경의 변화
    + 서능 최적화와 생선성
    + SPA 대중화 등등 

  



