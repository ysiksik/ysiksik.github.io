---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: BPMN 기본 표기법
date: '2022-06-17 00:00:00 +0900'
categories:
    - database-modeling
tags: databaseModeling
comments: true
---

# BPMN 기본 표기법

# BPMN 기본 표기법
* toc
{:toc}

## BPMN 표기법 정리

![예제](/assets/img/database-modeling/BPNM-Notation-Organize.png)

## 게이트웨이(Gateway)
  + 게이트웨이(Gateway)
    > + 게이트웨이는 프로세스의 논리적인 흐름을 정의하기 위해 프로세스를 분할하거나 병합하기  위한 용도로 사용됨


 <table>
  <tr>
    <th colspan="2">구분</th>
    <th>표기</th>
    <th colspan="2">설명</th>
  </tr>
  <tr>
    <td rowspan="2">배타적 (Exclusive)</td>
    <td>데이터기반<br/>(Data Based)</td>
    <td><img src="/assets/img/database-modeling/DataBased.png" width=100 height=100></td>
    <td rowspan="2">베타적 게이트웨이는 반드시 한 경로만 선택된다</td>
    <td>출구 조건을 갖는다</td>
  </tr>
  <tr>
    <td>이벤트 기반<br/>(Event Based)</td>
    <td><img src="/assets/img/database-modeling/EventBased.png" width=100 height=100></td>
    <td>출구 조건을 갖지 않는다</td>
  </tr>
  <tr>
    <td colspan="2">포괄적(Inclusive)</td>
    <td><img src="/assets/img/database-modeling/Inclusive.png" width=100 height=100></td>
    <td colspan="2">하나 혹은 그 이상의 경로로 분할되거나 병합한다</td>
  </tr>
  <tr>
    <td colspan="2">병렬(Parallel)</td>
    <td><img src="/assets/img/database-modeling/Parallel.png" width=100 height=100></td>
    <td colspan="2">두 개 이상의 경로로 분할되어 동시에 실행된다</td>
  </tr>
  <tr>
    <td colspan="2">복합(Complex)</td>
    <td><img src="/assets/img/database-modeling/Complex.png" width=100 height=100></td>
    <td colspan="2">토큰을 처리하기 위한 임의의 규칙이 포함될 수 있다</td>
  </tr>
</table>


### 배타적 게이트웨이(Exclusive Gateway)
  + 배타적 게이트웨이(Exclusive Gateway)
    > + 하나의 경로만 선택
    > + 프로세스를 분할 하거나 병합하기 위해 사용
    > + 빈 마름모 모양이나 마름모 안에 'X' 표시가 되어있는 마름모 기호를 사용
    > ![예제](/assets/img/database-modeling/ExclusiveGateway.png)
    > + 판단을 해야 하는 액티비티가 존재한다면 기본적으로 배타적 게이트웨이가 사용됨
    > + 배타적 게이트웨이 안에 질문이 포함될 수도 있음
    > ![예제](/assets/img/database-modeling/ExclusiveGateway2.png)
    > + 하나의 게이트웨이는 여러 출구를 가질 수 있으며, 기본 출구도 정의될 수 있음
    > ![예제](/assets/img/database-modeling/ExclusiveGateway4.png)
    > ![예제](/assets/img/database-modeling/ExclusiveGateway3.png)

### 병렬 게이트웨이(Parallel Gateway)
  + 병렬 게이트웨이(Parallel Gateway)
    > + 프로세스가 두 개 혹은 그 이상의 병렬 경로로 분할되어 동시에 실행되는 것을 표현하기 위한 게이트웨이
    > + 놀리적으로 "AND"에 해당하며, 마름모 기혼안에 '+' 표시가 되어있는 기호를 사용
    > ![예제](/assets/img/database-modeling/ParallelGateway.png)
    > + 병렬 게이트웨이에 의해 분할된 경로는 병렬 게이트웨이에 의해 다시 합쳐짐
    >   + 첫번째 : 분할 병렬 게이트웨이, 두번째 : 통합 병렬 게이트웨이
    > + 분할 병렬 게이트웨이는 각각의 시퀀스 플로우로 토큰을 복제
    > ![예제1](/assets/img/database-modeling/ParallelGateway2.png)
    > + 통합 병렬 게이트웨이는 모든 토큰들을 기다린 후 하나의 토큰으로 통합
    > ![예제](/assets/img/database-modeling/ParallelGateway3.png)

