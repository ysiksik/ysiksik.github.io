---
layout: post
bigtitle: '깃 브랜치 전략 세우기'
subtitle: 
date: '2025-11-18 00:00:01 +0900'
categories:
    - study-lab
comments: true

---

# 깃 브랜치 전략 세우기

# 깃 브랜치 전략 세우기
* toc
{:toc}

## 1. 깃 브랜치를 운영하는 방법론

### Gitflow

Gitflow는 **master, develop, feature, release, hotfix** 브랜치를 기반으로 운영하는 전통적인 워크플로우다. 릴리스 주기가 명확하거나, 여러 명이 병렬로 기능을 개발하는 프로젝트에 적합하다.

### GitHub Flow

GitHub Flow는 **main(master) + feature 브랜치**만 사용하는 단순한 구조의 브랜치 전략이다. 지속적인 배포(continuous deployment) 환경이나, 작은 기능 단위로 빠르게 릴리스하는 프로젝트에서 주로 사용된다.

---

## 2. 브랜치 전략을 세우는 이유

### 협업 중 발생하는 부작용 해결

여러 개발자가 하나의 소스를 수정하면서 생길 수 있는 문제(충돌, 품질 저하, 릴리스 혼선)를 방지한다.

### 협업을 위한 규칙 정의

브랜치의 역할·기준을 정하면 코드 품질 관리와 협업 효율이 높아진다.

### 전략 수립 시 고려 요소

* 해당 브랜치는 제품으로 배포 가능한가?
* 빌드 실패를 허용하는가?
* 테스트 실패를 허용하는가?
* 임시 운영 브랜치인가? 일정 주기로 삭제되는가?

---

## 3. Gitflow 워크플로우 상세 설명

Gitflow는 **master**가 최종 제품 상태를 유지하고, **develop**이 기능 개발의 중심이 된다.
각 기능별 feature 브랜치를 develop 기준으로 분기하고, 완성된 기능들은 develop으로 병합된다.

### 전체 흐름 개요

* `master`: 제품으로 배포 가능한 상태. CI/CD의 기준이 되는 브랜치.
* `develop`: 기능 개발이 이루어지는 메인 브랜치.
* `feature/*`: 개별 기능 개발용 브랜치.
* `release/*`: 릴리스를 준비하기 위한 브랜치. 버그 수정·문서 수정 등만 진행.
* `hotfix/*`: 배포 후 긴급 수정이 필요할 때 master에서 분기해 수정.

### Develop 브랜치 준비

```
$ git branch develop
$ git push -u origin develop
```

다른 개발자는 다음과 같이 clone 후 develop 브랜치를 체크아웃한다.

```
$ git clone ssh://user@host/...repo.git
$ git checkout -b develop origin/develop
```

### Feature 브랜치 작업 흐름

기능 개발은 develop을 기준으로 분기한다.

```
$ git checkout -b some-feature develop
```

기능 개발 → 커밋 반복
작업 완료 후 develop에 병합:

```
$ git pull origin develop
$ git checkout develop
$ git merge some-feature
$ git push
$ git branch -d some-feature
```

### Release 브랜치

기능 개발 중 일부가 릴리스 대상이 될 때 별도로 release 브랜치를 생성한다.

```
$ git checkout -b release-0.1 develop
```

릴리스 준비 작업(최종 QA, 문서, 버그 수정 등)을 마친 후:

```
$ git checkout master
$ git merge release-0.1
$ git push

$ git checkout develop
$ git merge release-0.1
$ git push

$ git branch -d release-0.1
```

릴리스 태그 부여:

```
$ git tag -a 0.1 -m "Initial public release" master
$ git push --tags

```

release 브랜치에서는 최종 QA, 버그 수정, 문서 정리 등 **배포 직전 안정화 작업만** 진행한다.

### 🔍 릴리스 브랜치와 태그를 사용하는 이유

릴리스 브랜치는 이번 배포에 포함될 기능의 **범위를 확정하고 안정성을 확보하는 단계**다.
develop에는 여러 기능이 섞여 있을 수 있지만, release 브랜치를 만들면 이번 릴리스에 포함할 코드만 고정된다.

release 브랜치 작업이 완료되면 master에 병합하고, 그 시점에 **태그(tag)** 를 부여한다.
태그는 아래와 같은 역할을 한다:

* **운영에 배포된 공식 버전의 기준점**
* **롤백 시점 확보** – 문제가 생기면 v0.1 등으로 정확히 돌아갈 수 있음
* **CI/CD 파이프라인에서 아티팩트 생성 기준**
* **배포 이력·릴리스 노트 관리**
* release 브랜치 QA 결과와 master 배포 커밋을 **정확히 일치**시키는 장치

Gitflow에서는 이 흐름이 사실상 필수적인 릴리스 절차로 정착되어 있다.

### Hotfix 브랜치

배포 후 발견된 버그를 빠르게 수정해야 할 때:

```
$ git checkout -b issue-001 master
```

수정 후 master와 develop에 모두 병합:

