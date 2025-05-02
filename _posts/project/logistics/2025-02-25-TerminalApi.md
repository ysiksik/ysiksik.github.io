---
layout: post
bigtitle: 'Terminal Schedule API'
subtitle: Terminal Schedule API
date: '2025-02-25 00:00:01 +0900'
categories:
- logistics
comments: true
---

# TERMINAL Schedule API

# TERMINAL Schedule API
* toc
{:toc}


## 1. 프로젝트 개요
+ **프로젝트명:** 터미널 스케줄 API 개발
+ **역할:** 백엔드 개발자
+ **프로젝트 목적:**
  + 터미널의 선박 입출항 및 작업 스케줄 데이터를 클라이언트에게 제공
  + API 기반 데이터 판매 모델 구축을 통해 수익 창출
  + REST API를 통해 클라이언트 및 내부 서비스와 연동하여 실시간 정보 제공
+ **기술 스택:**
  + **백엔드:** Java, Spring Boot
  + **API 설계:** RESTful API, REST Docs 문서화
  + **데이터베이스:** MSSQL, Redis
  + **배포 및 운영:** Azure DevOps
  + **보안:**  Spring Security, API Key 인증 
  + **문서:** rest docs, swagger

## 2. 터미널 API 주요 기능

### 1. 터미널 목록 조회 
- 터미널 목록을 제공하는 API
- 터미널 코드, 터미널명, 항구 정보(Port Name, Port Code) 포함
- 관리자(Admin) 및 클라이언트(Client) 권한에 따라 데이터 접근 범위 설정  


### 2. 터미널 스케줄 조회 (Client & Admin)
- 터미널에 입항/출항하는 선박 스케줄 정보 제공
- 검색 조건: 터미널 코드, 선박 ID, 페이지 정보 (페이징 지원)
- 응답 데이터: 터미널 코드, 선박명, 항구 코드, 출항 일정(ETD), 도착 일정(ETA), 작업 일정
- 비즈니스 목적:
  + 클라이언트에게 데이터 판매
  + 터미널 운영사 및 선사와 연동하여 데이터 활용 확대  

### 3. 터미널 작업 현황 조회 (Admin Only)
- 각 터미널에서 진행 중인 선박 작업 상태 제공
- 선박별 하역(loading/unloading) 진행률 및 완료 상태 제공
- API 호출 시 작업 스케줄이 실시간으로 업데이트됨  

### 4. 터미널 스케줄 다운로드 API
- 선박 스케줄 데이터를 CSV 또는 Excel 파일로 다운로드 가능
- 터미널 코드, 선박명, 입출항 시간 포함
- 페이징 정보가 없을 경우 전체 데이터를 제공하여 데이터 활용성 증가  

## 3. API 보안(Security) 적용 사항

### Spring Security 적용
- API 요청에 대한 인증 및 권한 부여 처리
- Client & Admin 사용자 권한 구분
- 관리자(Admin) 전용 API와 클라이언트(Client) API를 별도로 관리하여 데이터 접근 제한  

### API Key 인증 적용
- 각 클라이언트별 고유 API Key 발급 및 사용 로그 모니터링
- Unauthorized 요청 차단 및 보안 로깅  

## 4. API 아키텍처 및 데이터 흐름
- 데이터 수집: 터미널별 API/FTP에서 데이터를 가져와 데이터베이스에 저장
- 배치 처리: 정해진 주기마다 최신 스케줄 데이터를 자동 업데이트
- API 제공: 클라이언트 요청 시 데이터를 조회하여 JSON 응답
- 데이터 최적화: Redis를 활용하여 API 응답 속도를 최적화  

## 5. API 문서화 (Swagger & REST Docs 병행 사용)
### Swagger UI 적용
- 개발자가 API를 쉽게 테스트하고 활용할 수 있도록 Swagger UI 제공
- API 요청 및 응답 형식 자동 생성
- API Key 인증 방식도 Swagger를 통해 설명

### REST Docs 적용 (Spring REST Docs 기반)
- Swagger가 개발용이라면, REST Docs는 실제 서비스 운영 및 클라이언트용 API 문서 제공
- HTML 기반 정적 문서 생성하여 클라이언트에게 API 사용법을 명확히 안내
- API 변경 사항이 자동 반영되므로 유지보수 용이

## 6. 프로젝트 성과 및 기여도
+ Terminal 스케줄 API 구축으로 매출 채널 확보
+ 외부 고객사 2곳 도입 문의 및 기능 테스트 진행
+ Redis 도입으로 평균 응답 속도 약 40% 향상
+ API Key 기반 권한 분리로 보안 및 서비스 안정성 강화
+ Swagger & REST Docs 기반 API 문서 자동화로 개발·운영 협업 효율 개선
