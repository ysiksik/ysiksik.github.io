---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 젠슨의 AWS Private Subnet
date: '2026-04-14 00:00:01 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 젠슨의 AWS Private Subnet
[https://youtu.be/2xRJ5EYSEIw?si=mTS5eEjU4sb5NZsp](https://youtu.be/2xRJ5EYSEIw?si=mTS5eEjU4sb5NZsp)

# 젠슨의 AWS Private Subnet
* toc
{:toc}

---

## AWS Private Subnet: 왜 필요하고 어떻게 설계해야 할까

AWS에서 인프라를 설계할 때 가장 중요한 질문 중 하나는 이것이다.

**“이 서버를 외부에 노출해야 하는가?”**

대부분의 핵심 서버(DB, 내부 API, 인증 서버 등)는 외부에 노출될 필요가 없다. 오히려 노출되는 순간 공격 표면(Attack Surface)이 급격히 증가한다. 이 문제를 해결하기 위한 핵심 개념이 바로 **Private Subnet**이다.

발표에서도 Private Subnet은 “외부 인터넷과 직접 통신할 수 없는 독립적인 네트워크 공간”이라고 정의하며, 보안을 위해 필수적인 구조라고 설명한다.

## VPC와 Subnet부터 이해해야 하는 이유

Private Subnet을 제대로 이해하려면 먼저 VPC와 IP 구조를 이해해야 한다.

VPC(Virtual Private Cloud)는 AWS에서 제공하는 “내가 정의하는 가상 네트워크”다. 쉽게 말하면 클라우드 위에 나만의 데이터센터를 만드는 개념이다.

여기서 CIDR 블록이라는 개념이 등장한다.

예를 들어 `10.0.0.0/16` 이라는 CIDR은 전체 네트워크 범위를 의미한다. `/16`은 앞의 16비트가 네트워크 주소라는 뜻이며, 이 경우 약 65,536개의 IP를 사용할 수 있다.

이 VPC 내부의 IP를 다시 나누는 것이 Subnet이다.

예를 들어:

* `10.0.0.0/24` → 256개 IP
* `10.0.1.0/24` → 또 다른 256개 IP

이렇게 나누면 각 Subnet은 독립적인 네트워크 영역이 된다. 중요한 점은 **서브넷 간 IP는 절대 겹치면 안 된다**는 것이다.

## Public Subnet vs Private Subnet

이제 핵심 차이를 보자.

* Public Subnet: Internet Gateway와 연결됨 → 외부 인터넷과 직접 통신 가능
* Private Subnet: Internet Gateway와 연결되지 않음 → 외부와 직접 통신 불가

즉, Private Subnet은 구조적으로 “외부에서 접근할 수 없는 네트워크”다.

## Private Subnet이 반드시 필요한 이유

발표에서 나온 비유가 굉장히 직관적이다.

대통령의 집 주소가 공개되어 있으면 누구나 공격할 수 있다. 하지만 집 위치를 숨기고, 대신 비서가 있는 외부 접점만 노출하면 어떻게 될까? 공격자는 비서까지만 접근할 수 있고, 실제 핵심 대상은 보호된다.

이 구조를 시스템으로 바꾸면 다음과 같다.

* Private Subnet: 대통령 (핵심 서버)
* Public Subnet: 비서 (로드밸런서, Bastion)
* 외부 사용자: 클라이언트

이 구조의 핵심 가치는 하나다.

**“핵심 리소스를 외부에서 보이지 않게 만든다.”**

실무에서는 다음과 같은 서버들이 반드시 Private Subnet에 들어가야 한다.

* DB 서버
* 내부 API 서버
* 인증/권한 서버
* 배치/백엔드 처리 서버

## Private Subnet의 요청 흐름

Private Subnet은 외부와 직접 통신할 수 없기 때문에 요청 흐름이 일반 구조와 다르다.

### 1. 인바운드 요청 (외부 → 내부)

클라이언트는 Private IP를 직접 알 수도 없고 접근할 수도 없다. 그래서 반드시 Public Subnet을 거쳐야 한다.

흐름은 이렇게 된다.

1. 클라이언트 → Public IP (로드밸런서)
2. 로드밸런서 → Private Subnet 서버

즉, 외부는 항상 Public Subnet까지만 접근 가능하다.

이때 로드밸런서 대신 Nginx를 사용할 수도 있다.

### 2. 아웃바운드 요청 (내부 → 외부)

문제는 반대 방향이다.

Private Subnet 서버는 외부 API 호출이 불가능하다. (인터넷 연결이 없기 때문)

예를 들어:

* 결제 API 호출 (토스)
* OAuth 로그인 (카카오)

이런 요청은 반드시 외부로 나가야 한다.

이때 사용하는 것이 **NAT Gateway**다.

동작은 다음과 같다.

1. Private IP → NAT Gateway
2. NAT Gateway가 Public IP로 변환
3. Internet Gateway → 외부 API

즉, NAT는 “IP 변환기” 역할을 한다.

## Private Subnet에 접근하는 방법

Private Subnet은 외부에서 직접 접근할 수 없기 때문에, 개발자도 바로 접속할 수 없다.

그래서 중간 접근 방식이 필요하다.

## 1. Bastion Host 방식

가장 전통적인 방식이다.

구조:

* Public Subnet에 Bastion 서버 생성
* 개발자는 Bastion에 SSH 접속
* Bastion을 통해 Private 서버 접속

특징:

* SSH (22번 포트) 필요
* 키 페어 관리 필요
* 접근 흐름이 2단계

발표에서도 Bastion은 “중간 관문 역할을 하는 서버”라고 설명한다.

장점:

* 비용이 저렴
* 구조가 단순

단점:

* 키 관리 복잡
* SSH 포트 노출 → 보안 리스크

## 2. Session Manager 방식

AWS가 제공하는 더 현대적인 방식이다.

특징:

* SSH 필요 없음
* 키 페어 필요 없음
* AWS 콘솔에서 바로 접속

동작 원리는 조금 흥미롭다.

EC2 내부의 SSM Agent가 AWS 서비스(Session Manager)와 연결되면서, 콘솔에서 터널링 형태로 접속이 이루어진다.

하지만 문제는 하나 있다.

Private Subnet은 외부와 단절되어 있기 때문에 Session Manager와 통신할 수 없다.

그래서 두 가지 방법이 필요하다.

### 방법 1: NAT Gateway 사용

* Private → NAT → Internet → AWS 서비스

### 방법 2: VPC Endpoint 사용 (더 좋은 방법)

VPC Endpoint는 AWS 서비스에 “인터넷 없이” 접근할 수 있도록 해준다.

즉:

* Private Subnet → VPC Endpoint → AWS 서비스

이 방식의 장점은 명확하다.

* NAT 필요 없음
* 인터넷 경유 없음
* 보안 강화

발표에서도 VPC Endpoint를 사용하는 방식이 더 좋은 방법이라고 강조한다.

## Bastion vs Session Manager 선택 기준

둘은 철학 자체가 다르다.

### Bastion Host

* 장점: 저렴
* 단점: 키 관리 + 포트 노출

### Session Manager

* 장점:

    * SSH 포트 제거
    * 키 관리 없음
    * 접근 제어 쉬움
* 단점:

    * NAT 또는 Endpoint 필요
    * 초기 설정 복잡
    * 비용 증가

발표에서도 Session Manager가 더 안전하지만 비용과 설정 부담이 있다는 점을 명확히 언급한다.

## 실무에서의 아키텍처 정리

실무에서 많이 사용하는 구조를 정리하면 다음과 같다.

* Public Subnet

    * ALB / Nginx
    * Bastion (optional)

* Private Subnet

    * Application Server
    * DB

* 외부 연결

    * NAT Gateway (아웃바운드)
    * VPC Endpoint (AWS 서비스 연결)

이 구조의 핵심은 다음 두 가지다.

1. 외부 접근은 항상 Public → Private로 제한
2. 내부 서버는 절대 직접 노출되지 않음

## 마무리

Private Subnet은 단순한 네트워크 구성이 아니다.
**보안 아키텍처의 핵심이다.**

정리하면 핵심은 이렇다.

* Private Subnet은 외부와 직접 통신하지 않는다
* 인바운드는 Load Balancer를 통해서만 들어온다
* 아웃바운드는 NAT를 통해서만 나간다
* 개발자 접근은 Bastion 또는 Session Manager를 사용한다
* 가능하다면 VPC Endpoint로 보안을 강화한다

결국 이 구조의 본질은 하나다.

**“중요한 것은 외부에 노출하지 않는다.”**

이 원칙 하나만 제대로 지켜도, 인프라 보안 수준은 크게 올라간다.

