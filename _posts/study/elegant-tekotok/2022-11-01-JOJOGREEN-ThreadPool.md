---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 조조그린의 Thread Pool
date: '2022-11-01 00:00:00 +0900'
categories:
    - study
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
    + 문제점
      + Thread 생성비용이 크기 때문에 요청에 대한 응답시간이 늘어난다.
      + ![img.png](/assets/img/elegant-tekotok/ThreadPool.png)
        1. JAVA는 One-to-One Threading-Model로 Thread 생성한다.
        2. User Thread(Process의 스레드)생성시 OS Thread(OS 레벨의 스레드)와 연결해야한다.
        3. 새로운 Thread를 생성할 때 마다 OS Kernel의 작업이 필요하다.
        4. Thread는 생성 비용이 많이 든다.
        5. 작업 요청이 들어올 때 마다 Thread를 생성하면 최종적인 요청 처리 시간이 증가한다. 
