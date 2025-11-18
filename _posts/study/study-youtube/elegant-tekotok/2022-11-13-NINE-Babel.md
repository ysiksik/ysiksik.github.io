---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 나인의 Babel
date: '2022-11-13 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 나인의 Babel
[https://youtu.be/o-5K5Sc7L1k](https://youtu.be/o-5K5Sc7L1k)

# 나인의 Babel
* toc
{:toc}

## Babel
+ 구형 브라우저나 환경에서 ES6 이상의 기능들을 사용하기 위해서 이전 버전의 자바 스크립트 버전으로 변환해주는 도구를 의미한다. 

### Babel 사용법
+ 간단한 예시: 화살표 함수 transpiling
  + ![img.png](/assets/img/elegant-tekotok/NINE-Bable.png)
    + @babel/core: 바벨의 핵심적인 기능
    + babel/cli: 터미널로 바벨을 사용
    + @babel/plugin-transform-arrow-functions: 화살표 함수를 transform하는 플러그인
    + ![img.png](/assets/img/elegant-tekotok/NINE-Bable2.png)
      + ![img.png](/assets/img/elegant-tekotok/NINE-Bable3.png)
        + ES6에 추가된 const와 arrow function이 transform되었다.
+ 매번 플러그인을 하나씩 설치해야 되는 번거로움이 있고 플러그인을 설치할 때마다 명령어 뒤쪽의 플러그인 옵션에 하나씩 추가를 해줘야 되는데 이걸 매번 명령어로 작성하자니 번거롭다.
  + 그래서 보통은 바벨 설정 파일과 Preset을 활용한다.
  + config 파일 활용, babel.config.json 혹은 .babelrc.json 파일
  + Preset 활용
    + 다양한 플러그인들을 한데 모아서 만들어준 집합 관계같은 프리셋인데 프리셋을 활용하면 매번 번거롭게 플러그인을 설치할 필요 없이 한번에 바벨 트랜스파일링을 진행할 수 있다.

## Polyfill
+ 폴리필은 충전 솜이라는 의미를 갖고 있다. 
+ 부족한 것들을 채워 넣어준다라는 의미가 있다.
+ 바벨에서도 부족한 부분을 채워주는 것이 폴리필이다.
+ 구형 브라우저에서 자체적으로 지원하지 않는 최신 기능들을 지원하고자 가져오는 코드 뭉치라고 볼 수 있다.
+ 바벨은 프리셋과 플러그인을 통해서 코드를 트랜스파일링 하는데 코드들을 트랜스파일링 한다고 모든 기능들을 다 사용할 수 있는 게 아니다. 
  + 예를 들면 Promise 같은 빌트은 객체들 아니면 Array에 있는 includes 같은 인스턴스 메서드들은 트랜스파일링을 진행하더라도 코드가 변하지 않고 남아 있는 경우가 있는데 이런 경우에 문제가 발생할 수 있다. 
  + 타겟 환경에서 만약에 저런 빌트인 메서드들이 존재하지 않는다면 이 코드 자체가 에러를 발생하게 된다.
  + 이럴 때 필요한 것이 폴리필이다. 
+ 폴리필은 말 그대로 코드 뭉치로서 런타임에서 타겟환경에 빌트인이나 메서드가 존재하지 않으면 이를 확인하고 ECMA 최신 환경을 맞춰주기 위해서 코드들을 삽입하게 된다. 

### Polyfill 사용법 
+ @babel/polyfill라는 걸 예전에 사용했는데 7.4 버전부터는 이제 사용하지 않고 있다.
+ @babel/polyfill 대신에 core-js가 들어오게 됐다. 
+ @babel/polyfill이 사라지게 되면서 useBuiltIns 옵션이 같이 들어오게 됐다.
+ useBuiltIns 옵션과 core-js의 버전명시를 같이 해주게 되면은 import할 때 좀 더 효과를 볼 수 있다. 
+ useBuiltIns: entry
  + core-js/stable과 regenerator-runtime/runtime 모듈을 전역 스코프에 직접 삽입한 경우 이를 타깃 환경에 필요한 폴리필만 전역 스코프에 추가되도록 변경 
+ useBuiltIns: usage
  + 실제 필요한 폴리필만 삽입
  + import 자체를 삽입해줘서 따로 삽입할 필요 없다. 
+ core-ja만 단독적으로 사용하기만 하면은 원하는 것들을 다 일룰 수 있진 않다. 
  + Array에 있는 includes 나 indexOf 같은 것들 전부 다 구현이 되어 있다. 인스턴스, 메서드 전부 다 잘 동작한다. 하지만 전역 스코프가 오염될 수 있는 단점이 있다. 
  + core-js같은 경우에는 전역에 존재하지 않은 메서드들이나 빌트인들을 바로 주입해서 사용하기 때문에 전역 스코프가 오염 될 수 있다. 
    + 전역스코프가 오염되면 당연히 이름 충돌도 발생할 수 있고 외부에서 사용하는 라이브러리같은 경우를 가져왔을 때 만약 거기서 전역 스코프를 오염시켜 버리면 그 개발자는 예상치 못한 에러를 마주할 수도 있다. 
    + 그렇기 때문에 @babel/plugin-transform-runtime라는 것을 core-js와 함께 사용해준다.
  + @babel/plugin-transform-runtime + core-js@3 플러그인을 설치하고 core-js-pure 패키지에서 폴리필 삽입하게된다. 전역 스코프를 오염시키지 않고 잘 가져오게 된다.  
    + 이것도 문제가 있다. 플로젝트 내 패키지 중 전역 스코프에 의존하는 패키지가 존재한다면? 
      + Axios 같은 거는 전역에 존재하는 Promise를 의존하고 있다. 근데 이 node modules에 있는 Axios가 만약에 트랜스파일링이 되지 않으면 문제가 발생할 수 있다. 만약에 타겟 환경이 빌트인으로 프로미스가 없으면은 이 부분에 에러가 발생 된다.
      그래서 해당 패키지를 포함해서 반드시 트랜스파일링이 진행해 줘야 된다. 
      + 이때 필요한 것이 바벨 설정파일이다.
    + babel.config.json
      + 여러 패키지 디렉토리를 가진 프로젝트에서 하나의 바벨 설정을 적용하고 싶을 때 
      + Node_modules도 적용하고 싶을 때 
    + babelrc.json
      + 프로젝트 내에 서드 파티 라이브러리가 바벨에 의해 트랜스폼되기를 바라지 않는 경우 
      + 특정 부분만 적용하고 싶은 경우 

## Webpack에서의 babel
+ 어느 정도 규모가 있는 자바스크립트 프로젝트에서는 웹팩같은 모듈 번들러를 사용한다. 각 파일의 의존성을 파악해서 각 몇 개의 압축파일로 만들어 주고 최적의 결과를 만들어 준다. 그래서 보통 웹팩을 많이 사용한다. 
+ 바벨과 웹팩을 연결시켜주는 것이 바벨 로더이다. 
+ 바벨을 7 버전 부터 타입스크립트도 트랜스파일링 할 수 있게 지원을 해줬는데 

### babel-loader VS ts-loader
+ Type check
  + 바벨로더는 타입 체킹을 해주지 않지만 ts 로더는 체킹을 해준다. 
+ const enums
  + 바벨은 지원하지 않는다.
  + 하지만 (2017.7.26 출시된) Babel 7.15버전부터는 모든 TS 코드 베이스를 컴파일할 수 있다.
+ Decorator
  + Typescript의 decorator 아직까지도 많은 변화가 있는 기능이다.
  + Babel을 ECMAscript spec 기준이다보니 decorator를 typescript가 원하는대로 완전히 컴파일하지 못한다.
  + 관련된 플러그인을 사용하면 이 또한 가능하다. 
+ 빌드 속도 차이
  + 바벨 로더가 십 초 정도씩 더 빠르다
