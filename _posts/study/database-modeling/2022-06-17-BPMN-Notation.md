---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: BPMN 기본 표기법
date: '2022-06-17 00:00:00 +0900'
categories:
    - study
    - database-modeling
tags: databaseModeling
comments: true
---

# BPMN 기본 표기법

# BPMN 기본 표기법
* toc
{:toc}

## BPMN 표기법 정리

![예제1](/assets/img/database-modeling/BPNM-Notation-Organize.png)

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


## BPMN 소개
  + 비즈니스 프로세스 모델링(Business Process Modeling)
    > + 비즈니스 프로세스 모델링(BPM)은 업무 분석 단계에서 비즈니스 요구사항드을 정리하고, 이를 개발프로세스에서 사용할 수 있도록 정의하는 것
  + BPMN(Business Process Modeling and Notation)
    > + OMG에서 주관하는 비즈니스 프로세스를 모델링 하기위한 국제 표준 표기법

## BPMN 모델 예제
* EX1
  ![예제1](/assets/img/BPMN-AND-EA/BPMN.png)
* EX2  
  ![예제2](/assets/img/BPMN-AND-EA/BPMN2.png)
