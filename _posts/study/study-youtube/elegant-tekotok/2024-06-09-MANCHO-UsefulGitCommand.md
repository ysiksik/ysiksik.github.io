---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 망쵸의 유용한 Git 명령어
date: '2024-06-09 00:00:02 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 망쵸의 유용한 Git 명령어
[https://youtu.be/jXtUUm92RiQ?si=xVDR_chzlClo-4AV](https://youtu.be/jXtUUm92RiQ?si=xVDR_chzlClo-4AV)

# 망쵸의 유용한 Git 명령어
* toc
{:toc}

## Git reset
+ Git reset 이전 커밋 상태로 되돌아 가게 해주는 명령어 이다
+ ```git reset --hard :``` 변경 사항을 삭제
+ ```git reset --mixed :``` 변경 사항을 unstaged 상태로 유지 (default)
+ ```git reset --soft :``` 변경 사항을 staged 상태로 유지 

## Git commit --amend
+ 가장 최근의 커밋을 수정할 수 있다 
+ 주로 커밋 메시지를 변경하거나 변경 사항을 추가할 때 사용
+ amend 옵션은 기존 커밋을 덮어 쓴다 이전 커밋을 수정하는 게 아니라 아예 삭제 했다가 새로 생성하는 것과 동일한 역할

## Git revert 
+ 특정 커밋의 변경 내용을 되돌릴 수 있다
+ revert 명령어 는 특정 커밋 의 변경 내용을 되돌리기 해주는 명령어
+ reset 과 amend 와 다른 점은 새로운 커밋을 생성 한다는 점이다

## Git reflog
+ Git reflog 를 실행해서 돌아가기 원하는 시점을 찾는다 그리고 깃 리셋 하드 옵션에 시점을 넣으면 해당 시점으로 로컬의 파일과 원격 메인 브랜치의 커밋이 모두 복구된다 

## 정리
+ Git reset은 이전 commit을 삭제한다
+ Git commit amend 는 이전 commit을 덮어 쓴다
+ Git revert는 특정 commit의 변경 내용을 되돌리는 새로운 commit을 생성한다
+ Git reflog는 변경 이력에 대한 로그를 확인할 수 있다
