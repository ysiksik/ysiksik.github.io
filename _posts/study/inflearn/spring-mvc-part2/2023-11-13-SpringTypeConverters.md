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

## 타입 컨버터 - Converter
+ 타입 컨버터를 사용하려면 ```org.springframework.core.convert.converter.Converter``` 인터페이스를 구현하면 된다. 

> **주의**
> 
> Converter 라는 이름의 인터페이스가 많으니 조심해야 한다.
> org.springframework.core.convert.converter.Converter 를 사용해야 한다.

+ 컨버터 인터페이스

~~~java

package org.springframework.core.convert.converter;
public interface Converter<S, T> {
 T convert(S source);
}

~~~

### 문자를 숫자로 변환하는 타입 컨버터

~~~java

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.convert.converter.Converter;

@Slf4j
public class StringToIntegerConverter implements Converter<String, Integer> {
  @Override
  public Integer convert(String source) {
    log.info("convert source={}", source);
    return Integer.valueOf(source);
  }
}

~~~

+ ```String``` -> ```Integer``` 로 변환하기 때문에 소스가 String 이 된다. 이 문자를 ```Integer.valueOf(source)``` 를 사용해서 숫자로 변경한 다음에 변경된 숫자를 반환하면 된다.

### 숫자를 문자로 변환하는 타입 컨버터

~~~java

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.convert.converter.Converter;

@Slf4j
public class IntegerToStringConverter implements Converter<Integer, String> {
  @Override
  public String convert(Integer source) {
    log.info("convert source={}", source);
    return String.valueOf(source);
  }
}

~~~

+ 이번에는 숫자를 문자로 변환하는 타입 컨버터이다. 앞의 컨버터와 반대의 일을 한다. 이번에는 숫자가 입력되기 때문에 소스가 ```Integer``` 가 된다. ```String.valueOf(source)``` 를 사용해서 문자로 변경한 다음 변경된 문자를 반환하면 된다.

### 사용자 정의 타입 컨버터
+ 127.0.0.1:8080 과 같은 IP, PORT를 입력하면 IpPort 객체로 변환하는 컨버터

~~~java

import lombok.EqualsAndHashCode;
import lombok.Getter;

@Getter
@EqualsAndHashCode
public class IpPort {
  private String ip;
  private int port;

  public IpPort(String ip, int port) {
    this.ip = ip;
    this.port = port;
  }
}

~~~

+ 롬복의 ```@EqualsAndHashCode``` 를 넣으면 모든 필드를 사용해서 ```equals()``` , ```hashcode()``` 를 생성한다. 따라서 모든 필드의 값이 같다면 ```a.equals(b)``` 의 결과가 참이 된다.

~~~java

import lombok.extern.slf4j.Slf4j;
import org.springframework.core.convert.converter.Converter;

@Slf4j
public class StringToIpPortConverter implements Converter<String, IpPort> {
  @Override
  public IpPort convert(String source) {
    log.info("convert source={}", source);
    String[] split = source.split(":");
    String ip = split[0];
    int port = Integer.parseInt(split[1]);
    return new IpPort(ip, port);
  }
}

~~~
