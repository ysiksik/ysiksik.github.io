---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: JPA 페이징 처리
date: '2022-07-07 00:00:04 +0900'
categories:
    - springboot-rest-api
tags: RestAPI
comments: true
---

# JPA 페이징 처리

# JPA 페이징 처리 
* toc
{:toc}

## Spring Data JPA의 페이징과 정렬
+ Spring Data JPA에서는 쿼리 메소드에 페이징과 정렬 기능을 제공하는 2가지 클래스 제공
  + org.springframework.data.domain.Sort : 정렬 기능
  + org.springframework.data.domain.Pageable : 페이징 기능
+ Pageable 인터페이스는 Paging 하기 위한 파라미터들을 담은 PageRequest 같은 객체에 접근 하기 위한 역할을 한다. 이 매개변수를 통해 Paging 하기 위한 정보를 담은 객체가 들어오게 되고 이것을 통해 자동적으로 Paging에 필요한 데이터를 처리하여 반화하게 되는 것이다.
  + page : 검색을 원하는 페이지 번호를 나타낸다
  + size : 한 페이지의 보여줄 게시물 개수를 나타낸다
  + sort : 정렬 방식을 나타낸다.
  + [https://docs.spring.io/spring-data/commons/docs/current/api/index.html](https://docs.spring.io/spring-data/commons/docs/current/api/index.html)
## Event 목록 조회 API 구현 
  + "first", "prev", "self", "next", "last" 페이지로 가는 링크가 있어야 한다.
  + PagedResourcesAssembler는 Page 객체들을 손쉽게 PagedModel 객체로 변환 해주는 작업을 수행한다.
  + PagedModel은 Pageable 한 객체의 집합을 나타낸다.
  + 따라서 PagedModel 객체는 Pageable 한 객체를 모아서 전달하는 DTO 역할을 하게 된다.

~~~java
import org.springframework.hateoas.EntityModel;

@GetMapping
public ResponseEntity queryEvents(Pageable pageable, PagedResourcesAssembler<Event> assembler) {
        Page<Event> page = this.eventRepository.findAll(pageable);
        PagedModel<EntityModel<Event>> pagedResources = assembler.toModel(page);
        return ResponseEntity.ok(pagedResources);
}
~~~