```
$ git checkout master
$ git merge issue-001
$ git push

$ git checkout develop
$ git merge issue-001
$ git push

$ git branch -d issue-001
```

---

## 4. GitHub Flow 워크플로우 상세 설명

GitHub Flow는 다음의 6단계로 매우 단순하다.

1. main(master) 브랜치는 항상 배포 가능한 상태로 유지
2. 새로운 기능은 feature 브랜치를 생성해서 작업
3. 커밋 후 원격 저장소에 push
4. Pull Request를 생성해 코드 리뷰 진행
5. 승인되면 main에 병합
6. 병합 즉시 배포(또는 자동 배포)

### 특징

* 병합 후 배포를 전제로 하기 때문에 작은 기능 단위로 짧은 루프를 반복하기 좋다.
* 별도의 develop·release 브랜치가 필요 없다.
* CI 환경에서 자동 테스트/빌드를 기반으로 안정성을 유지한다.

### 사용 예시

```
$ git checkout -b feature/comment
$ git push origin feature/comment

# GitHub에서 Pull Request 생성 → 리뷰 → merge
```

아래는 **현재 작성한 문서 흐름을 그대로 유지하면서**, 요청한
**“develop에 여러 기능이 섞여 있을 때 특정 기능만 배포해야 하는 경우”**를 자연스럽게 이어서 추가한 문서 내용이다.

이미 있는 구조와 톤에 맞춰 **섹션 5**로 넣으면 가장 자연스럽다.

필요하면 더 확장된 예시나 그림도 제작해줄 수 있어.

---

---

## 5. 특정 기능만 선택적으로 배포해야 하는 경우의 전략

실제 협업 환경에서는 `develop` 또는 `main` 브랜치에 여러 기능이 함께 누적되어 있는 경우가 많다. 이때 **그 중 특정 기능만 운영(master)에 배포해야 하는 상황**이 발생할 수 있다.
브랜치 전략에 따라 선택할 수 있는 대응 방식은 아래와 같다.

---

### 5.1 Gitflow에서의 선택적 배포

Gitflow는 구조가 명확하기 때문에 선택적 배포가 필요할 때 몇 가지 안정적인 해결책을 사용할 수 있다.

#### (1) Release 브랜치에서 필요한 기능만 Cherry-pick (권장)

릴리스를 위한 브랜치를 만든 뒤, 이번 배포에 포함할 기능만 선택해서 cherry-pick 하는 방식이다.

```
$ git checkout -b release-0.2 develop
$ git cherry-pick <commit-id-of-feature1>
$ git cherry-pick <commit-id-of-feature2>
```

이후 QA 완료 → master/dev에 병합.

**장점**

* Gitflow 철학과 가장 자연스럽게 맞는다.
* develop에는 다른 기능이 섞여 있어도 상관 없다.
* 릴리스 스코프를 명확히 관리할 수 있다.

**단점**

* cherry-pick 과정에서 충돌 가능성 있음.

---

#### (2) Feature 브랜치를 master로 직접 병합 (비권장, 긴급 시만 가능)

```
$ git checkout some-feature
$ git rebase master
$ git checkout master
$ git merge some-feature
```

**주의:** develop 브랜치와 master의 히스토리가 달라져 관리가 복잡해질 수 있기 때문에 긴급한 상황에서만 고려한다.

---

#### (3) Feature Toggle(기능 토글) 사용

코드 레벨에서 기능 활성화 여부를 제어하는 방식이다.

* develop에 여러 기능이 합쳐져 있어도 무관하다.
* 운영에서는 해당 기능의 toggle만 OFF로 두면 된다.

**장점**

* 브랜치 전략과 독립적으로 기능을 제어할 수 있다.
* 대규모 서비스(Netflix, GitHub, Google 등)에서 표준적으로 사용.

---

### 5.2 GitHub Flow에서의 선택적 배포

GitHub Flow는 main이 배포 기준이므로 기능 단위 배포가 기본 구조에 강하게 녹아 있다.

#### (1) 기능 단위 PR 병합

GitHub Flow에서는 원래 **한 기능 → 한 PR → 바로 배포** 흐름이므로 선택적 배포가 가장 쉽다.

PR을 merge하지 않는 기능은 자동으로 배포되지 않는다.

---

#### (2) 임시 Release 브랜치 + Cherry-pick (하이브리드 방식)

GitHub Flow 환경에서도 release 브랜치를 잠시 도입하면 특정 기능만 포함하여 배포할 수 있다.

```
$ git checkout -b release-2025-01
$ git cherry-pick <commit-id>
$ git push
```

이후 PR 또는 병합을 통해 운영 배포.

---

#### (3) Feature Toggle 활용

GitHub Flow는 배포 주기가 짧기 때문에 Feature Toggle과 매우 궁합이 좋다.
배포와 코드 공개 시점을 완전히 분리할 수 있어 선택적 기능 노출이 자연스럽다.

---

## Reference

* [https://github.com/nvie/gitflow](https://github.com/nvie/gitflow)
* [https://docs.github.com/en/get-started/quickstart/github-flow](https://docs.github.com/en/get-started/quickstart/github-flow)

---



