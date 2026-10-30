---
layout: about
title: About
image: /assets/img/brand/siksik-logo.webp
description: >-
  Java와 Spring을 중심으로 API, 배치, 데이터 처리 시스템을 개발하는 SIKSIK입니다.
hide_description: true
hide_title: true
---

<div class="about-hero">
  <div class="about-hero-copy">
    <p class="about-eyebrow">SIKSIK / BACKEND DEVELOPER</p>
    <h1>데이터의 흐름을 이해하고,<br>안정적인 서비스를 만듭니다.</h1>
    <p class="about-hero-description">Java와 Spring으로 서비스를 만드는 백엔드 개발자 SIKSIK입니다.<br> 직접 개발하고 운영하며 마주한 문제, 그리고 그 과정에서 배운 것을 기록합니다.</p>
  </div>
  <img class="about-hero-logo" src="{{ site.logo | relative_url }}" alt="SIKSIK 로고" width="168" height="168">
</div>

<div class="about-links">
  <a href="{{ '/study/' | relative_url }}">학습 기록 <span aria-hidden="true">↗</span></a>
  <a href="{{ '/project/' | relative_url }}">프로젝트 <span aria-hidden="true">↗</span></a>
  <a href="mailto:{{ site.author.email }}">이메일 <span aria-hidden="true">↗</span></a>
</div>

## 개발을 대하는 태도

기능을 구현하는 일만큼, 요청이 어떤 경로를 지나고 데이터가 어떻게 바뀌는지 이해하는 일을 중요하게 생각합니다. API와 배치, 외부 시스템 연동을 개발하며 쌓은 경험을 바탕으로 서비스의 흐름과 데이터의 일관성을 살핍니다.

문제가 생기면 코드와 쿼리, 로그를 따라 원인을 확인하고 작은 변경부터 검증하려고 합니다. 학습한 기술도 사용법에 그치지 않고, 어떤 문제를 해결하며 어떤 제약이 있는지 함께 정리합니다.

## 다뤄 온 기술과 넓혀 가는 관심

<div class="about-skill-groups">
  <section>
    <h3>개발 경험</h3>
    <p>API 설계와 외부 연동, 배치 처리, 관리자 기능, 데이터 조회와 정산 업무를 개발해 왔습니다.</p>
    <ul class="about-tags" aria-label="개발 경험 기술">
      <li>Java</li><li>Spring Boot</li><li>Spring Batch</li><li>JPA · QueryDSL</li><li>MySQL</li><li>PostgreSQL</li><li>SQL Server</li><li>Thymeleaf · JSP</li>
    </ul>
  </section>
  <section>
    <h3>학습과 관심</h3>
    <p>애플리케이션을 넘어 데이터 처리와 운영 환경까지 이해하기 위해 공부하고 있습니다.</p>
    <ul class="about-tags" aria-label="학습 및 관심 기술">
      <li>Redis</li><li>Kafka</li><li>Docker</li><li>Kubernetes</li><li>AWS</li><li>MSA</li><li>정보관리 기술사</li>
    </ul>
  </section>
</div>

## 프로젝트 경험

물류, 결제, 쿠폰, 거래소 서비스를 개발하며 외부 데이터를 받아들이는 과정부터 사용자 요청 처리, 배치와 운영 기능까지 경험했습니다. 각 프로젝트에서 맡은 역할과 주요 구현, 운영 과정에서 다룬 문제를 정리했습니다. 제목을 누르면 상세 기록으로 이어집니다.

