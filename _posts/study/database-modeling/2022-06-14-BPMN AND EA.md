---
layout: post
bigtitle: '업무 프로세스 분석과 데이터베이스 모델링'
subtitle: BPMN과 EA(Enterprise Architecture)
date: '2022-06-14 00:00:00 +0900'
categories:
    - study
    - database-modeling
tags: databaseModeling
comments: true
---

# BPMN과 EA(Enterprise Architecture)

# BPMN과 EA (Enterprise Architecture)
* toc
{:toc}

## 왜 표기법이 필요한가?

+ 비즈니스 프로세스(Business Process)란?
  > + 기업에서 발생하는 모든 업무들을 처리하기 위한 절차.
+ 비즈니스 프로세스 관리(Business Process Management)
  > + BPM은 조직의 비즈니스 프로세스를 개선하기 위한 체계적 접근 방법
  > + 기업의 비즈니스 프로세스를 파악하고 정의하며, 이를 보다 효욜적으로 개선하기 위한  관리 체계
+ 비즈니스 프로세스 표기법
  > + 표기법은 비즈니스 프로세스를 설명하기 위한 표준화된 언어의 역할을 수행

## 용어 정리
  + 비즈니스 프로세스 관리(BPM)의 목적
    > + BPM의 목적은 비즈니스 프로세스의 분석과 개선을 통해 궁극적으로 기업의 경쟁력을 확보하기 위해
    > + AS-IS 분석을 통해 TO-BE 모델을 만들어냄
    >   + 비즈니스 프로세스의 효율을 증대시킴
  + 비즈니스 프로세스 관리 시스템(BPMS)
    > + BPM을 실현해 주는 일체의 시스템을 말하며, 다양한 솔루션이 존재
  + 비즈니스 프로세스 모델링(Business Process Modeling)
    > + 비즈니스 프로세스 모델링(BPM)은 업무 분석 단계에서 비즈니스 요구사항들을 정의
    > + 개발 프로세스에서 사용할 수 있도록 비즈니스 요구사항을 정의
  + BPMN(Business Process Modeling and Notation)
    > + 비즈니스 프로세를 모델링하기 위한 국제 표준 표기법
  + UML(Unified Modeling Language)
    > + 객체 지향 프로그래밍 중심의 개발 방법론
  + 데이터 모델링(Data Modeling)
    > + 데이터 중심의 개발 방법론

<div class="language-mermaid">
graph TD;
    BPMN-->UML;
    BPMN-->A[Data Modeling];
    UML-->BPMN;
    A[Data Modeling]-->BPMN;
</div>

## BPMN 소개
  + 비즈니스 프로세스 모델링(Business Process Modeling)
    > + 비즈니스 프로세스 모델링(BPM)은 업무 분석 단계에서 비즈니스 요구사항드을 정리하고, 이를 개발프로세스에서 사용할 수 있도록 정의하는 것
  + BPMN(Business Process Modeling and Notation)
    > + OMG에서 주관하는 비즈니스 프로세스를 모델링 하기위한 국제 표준 표기법