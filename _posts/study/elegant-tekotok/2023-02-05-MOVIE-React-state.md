---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 무비의 React의 state
date: '2023-02-05 00:00:02 +0900'
categories:
    - study
    - elegant-tekotok
comments: true
---

# 무비의 React의 state
[https://youtu.be/NpTizz_qgtA](https://youtu.be/NpTizz_qgtA)

# 무비의 React의 state
* toc
{:toc}

## React에서 state 란?
+ React가 데이터 바인딩을 대신 해준다 
  + 데이터 바인딩 : 제공자와 소비자로부터 데이터 워노을 결합시켜 이것들을 동기화 시키는 기법  
    + 데이터를 view 넣어주는것 
    + 자바스크립트 객체와 화면에 있는 데이터를 일치시키는 것 
+ React는 단방향 데이터 바인딩을 지원하는데 이는 데이터와 템플릿을 결합하여 화면을 생산한다 
+ 변경되는 데이터를 위해 React에서 지원하는 state를 사용해 줄 수 있다 
+ state를 사용하면 자동으로 관련된 화면은 리렌더링 해줄 수 있다 
+ React에서는 하향식으로 데이터가 흐른다
  + 컴포넌트는 자신의 state를 자식 컴포넌트에게 props로 전달해 준다 
  + 자식 컴포넌트를 설계할 때 자식은 props가 누구로부터 어떤 방식으로 전달되는지 전혀 알 필요가 없다 
  + 이 때문에 state는 종종 캡슐화라고 불린다  
    + state를 가진 컴포넌트 외에는 접근을 할 수 없어서 
+ state
  + 해당 컴포넌트에서 관리
+ props
  + 부모로부터 전달 받는다
  + 읽기 전용 데이터이다 
+ classComponent
  + 클래스형 컴포넌트에서 state를 사용하고 이 state를 갱신하기 위해 setState를 사용한다 
  + 변경되는 데이터를 표현하기 위해 state를 사용하는 이유는 state가 변경될 시 화면이 리렌더링 되기 때문이다 
    + setState를 통해 state를 변경했을 때 화면이 리렌더링 된다
+ 왜 state는 setState를 통해 변경해야 할까?
  + state를 직접적으로 변경했을 경우에는 새로운 state로 화면이 업데이트되지 않기 때문이다 
    + React의 라이프 사이클 흐름을 살펴보아야 한다 
    + 화면이 업데이트 되기 위해서는 render 함수가 실행되어야 한다 
    + setState는 컴포넌트 업데이트 프로세스를 trigger한다 
      + react가 state가 변경되었다는 것을 알 수 있게 해준다
    + shouldComponentUpdate
      + state에 변경사항이 있는지 비교연산 
      + shouldComponentUpdate는 퓨어 컴포넌트를 사용하지 않았다면 기본값으로 true를 반환하기 때문에 setState를 사용한다면 항상 re-render가 된다 
      + state를 직접 변경하게 되면 state는 변경되었을 수도 있다 하지만 render 함수가 실행되지 않았기 때문에 보이는 화면이 업데이트되지 않는다 
+ setState
  + setSate를 통해 state 변경 -> state가 변경됨을 감지 -> 화면을 re-render 
  + 리액트는 컴포넌트가 re-render될 때까지 state를 갱신하지 않는다
  + 즉각적인 명령이 아닌 요청 
  + state를 바로 갱신하지 않는다
  + state 변경사항을 대기열에 집어 넣고, 컴포넌트에게 새로운 state를 사용하기 위해 re-reander를 해야 한다고 알린다
  + setState는 비동기적으로 작동한다 
  + 업데이트 함수를 사용하면 state가 갱신된 이후에 다시 업데이트 해주는 것이 보장된다 
  + 업데이트 함수의 첫번째 매개 변수는 최신 state를 보장해주고, 두번째 매개 변수는 최신 props인 것을 보장해준다
  + setState가 비동기적으로 작동하는 이유는?
    + 연속적으로 state를 변경하고 변경 횟수만큼 리렌더링을 진행한다면 이는 성능 저하를 가져온다 
    + setState가 동기적으로 동작한다면 n번 변경만큼 n번의 렌더링이 되기 때문에 성능 저하를 가져올 수 있다
    + 성능향상을 위해 setState의 실행을 지연시키고 여러 컴포넌트를 한번에 갱신한다
    + setState를 연속적으로 호출하면 setState를 모아서 배치처리한 후 re-render
      + 배치 처리
        + 데이터를 실시간으로 처리하지 않고 종합하여 처리하는 것 
  + state룰 바로 갱신하지 않을 수 있다 
  + 최신 state나 props를 사용하려면 setState에 updator를 넘기거나 생명주기 함수인 componentDidUpdate를 활용해야 한다 
+ 클래스형 컴포넌트를 넘어 함수형 컴포넌트를 작성한다 
+ 함수형 컴포넌트는 stateless 컴포넌트라고도 불린다 
+ 함수형 컴포넌트는 일반적으로 일반 변수는 함수가 끝날 때 사라져서 state가 없다 
+ 함수형 컴포넌트는 state값을 저장하기 위해 훅에 useState를 활용한다 
  + useState를 통해 함수형 컴포넌트에서도 state를 사용할 수 있다 
+ useState는 다음 리렌더링시 배열의 첫 번째 요소로 갱신된 최신 state를 반환한다 
+ useState를 통해 state를 만들어 줄 때 const를 통해 선언한다 
  + const로 선언된 변수는 값이 변경되면 안 되는 것 아닌가요?
    + setState를 통해 state를 변경하는 것이 아니다 useState 함수 안에서 접근할 수 있는 변수 값을 변경한다 
    + useState 내부에는 변수의 값을 업데이트 해주고 이를 배열에 나눠 반환해 준다 
    + 함수형 컴포넌트가 실행이 될때 state 변수는 사실상 계속 할당이 되는 것이다 