<div class="about-projects">
  <section class="about-project">
    <span class="about-project-number" aria-hidden="true">01</span>
    <div>
      <p class="about-project-domain">LOGISTICS · 트레드링스</p>
      <h3><a href="{{ '/logistics/' | relative_url }}">물류 데이터와 서비스 연동 <span aria-hidden="true">↗</span></a></h3>
      <p>선사·터미널별로 다른 데이터를 수집·표준화하고, 스케줄 조회 API와 구독 결제 등 실제 서비스 기능으로 연결했습니다.</p>
      <dl class="about-project-details">
        <dt>담당 역할</dt>
        <dd>FCL·터미널 스크래퍼와 스케줄 API를 개발했습니다. PayPal·Stripe 구독 결제, 알림 센터와 선적 변경 알림, B2B 광고 플랫폼의 백엔드 기능도 담당했습니다.</dd>
        <dt>주요 구현</dt>
        <dd>
          <ul>
            <li>FTP와 웹 스크래핑으로 수집한 데이터를 공통 구조로 변환하고, 중복·오류 데이터를 걸러 내며 변경된 스케줄을 갱신했습니다.</li>
            <li>스케줄 조회·다운로드 API에 고객·관리자 권한 구분과 API Key 인증을 적용하고, Swagger와 REST Docs로 연동 문서를 제공했습니다.</li>
            <li>PayPal 구독의 생성·변경·취소와 결제 내역 관리를 구현하고, Webhook으로 전달되는 결제 성공·실패·환불 및 구독 상태 변경을 처리했습니다.</li>
          </ul>
        </dd>
        <dt>운영에서 고려한 점</dt>
        <dd>외부 결제 상태와 내부 멤버십 상태를 함께 관리해야 했습니다. 구독 변경 중 기존 결제 취소가 실패하면 멤버십 변경을 되돌리고, 외부에서 발생한 구독 취소는 메시지 큐를 통해 멤버십에 반영하도록 처리했습니다.</dd>
      </dl>
    </div>
  </section>
  <section class="about-project">
    <span class="about-project-number" aria-hidden="true">02</span>
    <div>
      <p class="about-project-domain">PAYMENTS · 립페이</p>
      <h3><a href="{{ '/payment-system/' | relative_url }}">결제 API와 정산·대사 <span aria-hidden="true">↗</span></a></h3>
      <p>가맹점의 결제 요청을 처리하는 API부터 원천사 연동, 결제 이후의 대사와 차액 정산까지 개발했습니다.</p>
      <dl class="about-project-details">
        <dt>담당 역할</dt>
        <dd>가맹점·대리점 API와 인증 결제, PG별 차액 정산·대사 배치, 결제 및 정산 내역을 확인하는 관리자 기능을 담당했습니다.</dd>
        <dt>주요 구현</dt>
        <dd>
          <ul>
            <li>가맹점의 인증 결제 요청과 원천사 응답을 처리하고, 결제 결과를 가맹점에 전달하는 연동 기능을 구현했습니다.</li>
            <li>Spring Batch로 거래·매입·정산 대사를 구성하고, 원천사별 대사 Step을 병렬로 실행하도록 처리했습니다.</li>
            <li>차액 정산 요청 대상을 선별한 뒤 원천사에 요청하고, 응답 결과를 조회하여 요청·결과 테이블의 상태에 반영하는 배치를 구현했습니다.</li>
          </ul>
        </dd>
        <dt>운영에서 고려한 점</dt>
        <dd>미처리 데이터를 기준으로 대사 대상을 조회하고, 처리 결과를 거래·매입·정산 정보와 이력 테이블에 반영했습니다. 외부 응답이 내부 데이터에 어떻게 반영됐는지 추적하고, 관리자가 결제와 정산 내역을 확인할 수 있도록 개발했습니다.</dd>
      </dl>
    </div>
  </section>
  <section class="about-project">
    <span class="about-project-number" aria-hidden="true">03</span>
    <div>
      <p class="about-project-domain">COUPON · 크레디프</p>
      <h3><a href="{{ '/coupon-service/' | relative_url }}">쿠폰의 발급부터 취소까지 <span aria-hidden="true">↗</span></a></h3>
      <p>결제와 연결된 쿠폰의 발급·사용·복원·취소 흐름을 개발하고, 반복적인 업무와 시나리오 검증을 자동화했습니다.</p>
      <dl class="about-project-details">
        <dt>담당 역할</dt>
        <dd>쿠폰 API와 결제 시스템 연동, 프로모션 운영용 관리자 기능, 통계·외부 연동 배치를 개발했습니다. 수동으로 진행하던 쿠폰 시나리오 테스트를 자동화하는 프로그램도 구현했습니다.</dd>
        <dt>주요 구현</dt>
        <dd>
          <ul>
            <li>쿠폰 조회·발급과 결제·취소 결과 연동을 구현하고, 결제에 따른 쿠폰 사용과 취소 후 복원 흐름을 처리했습니다.</li>
            <li>Quartz 기반 정기 배치로 쿠폰 통계 집계와 외부 파일 연동을 수행하고, 배치 ID나 실행일자를 지정하는 수동 실행 기능을 제공했습니다.</li>
            <li>일반·연관·다중 프로모션 설정에 맞는 테스트 데이터를 생성하여 결제, 쿠폰 발급·사용·복원·취소를 순서대로 검증하도록 자동화했습니다.</li>
          </ul>
        </dd>
        <dt>운영에서 고려한 점</dt>
        <dd>자동 테스트가 실패하면 오류 내용을 로그와 DB에 기록하고 관련 데이터를 남겨 원인을 확인할 수 있게 했습니다. 성공한 테스트의 데이터는 다음 실행 전에 정리하여 이후 시나리오에 영향을 주지 않도록 처리했습니다.</dd>
      </dl>
    </div>
  </section>
  <section class="about-project">
    <span class="about-project-number" aria-hidden="true">04</span>
    <div>
      <p class="about-project-domain">EXCHANGE · 코엔코코리아</p>
      <h3><a href="{{ '/coin-exchange/' | relative_url }}">거래소 서버와 지갑 연동 <span aria-hidden="true">↗</span></a></h3>
      <p>회원 인증과 거래·입출금 기능을 개발하고, 거래소와 지갑 서버를 클라우드 환경에서 구성·운영했습니다.</p>
      <dl class="about-project-details">
        <dt>담당 역할</dt>
        <dd>거래소의 화면·클라이언트·Controller 개발과 관리자 기능 구현에 참여했습니다. 거래소·지갑 서버 구성 및 운영, ISMS 인증 준비를 위한 보안 구축과 점검도 함께 수행했습니다.</dd>
        <dt>주요 구현</dt>
        <dd>
          <ul>
            <li>Spring Security 기반 회원가입·로그인, 본인 및 이메일 인증, 주문·주문 취소, 원화 입출금과 잔고·거래 내역 조회 기능을 개발했습니다.</li>
            <li>관리자가 고객의 입출금, 주문·거래 현황과 수수료를 확인하고 출금 승인·거부를 처리하는 기능을 구현했습니다.</li>
            <li>FSDC 환경에서 서버를 구성하고, NGINX를 이용한 로드밸런싱과 리버스 프록시를 적용했습니다.</li>
          </ul>
        </dd>
        <dt>운영에서 고려한 점</dt>
        <dd>출금 신청부터 이메일 인증과 승인·거부까지 이어지는 처리 흐름을 다뤘습니다. 사용자에게 보이는 잔고·거래 내역과 관리자 운영 기능을 함께 개발하며, 인증과 거래 상태를 확인할 수 있도록 구성했습니다.</dd>
      </dl>
    </div>
  </section>
