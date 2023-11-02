---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 로그인 처리2 - 필터, 인터셉터
date: '2023-11-01 00:00:01 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 예외 처리와 오류 페이지

# 예외 처리와 오류 페이지

* toc
{:toc}

## 서블릿 예외 처리 - 시작
+ 서블릿은 다음 2가지 방식으로 예외 처리를 지원한다
  + ```Exception``` (예외)
  + ```response.sendError(HTTP 상태 코드, 오류 메시지)```

