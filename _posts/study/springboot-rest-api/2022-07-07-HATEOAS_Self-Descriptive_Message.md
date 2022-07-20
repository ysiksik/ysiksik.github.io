---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: HATEOAS와 Self-Descriptive Message 적용
date: '2022-07-07 00:00:03 +0900'
categories:
    - study
    - springboot-rest-api
tags: RestAPI
comments: true
---

# HATEOAS와 Self-Descriptive Message 적용

# HATEOAS와 Self-Descriptive Message 적용 
* toc
{:toc}

## Spring HATEOAS 소개
+ HATEOAS (Hypermedia As The Engine Of Application state) 란? [https://en.wikipedia.org/wiki/HATEOAS](https://en.wikipedia.org/wiki/HATEOAS)
+ HATEOAS를 통해서 어플리케이션의 상태를 전이할 수 있는 메커니즘을 제공할 수 있다.
+ 예를 들어, 송금 어플리케이션 Home 화면에는 입금, 출금, 송금 등 다른 화면 혹은 기능, 리소스로 갈 수 있는 링크들이 존재 할 것 이다.
  + 이 링크를 통해서 다른 페이지로 가는 것을 다른 상태로 전이 한다고 보고 이 링크들에 대한 레퍼런스를 서버 측에서 전송 한다.
  + 클라이언트가 명시적으로 링크를 작성하지 않고도 서버 측에서 받은 링크의 레퍼런스를 통해 어플리케이션의 상태 및 전이를 표현할 수 있다, 이것이 바로 올바른 REST 아키텍처에서의 HATEOAS 구성법이다.
+ Sping HATEOAS [https://docs.spring.io/spring-hateoas/docs/current/reference/html/](https://docs.spring.io/spring-hateoas/docs/current/reference/html/)
+ 스프링 진영에서는 스프링 HATEOAS라는 프로젝트를 통해 스프링 사용자들에게 HATEOAS 기능을 손쉽게 쓸 수 있도록 제공하고 있다.
  + 이 프로젝트의 주요 기능은 HTTP 응답에 들어갈 유저, 게시판 글, 이벤트 등과 같은 Resource. 다른 상태 혹은 리소스에 접근할 수 있는 링크 레퍼런스인 Links를 제공하는 것이다.
+ HATEOAS 링크에 들어가는 정보는 현재 Resource의 관계이자 링크의 레퍼런스 정보인 REL 과 HREF 두 정보가 들어간다.
+ ![예제](/assets/img/springBoot-REST-API/HATEOAS1.jpg) 
+ ![예제](/assets/img/springBoot-REST-API/HATEOAS2.jpg)
+ Spring HATEOAS [https://docs.spring.io/spring-hateoas/docs/current/reference/html/](https://docs.spring.io/spring-hateoas/docs/current/reference/html/)
+ API [https://docs.spring.io/spring-hateoas/docs/1.1.3.RELEASE/api/](https://docs.spring.io/spring-hateoas/docs/1.1.3.RELEASE/api/)
+ DTO 객체는 RepresentationalModel 클래스를 상속 받아야 Link를 추가(add) 할 수 있다.
+ [WebMvcLinkBuilder](https://docs.spring.io/spring-hateoas/docs/0.25.3.BUILD-SNAPSHOT/api/org/springframework/hateoas/mvc/ControllerLinkBuilder.html) 를 사용해서 컨트롤러와 매핑된 URL + 이벤트 ID로 selfLinkBuilder 객체를 만든다. 이때 링크되는 URL은 http://localhost:8080/api/events/{id} 와 같다.
+ Event 객체를 EventResource 객체에 저장하여 HTTP 응답 메시지에 담을 수 있습니다.

~~~java
import static org.springframework.hateoas.mvc.WebMvcLinkBuilder.*;
public ResponseEntity createEvent(@RequestBody EventDto eventDto, Errors errors) {
        .......
        Event addEvent = this.eventRepository.save(event);
        WebMvcLinkBuilder selfLinkBuilder = linkTo(EventController.class).slash(addEvent.getId());
        URI createUri = selfLinkBuilder.toUri();
        EventResource eventResource = new EventResource(event);
        eventResource.add(linkTo(EventController.class).withRel("query-events"));
        eventResource.add(selfLinkBuilder.withSelfRel());
        eventResource.add(selfLinkBuilder.withRel("update-event"));
        return ResponseEntity.created(createUri).body(eventResource);
}
~~~

+ “event”로 Wrapping 하지 않기
  + @JsonUnwrapped : Jackson에게 어떤 필드의 값에 대해 Wrapping 하지 말고 펼쳐 달라는 의미

~~~java
import com.fasterxml.jackson.annotation.JsonUnwrapped;
public class EventResource<Event> extends RepresentationModel {
    
    @JsonUnwrapped
    private Event event;
    
    public EventResource(Event event) {
        this.event = event;
    }
    
    public Event getEvent() {
        return event;
    }
}
~~~

+ RepresentationModel 대신 EntityModel 상속 받기

~~~java
import org.springframework.hateoas.Link;
import org.springframework.hateoas.EntityModel;
public class EventResource extends EntityModel<Event> {
    @JsonWrapped
    private Event event;
    
    public EventResource(Event event) {
        this.event = event;
    }
}
~~~

+ Self를 EventResource에 추가
  + Event 객체 자신을 나타내는 self를 EventResource에 추가 한다.
    + add(linkTo(EventController.class).slash(event.getId()).withSelfRel()) 는 type safe 하다.
    + 같은  코드 => add(new Link("http://localhost:8080/api/events" + event.getId())) 는 Type Safe 하지 않다
  + self를 EventResource에 추가 한다.
  + eventResource.add(selfLinkBuilder.withSelfRel()); 코드는 제거해도 된다.

~~~java
import org.springframework.hateoas.RepresentationModel;
import static org.springframework.hateoas.mvc.WebMvcLinkBuilder.linkTo;
public class EventResource extends RepresentationModel<EventResource> {
    @JsonUnwrapped
    private Event event;
    
    public EventResource(Event event) {
        this.event = event;
        add(linkTo(EventController.class).slash(event.getId()).withSelfRel());
    }
}
~~~

+ API 인덱스 : IndexController 클래스 작성
  + 인덱스 핸들러

~~~java
@RestController
public class IndexController {
    @GetMapping("/api")
    public RepresentationModel index() {
        var index = new RepresentationModel ();
        index.add(linkTo(EventController.class).withRel("events"));
        return index;
    }
}
~~~

+ API 인덱스 : ErrorsResource 클래스 작성 / EventController 클래스 수정
  + 에러가 발생했을 때에도 Index 링크를 제공하기 위해서 ErrorsResource 클래스를 작성한다.
  + EventController에서 Errors 객체를 ErrorsResource에 Wrapping 하여 리턴 합니다.

~~~java
import org.springframework.hateoas.EntityModel; 
import org.springframework.validation.Errors;

public class ErrorsResource extends EntittyModel<Errors> {
    @JsonUnwrapped
    private Errors errors;

    public ErrorsResource(Errors content) {
        this.errors = content;
        add(linkTo(methodOn(IndexController.class).index()).withRel("index"));
    }
}
~~~

+ API 인덱스 : ErrorsResource 클래스 작성 / EventCotoller 클래스 수정
  + EventController에서 Errors 객체를 ErrorsResource에 Wrapping 하여 리턴 한다.

~~~java
public class EventController {
    public ResponseEntity createEvent(@RequestBody @Valid EventDto eventDto, Errors errors) {
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().body(new ErrorsResource(errors));
        }
        eventValidator.validate(eventDto, errors);
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().body(new ErrorsResource(errors));
        }
    }
    //createEvent 
}
~~~