</div>

## 배움을 이어 온 기록

업무에서 만난 질문을 공부로 이어 가고, 공부한 내용을 다시 코드와 글로 정리합니다.

<details class="about-record" markdown="1">
<summary>자격증 <span>4개</span></summary>

- 정보처리기사 · 2019.08
- 네트워크관리사 2급 · 2018.12
- 컴퓨터활용능력 2급 · 2017.12
- Oracle Certified Java Programmer (OCJP) · 2016.10

</details>

<details class="about-record" markdown="1">
<summary>수료한 강의 <span>Java · Spring · 데이터베이스 외</span></summary>

- 스프링 핵심 원리 - 고급편/inflearn
- 스프링 DB 2편 - 데이터 접근 활용 기술/inflearn
- 스프링 DB 1편 - 데이터 접근 핵심 원리/inflearn
- 백엔드 개발자를 위한 한 번에 끝내는 대용량 데이터 & 트래픽 처리 초격차 패키지 Online./fastcampus
- 10개 프로젝트로 완성하는 백엔드 웹개발(Java Spring) 초격차 패키지 Online./fastcampus
- 한 번에 끝내는 코딩테스트 365 Java편 초격차 패키지/fastcampus
- 이펙티브 자바 완벽 공략 2부/inflearn
- 이펙티브 자바 완벽 공략 1부/inflearn
- 코딩으로 학습하는 리펙토링/inflearn
- 스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술/inflearn
- 스프링 MVC 1편 - 백엔드 웹 개발 핵심 기술/inflearn
- 모든 개발자를 위한 HTTP 웹 기본 지식/inflearn
- 코딩으로 학습하는 GoF의 디자인 패턴/inflearn
- Spring Cloud로 개발하는 마이크로서비스 어플리케이션(MSA)/inflearn
- Spring boot를 이용한 RESTful Web Services 개발/inflearn
- 더 자바, Java 8/inflearn
- 더 자바, 애플리케이션을 테스트하는 다양한 방법/inflearn
- 더 자바, 코드를 조작하는 다양한 방법/inflearn
- 한 번에 끝내는 Spring 완.전.판 초격차 패키지/fastcampus
- 자바(Java) 알고리즘 문제풀이/inflearn
- 2021.02 ~ 2021.02 Java12 프로그래밍/ktds
- 2021.02 ~ 2021.02 Spring boot API Service 개발/ktds
- 2020.11 ~ 2021.11 실무 적용 SQL 성능 튜닝/ktds
- 2020.08 ~ 2021.08 Postgre SQL & PPAS 실무적용/ktds
- 2020.07 ~ 2021.07 리액트 프로그래밍/ktds
- 2020.06 ~ 2021.06 Angular 프론트엔드 웹 개발/ktds
- 2020.05 ~ 2021.05 데이터베이스 모델링 실무/ktds

</details>

<details class="about-record" markdown="1">
<summary>읽은 책 <span>코드와 설계를 이해하는 시간</span></summary>

- 클린코드
- 업무에 바로 쓰는 SQL 튜닝
- Do it! 자료구조와 함께 배우는 알고리즘 입문 자바 편
- 토비의 스프링 3.1
- Java의 정석
- 비전공자를 위한 이해할 수 있는 IT 지식

</details>

<details class="about-record" markdown="1">
<summary>수상 기록 <span>2016</span></summary>

- 동원대학교 교내 캡스톤 경진대회 · 금상 · 2016.12
- 일산킨텍스 작품 전시 · 입상 · 2016.10
- 산학협력 선도전문대학(LINC) 육성사업 캡스톤디자인 경진대회 · 입상 · 2016.10

</details>

<div class="about-closing">
  <p class="about-eyebrow">KEEP LEARNING, KEEP BUILDING.</p>
  <p>기록하고, 연결하고, 개선합니다.<br>이곳에 쌓인 기록이 비슷한 문제를 만난 누군가에게 도움이 되길 바랍니다.</p>
</div>