### 포괄적 게이트웨이(Inclusive Gateway)
  + 포괄적 게이트웨이(Inclusive Gateway)
    > + 포괄적 게이트웨이는 하나 혹은 그 이상의 경로를 선택하거나 병합한다.
    > + 놀리적으로 "OR"에 해당하며, 마름모 기호안에 동그라미 표시가 되어있는 기호를 사용
    > ![예제](/assets/img/database-modeling/InclusiveGateway.png)
    >   + 첫번째 : 분할 포괄적 게이트웨이, 두번째 : 통합 포괄적 게이트웨이
    > + 최소한 하나 이상의 어떤 조합도 가능
    > + 분할 포괄적 게이트웨이의 송신 시퀀스 플로우는 조건이 함께 제시가 됨
    > ![예제](/assets/img/database-modeling/InclusiveGateway2.png)
    > ![예제](/assets/img/database-modeling/InclusiveGateway3.png)
    > + 모든 토큰들이 포괄적 병합 게이트웨이에 도착할 수 있는 것은 아니다
    > ![예제](/assets/img/database-modeling/InclusiveGateway4.png)
    > + 다른 분할 게이트웨이에 의해서 분할된 시퀀스 플로우를 병합할 수 있다.
    > ![예제](/assets/img/database-modeling/InclusiveGateway5.png)
    > + 기본 시퀀스 플로우를 표현할 수 있으며, 기본 시퀀스 플로우는 다른 시퀀스 플로우와 함께 사용될 수 없다.
    > ![예제](/assets/img/database-modeling/InclusiveGateway6.png)
    > + 기본 시퀀스 플로우 없이도 모델링 될 수 있다
    > ![예제](/assets/img/database-modeling/InclusiveGateway7.png)
    >   + 그러나 입사 지원서를 검터한 후 다시 자격증이 누락 되었는지, 아니면 중요 정보가 누락 되었는지를 확인하는 것은 이치에 맞지 않는다,
    > ![예제](/assets/img/database-modeling/InclusiveGateway6.png)

### 복합 게이트웨이(Complex Gateway)
  + 복합 게이트웨이(Complex Gateway)
    > + 복합 게이트웨이는 프로세스를 처리하기 위한 임의의 규칙을 포함할 수 있다.
    > + 마름모 기호 안에 별표 표시가 되어있는 기호를 사용.
    > ![예제](/assets/img/database-modeling/ComplexGateway.png)
    > + 시퀀스 플로우를 병합하는 것 뿐만 아니라 분할하는 데에도 사용될 수 있다.
    > + 복잡한 규칙을 정의하기 위해 다수의 게이트웨이를 사용하는 것에 대한 대안이 될 수 있다.

## 이벤트(Event)
  + 이벤트(Event)
  > + 이벤트는 비즈니스 프로세스에서 발생되는 하나의 사건을 표현하기 위해서 사용 됨.
  > + 기간을 표시하지 않음.
  > + 이벤트 유형
  >   + ![예제](/assets/img/database-modeling/Event.png)
  > + 이벤트를 발생시키는 전형적인 상황들
  >   + 프로세스의 시작과 끝
  >   + 메시지의 도착 (전화, 이메일, 편지)
  >   + 특정 시점의 도달 (매일 오전 5시가되면, 매월 말일이 되면)
  >   + 특정 시간 경과 (계약 후 1달이 경과하면, 가열 후 5분 경과하면)
  >   + 참으로 판명되는 조건 (외부 온도가 30도를 넘으면, 시속 80km 이상이 되면)
  >   + 오류 발생 (정전이 발생하면, 기계가 고장나면)

