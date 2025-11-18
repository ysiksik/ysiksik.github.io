---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 콤피의 CSS를 통한 브라우저 렌더링 최적화
date: '2022-11-02 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 콤피의 CSS를 통한 브라우저 렌더링 최적화 
[https://youtu.be/TZz9VHjJzMk](https://youtu.be/TZz9VHjJzMk)

# 콤피의 CSS를 통한 브라우저 렌더링 최적화
* toc
{:toc}

## CCS란 무엇일까요?
+ CSS는 HTML이나 XML으로 작성된 문서의 표시 방법을 기술하기 위한 스타일시트 언어이며, 웹페이지를 꾸미기 위한 코드이다.
+ CSS는 요소가 화면, 종이, 음성이나 다른 매체 상에 어떻게 렌더링되어야 하는지 지정한다. 

## 가볍게 보는 브라우저 렌더링 과정
+ ![img.png](/assets/img/elegant-tekotok/CssBrowserRenderingOptimize.png)
  + 총 4단계로 나뉜다. Parse, Layout, Paint, Composite
  + HTML 문서를 통해 HTML Parser와 CSS Parse가 DOM Tree와 CSSOM(Object Model)을 작성한다. 이 두 데이터를 기반으로 Render Tree가 된다.
  + Render Tree에는 문서의 구조와 각 요소의 Style 속성들이 입력된다.
  + Layout 단계에서는 상대적인 크기 예를 들면 REM, VH, VW와 같은 단위들을 픽셀 단위로 변환하는 과정을 Layout 과정에서 진행하며 픽셀 단위로 어떤 위치에 Layout이 표시되고 어떤 크기로 출력 되어야 하는지 작성하여 Layout Tree를 생성한다. 
  + 페이트 단계에서는 앞서 작성된 Layout Tree에서 사이즈와 크기를 제외한 CSS 속성을 적용한다. 예를 들어 배경화면 색, 이미지, 선, 그림자 같은 속성들을 Layout Tree를 기반으로 작성하게 되면 이때 작성된 데이터는 Layer Tree라고 말한다. 
  + Composit 단계에서는 Layer Tree를 기반으로 생성된 Layer들을 기준으로 순차적으로 레지스터화를 시도하여 사용자의 화면에 순서대로 출력한다. 

## Reflow를 방지하는 방법 중 가장 먼저 생각나는 것은 무엇인가요? 
+ 브라우저의 렌더링 과정 중 Reflow는 Repaint의 상위 과정이기 때문에 DOM 요소의 변경이 일어나면 Reflow가 발생되면 자연스럽게 Repaint도 함께 발생해 자원을 더 소모하게 된다.
+ Reflow를 방지하는 방법
  + top,bottom,left,right와 같은 특성들을 transform: translate(X, Y); 로 변경하는 작업
  + transform: translate3d(x, y, z) 값으로 활용하는 것

## 왜 transform: translate3d 가 빠를까?
+ Composit 단계를 자세히 알아볼 필요가 있다.
+ ![img.png](/assets/img/elegant-tekotok/CssBrowserRenderingOptimize2.png)
  + Composit 단계 이전에 Layout 과 Painting 단계를 거치며 Layout Tree가 형성되면 이 Layer를 기반으로 이미지로 변환하여 GPU로 합성 후 출력하게 된다.
  + Composit 단에서 이 Layer들이 총 두가지로 나뉜다. Paint Layer와 Graphice Layer 이 두 가지로 나뉜다.
+ Graphics Layer의 특징 알아보기 
  + 그래픽 레이어는 GPU를 활용하여 이미지로 변환되며 병렬처리에 특화되어 있어 더 빠르게 변환한다.
  + 기존 레이어에서 새로게 분리되어 주변 레이어에 영향이 없이 해당 레이어만 빠르게 그리고, 출력할 수 있다.
  + GPU에서 작업이 이뤄져 CPU와 그래픽 작업을 분리할 수 있어 저사양 기기에서 CPU의 부담을 덜어줄 수 있다.
+ Paint Layer에서 Graphics Layer 분리 조건
  + transform 3d 관련 값을 사용한 경우 video 태그, 3D 혹은 하드웨어 가속된 2D cnavas 태그 animation 또는 transition이 적용 되어있고 opacity, transform, filter 속성이 적용되어있을 때 Graphics Layer로 나눠지게 된다.
  + backdrop-filter, will-change 속성을 사용했을 때 Graphics Layer로 나눠지게 된다.
  + 지금은 사용되지 않지만 플래시와 같은 하드웨어 가속 플러그인 사용했을 때 Graphics Layer로 나눠지게 된다.

## 모두 GPU를 사용하면 안되나요?
+ Graphics Layer를 활용하기 위해선 고려해야할 내용이 있다. 
  + Layer 정보를 GPU의 비디오 메모리에도 저장하게 되어 추가적인 메모리 점유 발생하게 된다. 
  + CPU에서 GPU 데이터 전달 과정에서 지연 시간 발생하게 되어 프레임드랍이 발생할 수 있다.
  + 일부 연산의 경우 CPU에서의 연산이 더 빠른 케이스 존재한다. 
    + 예를 들면 폰트를 렌더링할 때가 대표적으로 CPU 연산이 더 빠른 경우이다. 
  + 모바일 기준 GPU의 전력 소모량이 1.5 ~ 2배 가량 추가적인 소모된다.

## 간다하게 보는 Composite 단계 정리
+ Transform의 3D 요소와 같이, 일부 CSS 속성과 태그에서는 Graphics Layer로 분리.
+ Graphics Layer로 분리되었을 땐, 기존 레이어에서 분리되어 별도로 렌더링 진행.
+ Paint Layer는 CPU의 Raster Thread에서 레이어를 이미지로 변환하며 Graphics Layer에서는 GPU에서 레이어를 이미지로 변환.
+ 레이어가 래스터화 될 때마다 Composite Thread는 GPU를 활용하여 쌓임 맥락을 통해 결정된 순서에 따라 이미지르 합성하여 화면에 츨력
+ ![img.png](/assets/img/elegant-tekotok/CssBrowserRenderingOptimize3.png)

## translate3d 다시 생각해보기 
+ Graphics Layer로 분리될 시 대기 중에도 비디오 메모리를 사용하게 됨 
+ 크롬 개발자 도구 - 톱니바퀴 모양 아이콘 - 도구 더보기에서 레이어를 누를 시 나뉘어진 레이어와 레이어 별 차지하고 있는 메모리 확인 

## CSS will-change
+ will-change 속성은 즉가적으로 예상되는 변화의 종류에 관한 힌트를 브라우저에 제공하는 CSS 속성

~~~css

#a {
  will-change: transform;
}

