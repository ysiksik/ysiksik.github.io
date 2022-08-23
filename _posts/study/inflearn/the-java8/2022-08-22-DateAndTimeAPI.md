---
layout: post
bigtitle: '더 자바, Java 8'
subtitle: Date 와 Time API
date: '2022-08-22 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java8
comments: true
---

# Date 와 Time API

# Date 와 Time API
* toc
{:toc}


## Date 와 Time API 소개

### 자바 8에 새로운 날짜와 시간 API 가 생긴 이유
+ 그전까지 사용하던 java.util.Date 클래스는 mutable 하기 때문에 thread safe 하지 않다.
  + mutable : 객체의 상태를 바꿀수 있다.
+ 클래스 이름이 명확하지 않다. Date 인데 시간까지 다룬다.
+ 버그 발생할 여지가 많다. (타입 안정성이 없고, 월이 0 부터 시작한다.)
+ 날짜 시간 처리가 복잡한 애플리케이션에서는 보통 Joda Time 을 쓰곤 했다.
+ [https://codeblog.jonskeet.uk/2017/04/23/all-about-java-util-date/](https://codeblog.jonskeet.uk/2017/04/23/all-about-java-util-date/)

~~~java

        Date date = new Date(); // Date 인데 시간까지 나타낼 수 있다. - 이상하다
        GregorianCalendar gregorianCalendar = new GregorianCalendar();
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat();

~~~

### 자바 8 에서 제공하는 Date-Time API  
+ JSR-310 스팩의 구현체를 제공한다.
+ 디자인 철학
  + Clear(분명한)
    + API의 메서드는 잘 정의되어 있으며 동작이 명확하고 예상됩니다. 예를 들어 null 매개 변수 값으로 Date-Time 메서드를 호출하면 일반적으로 NullPointerException 이 트리거됩니다.
  + Fluent(유창한)
    + Date-Time API 는 유창한 인터페이스를 제공하여 코드를 읽기 쉽게 만듭니다. 대부분의 메서드는 null 값이 있는 매개 변수를 허용하지 않고 null 값을 반환하지 않기 대문에 메서드 호출 을 함께 연결할 수 있고 결과 코드를 빠르게 이해 할 수 있습니다.
    
~~~java

LocalDate today = LocalDate.now();
LocalDate payday = today.with(TemporalAdjusters.lastDayOfMonth()).minusDays(2);

~~~

  + Immutable(불변의)
    + Date-Time API 의 대부분의 클래스는 변경할 수 없는 객체를 생성합니다. 즉, 객체가 생성된 후에는 수정할 수 없습니다. 변경할 수 없는 개체의 값을 변경하려면 새 개체를 원분의 수정된 복사본으로 생성해야 합니다. 이것을 또한 Date-Time API 가 정의상
    스레드로부터 안전하다는 것을 의미합니다. 이는 날짜 또는 시간 객체를 생성하는 데 사용되는 대부분의 메서드에 생성자가 아니라 of, from 가 접두사로 붙고 메서드가 없다는 점에서 API 에 영향을 줍니다.

~~~java

LocalDate dateOfBirth = LocalDate.of(2012, Month.MAY, 14);
LocalDate firstBirthday = dateOfBirth.plusYears(1);

~~~

  + Extensible(확장)
    + Date-Time API 는 가능한 모든 곳에서 확장할 있습니다. 예를 들어, 고유한 시간 조정자와 쿼리를 정의하거나 고유한 달력 시스템을 구축할 수 있습니다.
  + [https://docs.oracle.com/javase/tutorial/datetime/overview/index.html](https://docs.oracle.com/javase/tutorial/datetime/overview/index.html)

### 주요 API
+ 기계용 시간(machine time)과 인류용 시간(human time)으로 나눌 수 있다.
+ 기계용 시간은 EPOCK(1970년 1월 1일 0시 0분 0초)부터 현재까지의 타임 스탬프를 표현한다.
+ 인류용 시간은 우리가 흔히 사용하는 연,월,일,시,분,초 등을 표현한다.
+ 타임스탬프는 Istant 를 사용한다.
+ 기간을 표현할 때는 Duration(시간 기반)과 Period(날짜 기반)를 사용할 수 있다.
+ DateTimeFormatter 를 사용해서 일시를 특정한 문자열로 포매팅할 수 있다.