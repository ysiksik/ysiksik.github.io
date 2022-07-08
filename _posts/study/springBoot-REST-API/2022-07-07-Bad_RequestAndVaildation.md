---
layout: post
bigtitle: 'Spring Boot 기반 REST API 개발'
subtitle: Bad_Request와 Validation
date: '2022-07-07 00:00:02 +0900'
categories:
    - study
    - springBoot-REST-API
tags: RestAPI
comments: true
---

# Bad_Request와 Validation

# Bad_Request와 Validation
* toc
{:toc}

## Bad Request로 응답하기
+ Bad_Request로 응답 vs 받기로 한 값 이외는 무시
+ 스프링 부트에서는 기본적으로 Unknown Property는 Deserializaion(역직렬화) 중에 무시 된다.
+ 입력 값 이외에 값이 들어왔을 때 에러(Bad Request)를 발생 시키기 위해서는 spring.jackson.deserialization.fail-on-unknown-properties=true 로 설정해야 한다.

## 입력 데이터 체크와 에러 메시지 출력
+ 입력 데이터의 값이 이상한 경우 Bad_Request로 응답
+ 비즈니스 로직으로 검사할 수 있는 에러
+ 응답(response) 메시지에 에러에 대한 정보가 있어야 한다.

## Java Bean Vaildation
+ 데이터 검증을 위한 로직을 도메인 모델 자체에 묶어서 표현하는 방법이 있다.
+ Java Bean Vaildation 에서 데이터 검증을 위한 어노테이션 (Annotation)을 제공하고 있다.

## Valid 어노테이션을 이용한 Validation 체크
+ @Vaild는 JSR-303이란 이름으로 채택된 서블릿 2.3 표준 스펙 중 하나이며, 스프링은 이 표준을 확장하고 쉽게 사용할 수 있도록 스프링만의 방식으로 재편성 해 주었다. 
+ @NotNull, @NotEmpty, @Min, @Max, @Size(min=, max=) 사용해서 입력 값을 바인딩할 때 에러를 확인할 수 있다.
+ Errors ( BindingResult )는 항상 @Valid 바로 다음 인자로 사용해야 한다.

## Custom Validation 
+ Custom Validation 작성
  + Vaildator 클래스를 Spring Bean 컴포넌트로 정의한다.

~~~java
    @Component
    public class EventValidator {
        public void validate(EventDto eventDto, Errors errors) {
            if (eventDto.getBasePrice() > eventDto.getMaxPrice() && eventDto.getMaxPrice() != 0) {
                //Field Error 
                errors.rejectValue("basePrice", "wrongValue", "BasePrice is wrong");
                errors.rejectValue("maxPrice", "wrongValue", "MaxPrice is wrong");
                //Global Error 
                errors.reject("wrongPrices", "Values for prices are wrong");
            }
            LocalDateTime endEventDateTime = eventDto.getEndEventDateTime();
            if (endEventDateTime.isBefore(eventDto.getBeginEventDateTime())||endEventDateTime.isBefore(eventDto.getCloseEnrollmentDateTime())||endEventDateTime.isBefore(eventDto.getBeginEnrollmentDateTime())) {
                errors.rejectValue("endEventDateTime", "wrongValue", "EndEventDateTime is wrong");
            }
        }
    }
~~~

+ Custom Validation 사용
  + EventValidator 를 주입 받고, EventValidator의 validate() 메서드를 호출하고, Errors 객체에 에러가 포함되어 있는지 확인합니다.

~~~java
    private final EventValidator eventValidator;

    public EventController(EventRepository eventRepository, ModelMapper modelMapper, EventValidator eventValidator) {
        this.eventRepository = eventRepository;
        this.modelMapper = modelMapper;
        this.eventValidator = eventValidator;
    }

    public ResponseEntity createEvent(@RequestBody EventDto eventDto, Errors errors) {
        eventValidator.validate(eventDto, errors);
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().build();
        } 
        .....
    }
~~~

## Custom JsonSerializer
+ 에러 메시지를 출력하기 위해서 Custom JsonSerializer를 작성해야 한다.
+ Jackson JSON이 제공하는 JsonSerializer를 상속 받는다. => Errors 객체를 JsonSerializer로 Wrapping 한다.
+ Spring Boot가 제공하는 @JsonSerialize 어노테이션은 Custom Serializer 클래스를 Spring Bean으로 등록해 주는 역학을 한다.
+ Errors는 Java Bean Spec을 준수하는 객체가 아니어서 Json 객체로 변환할 수 없다.
+ JsonSerializer를 상속 받고 serialize() 메서드를 재정의 한다.
+ Spring Boot에서 제공하는 @JsonComponent를 선언 한다.
+ @JsonComponent annotation을 사용하면 주석이 달린 클래스를 ObjectMapper에 수동으로 추가할 필요 없이 JACKSON SERIALIZER 및/또는 deserializer로 노출할 수 있다.
+ ErrorSerializer 작성하기
  1. FieldError와 GlobalError를 둘 다 매핑해서 JSON에 담아 줘야 한다.
  2. ObjectMapper는 Errors라는 객체를 직렬화(Serialization) 할 때 ErrorSerializer를 사용한다. 

~~~java
import java.io.IOException;

import org.springframework.boot.jackson.JsonComponent;
import org.springframework.validation.Errors;

import com.fasterxml.jackson.core.JsonGenerator;
import com.fasterxml.jackson.databind.JsonSerializer;
import com.fasterxml.jackson.databind.SerializerProvider;

@JsonComponent
public class ErrorSerializer extends JsonSerializer<Errors>{
	@Override
	public void serialize(Errors errors, JsonGenerator gen, SerializerProvider serializers) throws IOException {
		gen.writeStartArray();
        errors.getFieldErrors().forEach(e -> {
            try {
                gen.writeStartObject();
                gen.writeStringField("field", e.getField());
                gen.writeStringField("objectName", e.getObjectName());
                gen.writeStringField("code", e.getCode());
                gen.writeStringField("defaultMessage", e.getDefaultMessage());
                Object rejectedValue = e.getRejectedValue();
                if (rejectedValue != null) {
                    gen.writeStringField("rejectedValue", rejectedValue.toString());
                }
                gen.writeEndObject();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        });

        errors.getGlobalErrors().forEach(e -> {
            try {
                gen.writeStartObject();
                gen.writeStringField("objectName", e.getObjectName());
                gen.writeStringField("code", e.getCode());
                gen.writeStringField("defaultMessage", e.getDefaultMessage());
                gen.writeEndObject();
            } catch (IOException e1) {
                e1.printStackTrace();
            }
        });
        gen.writeEndArray();
		
	}
}
~~~

+ Bad_Request 에러가 발생 하면, Errors 객체를 Body에 Wrapping 해서 보내면 에러 메시지가 잘 출력된다.

~~~java
    public ResponseEntity createEvent(@RequestBody EventDto eventDto, Errors errors) {
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().body(errors);
        }
        eventValidator.validate(eventDto, errors);
        if (errors.hasErrors()) {
            return ResponseEntity.badRequest().body(errors);
        } 
        .....
    }
~~~