---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 스프링 타입 컨버터
date: '2023-11-13 00:00:01 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 스프링 타입 컨버터

# 스프링 타입 컨버터

* toc
{:toc}

## 스프링 타입 컨버터 소개
+ 문자를 숫자로 변환하거나, 반대로 숫자를 문자로 변환해야 하는 것 처럼 애플리케이션을 개발하다 보면 타입을 변환해야 하는 경우가 상당히 많다.

### 문자 타입을 숫자 타입으로 변경

~~~java

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

import javax.servlet.http.HttpServletRequest;

@RestController
public class HelloController {
    @GetMapping("/hello-v1")
    public String helloV1(HttpServletRequest request) {
        String data = request.getParameter("data"); //문자 타입 조회
        Integer intValue = Integer.valueOf(data); //숫자 타입으로 변경
        System.out.println("intValue = " + intValue);
        return "ok";
    }
}

~~~

+ ```String data = request.getParameter("data")``` 
+ HTTP 요청 파라미터는 모두 문자로 처리된다. 따라서 요청 파라미터를 자바에서 다른 타입으로 변환해서 사용하고 싶으면 다음과 같이 숫자 타입으로 변환하는 과정을 거쳐야 한다.
  + ```Integer intValue = Integer.valueOf(data)```

### @RequestParam 사용

~~~java

@GetMapping("/hello-v2")
public String helloV2(@RequestParam Integer data) {
 System.out.println("data = " + data);
 return "ok";
}

~~~

+ 스프링이 제공하는 @RequestParam 을 사용하면 이 문자 10을 Integer 타입의 숫자 10으로 편리하게 받을 수 있다. 
+ 이것은 스프링이 중간에서 타입을 변환해주었기 때문이다.
+ 이러한 예는 ```@ModelAttribute``` , ```@PathVariable``` 에서도 확인할 수 있다.

+ 스프링의 타입 변환 적용 예
  + 스프링 MVC 요청 파라미터
    + ```@RequestParam , @ModelAttribute , @PathVariable```
  + ```@Value``` 등으로 YML 정보 읽기
  + XML에 넣은 스프링 빈 정보를 변환
  + 뷰를 렌더링 할 때

+ 스프링과 타입 변환
  + 스프링이 중간에 타입 변환기를 사용해서 타입을 ```String``` -> ```Integer``` 로 변환해주었기 때문에 개발자는 편리하게 해당 타입을 바로 받을 수 있다.
  + 앞에서는 문자를 숫자로 변경하는 예시를 들었지만, 반대로 숫자를 문자로 변경하는 것도 가능하고, Boolean 타입을 숫자로 변경하는 것도 가능하다.

### 컨버터 인터페이스
+ 스프링은 확장 가능한 컨버터 인터페이스를 제공한다
+ 개발자는 스프링에 추가적인 타입 변환이 필요하면 이 컨버터 인터페이스를 구현해서 등록하면 된다.
+ 이 컨버터 인터페이스는 모든 타입에 적용할 수 있다. 필요하면 X -> Y 타입으로 변환하는 컨버터 인터페이스를 만들고, 또 Y -> X 타입으로 변환하는 컨버터 인터페이스를 만들어서 등록하면 된다.
+ 예를 들어서 문자로 "true" 가 오면 Boolean 타입으로 받고 싶으면 String Boolean 타입으로 변환되도록 컨버터 인터페이스를 만들어서 등록하고, 반대로 적용하고 싶으면 Boolean String 타입으로 변환되도록 컨버터를 추가로 만들어서 등록하면 된다.

> **참고** 
>
> 과거에는 PropertyEditor 라는 것으로 타입을 변환했다. PropertyEditor 는 동시성 문제가 있어서
> 타입을 변환할 때 마다 객체를 계속 생성해야 하는 단점이 있다. 지금은 Converter 의 등장으로 해당
> 문제들이 해결되었고, 기능 확장이 필요하면 Converter 를 사용하면 된다.

