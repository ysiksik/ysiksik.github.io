---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: Event 생성 API 개발
date: '2022-07-07 00:00:00 +0900'
categories:
    - study
    - springBoot-REST-API
tags: RestAPI
comments: true
---

# Event 생성 API 개발

# Event 생성 API 개발
* toc
{:toc}


## Lombok 이란?
+ 자바에서 Model(DTO, VO, Entity) Object 를 작성할 때, 멤버필드(프로퍼티)에 대한 Getter/Settter,ToString과 멤버 필드에 주입하는 생성자 등 반복적으로 만드는 코드들을 어노테이션(@)을 통해 줄여주는 라이브러리이다.
+ 동작원리
  + Lombok annotation이 부여된 Java Source를 컴파일 할 때 등록된 Lombok processor가 어노테이션을 확인하고, 그에 맞는 메서드를 자동으로 생성하여 byte code로 변환시켜 준다.
+ 단점
  + 협업 모든 이원이 lombok을 설치해야하고, 추가적인 어노테이션을 사용 할 경우 소스코드 분석이 어려울 수도 잇다.

|       @어노테이션       | 설명                                                                                | 세부 기능                                                                          |
|:-----------------------:|-------------------------------------------------------------------------------------|------------------------------------------------------------------------------------|
| Getter, @Setter         | getter, setter 메서드 자동생성                                                      | accessLevel : 해당 접근 제한자를 설정 lazy : 동기화를 이용하여 최초 1회만 호출     |
| ToString                | toString 메서드 자동생성                                                            | exclude : 출력하지 않을 필드명 입력 callSuper : 상위클래스 toString 호출 여부 설정 |
| EqualsAndHashCode       | equals, hashcode 자동생성                                                           |                                                                                    |
| NoArgsConstructor       | 인자가 없는 생성자 생성                                                             |                                                                                    |
| RequiredArgsConstructor | 필수 인자만 있는 생성자 생성                                                        |                                                                                    |
| AllArgsConstructor      | 모든 인자를 가진 생성자 생성                                                        |                                                                                    |
| Data                    | @ToString, @EqualsAndHashCode , @Getter, @Setter, @RequiredArgsConstructor 자동생성 |                                                                                    |

## Lombok 어노테이션 사용
+ @Builder Annotation은 Class에 대한 복잡한 Builder API들을 자동으로 생성해 준다.
+ 빌터 패턴은 객체를 생성할 때 필수적인 인자와 선택적인 인자를 구별할 수 잇는 장점이 있다.

## ResponseEntity를 사용하는 이유
+ 응답 코드, 헤더, 본문을 모두 저장 해주는 편리한 API

## Location URI 만들기
+ Spring HATEOAS WebMvcLinkBuilder의 linkTo(), methodOn() 사용

~~~java
    import org.springframework.hateoas.server.mvc.WebMvcLinkBuilder;
    @Controller
    @RequestMapping(value="/api/events", produces = MediaTypes.HAL_JSON_UTF8_VALUE)
    public class EventController {
        @PostMapping
        public ResponseEntity createEvent(@RequestBody Event event) {
            event.setId(10);
            URI createUri = WebMvcLinkBuilder.linkTo(EventController.class).slash(event.getId()).toUri();
            return ResponseEntity.created(createUri).body(event);
        }
    }
~~~

## @JsonFormat 어노테이션 사용하기
+ @JsonFormat은 Jackson 라이브러리에서 제공하는 어노테이션으로 JSON 응답값의 형식을 지정할 때 사용한다.
+ @JsonFormat을 이용해서 날짜 형식을 지정하려면 아래와 같이 사용한다.

~~~java
    import com.fasterxml.jackson.annotation.JsonFormat;

        @JsonFormat(pattern="yyyy-MM-dd HH:mm")
        private LocalDateTime beginEnrollmentDateTime;
        @JsonFormat(pattern="yyyy-MM-dd HH:mm")
        private LocalDateTime closeEnrollmentDateTime;
        @JsonFormat(pattern="yyyy-MM-dd HH:mm")
        private LocalDateTime beginEventDateTime;
        @JsonFormat(pattern="yyyy-MM-dd HH:mm")
        private LocalDateTime endEventDateTime;
        private String location;
        private int basePrice;
        private int maxPrice;
        private int limitOfEnrollment
~~~

~~~json
    {
        "name":"Spring",
        "description":"REST API Development with Spring",
        "beginEnrollmentDateTime":"2019-02-03 10:08",
        "closeEnrollmentDateTime":"2019-02-04 10:08",
        "beginEventDateTime":"2019-02-10 10:08",
        "endEventDateTime":"2019-02-11 10:08",
        "location":"강남역 D2 스타텁 팩토리",
        "basePrice":100,
        "maxPrice":200,
        "limitOfEnrollment":100
    }
~~~