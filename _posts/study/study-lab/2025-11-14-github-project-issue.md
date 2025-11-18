---
layout: post
bigtitle: '깃헙 프로젝트와 이슈 정리하기'
subtitle: 
date: '2025-11-14 00:00:01 +0900'
categories:
    - study-lab
comments: true

---

# 깃헙 프로젝트와 이슈 정리하기

# 깃헙 프로젝트와 이슈 정리하기
* toc
{:toc}

## `.gitignore` 팁

`.gitignore` 파일은 Git이 추적하지 않아야 할 파일들을 정의합니다.
이것은 코드 외의 불필요한 파일들이 Git 저장소에 포함되지 않도록 방지합니다.

### 포함시키지 말아야 할 파일 예시

* **IDE/에디터 설정 파일**: `.vscode/`, `.idea/`, `*.sublime-project`, `*.code-workspace` 등
* **OS 메타 데이터 파일**: `.DS_Store`, `Thumbs.db` 등
* **빌드/컴파일 결과물**: `dist/`, `build/`, `*.class`, `*.o` 등
* **환경 설정 파일**: `.env`, `config.local.js` (보안 이유로 제외)

### 추천 툴

* [gitignore.io](https://www.toptal.com/developers/gitignore):
  사용하는 언어나 툴을 선택하면 자동으로 최적의 `.gitignore`를 생성해줍니다.

---


## Issues

이슈는 **작업 항목(Task)**, **버그**, **기능 요청(Feature Request)** 등을 기록하는 도구입니다.
모든 개발 업무를 **이슈 기반으로 관리**하면 협업과 기록에 큰 도움이 됩니다.

### 주요 기능

* **Labels**:
  우선순위, 타입(버그/기능 등), 상태(진행 중/대기 등)를 시각적으로 구분
  → `Edit labels`에서 커스터마이징 가능
* **Assignees**:
  각 이슈에 담당자를 지정하여 책임 명확화
* **Projects**:
  이슈를 칸반 보드로 관리 가능 (아래 Projects 항목 참조)
* **Milestones**와 연동 가능:
  릴리즈 또는 스프린트 단위로 이슈를 그룹화할 수 있음
* **템플릿 설정**:
  Issue 템플릿을 만들어 작성 가이드를 제공 가능 (`.github/ISSUE_TEMPLATE/` 폴더)


## Milestones

Milestone은 프로젝트의 **개발 목표 또는 마일스톤 단위 일정 관리**를 위한 기능입니다.
이를 통해 이슈들을 특정 시점(예: v1.0 릴리즈)에 맞게 정리할 수 있습니다.

### 활용 예

* `v1.0 배포`
* `Sprint 1`, `Sprint 2` 등의 반복 개발 주기
* 릴리즈 날짜와 이슈 완료율 확인 가능

---

## Pull Requests (PR)

Pull Request는 브랜치에서 완료된 작업을 메인 브랜치(main/dev 등)에 반영하기 위한 요청입니다.

### PR 프로세스 예시

1. 새 기능 개발 → `feature/login` 브랜치에서 작업
2. PR 생성 → `main` 또는 `develop` 브랜치로 머지 요청
3. **코드 리뷰** → 팀원들이 리뷰 및 피드백 제공
4. 리뷰 승인 후 Merge
5. 자동화된 테스트/CI 동작 확인

---


## Actions

GitHub Actions는 **CI/CD 파이프라인**을 구축하는 자동화 도구입니다.

### 주요 기능

* 코드 커밋 시 **자동 테스트 실행**
* PR 생성 시 **자동 리뷰 체크**
* `main` 브랜치 머지 시 **자동 배포**
* Lint, 포맷터, 테스트 스크립트 자동 실행 가능

### 예시 Workflow

```yaml
name: Node.js CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Use Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    - run: npm ci
    - run: npm test
```


## Projects

Projects는 GitHub의 **칸반 스타일 보드** 기능입니다.
이슈, PR 등을 보드에 연결해 시각적으로 프로젝트 상태를 관리할 수 있습니다.

### 활용법

* `To Do`, `In Progress`, `Done` 컬럼 구성
* 이슈 드래그 앤 드롭으로 진행 상태 변경
* PR 병합 시 자동으로 상태 업데이트 가능 (Workflows 설정)

### Projects v2 (beta)

* 더 유연한 필터링, 정렬, 자동화 기능
* SQL-like 필터링 및 커스텀 필드 지원

---

## Discussions

Discussions는 프로젝트 관련 **자유로운 소통 공간**입니다.
이슈와 달리 **문제 해결 목적이 아닌 토론/의견 공유**에 초점을 둡니다.

### 사용 예

* 기술 스택에 대한 논의
* 구조 개선 아이디어
* 개발 문화 제안
* 팀원 간 질의응답

---

## Wiki

GitHub Wiki는 프로젝트의 **공식 문서 공간**입니다.
Markdown 기반으로 문서를 작성하며 팀과 지식을 공유할 수 있습니다.

### 예시 문서

* 프로젝트 구조 설명
* API 문서
* 개발 환경 세팅 가이드
* 릴리즈 노트

> `.md` 파일을 GitHub Wiki로 직접 올리거나, 별도 관리하는 저장소를 연동할 수 있습니다.

---