### 시작 이벤트
+ 시작 이벤트

 | 시작 이벤트 | 표기 | 설명 |
 | --- | --- | --- |
 | 비 형식 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent1.png) | 가장 일반적인 이벤트로 시작의 주체는 중요하지 않거나 정확히 알려져 있지 않은 이벤트, 종종 상황을 보고 이벤트의 발생 주체를 알 수도 있다 |
 | 타이머 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent2.png) | 특정 시점에 도달하는 경우 발생하는 이벤트 |
 | 메세지 수신 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent3.png) | 메세지(전화, 이메일, 우편)가 도착하면 발생하는 이벤트 |
 | 조건 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent4.png) | 조건에 부합하면(참이면) 발생하는 이벤트 |
 | 신호 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent5.png) | 메시지는 특정 수신자에게 전달되는데 반해서 신호는 불특정 다수에게 전달되는 메시지, 이러한 시호는 같을 풀이나 다른 풀 또는 다른 프로세스에서 발생할 수 있다. |
 | 다중 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent6.png) | 여러 개의 이벤트를 가지고 있으면서 그들 중 하나라도 발생하면 프로세스가 시작되는 이벤트 (Or 조건의 이벤트) |
 | 병렬 시작 이벤트 | ![예제](/assets/img/database-modeling/StartEvent7.png) | 여러 개의 이벤트들이 모두 발생해야 프로세스가 시작되는 이벤트 (And 조건의 이벤트) |

### 종료 이벤트
 + 종료 이벤트

 | 종료 이벤트 | 표기 | 설명 | |
 | --- | --- | --- | --- |
 | 비 형식 종료 이벤트 | ![예제](/assets/img/database-modeling/EndEvent1.png) | 가장 일반적인 종료 이벤트로 토큰이 도착했을 때 그것을 제거한다. 그러나 여러 토큰들이 있는 경우 다른 토큰들은 계속해서 프로세스를 진행하게 된다. | ![예제](/assets/img/database-modeling/EndEvent1-1.png) |
 | 메시지 종료 이벤트 | ![예제](/assets/img/database-modeling/EndEvent2.png) | 다른 프로세스에 메세지를 전달하고 프로세스를 종료하는 이벤트 | ![예제](/assets/img/database-modeling/EndEvent2-1.png) |
 | 종결 종료 이벤트 | ![예제](/assets/img/database-modeling/EndEvent3.png) | 단일 토큰일 제거할 뿐만 아니라 모든 프로세스들의 진행을 즉시 중지시키는 이벤트 | ![예제](/assets/img/database-modeling/EndEvent3-1.png) |
 | 신호 송신 종료 이벤트 | ![예제](/assets/img/database-modeling/EndEvent4.png) | 프로세스를 종료하면서 특정 신호를 발생시킨다. | ![예제](/assets/img/database-modeling/EndEvent4-1.png) |
 | 다중 송신 종료 이벤트 | ![예제](/assets/img/database-modeling/EndEvent5.png) | 프로세스의 끝에서 많은 결과들이 발생하게 된다. 즉, 다중 종료 이벤트에 도달하게 되면, 해당 토큰은 종료 되지만, 정의된 모든 이벤트들이 발생 | ![예제](/assets/img/database-modeling/EndEvent5-1.png) |

    송신 이벤트의 기호는 진하게 색칠되어있는 반면에 수신 이벤트의 기호는 같은 기호이지만 비어있는 형태를 취하게 된다.

### 중간 이벤트
  + 중간 이벤트
    + 프로세스 안에서 어디든지 발생할 수 있는 이벤트들을 말하면, 기폰 표기번은 이중선을 가진 원이다.
    > + 시작 이벤트는 수신(Catching)만 가능
    > + 종료 이벤트는 송신(Throwing)만 가능
    > + 수신 메시지 시작 이벤트
    >   + ![예제](/assets/img/database-modeling/MiddleEvent1.png)
    > + 송신 메시지 종료 이벤트
    >   + ![예제](/assets/img/database-modeling/MiddleEvent2.png)
    > + 중간 이벤트는 송신 이벤트(Throwing Event)가 될 수도있고, 수신 이벤트(Catching Event)가 될 수도 있다.
    >   + 송신 메시지 중간 이벤트
    >     + ![예제](/assets/img/database-modeling/MiddleEvent3.png)
    >   + 수신 메시지 중간 이벤트
    >     + ![예제](/assets/img/database-modeling/MiddleEvent4.png)

