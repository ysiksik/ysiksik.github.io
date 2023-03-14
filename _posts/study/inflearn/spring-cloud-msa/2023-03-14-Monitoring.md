---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: Microservice 모니터링
date: '2023-03-14 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# Microservice 모니터링

# Microservice 모니터링
* toc
{:toc}


## Hystrix Dashboard + Turbine Server


### Turbine Server 
+ 마이크로서비스에 설치된 Hystrix 클라이언트의 스트림을 통합
  + 마이크로서비스에서 생성되는 Hystrix 클라이언트 스트림 메시지를 터빈 서버로 수집
+ ![img.png](../../../../assets/img/spring-cloud-msa/Monitoring.png)

### Hystrix Dashboard
+ Web Dashboard
  + ![img_1.png](../../../../assets/img/spring-cloud-msa/Monitoring1.png)
+ ![img_2.png](../../../../assets/img/spring-cloud-msa/Monitoring2.png)
+ ![img_3.png](../../../../assets/img/spring-cloud-msa/Monitoring3.png)

## Micrometer + Monitoring
+ ![img_4.png](../../../../assets/img/spring-cloud-msa/Monitoring4.png)

### Micrometer
+ Micrometer
  + [https://micrometer.io/](https://micrometer.io/)
  + JVM기반의 애플리케이션의 Metrics 제공
  + Spring Framework 5, Spring Boot 2부터 Spring의 Metrics 처리
  + Prometheus등의 다양한 모니터링 시스템 지원
+ Timer
  + 짧은 지연 시간, 이벤트의 사용 빈도를 측정
  + 시계열로 이벤트의 시간, 호출 빈도 등을 제공
  + @Timed 제공

### Microservice 수정
+ ![img_5.png](../../../../assets/img/spring-cloud-msa/Monitoring5.png)
+ ![img_6.png](../../../../assets/img/spring-cloud-msa/Monitoring6.png)
+ metrics 정보
  + ![img_7.png](../../../../assets/img/spring-cloud-msa/Monitoring7.png)

## Prometheus + Grafana
+ Prometheus
  + Metrics를 수집하고 모니터링 및 알람에 사용되는 오픈소스 애플리케이션
  + 2016년부터 CNCF에서 관리되는 2번째 공식 프로젝트
    + Level DB -> Time Series Database(TSDB)
  + Pull 방식의 구조와 다양한 Metric Exporter 제공
  + 시계열 DB에 Metrics 저장 -> 조회 가능 (Query)
+ Grafana
  + 데이터 시각화, 모니터링 및 분석을 위한 오픈소스 애플리케이션
  + 시계열 데이터를 시각화하기 위한 대시보드 제공
+ ![img_8.png](../../../../assets/img/spring-cloud-msa/Monitoring8.png)

### Prometheus 설치
+ Prometheus 다운로드
  + [https://prometheus.io/download/](https://prometheus.io/download/)

### Prometheus
+ prometheus.yml 파일 수정
  + target 지정
  + ![img_9.png](../../../../assets/img/spring-cloud-msa/Monitoring9.png)
+ Prometheus 서버 실행
  + ![img_10.png](../../../../assets/img/spring-cloud-msa/Monitoring10.png)
+ Prometheus Dashboard
  + http://127.0.0.1:9090/
  + ![img_11.png](../../../../assets/img/spring-cloud-msa/Monitoring11.png)
+ metrics 검사 – Table 
  + ![img_12.png](../../../../assets/img/spring-cloud-msa/Monitoring12.png)
+ metrics 검사 – Graph 
  + ![img_13.png](../../../../assets/img/spring-cloud-msa/Monitoring13.png)

### Grafana
+ Grafana 다운로드 – MacOS
  + ![img_14.png](../../../../assets/img/spring-cloud-msa/Monitoring14.png)
+ Grafana 다운로드– Windows
  + ![img_15.png](../../../../assets/img/spring-cloud-msa/Monitoring15.png)
+ Grafana 실행
  + http://127.0.0.1:3000/
  + ID: admin, PW: admin
  + ![img_16.png](../../../../assets/img/spring-cloud-msa/Monitoring16.png)
+ Grafana – Prometheus 연동
  + ![img_17.png](../../../../assets/img/spring-cloud-msa/Monitoring17.png)
+ Grafana Dashboard
  + JVM(Micrometer)
  + Prometheus
  + Spring Cloud Gateway
  + ![img_18.png](../../../../assets/img/spring-cloud-msa/Monitoring18.png)
+ Grafana – Prometheus 연동
  + ![img_19.png](../../../../assets/img/spring-cloud-msa/Monitoring19.png)
+ Grafana Dashboard
  + ![img_20.png](../../../../assets/img/spring-cloud-msa/Monitoring20.png)
+ Spring Cloud Gateway dashboard
  + ![img_21.png](../../../../assets/img/spring-cloud-msa/Monitoring21.png)
