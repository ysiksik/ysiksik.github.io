---
layout: post
bigtitle: 'Spring Cloud로 개발하는 마이크로서비스 애플리케이션(MSA)'
subtitle: Service Discovery
date: '2023-02-23 00:00:00 +0900'
categories:
    - spring-cloud-msa
comments: true
---

# Service Discovery

# Service Discovery
* toc
{:toc}

## Spring Cloud Netflix Eureka
+ ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery1.png)

## EcommerceDiscoveryService
+ Dependencies
  + Spring Cloud Discovery > Eureka Server
+ pom.xml
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery2.png)
+ EcommerceApplication.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery3.png)
+ application.yml (or application.properties)
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery4.png)

~~~yaml

# 자신의 정보를 등록하는것을 방지
eureka:
  client:
    register-with-eureka: false
    fetch-registry: false

~~~

+ 실행 화면 
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery5.png)


## User Service
+ Eureka Discovery Service에 등록
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery6.png)
+ pom.xml
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery7.png)
+ Application.java
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery8.png)
+ application.yml
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery9.png)
  + eureka.client.fetch-registry: true
    + eureka 서버로부터 인스턴스들의 정보를 주기적으로 가져올 것인지를 설정하는 속성이다. true로 설정하면, 갱신 된 정보를 받겠다는 설정이다 
+ Scaling – 같은 서비스 추가 실행 #1
  + VM Options -> -Dserver.port=[다른포트]
+ Scaling - 같은 서비스 추가 실행 #2
  + $ mvn spring-boot:run -Dspring-boot.run.jvmArguments='-Dserver.port=9003'
+ Scaling - 같은 서비스 추가 실행 #3
  + mvn clean compile package
  + java -jar -Dserver.port=9004 ./target/user-service-0.0.1-SNAPSHOT.jar
+ Scaling – Random 포트 사용으로 같은 서비스 추가 실행
  + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery10.png)
  + 같은 서비스 명으로 인해 Eureka에 하나의 앱만 등록
  + application.yml에 instance 정보 등록
    + eureka.instance.instanceId
    + ![img.png](../../../../assets/img/spring-cloud-msa/Service-Discovery11.png)
