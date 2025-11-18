---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 조조그린의 Thread Pool
date: '2022-11-01 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 조조그린의 Thread Pool
[https://youtu.be/um4rYmQIeRE](https://youtu.be/um4rYmQIeRE)

# 조조그린의 Thread Pool
* toc
{:toc}

## Program / Process / Thread
+ Program
  + 어떤 목적을 달성하기 위해서 컴퓨터의 동작들을 하나로 모아 놓은 것
+ Process
  + 컴퓨터가 현재 실행중인 프로그램 
+ Thread
  + CPU Core의 실행 단위 
  + CPU Core가 Thread 단위로 작업을 처리한다.
  + Cpu Core의 실행 단위 Unit Of Execution
  + Process의 작업을 Thread 단위로 나눈다.
  + Thread를 사용함으로서 하나의 Process에서 두가지 이상의 작업을 동시에 실행 가능하다. 

## 단순히 Thread 만 사용해서 동시에 여러 작업을 실행시킬 수 있는 프로그램을 만들 수 있을까?
+ Thread를 단순하게 사용할 때 
  + 요청이 올 때마다 새로운 쓰레드를 생성해 가지고 작업을 처리하고 처리가 끝나면 쓰레드를 없애는 방식으로 동작하는 프로세스를 사용하면.
  + Thread 생성비용이 크기 때문에 요청에 대한 응답시간이 늘어난다.
    + ![img.png](/assets/img/elegant-tekotok/ThreadPool.png) 
  >  JAVA는 One-to-One Threading-Model로 Thread 생성한다. ->
  >  User Thread(Process의 스레드)생성시 OS Thread(OS 레벨의 스레드)와 연결해야한다. ->
  >  새로운 Thread를 생성할 때 마다 OS Kernel의 작업이 필요하다. ->
  >  Thread는 생성 비용이 많이 든다. ->
  >  작업 요청이 들어올 때 마다 Thread를 생성하면 최종적인 요청 처리 시간이 증가한다.
  
  + Thread가 너무 많으면 여러가지 문제를 발생시킨다. 
  > Process의 처리 속도보다 빠르게 요청이 쏟아져 들어요면 ->
  > 새로운 Thread가 무제한적으로 계속 생성된다. ->
  > Thread가 많아 질수록 메모리를 차지하고 Context-Switching이 더 자주 발생한다. ->
  > 메모리 문제가 발생할 수 있고 CPU 오버헤드가 증가한다.

## 단순히 Thread만 사용해서는 문제가 많다, 방법이 없을까? 
+ Thread Pool 이란?
  + Thread를 허용된 개수 안에서 사용하도록 제한하는 시스템 
  + ![img.png](/assets/img/elegant-tekotok/ThreadPool2.png)
    + 간단하게 쓰레드 풀은 두 가지 요소로 구성되어 있는데 첫 번째가 쓰레드 풀에서 쓰레드 작업을 할 쓰레드들 그리고 작업 큐이다. 
    + 쓰레드 풀에 작업 요청이 들어오면 작업 큐에 작업들이 쌓이게 되고 쓰레드 풀 안의 쓰레드들이 작업 큐에 있는 작업을 빼서 처리하게 된다.
    + 쓰레드 풀 특징은 정해진 양만큼의 쓰레드를 사용하는 것도 특징이지만 한 번 사용된 쓰레드가 작업이 끝났을 때 없어지지 않고 재사용이 가능하다는 것도 특징이다. 
  + Thread Pool 을 사용하면 두가지 문제를 해결 할 수 있다.
    + 작업 요청이 들어올 때 마다 Thread를 생성하면 최종적인 요청 처리 시간이 증가한다.
      + 미리 만들어 놓은 Thread를 재사용할 수 있기 때문에 새로운 Thread를 생성하는 비용을 줄일 수 있다.
    + 메모리 문제가 발생할 수 있고, CPU 오버헤드가 증가한다.
      + 사용할 Thread를 개수를 제한하기 때문에 무제한적으로 스레드가 생성되지 않아서 방지 가능하다. 
+ 여러개의 작업을 동시에 처리하면서 안정적으로 처리하고 싶을 때 Thread Pool은 효과적이다. 

## JAVA의 Thread Pool
+ ![img.png](/assets/img/elegant-tekotok/ThreadPool3.png)
  + ThreadPoolExecutor라는 클래스를 이용해가지고 쓰레드 풀을 구현
  + maximumPoolSize는 쓰레드 풀에서 사용할 수 있는 최대 쓰레드 개수를 의미하는데 항상 이만큼 유지하고 있지 않고 있다.
  왜냐하면 요청이 적을 때는 많은 양의 쓰레드를 계속 가지고 있을 이유가 없기 때문에 이거를 최적화하는 기능들이 들어가 있는데 만약에 작업이 없고 쓰레드 개수가 최대이면 
  keepAliveTime 시간 이후로도 계속 요청이 없으면 그 말은 work queue하는 작업이 없다는 뜻이다 그러면 쓰레드는 없어진다. 무한히 없어지는게 아니라 corePoolSize만큼만 없어진다.
  + 쓰레드 풀에서는 최대 maximumPoolSize 만큼의 쓰레드를 가질 수 있고 최소 corePoolSize의 만큼 쓰레드는 항상 유지한다는 걸 의미한다. 

## Web Server
+ ![img.png](/assets/img/elegant-tekotok/ThreadPool4.png)
  + 웹 서버라는 것의 특성상 기본적으로 동식적인 요청을 동시적으로 처리해 내야되는 어플리케이션적인 특징을 가지고 있기 때문에 많은 웹 서버들이 쓰레드 풀 시스템을 사용하고 있다.

### Tomcat의 Thread Pool
+ SpringBoot의 내장 Servlet Container 중 하나
+ SpringBoot 최신 버전에는 Tomcat9 버전을 사용 중
+ JAVA 기반의 WAS
+ JAVA의 Thread Pool 클래스와 매우 유사한 자체 스레드 풀 구현체를 가지고 있다.
+ org.apache.tomcat.util.threads.ThreadPoolExecutor
+ ![img.png](/assets/img/elegant-tekotok/ThreadPool5.png)
  + Max-Connections
    + Tomcat이 최대로 동시에 처리할 수 있는 Connection의 개수 
    + Web 요청이 들어오면 Tomcat의 Connector가 Connection을 생성하면서 요청된 작업을 Thread Pool의 Thread 에 연결한다.
+ ![img.png](/assets/img/elegant-tekotok/ThreadPool6.png)
  + Accept-Count
    + Max-Connections 이상의 요청이 들어왔을 때 사용하는 대기열 Queue의 사이즈
    + Max-Connections 와 Accept-Count 이상의 요청이 들어왔을 때 추가적으로 들어오는 요청은 거절될 수 있다. 

## 어떻게 하면 Thread Pool을 잘 설정해서 Server Application 을 효과적으로 구현할 수 있을까?

### SpringBoot 설정을 통한 Tomcat Thread Pool 설정
+ server.tomcat.threads.max
  + Thread Pool 에서 사용할 최대 스레드 개수, 기본 갑은 200
  + 서버 어플리케이션이 동시에 처리할 수 있는 요청 개수와 관련있다. 
  + 요청 수에 비해 너무 많게 설정
    + 놀고 있는 스레드가 많아져서 비효율 발생
  + 너무 적게 설정
    + 동시 처리 요청수가 줄어든다, 평균응답시간, TPS 감소
  + 기본적으로 Thread가 많아지면 CPU 오버헤드와 메모리에서 문제가 생길 수 있다는걸 고려해야 한다.
+ server.tomcat.threads.min-spare
  + Thread Pool 에서 최소한 유지할 Thread 개수, 기본 값은 10
  + 너무 많이 설정
    + Thread Pool 이 상항 유지해야 할 Thread 수가 너무 많아진다.
  + 적절하게 설정
    + 적은 수의 요청에서 새로운 스레드를 만들 필요없이 요청을 효과적으로 처리할 수 있다.
  + 잘못 설정했을 때 사용하지 않는 Thread 가 메모리를 차지하면서 비효율을 발생시킨다는걸 고려해야한다.
+ server.tomcat.threads.max-connections
  + 동시에 처리할 수 있는 최대 Connection의 개수, 기본 값은 8192
  + 사실상 서버의 실질적인 동시 요청 처리 개수라고 생각할 수 있다. 
  + Non-Blocking IO 에서는 Thread Pool 의 최대 스레드 개수보다 많은 양의 Connection 을 유지할 수 있다.
  + Non-Blocking IO 에서는 최대 Thread 개수보다 적거나 같은 수의 max-connections를 설정하는 것은 비효율적인 설정이 될 수 있다. 
  + Blocking IO : 1 Connection, 1 Thread
  + Non-Blocking IO : N Connection, 1 Thread
    + from Tomcat 8 at later
+ server.tomcat.accept-count
  + max-connections 이상의 요청이 들어왔을 때 사용하는 요청 대기열 Queue 의 사이즈 , 기본 값은 100
  + 너무 크게 설정
    + 대기열이 커지면서 메모리 문제를 유발할 수 있다.
  + 너무 작게 설정
    + 요청이 몰렸을 때 들어오는 요청들을 거절해 버릴 수 있다.
  + 이 설정을 하는 이유중 하나는 부적절하거나 잘못된 요청이 한번에 너무 많이 들러와 서버에 장애를 발생시키는것을 방지하기 위함도 있다.

## 우리가 Thread Pool 설정을 해야하는 이유
+ Thread Pool 은 응답시간과 TPS에 영향을 주는 하나의 요소이다.
+ 잘 조정된 Thread Pool 은 시스템의 성능을 끌어내고 안정적인 어플리케이션 운용을 가능하게 한다.
+ 부적절하게 설정된 Thread Pool 은 병목 현상, CPU 오버헤드, 메모리 문제를 유발 할 수 있다. 

