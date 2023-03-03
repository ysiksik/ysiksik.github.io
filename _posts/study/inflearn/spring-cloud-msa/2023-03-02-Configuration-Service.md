---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: Configuration Service
date: '2023-03-02 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# Configuration Service

# Configuration Service
* toc
{:toc}

## Spring Cloud Config
+ 분산 시스템에서 서버, 클라이언트 구성에 필요한 설정 정보(application.yml)를 외부 시스템에서 관리
+ 하나의 중앙화 된 저장소에서 구성요소 관리 가능
+ 서비스를 다시 빌드하지 않고, 바로 적응 가능
+ 애플리케이션 배포 파이프라인을 통해 DEV – UAT – PROD 환경에 맞는 구성 정보 사용
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service.png)

## Local Git Repository
+ $ ~/Desktop/Work/git-local-repo 디렉토리 생성
+ $ cd git-local-repo
+ $ git init
+ ecommerce.yml 파일 생성
+ $ git add ecommerce.yml.
+ $ git commit –m “upload an application yaml file”
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service2.png)
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service3.png)

### Spring Cloud Config Project
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service4.png)

### Spring Cloud Config Server 설정
+ Dependencies 추가
  + ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service5.png)
+ ConfigServiceApplication.java 파일 수정
  + ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service6.png)

### application.yml
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service7.png)

### 우선순위
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service8.png)

### http://127.0.0.1:8888/ecommerce/default
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service9.png)

## Microservice에 적용
+ Dependencies 추가
  + spring-cloud-starter-config
  + spring-cloud-starter-bootstrap
    + or) spring.cloud.bootstrap.enabled=true
  + ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service10.png)
+ bootstrap.yml 추가
  + application.yml 보다 우선 순위가 높다
  + ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service11.png)

### Fetching config from server
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service12.png)

### Changed configuration values
+ 서버 재기동
+ Actuator refresh
  + Spring Boot Actuator
    + Application 상태, 모니터링
    + Metric 수집을 위한 Http End point 제공
    + ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service13.png)
+ Spring cloud bus 사용

## Spring Boot Actuator
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service14.png)
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service15.png)
+ properties 값 수정 후 반영 (commit)
+ http://[service ip]/actuator/refresh
+ 번거로운 작업으로 인해 Spring Cloud Bus를 사용
+ ![img.png](../../../../assets/img/spring-cloud-msa/Configuration-Service16.png)

