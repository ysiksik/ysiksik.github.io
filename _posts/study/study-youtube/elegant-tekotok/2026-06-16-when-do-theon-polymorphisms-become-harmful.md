---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 티온의 다형성은 언제 해가 되는가?
date: '2026-06-16 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true

---

# 티온의 다형성은 언제 해가 되는가?
[https://youtu.be/bd_JZJxjm4I?si=H8-cjPWesFhUdzXE](https://youtu.be/bd_JZJxjm4I?si=H8-cjPWesFhUdzXE)

# 티온의 다형성은 언제 해가 되는가?
* toc
{:toc}

---


## 다형성은 언제 코드에 해가 될까?

객체지향 프로그래밍을 학습하다 보면 다형성은 변경에 유연한 코드를 만드는 핵심 원칙으로 소개된다.

인터페이스나 추상 클래스를 중심으로 설계하면 새로운 구현체를 추가하더라도 기존 코드를 크게 수정하지 않고 기능을 확장할 수 있다. 이는 개방-폐쇄 원칙과도 연결되며, 유지보수하기 좋은 코드의 대표적인 특징으로 여겨진다.

하지만 다형성을 적용했다고 해서 코드가 반드시 좋아지는 것은 아니다.

다형성을 적용하는 과정에서 클래스와 인터페이스가 계속 늘어나고, 하나의 기능을 이해하기 위해 여러 객체를 오가야 하며, 실제 필요한 정보가 객체 외부로 흘러나오기 시작한다면 오히려 구조가 더 복잡해질 수 있다.

결국 중요한 질문은 이것이다.

**다형성을 적용했는가가 아니라, 다형성을 적용한 결과 코드가 실제로 더 이해하기 쉬워졌는가?**

---

## 다형성이란 무엇인가?

다형성은 같은 메시지를 서로 다른 객체가 각자의 방식으로 처리할 수 있게 만드는 객체지향 특성이다.

예를 들어 이동 전략이라는 인터페이스가 있다고 가정해보자.

```java
public interface MovementStrategy {

    List<Position> createPath(Position source, Position target);
}
```

각 기물은 자신의 이동 규칙에 맞는 구현체를 가질 수 있다.

```java
public class LinearMovementStrategy implements MovementStrategy {

    @Override
    public List<Position> createPath(Position source, Position target) {
        return createLinearPath(source, target);
    }
}
```

```java
public class DiagonalMovementStrategy implements MovementStrategy {

    @Override
    public List<Position> createPath(Position source, Position target) {
        return createDiagonalPath(source, target);
    }
}
```

호출하는 쪽에서는 구체적인 이동 방식에 의존하지 않고 공통 인터페이스만 사용할 수 있다.

```java
public List<Position> createPath(
        MovementStrategy movementStrategy,
        Position source,
        Position target
) {
    return movementStrategy.createPath(source, target);
}
```

새로운 이동 규칙이 추가되더라도 기존 로직을 직접 수정하는 대신 새로운 구현체를 추가할 수 있다.

이것이 다형성의 대표적인 장점이다.

---

## 추가와 확장은 어떻게 다를까?

기능 요구사항을 분석할 때는 새로운 요구가 기존 기능의 **확장**인지, 완전히 새로운 책임의 **추가**인지 구분할 필요가 있다.

두 개념은 비슷해 보이지만 설계 방향은 다를 수 있다.

### 추가

추가는 기존 구조에 새로운 기능이나 요소를 더하는 것이다.

예를 들면 기존에 없던 대각선 이동 규칙을 새로 만드는 경우다.

```text
기존 이동 규칙
+
대각선 이동 규칙
```

기존 기능의 범위를 넓히는 것보다 새로운 동작 자체를 도입하는 성격이 강하다.

### 확장

확장은 기존 코드를 가능한 한 유지하면서 새로운 상황에 대응할 수 있도록 범위를 넓히는 것이다.

예를 들면 이동 경로를 계산하는 공통 구조는 그대로 두되 다음 조건을 적용할 수 있다.

```text
일반 기물은 보드 경계를 벗어나지 않는다
궁성 기물은 궁성 경계를 벗어나지 않는다
```

이 경우 경로 생성이라는 본질은 같지만, 적용 가능한 영역이 달라진다.

객체지향에서 말하는 확장은 대체로 기존 코드의 변경을 최소화하면서 새로운 동작을 추가하는 것과 연결된다.

---

## 다형성을 적용하기 좋은 상황

다형성이 효과적인 상황은 여러 구현이 **같은 목적과 같은 계약**을 공유할 때다.

예를 들어 경로 생성 전략들이 모두 다음 질문에 답한다면 다형성을 적용하기 좋다.

```text
출발점과 목적지를 받아
해당 이동 방식의 경로를 반환한다
```

구현체마다 계산 방식은 다르지만 역할은 같다.

```text
직선 이동
대각선 이동
한 칸 이동
단계 이동
```

이런 구조에서는 새로운 구현체가 추가되더라도 사용하는 쪽의 로직은 거의 바뀌지 않는다.

다형성으로 얻는 이점이 명확하다.

```text
조건문 감소
구현체 교체 용이
기능 확장 용이
호출부 단순화
```

---

## 문제는 다형성을 적용하는 것 자체가 목적이 될 때 발생한다

다형성을 적용하기 시작하면 중복을 발견할 때마다 새로운 인터페이스와 구현체를 만들고 싶은 유혹이 생긴다.

처음에는 다음 정도의 구조일 수 있다.

```text
Game
→ Board
→ Piece
```

그러나 다형성을 반복적으로 적용하다 보면 다음과 같이 계층이 늘어날 수 있다.

```text
Game
→ Board
→ CandidatePath
→ PathStrategy
→ Movement
→ ApplicableArea
→ Piece
```

각 추상화는 나름의 이유를 가지고 만들어졌을 수 있다.

하지만 전체 기능을 이해하기 위해 너무 많은 객체를 따라가야 한다면 문제가 된다.

다형성은 중복을 줄였지만, 그 대가로 **인지적 복잡도**를 크게 높였을 수 있다.

---

## 다형성이 복잡성을 높이는 첫 번째 신호: 계층이 계속 늘어난다

새로운 요구사항이 들어올 때마다 인터페이스와 추상 클래스가 하나씩 추가된다면 설계를 다시 살펴볼 필요가 있다.

```text
전략 인터페이스 추가
전략 구현체 추가
적용 범위 인터페이스 추가
적용 범위 구현체 추가
조합 객체 추가
팩토리 추가
```

이런 구조는 확장 가능해 보이지만, 실제로는 단순한 기능 하나를 이해하기 위해 수많은 파일을 열어봐야 할 수 있다.

특히 구현체마다 동일한 메서드를 형식적으로 오버라이딩하고 있다면 추상화가 실제 차이를 표현하고 있는지 확인해야 한다.

```java
@Override
public List<Position> createPath(...) {
    return delegate.createPath(...);
}
```

대부분의 구현체가 단순 위임만 반복한다면 다형성이 의미 있는 변화를 추상화하는 것이 아니라, 구조를 유지하기 위한 형식적인 코드가 되었을 가능성이 있다.

---

## 두 번째 신호: 필요한 정보는 한 객체에 있는데 로직은 다른 객체에 있다

객체지향 설계에서 행동은 가능한 한 그 행동에 필요한 데이터를 가진 객체와 함께 있어야 한다.

예를 들어 기물의 이동 경로를 계산하기 위해 필요한 정보가 모두 `Piece`에 있다고 가정해보자.

```text
기물의 현재 위치
기물의 이동 방식
기물의 적용 가능 영역
궁성 이동 가능 여부
```

그런데 실제 경로 생성은 `Board`가 담당하고, 궁성 경계 확인은 `Game`이 담당한다면 책임이 분산된다.

```text
Piece가 이동 정보를 소유한다
Board가 경로를 생성한다
Game이 궁성 영역을 확인한다
```

이 구조에서는 하나의 이동 규칙을 이해하려면 세 객체를 모두 확인해야 한다.

수정이 필요할 때도 여러 계층을 함께 변경해야 한다.

```text
Piece 변경
Board 변경
Game 변경
```

다형성은 적용되어 있지만 변경 영향 범위는 오히려 커진다.

---

## 응집도란 무엇인가?

응집도는 서로 관련된 데이터와 행동이 얼마나 가까이 모여 있는지를 나타낸다.

응집도가 높은 객체는 하나의 명확한 책임을 수행한다.

예를 들어 `Piece`가 자신의 이동 규칙을 알고 있다면 다음과 같이 직접 경로를 생성할 수 있다.

```java
public class Piece {

    private final Movement movement;
    private final ApplicableArea applicableArea;

    public List<Position> createPath(
            Position source,
            Position target
    ) {
        List<Position> path = movement.createPath(source, target);

        return path.stream()
                .filter(applicableArea::contains)
                .toList();
    }
}
```

이 객체는 이동 경로 생성에 필요한 상태와 행동을 함께 가진다.

반대로 관련 기능이 여러 객체로 흩어지면 응집도가 낮아진다.

```text
Movement는 방향을 계산한다
Board는 임시 경로를 만든다
Game은 이동 가능 영역을 확인한다
Piece는 마지막 검증만 한다
```

하나의 기능이 여러 객체에 흩어져 있어 흐름을 파악하기 어렵다.

---

## 캡슐화란 무엇인가?

캡슐화는 객체가 자신의 상태와 구현 세부사항을 외부에 불필요하게 노출하지 않는 것이다.

외부 객체는 내부 구현을 직접 조립하기보다 객체에게 필요한 행동을 요청해야 한다.

좋지 않은 구조는 다음과 같다.

```java
Movement movement = piece.getMovement();
ApplicableArea area = piece.getApplicableArea();
Position source = piece.getPosition();

List<Position> path = board.createPath(
        movement,
        area,
        source,
        target
);
```

호출하는 쪽에서 `Piece` 내부 데이터를 꺼낸 뒤 직접 조합하고 있다.

이 경우 `Piece`는 자신의 상태를 보호하지 못한다.
외부 객체가 내부 구현 방식을 알아야 한다.

더 나은 방식은 `Piece`에게 직접 요청하는 것이다.

```java
List<Position> path = piece.createPath(target);
```

이제 외부 객체는 `Piece`가 어떤 전략과 적용 영역을 사용하는지 알 필요가 없다.

```text
어떻게 경로를 만드는가
→ Piece 내부 책임

어디로 이동할 것인가
→ 외부에서 전달
```

이것이 캡슐화된 구조에 가깝다.

---

## 맹목적인 다형성이 응집도를 해치는 과정

중복을 줄이기 위해 전략 객체를 도입했다고 가정해보자.

```text
Board가 MovementStrategy를 전달받는다
Board가 ApplicableArea를 전달받는다
Board가 경로를 만든다
Game이 최종 유효성을 확인한다
```

각 역할은 다형화되어 있지만, 실제로는 하나의 이동이라는 책임이 여러 객체로 찢어졌다.

```text
정보는 Piece에 있다
판단은 Game에 있다
경로 생성은 Board에 있다
구체 전략은 별도 구현체에 있다
```

이런 구조는 확장성만 강조하다가 응집도를 희생한 사례가 될 수 있다.

객체 간 연결이 늘어나면 다음 문제가 발생한다.

```text
변경 지점 증가
메서드 파라미터 증가
객체 탐색 비용 증가
코드 리뷰 난이도 증가
테스트 설정 복잡도 증가
```

결국 다형성을 적용하기 전보다 유지보수가 어려워질 수 있다.

---

## 다형성이 캡슐화를 해치는 과정

다형성을 적용하기 위해 객체 내부 정보를 밖으로 꺼내는 경우도 있다.

예를 들어 외부에서 전략을 선택하기 위해 다음 정보를 조회한다고 해보자.

```java
piece.getType();
piece.getMovement();
piece.getApplicableArea();
piece.isPalacePiece();
```

외부 객체는 이 정보를 이용해 실행할 전략을 결정한다.

```java
if (piece.isPalacePiece()) {
    palaceStrategy.move(piece);
} else {
    normalStrategy.move(piece);
}
```

이 구조에서는 객체가 자신의 행동을 결정하지 못하고 외부에서 내부 상태를 분석해 행동을 선택한다.

다형성을 위한 클래스는 존재하지만 실제 캡슐화는 약해진다.

객체에게 메시지를 보내는 방식이 더 자연스럽다.

```java
piece.moveTo(target);
```

어떤 경로를 사용하고 어떤 경계를 적용할지는 `Piece` 내부에서 결정할 수 있다.

---

## 리팩토링 방향: 책임을 데이터를 가진 객체로 되돌린다

문제를 해결하는 첫 번째 방향은 흩어진 책임을 가장 관련 있는 객체로 되돌리는 것이다.

기물 이동과 관련된 정보가 `Piece`에 있다면 다음 책임도 `Piece` 또는 그 하위 타입에 위치하는 것이 자연스러울 수 있다.

```text
경로 생성
적용 범위 확인
궁성 이동 여부 확인
이동 가능성 검증
```

`Game`과 `Board`는 전체 게임과 보드 상태를 관리하되, 개별 기물이 어떻게 움직이는지는 기물에게 위임한다.

```java
public class Board {

    public void move(Position source, Position target) {
        Piece piece = findPiece(source);
        List<Position> path = piece.createPath(target);

        validateCollision(path);
        relocate(piece, target);
    }
}
```

`Board`는 보드 차원의 책임만 가진다.

```text
기물 조회
경로 위 다른 기물 확인
최종 위치 변경
```

개별 이동 방식은 `Piece`가 담당한다.

---

## 추상 클래스와 템플릿 메소드 패턴 활용

여러 기물이 이동 처리의 전체 흐름은 공유하지만, 일부 단계만 다르다면 템플릿 메소드 패턴을 고려할 수 있다.

상위 추상 클래스가 알고리즘의 전체 틀을 정의하고, 변경되는 일부 단계만 하위 클래스가 구현한다.

```java
public abstract class Piece {

    public final List<Position> createPath(
            Position source,
            Position target
    ) {
        validateTarget(source, target);

        List<Position> path = createMovementPath(source, target);

        return applyArea(path);
    }

    protected abstract List<Position> createMovementPath(
            Position source,
            Position target
    );

    protected abstract List<Position> applyArea(
            List<Position> path
    );

    private void validateTarget(
            Position source,
            Position target
    ) {
        if (source.equals(target)) {
            throw new IllegalArgumentException(
                    "출발지와 목적지는 같을 수 없습니다."
            );
        }
    }
}
```

구체 기물은 달라지는 부분만 재정의한다.

```java
public class LinearPiece extends Piece {

    @Override
    protected List<Position> createMovementPath(
            Position source,
            Position target
    ) {
        return LinearMovement.create(source, target);
    }

    @Override
    protected List<Position> applyArea(
            List<Position> path
    ) {
        return BoardArea.filter(path);
    }
}
```

궁성에 제한되는 기물은 다른 적용 범위를 사용할 수 있다.

```java
public class PalacePiece extends Piece {

    @Override
    protected List<Position> createMovementPath(
            Position source,
            Position target
    ) {
        return PalaceMovement.create(source, target);
    }

    @Override
    protected List<Position> applyArea(
            List<Position> path
    ) {
        return PalaceArea.filter(path);
    }
}
```

이 구조의 장점은 전체 이동 절차가 한 곳에 모인다는 점이다.

```text
검증
→ 경로 생성
→ 영역 적용
→ 결과 반환
```

각 구현체는 자신에게 필요한 차이만 표현한다.

---

## 템플릿 메소드 패턴도 무조건 좋은 것은 아니다

다형성의 문제를 해결하기 위해 추상 클래스를 도입했더라도 주의해야 한다.

상속 계층이 깊어지면 다시 복잡성이 높아질 수 있다.

```text
Piece
→ ApplicablePiece
→ PalaceApplicablePiece
→ LinearPalaceApplicablePiece
```

이처럼 상속이 계속 이어지면 어떤 메서드가 어디에서 정의되었는지 파악하기 어렵다.

템플릿 메소드 패턴은 다음 조건에서 효과적이다.

```text
전체 알고리즘의 흐름이 안정적이다
일부 단계만 구현체마다 다르다
구현체 사이의 공통 의미가 명확하다
상속 관계가 자연스럽다
```

그렇지 않다면 조합을 사용하는 편이 나을 수 있다.

---

## 상속 대신 조합을 사용할 수도 있다

기물마다 이동 방식과 적용 영역을 유연하게 조합해야 한다면 상속보다 조합이 적합할 수 있다.

```java
public class Piece {

    private final Movement movement;
    private final ApplicableArea applicableArea;

    public Piece(
            Movement movement,
            ApplicableArea applicableArea
    ) {
        this.movement = movement;
        this.applicableArea = applicableArea;
    }

    public List<Position> createPath(
            Position source,
            Position target
    ) {
        List<Position> path = movement.create(source, target);
        return applicableArea.apply(path);
    }
}
```

기물 생성 시 필요한 정책을 조합한다.

```java
Piece rook = new Piece(
        new LinearMovement(),
        new BoardApplicableArea()
);
```

```java
Piece palaceKing = new Piece(
        new PalaceMovement(),
        new PalaceApplicableArea()
);
```

이 방식은 상속 계층을 깊게 만들지 않고도 다양한 조합을 표현할 수 있다.

다만 전략 객체가 지나치게 잘게 나뉘면 다시 객체 수가 증가하므로 실제 변화 가능성을 기준으로 분리해야 한다.

---

## 다형성 적용 전 확인해야 할 질문

다형성을 도입하기 전에 다음 질문을 해보는 것이 좋다.

### 구현체들이 정말 같은 역할을 수행하는가?

이름만 비슷할 뿐 서로 다른 책임을 가진다면 하나의 인터페이스로 묶지 않는 것이 나을 수 있다.

### 새로운 구현체가 실제로 자주 추가될 가능성이 있는가?

가능성만으로 추상화를 만들면 사용되지 않는 확장 지점만 늘어날 수 있다.

### 다형성을 적용하면 조건문이 줄어드는가?

조건문이 다른 계층으로 이동했을 뿐이라면 구조가 개선된 것이 아닐 수 있다.

### 데이터를 가진 객체가 행동도 함께 가지고 있는가?

데이터와 행동이 분리되면 응집도가 낮아질 수 있다.

### 외부 객체가 내부 상태를 꺼내 조립하고 있지는 않은가?

Getter로 정보를 꺼내 외부에서 판단하는 구조라면 캡슐화를 의심해야 한다.

### 기능 하나를 이해하기 위해 몇 개의 클래스를 열어봐야 하는가?

추상화가 너무 많아 흐름을 따라가기 어렵다면 다형성 비용이 이점보다 커졌을 수 있다.

---

## 다형성이 해가 되는 대표적인 상황

다형성이 유지보수를 어렵게 만드는 경우를 정리하면 다음과 같다.

| 상황                      | 문제           |
| ----------------------- | ------------ |
| 구현체가 하나뿐인데 인터페이스부터 생성   | 불필요한 추상화 증가  |
| 구현체들이 사실상 같은 코드 반복      | 형식적인 다형성     |
| 전략 적용을 위해 내부 상태를 외부로 노출 | 캡슐화 저하       |
| 하나의 책임이 여러 객체에 분산       | 응집도 저하       |
| 요구사항마다 상속 계층 증가         | 구조 이해 난이도 증가 |
| 변경 가능성을 추측해 미리 확장 설계    | 과도한 설계       |
| 조건문이 팩토리나 외부 조립 코드로 이동  | 복잡성 이전       |
| 구현체마다 대부분 빈 메서드나 단순 위임  | 잘못된 추상화 가능성  |

---

## 다형성을 적용해야 하는 기준

다형성은 다음 조건에서 강력하다.

```text
같은 역할을 가진 여러 구현이 존재한다
구현체 선택이 런타임에 달라질 수 있다
새로운 구현이 실제로 추가될 가능성이 높다
호출하는 쪽이 구체 구현을 알 필요가 없다
행동 차이가 명확하게 분리된다
```

반대로 다음과 같은 상황에서는 단순한 조건문이 더 나을 수 있다.

```text
경우의 수가 두세 개로 고정되어 있다
규칙이 자주 함께 변경된다
구현체별 차이가 매우 작다
추상화를 위한 객체가 더 많은 코드를 만든다
```

조건문이 있다는 이유만으로 무조건 다형성으로 바꾸는 것은 좋은 설계가 아니다.

작은 조건문 하나보다 인터페이스 다섯 개가 더 큰 복잡성을 만들 수 있다.

---

## 요구사항의 의도를 해석하는 것이 중요하다

설계에서는 요구사항의 문장을 단순히 구현 목록으로 받아들이지 않고, 어떤 변경 방향을 기대하는지 해석해야 한다.

예를 들어 요구사항 제목이 ‘기물 추가’가 아니라 ‘기물 확장’이라면 다음 질문을 생각해볼 수 있다.

```text
기존 기물 구조를 유지하면서 확장하라는 의미인가?
새 규칙이 들어와도 기존 호출부가 바뀌지 않아야 하는가?
보드보다 기물이 책임져야 할 변화인가?
```

이 해석이 무조건 하나의 정답으로 이어지는 것은 아니다.

중요한 것은 설계 선택에 자신의 근거가 있어야 한다는 점이다.

```text
왜 이 책임을 Piece로 옮겼는가?
왜 Strategy를 도입했는가?
왜 상속보다 조합을 선택했는가?
왜 이 경우에는 조건문을 유지했는가?
```

이 질문에 답할 수 있다면 설계 의도가 분명해진다.

---

## 실무에서의 적용

실무에서도 새로운 요구사항이 들어올 때마다 인터페이스와 구현체를 추가하다 보면 빠르게 복잡한 구조가 만들어질 수 있다.

예를 들어 결제 수단을 다형성으로 처리한다고 해보자.

```text
CardPayment
PayPalPayment
BankTransferPayment
```

각 결제 수단의 승인, 취소, 검증 절차가 실제로 다르다면 다형성이 효과적이다.

반면 단순히 화면에 표시할 결제 수단 이름만 다르다면 각각의 클래스를 만드는 것은 과도할 수 있다.

```java
public enum PaymentType {
    CARD,
    PAYPAL,
    BANK_TRANSFER
}
```

단순 데이터 차이는 enum으로 충분할 수 있다.

반면 동작 차이가 크고 외부 API 연동 방식도 서로 다르면 전략 객체가 적절하다.

결국 다형성은 객체 수를 늘리기 위한 기술이 아니라, **실제로 변하는 행동을 격리하기 위한 도구**다.

---

## 정리

다형성은 변경에 유연한 코드를 만들 수 있는 강력한 객체지향 도구다.

하지만 맹목적으로 적용하면 다음 문제가 발생할 수 있다.

```text
계층과 클래스 수 증가
책임 분산
응집도 저하
내부 정보 노출
캡슐화 저하
코드 흐름 추적 어려움
```

이런 문제가 나타난다면 다형성을 없애야 한다는 뜻이 아니라, 책임이 올바른 객체에 배치되어 있는지 다시 살펴봐야 한다.

리팩토링의 핵심은 다음과 같다.

```text
관련 데이터와 행동을 가까이 둔다
객체 내부 정보를 외부로 꺼내지 않는다
전체 흐름과 변경되는 부분을 구분한다
실제 요구사항에 필요한 만큼만 추상화한다
```

다형성의 가치는 인터페이스와 구현체의 개수로 평가되지 않는다.

다형성을 적용한 결과 다음 질문에 긍정적으로 답할 수 있어야 한다.

```text
새 기능을 추가하기 쉬워졌는가?
기존 코드의 변경이 줄어들었는가?
책임이 더 명확해졌는가?
객체의 내부 정보가 더 잘 숨겨졌는가?
코드 전체를 이해하기 쉬워졌는가?
```

이 질문에 답하기 어렵다면 다형성은 확장성을 높인 것이 아니라 복잡성을 다른 곳으로 옮긴 것일 수 있다.

### 한 줄 요약

**좋은 다형성은 실제로 변하는 행동을 격리하지만, 맹목적인 다형성은 책임을 흩뜨리고 코드의 복잡성만 높인다.**
