---
layout: post
bigtitle: '스프링 MVC 2편 - 백엔드 웹 개발 핵심 기술'
subtitle: 타임리프 - 스프링 통합과 폼
date: '2023-05-17 00:00:00 +0900'
categories:
- spring-mvc-part2
comments: true

---

# 타임리프 - 스프링 통합과 폼

# 타임리프 - 스프링 통합과 폼
* toc
{:toc}

## 타임리프 스프링 통합
타임리프는 크게 2가지 메뉴얼을 제공한다
+ 기본 메뉴얼: [https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html](https://www.thymeleaf.org/doc/tutorials/3.0/usingthymeleaf.html)
+ 스프링 통합 메뉴얼: [https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html](https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html)
+ 타임리프는 스프링 없이도 동작하지만, 스프링과 통합을 위한 다양한 기능을 편리하게 제공한다
+ 그리고 이런 부분은 스프링으로 백엔드를 개발하는 개발자 입장에서 타임리프를 선택하는 하나의 이유가 된다

### 스프링 통합으로 추가되는 기능들
+ 스프링의 SpringEL 문법 통합
+ ```${@myBean.doSomething()}``` 처럼 스프링 빈 호출 지원
+ 편리한 폼 관리를 위한 추가 속성
  + ```th:object``` (기능 강화, 폼 커맨드 객체 선택)
  + ```th:field``` , ```th:errors``` , ```th:errorclass```
+ 폼 컴포넌트 기능
  + checkbox, radio button, List 등을 편리하게 사용할 수 있는 기능 지원
+ 스프링의 메시지, 국제화 기능의 편리한 통합
+ 스프링의 검증, 오류 처리 통합
+ 스프링의 변환 서비스 통합(ConversionService)

### 설정 방법
타임리프 템플릿 엔진을 스프링 빈에 등록하고, 타임리프용 뷰 리졸버를 스프링 빈으로 등록하는 방법
+ [https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html#the-springstandard-dialect](https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html#the-springstandard-dialect)
+ [https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html#views-and-view-resolvers](https://www.thymeleaf.org/doc/tutorials/3.0/thymeleafspring.html#views-and-view-resolvers)
+ 스프링 부트는 이런 부분을 모두 자동화 해준다. build.gradle 에 다음 한줄을 넣어주면 Gradle은 타임리프와 관련된 라이브러리를 다운로드 받고, 스프링 부트는 앞서 설명한 타임리프와 관련된 설정용 스프링 빈을 자동으로 등록해준다
  + ```implementation 'org.springframework.boot:spring-boot-starter-thymeleaf'```
+ 타임리프 관련 설정을 변경하고 싶으면 다음을 참고해서 application.properties 에 추가하면 된다.
  + 스프링 부트가 제공하는 타임리프 설정, thymeleaf 검색 필요 [https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-application-properties.html#common-application-properties-templating](https://docs.spring.io/spring-boot/docs/current/reference/html/appendix-application-properties.html#common-application-properties-templating)

## 입력 폼 처리
+ ```th:object``` : 커맨드 객체를 지정한다.
+ ```*{...}``` : 선택 변수 식이라고 한다. ```th:object``` 에서 선택한 객체에 접근한다
+ ```th:field```
  + HTML 태그의 ```id``` , ```name``` , ```value``` 속성을 자동으로 처리해준다.
  + 렌더링 전
    + ```<input type="text" th:field="*{itemName}" />```
  + 렌더링 후
    + ```<input type="text" id="itemName" name="itemName" th:value="*{itemName}" />```

~~~html

<form action="item.html" th:action th:object="${item}" method="post">
  <div>
    <label for="itemName">상품명</label>
    <input type="text" id="itemName" th:field="*{itemName}" class="formcontrol" placeholder="이름을 입력하세요">
  </div>
  <div>
    <label for="price">가격</label>
    <input type="text" id="price" th:field="*{price}" class="form-control" placeholder="가격을 입력하세요">
  </div>
  <div>
    <label for="quantity">수량</label>
    <input type="text" id="quantity" th:field="*{quantity}" class="formcontrol" placeholder="수량을 입력하세요">
  </div>
</form>

~~~


+ ```th:object="${item}"``` : ```<form>``` 에서 사용할 객체를 지정한다. 선택 변수 식( ```*{...}``` )을 적용할 수 있다
+ ```th:field="*{itemName}"```
  + ```*{itemName}``` 는 선택 변수 식을 사용했는데, ```${item.itemName}``` 과 같다. 앞서 ```th:object``` 로 ```item``` 을 선택했기 때문에 선택 변수 식을 적용할 수 있다.
    + ```id``` : ```th:field``` 에서 지정한 변수 이름과 같다. ```id="itemName"```
    + ```name``` : ```th:field``` 에서 지정한 변수 이름과 같다. ```name="itemName"```
    + ```value``` : ```th:field``` 에서 지정한 변수의 값을 사용한다. ```value=""```
  + id 속성을 제거해도 ```th:field``` 가 자동으로 만들어준다

## 체크 박스 - 단일1
+ 체크 박스를 체크하면 스프링은 on 이라는 문자를 true 타입으로 변환해준다.
+ 주의 - 체크 박스를 선택하지 않을 때
  + HTML에서 체크 박스를 선택하지 않고 폼을 전송하면 필드 자체가 서버로 전송되지 않는다.
+ HTTP 요청 메시지 로깅
  + HTTP 요청 메시지를 서버에서 보고 싶으면 다음 설정을 추가하면 된다.

~~~properties

logging.level.org.apache.coyote.http11=debug

~~~

+ HTML checkbox는 선택이 안되면 클라이언트에서 서버로 값 자체를 보내지 않는다.
+ 수정의 경우에는 상황에 따라서 이 방식이 문제가 될 수 있다.
+ 사용자가 의도적으로 체크되어 있던 값을 체크를 해제해도 저장시 아무 값도 넘어가지 않기 때문에, 서버 구현에 따라서 값이 오지 않은 것으로 판단해서 값을 변경하지 않을 수도 있다.
+ 이런 문제를 해결하기 위해서 스프링 MVC는 약간의 트릭을 사용하는데, 히든 필드를 하나 만들어서, 기존 체크 박스 이름 앞에 언더스코어( _ )를 붙여서 전송하면 체크를 해제했다고 인식할 수 있다.
+ 히든 필드는 항상 전송된다. 따라서 체크를 해제한 경우 전송되지 않고, 히 필드 만 전송되는데, 이 경우 스프링 MVC는 체크를 해제했다고 판단한다.
+ 체크 해제를 인식하기 위한 히든 필드
  + ```<input type="hidden" name="_open" value="on"/>```

~~~html

<!-- single checkbox -->
<div>판매 여부</div>
<div>
  <div class="form-check">
    <input type="checkbox" id="open" name="open" class="form-check-input">
    <input type="hidden" name="_open" value="on"/> <!-- 히든 필드 추가 -->
    <label for="open" class="form-check-label">판매 오픈</label>
  </div>
</div>


~~~

+ 체크 박스 체크
  + ```open=on&_open=on```
  + 체크 박스를 체크하면 스프링 MVC가 open 에 값이 있는 것을 확인하고 사용한다. 이때 _open 은 무시한다.
+ 체크 박스 미체크
  + ```_open=on```
  + 체크 박스를 체크하지 않으면 스프링 MVC가 _open 만 있는 것을 확인하고, open 의 값이 체크되지 않았다고 인식한다.
  + 이 경우 서버에서 Boolean 타입을 찍어보면 결과가 null 이 아니라 false 인 것을 확인할 수 있다.

## 체크 박스 - 단일2
타임리프
+ 개발할 때 마다 이렇게 히든 필드를 추가하는 것은 상당히 번거롭다. 
+ 타임리프가 제공하는 폼 기능을 사용하면 이런 부분을 자동으로 처리할 수 있다.

~~~html

<!-- single checkbox -->
<div>판매 여부</div>
<div>
  <div class="form-check">
    <input type="checkbox" id="open" th:field="*{open}" class="form-checkinput">
    <label for="open" class="form-check-label">판매 오픈</label>
  </div>
</div>

~~~

+ ```<input type="hidden" name="_open" value="on"/>```
  + 타임리프를 사용하면 체크 박스의 히든 필드와 관련된 부분도 함께 해결해준다. HTML 생성 결과를 보면 히든 필드 부분이 자동으로 생성되어 있다.
+ 타임리프의 체크 확인
  + ```checked="checked"```
  + 체크 박스에서 판매 여부를 선택해서 저장하면, 조회시에 checked 속성이 추가된 것을 확인할 수 있다. 
  + 이런 부분을 개발자가 직접 처리하려면 상당히 번거롭다. 타임리프의 ```th:field``` 를 사용하면, 값이 true 인 경우 체크를 자동으로 처리해준다

## 체크 박스 - 멀티

~~~java

@ModelAttribute("regions")
public Map<String, String> regions() {
 Map<String, String> regions = new LinkedHashMap<>();
 regions.put("SEOUL", "서울");
 regions.put("BUSAN", "부산");
 regions.put("JEJU", "제주");
 return regions;
}

~~~

+ @ModelAttribute의 특별한 사용법
  + 등록 폼, 상세화면, 수정 폼에서 모두 서울, 부산, 제주라는 체크 박스를 반복해서 보여주어야 한다. 이렇게
    하려면 각각의 컨트롤러에서 model.addAttribute(...) 을 사용해서 체크 박스를 구성하는 데이터를
    반복해서 넣어주어야 한다.
  + @ModelAttribute 는 이렇게 컨트롤러에 있는 별도의 메서드에 적용할 수 있다.
    이렇게하면 해당 컨트롤러를 요청할 때 regions 에서 반환한 값이 자동으로 모델( model )에 담기게 된다.
    물론 이렇게 사용하지 않고, 각각의 컨트롤러 메서드에서 모델에 직접 데이터를 담아서 처리해도 된다


~~~html

<!-- multi checkbox -->
<div>
  <div>등록 지역</div>
  <div th:each="region : ${regions}" class="form-check form-check-inline">
    <input type="checkbox" th:field="*{regions}" th:value="${region.key}" class="form-check-input">
    <label th:for="${#ids.prev('regions')}" th:text="${region.value}" class="form-check-label">서울</label>
  </div>
</div>

~~~

+ ```th:for="${#ids.prev('regions')}"```
  + 멀티 체크박스는 같은 이름의 여러 체크박스를 만들 수 있다.
  + 그런데 문제는 이렇게 반복해서 HTML 태그를 생성할 때, 생성된 HTML 태그 속성에서 name 은 같아도 되지만, id 는 모두 달라야 한다.
  + 따라서 타임리프는 체크박스를 each 루프 안에서 반복해서 만들 때 임의로 1 , 2 , 3 숫자를 뒤에 붙여준다.
  + HTML의 id 가 타임리프에 의해 동적으로 만들어지기 때문에 ```<label for="id 값">``` 으로 label 의 대상이 되는 id 값을 임의로 지정하는 것은 곤란하다.
  + 타임리프는 ```ids.prev(...)``` , ```ids.next(...)``` 을 제공해서 동적으로 생성되는 id 값을 사용할 수 있도록 한다
+ 타임리프의 체크 확인
  + ```checked="checked"```
  + 멀티 체크 박스에서 등록 지역을 선택해서 저장하면, 조회시에 checked 속성이 추가된 것을 확인할 수 있다.
  + 타임리프는 ```th:field``` 에 지정한 값과 ```th:value``` 의 값을 비교해서 체크를 자동으로 처리해준다.

## 라디오 버튼

~~~java

@ModelAttribute("itemTypes")
public ItemType[] itemTypes() {
 return ItemType.values();
}

~~~

+ ```ItemType.values()``` 를 사용하면 해당 ENUM의 모든 정보를 배열로 반환한다. 예) ```[BOOK, FOOD, ETC]```


~~~html

<!-- radio button -->
<div>
  <div>상품 종류</div>
  <div th:each="type : ${itemTypes}" class="form-check form-check-inline">
    <input type="radio" th:field="*{itemType}" th:value="${type.name()}" class="form-check-input">
    <label th:for="${#ids.prev('itemType')}" th:text="${type.description}" class="form-check-label">BOOK</label>
  </div>
</div>

~~~

+ 체크 박스는 수정시 체크를 해제하면 아무 값도 넘어가지 않기 때문에, 별도의 히든 필드로 이런 문제를 해결했다.
+ 라디오 버튼은 이미 선택이 되어 있다면, 수정시에도 항상 하나를 선택하도록 되어 있으므로 체크 박스와 달리 별도의 히든 필드를 사용할 필요가 없다.

## 타임리프에서 ENUM 직접 사용하기
모델에 ENUM을 담아서 전달하는 대신에 타임리프는 자바 객체에 직접 접근할 수 있다.
+ 타임리프에서 ENUM 직접 접근

~~~html

<div th:each="type : ${T(hello.itemservice.domain.item.ItemType).values()}">

~~~

+ ```${T(hello.itemservice.domain.item.ItemType).values()}``` 스프링EL 문법으로 ENUM을 직접 사용할 수 있다. ENUM에 ```values()``` 를 호출하면 해당 ENUM의 모든 정보가 배열로 반환된다.
+ 그런데 이렇게 사용하면 ENUM의 패키지 위치가 변경되거나 할때 자바 컴파일러가 타임리프까지 컴파일 오류를 잡을 수 없으므로 추천하지는 않는다

## 셀렉트 박스

~~~java

@ModelAttribute("deliveryCodes")
public List<DeliveryCode> deliveryCodes() {
 List<DeliveryCode> deliveryCodes = new ArrayList<>();
 deliveryCodes.add(new DeliveryCode("FAST", "빠른 배송"));
 deliveryCodes.add(new DeliveryCode("NORMAL", "일반 배송"));
 deliveryCodes.add(new DeliveryCode("SLOW", "느린 배송"));
 return deliveryCodes;
}

~~~

+ @ModelAttribute 가 있는 deliveryCodes() 메서드는 컨트롤러가 호출 될 때 마다 사용되므로 deliveryCodes 객체도 계속 생성된다. 이런 부분은 미리 생성해두고 재사용하는 것이 더 효율적이다.

~~~html

<!-- SELECT -->
<div>
  <div>배송 방식</div>
  <select th:field="*{deliveryCode}" class="form-select">
    <option value="">==배송 방식 선택==</option>
    <option th:each="deliveryCode : ${deliveryCodes}" th:value="${deliveryCode.code}" th:text="${deliveryCode.displayName}">FAST
    </option>
  </select>
</div>
<hr class="my-4">


~~~