## 협업 모델(Collaboration)

### 협업에 대한 소개

  + 협업(Collaboration) 이란?
  > + 협업이란 중앙의 통제 없이 둘 혹은 그 이상의 프로세스간에 정의된 상호작용
  > + 각각의 프로세스는 독립된 풀에 속하게 됨

  + 여러 풀(Poll)을 이용한 모델링
  > + 궁극적으로 협업은 둘 혹은 그 이상의 풀(Poll)을 이용해서 모델링됨
  > + 각각의 풀은 메시지 교환(Message Exchange)을 통해서 소통

  + 협업 에서의 표현
  > + 협업 모델은 여러 회사간의 상호 협동을 문서화하기에 유용
  > + 협업을 통해 상호 작용하는 컴퓨터 프로그램이나 기술 시스템을 표현할 수도 있음

  + 협업 모델
  > + 협업에는 통합 연출(Choreography) 과 오케스트레이션(Orchestration) 모델이 있음

### 협업 모델 예제
![예제](/assets/img/database-modeling/Collaboration.png)
> + 입사지원 프로세스에서 지원자와 기업간의 상호작용을 협업을 통해서 작성한 다이어그램
> + 각각의 풀은 시작 이벤트와 종료이벤트, 그리고 액티비티들과 시퀀스 플로우를 가진 완전한 프로세스를 갖고 있음. 하지만  두풀은 서로 메시지를 주고받기 때문에 완전히 독립적이지는 않다.
> + 각각의 풀은 파트너 역할에 따라 이름이 붙여졌으며, 이 방법이 협업 모델에서 일반적이다.

### 메시지 플로우 모델링

  + 메시지 플로우(Message Flow)
  > + 전화나 이메일, 팩스 혹은 편지 등을 포함한 모든 종류의 정보 교환을 표현한다.
  > + 기호
  >   + ![예제](/assets/img/database-modeling/MessageFlow1.png)
  >     +  시작은 작은 원으로 표시되고, 끝은 빈 화살표 머리로 구성되며, 선은 대쉬 라인(긴 점선)으로 그려짐
  > + 메시지 플로우 사용 방법
  >   + ![예제](/assets/img/database-modeling/MessageFlow2.png)
  >     + BPMN에서 메시지 플로우는 다른 풀에 있는 독립적인 프로세스들 사이의 통신 에만 사용된다.
  >   + ![예제](/assets/img/database-modeling/MessageFlow3.png)
  >   + ![예제](/assets/img/database-modeling/MessageFlow4.png)
  >   + ![예제](/assets/img/database-modeling/MessageFlow5.png)
  >     + 반면에 시퀀스 플로우는 동일한 풀에서만 허용되며, 풀의 경계를 넘을 수는 없다.

## 액티비티(Activity)

### 액티비티(Activity)소개

  > + ![예제](/assets/img/database-modeling/Activity1.png)
  >   + 액티비트는 작업(Task)과 하위 프로세스(SubProcess)로 구현 됨
  >   + 작업은 세분화되지 않는데 반해서 하위 프로세스는 구체적인 상세 프로세스를 포함
  >   + 하위 프로세스는 조그만 사각형 안에 플러스 표시로 정의되며, 액티비티 하단에 위치함
  >   + ![예제](/assets/img/database-modeling/Activity2.png)
  >     + 액티비티에 정의된 작업이 여러 번 반복되어야 하는 경우 반복 액티비티를 사용하며, 반복 액티비트는 동그란 모양의 되돌림 화살표 기호로 액티비티 하단에 표시 됨
  >     + 하위 프로세스도 역시 반복 액티비티로 정의될 수 있다
  >   + ![예제](/assets/img/database-modeling/Activity3.png)
  >     + 다중 인스턴스 액티비티는 실행되어야 하는 객체 집합을 다루는데 사용되며, 세 개의 수직선으로 표시됨
  >     + 다중 인스턴스 액티비티도 실행될 요소를 지정하기 위한 속성을 가질 수 있으며, 주석을 상요할 수도 있다