~~~
+ will-change 속성 값으로 transform 입력 시 브라우저는 transform이 변경되는 상황을 미리 준비

~~~css

*, *::after, *::before{
  will-change: transform;
}

~~~
+ 잘못된 사용예시
  + 변경되지 않을 모든 요소까지 미리 적용하게 될 시 Graphics Layer가 계속 유지되고 메모리를 점유하여 성능 저하 발생 

## Composite 단계 마무리하기 
+ Graphics Layer는 상황을 고려하고 사용
  + 메모리가 적은 저사양 모바일 기기에서도 잘 작동되어야 하는가?
  + 레이어의 크기가 너무 크지 않은가?
  + 너무 많은 레이어가 생성되진 않는가?
  + GPU가 잘 하는 일인가? (opacity, filter, rotate, scale, 3d)
  + 레이어 분리를 통해 연산에 이점을 얻을 수 있는가?
  + 많은 요소의 이동이 발생되어 프레임 저하를 예측할 수 있는가?
+ will-change 속성은 즉가적인 변화가 예측될 때 활용
  + will-change의 값이 짧은 순간에 너무 자주 바뀌는가?
  + 확실하지 않은 변경을 미리 준비하는 것인가?
  + 한번에 너무 많은 요소가 적용하였는가?
+ CSS animation과 transition 속성
  + will-change보다는 CSS를 통한 animation과 transition을 우선 시도
  + 애니메이션이 종료된 이후에 그래픽 레이어가 그대로 남아있어도 되는가?
+ 부록 : Reflow 연산 시간을 줄이기 위한 CSS Contain 속성
  + 레이아웃 과정 중 Reflow 시간을 단축시킬 수 있는 CSS Contain 속성
  + 특정 요소를 문서 트리에서 독립되어 있음으 나타낼 때 연산 과정을 격리 시킬 수 있다.

