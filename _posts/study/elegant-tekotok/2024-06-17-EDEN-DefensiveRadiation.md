---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 이든의 방어적 복사
date: '2024-06-17 00:00:01 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 이든의 방어적 복사
[https://youtu.be/VsYw2GWgZV0?si=NQqsANYVbiYBTmc1](https://youtu.be/VsYw2GWgZV0?si=NQqsANYVbiYBTmc1)

# 이든의 방어적 복사
* toc
{:toc}

## 자바의 참조 타입
+ 참조 타입이란 변수의 값으로 실제 값이 아니라 값이 저장된 메모리의 주소를 가지는 타입을 뜻한다
+ 참조 타입의 종류로는 클래스, 인터페이스, 배열, 열거형이 있다
+ 참조 타입은 인스턴스를 생성했을 때 스택에 그대로 저장되는 것이 아니라 힙에 실제 값이 저장이 되고 그 힙의 주소를 스택에서 가진 뒤에 인스턴스 사용할 때 스택에 있는 힙의 주소를 참조해서 실제 값에 접근할 수 있게 된다 그래서 참조 객체라는 이름을 가졌다
+ 참조 타입을 클래스의 인스턴스 변수로 사용하게 되면 사이드 이펙트가 발생할 수 있는 우려를 가지게 된다 

## 방어적 복사
+ 방어적 복사란 원본과의 참조를 끊은 복사본을 사용하는 방식으로 원본의 변경에 의한 복사본의 예상치 못한 변경을 방지해서 안전한 코드를 만들 수 있도록 도와준다

### 객체 생성 시점의 방어적 복사
+ ![EDEN-DefensiveRadiation.png](../../../assets/img/elegant-tekotok/EDEN-DefensiveRadiation.png)
+ 외부에서 주입받은 Cars를 새로운 ArrayList에 담아서 인스턴스 필드에 주입 서로 다른 메모리 주소를 참조하게 되기 때문에 외부의 변경에 내부의 영향이 없게 된다 

#### TOCTOU (Time of check, Time of use)
+ ![EDEN-DefensiveRadiation.png](../../../assets/img/elegant-tekotok/EDEN-DefensiveRadiation.png)
+ 멀티스레드 환경에서 사용되게 된다면 지금은 Validation을 먼저 수행하고 방어적 복사를 하고 있는 이러한 코드지만 validation을 수행하는 시점에 외부에서 변경이 발생하게 된다면 외부의 변경에 의해서 인자로 받은 Cars에
  변경이 생겨 new ArrayList에 담기는 값은 결국 변경이 된 값이고 Cars에는 원하는 값을 담을 수 없게 된다 TOCTOU를 고려할 때
+ TOCTOU란 Time of check, Time of use의 줄임말로 참조 타입 객체를 방어적 복사하기 전 검증 (check) 또는 사용 (use) 하는 시점에 같은 주소를 가리키는 다른 곳에서 변경이 발생할 수도 있다는 개념이다
+ 멀티스레드 환경일 때는 원본 객체를 검증한 후에 복사본을 만드는 찰나의 순간에 다른 스레드에 의해서 같은 주소를 참조하는 원본의 상태가 변경되는 상황을 고려해야 한다 
+ ![EDEN-DefensiveRadiation_1.png](../../../assets/img/elegant-tekotok/EDEN-DefensiveRadiation_1.png)
+ TOCTOU를 적용하게 되면 방어적 복사를 먼저 수행하고 Validation을 수행하도록 변경 이렇게 되면 외부에서 변경이 발생하기 전에 미리 방어적 복사를 해놨기 때문에 검증하는 시점
  그리고 사용하는 시점에 아무런 영향도 받지 않게 된다

### Getter 사용 시점의 방어적 복사
+ 객체가 메시지를 주고받으면서 내부에서 책임을 수행할 수 있다면 좋겠지만, Getter 사용이 불가피할 때도 분명 있을 것이다
+ Cars 객체 내부에 getCars가 꼭 필요하다고 가정하면 getCars를 통해 내부에 참조를 얻어 외부에서는 내부값 조작이 가능하게 되는데  getCars를 통해 얻은 List에서 0번 인덱스를 제거하게 되면 실제로 두 개였어야 했던 Cars 내부에 객체가 한 개만 남게 된다

#### UnmodifiableCollection
+ unmodifiableCollection은 java.util에서 제공하고 있으며 ReadOnly 컬렉션이라고도 불린다
+ 읽기 전용 컬렉션인데 읽기 외에 다른 동작을 하게 되면 UnsupportedOperation Exception이 발생하면서 내부의 변경을 막게 된다

## 추가적으로 고려해볼 사항
+ 현재 코드는 아직 외부에서 Car 객체를 생성해서 Cars의 생성자 인자로 사용하고 있다 때문에 아직 외부에서 Cars 객체의 상태에 대한 수정 가능성이 열려있는 상태 객체 생성 방법을 캡슐화 함으로써 이러한 참조 객체의 특성을 막을 수 있다 
+ ![EDEN-DefensiveRadiation_2.png](../../../assets/img/elegant-tekotok/EDEN-DefensiveRadiation_2.png)
+ 카 생성에 필요한 List만을 받아서 그 carNames로 내부에서 Car 객체를 직접 생성해서 내부 인스턴스 필드에 초기화해주고 있다 이렇게 되면 Car 객체의 생성 책임을
  Car의 일급 컬렉션인 Cars가 가지도록 변경한 것이다 이렇게 관리하게 되면 불안전한 코드가 안전한 코드로 변경하게 된다 
+ UnmodifiableCollection을 통해 ReadOnly가 된 것은 컬렉션만 해당된다 컬렉션 내부에 있는 Car 객체들은 변경이 가능한 상태이다 그렇게 되면 getCars를 통해 얻은 List는 아직 변경에 열려있는 상태이다 
+ ![EDEN-DefensiveRadiation_3.png](../../../assets/img/elegant-tekotok/EDEN-DefensiveRadiation_3.png)
+ 내부의 상태를 변경시키는 게 아니라 내부의 상태가 변경이 된 새로운 Position 객체를 리턴한다 이런 Position을 활용해서 Car는 자신이 가지고 있는 상태인 name을 활용해 Position이 변경된 새로운 Car 객체를 생성하여 리턴하게된다
  이렇게 변경하게 되면 서로 다른 메모리를 참조하기 때문에 리스트 내부에 있는 Car는 영향을 받지 않고 외부에서 move를 수행한 Car만 영향을 받게 되는 것이다
+ 이러한 패턴은 실제로 자바에서도 사용을 하고 있는데 LocalDateTime은 시간을 조정할 때 내부의 필드를 변경하는 것이 아니라 필드가, 내부의 상태가 변경된 새로운 LocalDateTime을 생성해서 리턴하도록 만들어져 있다