### 작업의(Task) 유형

![예제](/assets/img/database-modeling/Task.png)
> 추상 작업을 제외한 다른 작업들은 아이콘으로 표시되는데 이러한 아이콘의 유형들은 향후 프로세스 엔진을 이용한 프로세스 자동화의 관점을 반영한다.

## 예외 처리(Exception Handling)

### 방해 중간 이벤트(Interrunpting Intermediate Events)
> + 방해 중간 이벤트는 기존 프로세스의 흐름을 중단 시키며, 액티비티의 가장자리에 위치하게 된다
> + ![예제](/assets/img/database-modeling/InterrunptingIntermediateEvents1.png)

### 비방해 중간 이벤트(Non-Interrupting Intermedeiate Events)
> + 비 방해 이벤트는 기존 프로세스의 흐름을 중단 시키지 않으며, 동그라미가 쉬라인으로 표시된다
> + ![예제](/assets/img/database-modeling/InterrunptingIntermediateEvents2.png)

### 오류 중간 이벤트(Error Intermediate Event)
> + 오류(Error) 발생으로 인한 예외처리를 해야 하는 경우 오류 중간 이벤트가 사용될수 있으며, 플래시 기호를 사용한다
> + ![예제](/assets/img/database-modeling/ErrorIntermediateEvent.png)
>   + 오류 이벤트는 당연히 방해 이벤트 이다

## 보상(Compensation) 프로세스

### 트랜잭션
> + 트랜젝션은 일반적으로 완성된 작업의 처리 단위를 말하는데 작업 내에 정의된 일들이 모두 처리가되거나 처리되지 않아야 한다(ALL or Nothing)
> + ![예제](/assets/img/database-modeling/Compensation1.png)

### 보상 프로세스
![예제](/assets/img/database-modeling/Compensation2.png)
> + 보상 프로세스는 트랜잭션 없이도 모델링 될 수 있다.
> + 현재 보상 프로세스를 트랜잭션으로 하지 않은 이유는 봇아 프로세스가 발생하더라도 전체 프로세스를 되돌리지 않도록 하기 위함이다
> + 거절을 만나면 보상 프로세스가 진행되어 비행기 예약과 호텔 예약 전체가 취소된다.
> + '비행기 예약 취소' 보상 액티비티만 실행된다

## 프로세스 안의 데이터 객체(Data Object)

### 데이터 플로우 모델링
> + 프로세스가 수행될 때 데이터, 정보, 파일, 문서 등이 만들어지거나 사용되며, 이를 표현하고자 하는 것이 바로 데이터 플로우 모델링이다
> + 시퀀스 플로우는 액티비티간에 데이터 전송을 동반하게 되며, 메시지 플로우 또한 데이터 상호 교환이 주된 목적이다
> + 프로세스 안의 모든 액티비티들은 언제든지 풀 안에 정의된 몬든 데이터들에 대해 접근할 수 있어야 한다
> + ![예제](/assets/img/database-modeling/DataObject1.png)

### 다중 데이터 객체
![예제](/assets/img/database-modeling/DataObject2.png)
> + 데이터 목록이나 집합에 대한 모델링을 할 때 다중 데이터 객체를 통해서 표현
> + 다중 데이터 객체는 다중 인스턴스 액티비처럼 3개의 수직 선으로 표시된다
> + 위 그림의 내용은 여러 명의 지원자들에 대한 지원서를 수신해서 지원서를 검토한 후 몇 개의 적합한 지원서를 고른 다음 그 중에서 한 명의 지원자에 대한 지원서를 선택하는 내용이다

## ER/Studio Business Architect 사용 방법

### 구인 광고 프로세스 작성하기
![예제](/assets/img/database-modeling/StudioBusinessArchitect1.png)

### 협업 모델 프로세스 작성하기
![예제](/assets/img/database-modeling/StudioBusinessArchitect2.png)
