---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 자스민, 병민의 웹팩 최적화
date: '2022-10-11 00:00:00 +0900'
categories:
    - study
    - inflearn
    - elegant-tekotok
comments: true
---

# 자스민, 병민의 웹팩 최적화
[https://youtu.be/QXYWlqK2eHI](https://youtu.be/QXYWlqK2eHI)
[https://youtu.be/lsXhMLlbT3M](https://youtu.be/lsXhMLlbT3M)

# 자스민, 병민의 웹팩 최적화
* toc
{:toc}

## 웹팩이란?
+ 웹팩은 오픈 소스 자바스크립트 모듈 번들러로써 여러개로 나누어져 있는 파일들을 하나의 자바스크립트 코드로 압축하고 최적화하는 라이브러리입니다.

## 모듈번들러란?
+ 웹 애플리케이션을 구성하는 자원(HTML, CSS, JS, IMAGE 등등) 을 모두 각각의 모듈로 보고, 이를 조합해서 병합된 하나의 결과물을 만드는 도구 

## 웹팩은 왜 나오게 되었을까?
+ javascript 에서의 모듈의 한계가 들어나서 그에따라 웹팩이 등장하였다.
+ javascript 에서는 script 태그를 분리하여 모듈처럼 사용하고 있는데 이렇게 이용하게 된다면 전역을 공유하기 때문에 같은 변수 이름에 대해서 문제가 발생하게 된다. 
  + 해별방법 1 
    + IIFE(즉시 실행함수) - 사용법이 어렵다. 
  + 해별방법 2
    + AMD, CommonJs 등의 다양한 모듈 스펙 - 모든 브라우저에서 지원하지 않는다. 
  + 위의 문제로 인해 웹팩이 등장 

## 웹팩의 기본 옵션
+ Entry
  + 앱이 번들 처리를 시작할 지점을 뜻한다. index.js부터 시작해서 import 문을 따라서 빌드를 진행한다.
+ Output 
  + output은 번들링 된 결과물의 위치 및 파일 이름을 지정해 준다. path나, filename이라는 옵션으로 위치 및 파일 이름을 지정할 수가 있다. 
  + 여기서 이미지나 파일 같은 외부 리소스를 로드할때는 또다른 path가 필요하다.
    + publicPath: publicPath는 prefix 개념으로 사용자가 webpack.config.js 에 설정한 주소가 실제 배포되는 주소 앞에 설정이된다.
+ Resolve
  + 이 옵션은 모듈을 해석하는 방식을 변경 할 수 있다. 예를 들어 alias 옵션을 이용할 시에는 특정 모듈의 별칭을 만들 수 있다. 일반적으로는 사용되는 src 폴더의 별칭을 지정할 수 있다.
+ Loader
  + 기본적으로 Webpack은 JavaScript 및 JSON 파일만 해석 자능하다. 하지만 로더를 사용하면 Webpack이 다른 포멧의 파일을 처리하고, 이를 앱에서 사용할 수 있는 모듈로 변환할 수 있다
  + CSS: style-loader, css-loader
  + File: file-loader, raw-loader, url-loader
  + Typescript: ts-loader
+ Plugin
  + 로더가 파일단위로 처리한다면 플러그인은 주로 번들된 결과물을 처리한다.
  + ex) html-webpack-plugin 
+ externals
  + externals 옵션은 출력 번들에서 의존성을 제외하는 방법을 제공한다.
  + 우리 코드가 의존하고 있지만 빌드 과정에서는 포함하지 않아도 되는, axios, jQuery 같은 써드파티 라이브러리를 이 externals에 명시하면 빌드 프로세스에 포함되지 않는다. 
+ performance
  + 성능과 관련된 옵션이다.
  + 예를 들어 파일이 250kb 가 넘어갈 경우 경고를 띄워준다.

## 웹팩의 최적화 
+ ![img.png](/assets/img/elegant-tekotok/webpack.png)

## 번들 사이즈 줄이기

### 번들 사이즈를 왜 줄여야 하나요?
1. 네트워크 비용
   + 파일이 무거울수록 네트워크 통신이 더 오래 걸린다.
2. 파싱 및 컴파일 비용
   + 브라우저의 main thread는 js를 파싱 및 컴파일 하고 사용자의 이벤트를 받아 처리한다.
   + 만약 js 파일의 크가가 크다면 파싱과 컴파일 하는데 시간이 오래걸리고 따라서 이벤트를 처리하는 시간이 길어지기에 유저들은 답답함을 느낄 수 있다.
3. 메모리 비용
   + 코드가 실해되지 않는다 하더라도 RAM에 코드가 올라가기 때문에 메모리를 낭비하게 된다.
   + 메모리가 작은 핸드폰 기종의 경우 페이지가 버벅이거나 느려질 수 있다. 

### 번들 사이즈를 줄이는 방법 

#### Webpack mode 
+ development vs production
  + Development : 강력한 소스 매핑, localhost 서버에서 라이브러리 로딩이나 hot module replacement 기능을 목적으로 이용한다.
  + Production : 로드 시간을 줄이기 위해 번들 최소화, 가벼운 소스맵 및 에셋 최적화에 초점을 맞춘다.
    + production mode 에서는 기본적으로 tersurPlugin을 이용하여 코드 압축, 난독화를 한다. 
    
#### 소스맵이란?
+ 소스맵이란 배포용으로 빌드한 파일과 원본 파일을 서로 연결시켜주는 기능이다.
+ 보통 서버에서 빠르게 전달되고 보안성을 높이기 위해서 난독화와 압축이 사용되는데 이럴경우 페이지에서 에러가 발생할 시 디버깅하기 힘들어진다. 
+ 브라우저의 디버깅툴은 난독화된 코드에서 에러가 난 부분을 가르키기 때문에 개발자로서는 에러가 난 코드가 애초에 무엇인지 알 수 가 없다.
+ 그래서 sourceMap이 등장 했다.
+ 소스맵은 원본코드를 특정한 알고리즘으로 인코딩하여 특정 키워드로 맵핑을 시켜놓으면 나중에 브라우저에서 난독화된 코드를 그대로 디코딩하여 복원시킬수 있다.
+ 소스맵은 어떻게 이루어져 있을까?
  + ![img.png](/assets/img/elegant-tekotok/sourceMap.png)
  + file: 연결된 파일명을 나타낸다.
  + sources: bundle.js 를 만드는데 활용된 소스 코드 파일 목록이다.
  + names: 소스코드의 모든 변수와 함수이름이 기록된다.
  + mapping: 실제 코드와 매핑할 수 있다록 하는 데이터이며 Base64 VLQ 로 인코딩되어 기록된다. 
+ 소스맵의 종류 
  + None
    + 소스맵을 생서하지 않는다.
    + 최대 성능의 프로덕션 빌드에서 추천하는 옵션이다.
  + Source-map
    + 고품질 소스맵을 포함한 프로덕션 빌드를 위해 추천하는 옵션이다.
  + 대부분의 소습맵은 (option)-source-map 형식이다.
  + 옵션
    + eval: eval이 붙는 source map 옵션은 JavaScript 의 함수인 eval() 을 사용하여 source map 을 만든다. 
      + eval 함수는 각 모듈을 따로 실행시키기 때문에 수정된 모듈만 재빌드해서 빠르지만 정확한 소스 코드 위치를 매핑하지 못하는 경우가 종종 있다.
      + mode: development 에서 devtool 옵션을 주지 않으면 default 값으로 devtool: eval 이 들어간다.
      + 실제로 source-map 을 생성하지 않으려면 devtool: false 를 준 상태로 빌드를 진행해야한다.
    + inline: map 파일을 만들지 않고 주석에 파일을 data URL 로 적는다. Source Map 이 돌깁된 파일로 존재하지 않고 bundle.js 파일 내에 포함되게 된다. 
      + eval, inline 옵션은 소스맵을 bundle.js 파일내에 인라인으로 생성한다 eval은 리빌드가 빠르지만 정확한 매핑이 되지 않고 inline은 빌드, 리빌드 모두 느리지만 정확한 매핑이 가능하다. 
      + ![img.png](/assets/img/elegant-tekotok/sourceMap2.png)
    + hidden: source-map과 거의 동일하지만 소스맵에 대한 참조가 추가되지 않는다. 
      + 주로 사용자에게 개발자 도구에서 소스맵을 보여주고 싶지 않을 때 사용하는 옵션이다. 
      + ![img.png](/assets/img/elegant-tekotok/sourceMap3.png)
    + nosources: 소스코드가 제외된 소스맵이 생성된다.
      + ![img.png](/assets/img/elegant-tekotok/sourceMap4.png)
      + 주로 사용자에게 내부 소스코드를 보여주고 싶지 않을 때 사용한다.
    + Cheap: 라인 넘버만 매핑하고 라인에서 몇 번째 글자인지는 매핑하지 않습니다.
      + 에러가 나면 몇 번째 라인에서 발생했는지 알 수 있지만 실제로 몇번째 글자에서 발생했는지 알 수 없다.
  + 번들링 사이즈 비교
    + (none), hidden-source-map < source-map, cheap-module-source-map, nosource-source-map << eval < eval-source-map < inline-source-map
  + 빌드 속도 비교 
    + hidden-source-map, source-map, nosource-source-map, eval-source-map < cheap-module-source-map << eval < none
  + 리빌드 속도 비교
    + hidden-source-map, source-map, nosource-source-map < cheap-module-source-map << eval-source-map < none, eval 
+ mode 별 추천하는 소스맵
  + Development
    + eval: 매우 빠른 re-build와 빠른 build를 제공한다. 하지만 개발자가 작상한 코드가 아닌 babel, webpack 로 변환된 코드를 보게된다. 
    + eval-cheap-module-source-map: 빠른 re-build와 함께 소스맵을 제공한다. 하지만 정확한 매핑은 기대할수 없다.
    + eval-source-map: re-build가 약간 더 느리지만 좀더 성능 좋은 소스맵을 제공한다.
  + Production
    + none: 매우 빠른 re-build와 빠른 build를 제공한다. 소스맵을 제공하지 않기에 디버깅을 할 수 없다. 
    + source-map: 성능좋은 소스맵을 프로덕션 환경에서 사용하고 싶다면 이용한다. 
    + eval-*, inline-* 같은 소스맵은 인라인으로 생성되기 때문에 번들 사이즈가 커져서 프로덕션 빌드에 적합하지 않다.

#### 코드 스프리팅이란?
+ 우리가 자바스크립트로 애플리케이션을 개발하게 되면, 기본적으로 하나의 파일에 모든 로직들이 들어가게 된다. 
+ 그럼, 프로젝트의 규모가 커질수로 자바스크립트 파일의 용량도 커지게 된다. 용량이 커지면 페이지 로딩 속도도 느려진다.
+ 코드 스플리팅을 하게 되면, 지금 당장 필요한 코드가 아니라면 따로 분리시켜서, 나중에 필요할때 불러와서 사용 할 수 있다.
+ 전통적인 페이지에서 코드 스플리팅 하는법
  + entry-point 를 통하여 나누기 
    + ![img.png](/assets/img/elegant-tekotok/codeSplitting.png)
    + ![img.png](/assets/img/elegant-tekotok/codeSplitting2.png)
  + dynamic import를 이용하기 
    + dynamic import를 사용하면 러타임시 필요한 module을 import할 수 있다. 
    + import(경로) 형식으로 사용하며 Promise를 반환한다. 
    + ![img.png](/assets/img/elegant-tekotok/codeSplitting3.png)
    + 하지만 dynamic import는 모든 브라우저에서 지원하지 않는다. 
      + 설정이 필요하다.
      + ![img.png](/assets/img/elegant-tekotok/codeSplitting4.png)
      + output에 chunkFilename과 babel의 plugin-syntax-dynamic-import 플러그인을 추가해서 이용한다.
    + Prefetch/preload
      + preload: 현재 페이지에서 확실히 사용되는곳에 이용을 한다.
        + ![img.png](/assets/img/elegant-tekotok/codeSplitting5.png)
        + 동적 import 안에 인라인으로 주석을 작성해서 이용을 한다. 
        + 반드시 내가 먼저 불러와야 되는 모듈에 대해서 이용한다
        + ex) 글꼴 
      + Prefetch: 추후에 사용될것 같은곳에 이용한다.
        + ![img.png](/assets/img/elegant-tekotok/codeSplitting6.png)
        + 동적 import 안에 인라인으로 주석을 작성해서 이용을 한다.
        + 로그인 버튼을 클릭하면 로드인 모달이 뜨는 어플리케이션이 있다고 가정하면 로그인 버튼을 누르기 전까지는 로그인 모달을 부를 필요가 없다. 
        그래서 로그인 모달에 prefetch 옵션을 주게되면 브라우저의 유휴 시간 동안 로그인 모달을 불러오게 된다. 
+ SPA로 구현된 react project 에서 코드 스플리팅 하는법
  + react 에서는 컴포넌트을 동적으로 불러오기 위해서는 React.lazy를 사용해야 한다.
  + React.lazy 를 사용하기 위해서는 하나의 조건이 있다. React.Suspense를 함께 이용해야 한다. 
  + ![img.png](/assets/img/elegant-tekotok/codeSplitting7.png)
  + ![img.png](/assets/img/elegant-tekotok/codeSplitting8.png)
+ optimization.splitChunks 
  + 중복된 모듈을 처리하기 위한 옵션 splitChunks 
  + ![img.png](/assets/img/elegant-tekotok/codeSplitting9.png)
  + isNull 은 왜 분리되지 않을까? 
    + Webpack 은 다음 조건에 따라 자동으로 청크를 분할한다. 
      + 새 청크를 공유 할 수 있거나 모듈이 node_modules 폴더에 있는 경우 
      + 새 청크가 20kb보다 클 경우(min+gz 이전에)
      + 요청 시 청크를 로드할 때 최대 병렬 요청 수가 30개 이하일 경우
      + 초기 페이지 로드 시 최대 병렬 요청 수가 30개 이하일 경우 
      + 커스텀으로 변경 가능하다.

#### tree shaking
+ 일반적으로 사용하지 않는 코드를 번들링 결과에 포함하지 않는 일
+ 사용하지 않는 코드?
  + ![img.png](/assets/img/elegant-tekotok/treeShaking.png)
+ 그럼 이런것도 tree shaking 인가요?
  + ![img.png](/assets/img/elegant-tekotok/treeShaking2.png)
  + 이런 경우는 tree shaking 이라고 보기 어렵다. tree shaking 은 import와 export로 모듈들이 연결되는게 중요하기 때문이다.
  + import와 export 를 사용하지 않고 단순히 b,c 함수를 사용하지 않는 것이기 때문에 tree shaking 이라고 보기 어렵다  
+ ![img.png](/assets/img/elegant-tekotok/treeShaking3.png)
  + import와 export로 연결된 모듈 중에서 사용되지 않은 것들을 지우는 것을 의미한다.
+ 그냥 지워버리면 되는거 아닌가요?
  + 만약에 우리가 작성한 코드라면 그냥 폴더에서 파일을 삭제하면 되지만 어떤 라이브러리를 사용할 때는 함부로 node_modules 폴더에 접근해서 파일을 삭제하면 안 된다. 
+ 그럼 tree shaking 을 왜 알아야 하나요?
  1. Library
     + 라이브러리를 만드는 경우에는 Tree Shaking 개념을 알고 있어야 소비자들의 자원이 낭비되지 않는다.
     + 소비자들은 webpack 을 쓸지 rollup 을 쓸지 또 webpack 최신 버전을 안쓸지도 모르기 때문이다. 
  2. commonjs
     + tree shaking의 개념을 알고 있으면 오래전에 commonjs 방식으로 개발된 lodash 같은 라이브러리를 사용할 때 더 조심할 수 있게 된다. 
     + 사용하지 않는 코드들도 다 같이 불러와질 수 있기 때문이다. 
+ tree shaking 은 어떻게 하나요?
  + production mode 를 켜면 알아서 잘 이루어 진다. 
+ 라이브러리를 만드는 경우라면?
  + tree shaking 을 함에 있어서 사이드 이펙트에 대해 알고 있어야 된다. 
  + side effect
    + import 하는 것 만으로도 실행되서 외부에 영향을 끼치는 코드. polyfill
    + sideEffects: [".."]
      + ![img.png](/assets/img/elegant-tekotok/sideEffect.png)
      + package.json 의 sideEffects 속성에 사이드 이팩트가 있는 파일의 위치를 정해주면 webpack 은 이파일에 사이드 이팩트가 있고 다른 파일들은 다 사이드 이펙트가 없는 
      pure 한 코드들이겠구나 라고 생각하고 tree shaking 을 한다. 
    + sideEffects: false
      + 모든 모듈에 사이드 이펙트가 없다는 것이다. 
##### tree shaking 실험 1
+ webpack config
  + mode: development
  + usedExports: true
    + 어떤 export 가 사용됐는지 안 됐는지에 대한 정보를 수집하고  빌드 결과에 comment 로 export 가 사용됐는지 안 됐는지 표시해주는 역할을 한다. 
    + 개발 모드에서는 단순히 주석을 달기 위해 사용됐지만 실제 프로덕션 모드에서는 다른 플러그인 설정과 함께 사용되어서 tree shaking 에 중요한 역할을 한다. 
+ ![img.png](/assets/img/elegant-tekotok/treeShaking4.png)
  + main.js 에서 utils 에 있는 a와 b를 import 한 상황이다.
+ ![img.png](/assets/img/elegant-tekotok/treeShaking5.png)
  + utils 는 index.js 에서 a,b,c 를 re-export 하고 있는 상황이다. 
+ ![img.png](/assets/img/elegant-tekotok/treeShaking6.png)
  + 사이드 이펙트를 package.json 에 명시하지 않은 경우 a,b,c 가 모두 번들 결과에 포함된다.
    + c 같은 경우는 usedExports 를 true 로 했기 때문에 unused harmony export c 라는 주석이 붙어있다. 사용되지 않는 export 라는 말이다. 
      + 여기서 harmony 는 단순히 ES6의 모듈을 의미한다. 
  + sideEffects 를 false 로 했을 때는 사이드 이펙트가 없음 이라고 명시해줬기 때문에 index.js 가 c를 import 했지만 c 는 사용되지 않고 사이드 이펙트가 없을 명시 했기 때문에
  c 는 포함되지 않는다. 
##### tree shaking 실험 2
+ ![img.png](/assets/img/elegant-tekotok/treeShaking7.png)
  + utils.js 에서 a,b를 똑같이 import 했고 이번에는 utils.js 안에 모든 함수들을 export 했다. 함수들을 파일 별로 쪼갠 것이 아니다. 
+ ![img.png](/assets/img/elegant-tekotok/treeShaking8.png)
  + 이런 상황에서는 a,b,c가 아까처럼 사이드 이펙트가 있다고 판단됐기 때문에 모든 걸 다 번들링에 포함 하는데 이렇게 사이드 이펙트가 없다고 명시해 줬음에도 c는 포함이 된다.
  왜냐면 a,b 안에서 c 를 사용하고 있는지 안 하고 있는지 확신할 수 없기 때문이다. 
+ 앞에 실험으로 알 수 있는 것은 라이브러리를 만드는 입장이라면 한 파일 안에서 여러 개 export 를 하지 말고 파일 하나당 하나의 export 를 해서 라이브러리 사용자들의 
번들러가 tree shaking 을 더 잘 할 수 있도록 하는 것이다 
##### tree shaking 실험 3
+ ![img.png](/assets/img/elegant-tekotok/treeShaking9.png)
  + AllUtils 에 한번데 다 넣으면 이렇게 a,b 두 가지만 사용했을 때
  + ![img.png](/assets/img/elegant-tekotok/treeShaking10.png)
    + sideEffects 를 지정하지 않은 경우 모두 포함되고 false 로 했을 경우에는 c 가 잘 삭제 되는 걸 확인할 수 있다. 
##### tree shaking 실험 4
+ ![img.png](/assets/img/elegant-tekotok/treeShaking11.png)
  + import 만 하고 사용하지 않는 경우
  + ![img.png](/assets/img/elegant-tekotok/treeShaking12.png)
    + sideEffects 를 지정 안했을 경우에는 이런 식으로 사용하지 않았음에도 polyfill 처럼 전체 코드에 어떤 영향을 끼칠지 모르기 때문에 임의 판단하지 않고 a,b,c 를다 가져온다.
      + 다만 사용되지 않았다고 주석이 붙는다. 
    + sideEffects 를 false 했을 때는 a,b 를 import 했지만 어느 곳에서도 사용을 하지 않았고 사이드 이펙트가 없음을 명시해놨기 때문에 코드를 번들링에 포함하지 않는다. 
##### tree shaking 실험 5
+ ![img.png](/assets/img/elegant-tekotok/treeShaking13.png)
  + 아까처럼 a,b 를 index.js 에서 re-export 한 상황이고 c 는 좀 달라졌다. 안에 hihi 라는 함수가 있고 c 에서 hihi 함수를 호출한다. 
  c.js 에서 hello.js 를 import 하고 hihi 에서 hello.js 에서 가져온 함수를 호출 한다. 
  + webpack config
    + mode: development
    + usedExports: true
    + innerGraph: true
      + 그래프 안에 있는 그래프까지도 tree shaking 해주겠다는 의미이다. 
      + webpack5 이상에서만 사용가능하다.
  + ![img.png](/assets/img/elegant-tekotok/treeShaking14.png)
    + 결국에는 사용되지 않았기 때문에 hello.js 도 c 와 함께 포함되지 않은 걸 확인할 수 있다.

##### tree shaking 과 CommonJs 관계 
+ CommonJs 는 2009년에 나왔다. 모듈을 더 작성하기 쉽고 모듈들의 의존성을 좀 관리하기 쉽게 만들 수 있도록 도와주는 역활을 한다.
+ ![img.png](/assets/img/elegant-tekotok/CommonJs.png)
  + 이런 식으로 require 한다. 
  + ![img.png](/assets/img/elegant-tekotok/CommonJs2.png)
    + 문제는 require 가 함수기 때문에 이렇게도 작성할 수 있다는 것이다.
    + 이런 것을 보통 동적(dynamic) 이라고 하는데 동적으로 했을 때 장점도 있지만 tree shaking 입장에서는 동적으로 하게 되면 런타임(runtime) 까지 가봐야 
    어떤 것들을 실제로 import 한지 알 수 있기 때문에 tree shaking 이 제대로 이루어지지 않는다.
    + 그래서 CommonJs 방식으로 작성된 라이브러리 같은 경우에는 tree shaking 을 일반적으로 지원하지 않는다.
    + webpack5 에서는 CommonJs 에서도 어느 정도는 tree shaking 을 지원한다. 
    + CommonJs 방식으로 이루어진 라이브러리를 사용할 때는 주의가 필요하다. 
+ ES 모듈과 webpack 은 궁합이 잘 맞는다. ES 모듈 방식으로 의존성(dependency)을 관리하면 정적이어서 런타임 까지 가지 않고 빌드 타임 때 그모듈이 사용되는지 안 사용되는지를 
명확하게 파악할 수 있기 때문이다. 그래서 라이브러리를 만들때 ES 모듈 방식으로 라이브러리를 만들고 프로젝트에서 라이브러리를 쓸 때도 가급적이면 ES 모듈 방식으로 
작성된 라이브러리를 사용하는게 tree shaking 에 이점이 있다. 

#### 기타 - html, css 최적화
+ html: html-webpack-plugin 의 minify option 을 이용하면 html 상의 공백, 주석 등 서비스에 필요없는 코드들을 삭제할 수 있다.
  + ![img.png](/assets/img/elegant-tekotok/remainder.png)
+ css: mini-css-extract-plugin: js와 css 코드의 분리가 가능하다. css-loader 를 써서 받은 css 코드를 파일로 추출해 낸다.
  + 또 브라우저 캐싱의 도움을 받을 수 있다. 
+ css-minimizer-webpack-plugin 을 사용하면 한줄로 css 를 압축해 준다. 

## 빌드 속도 높이기 
+ webpack 5에 와서 persistent cache 라는 기능이 추가가 되었다.
  + persistent cache 하드디스크에 빌드된 결과물을 저장해 놓는다는 것이다. 그리고 다시 re-build 가 일어났을 때 파일이 변경되지 않았다면 하드디스크에 
  저장돼 있는 캐시 데이터를 재활용하고 만약에 변경이 되었다면 하드디스크에 있는 캐시 데이터를 무효화하는 일을 한다. 
+ persistent cache 예시
  + ![img.png](/assets/img/elegant-tekotok/persistentCache.png)
+ persistent cache 적용 방법
  + ![img.png](/assets/img/elegant-tekotok/persistentCache2.png)
    + cache 옵션에 type을 "filesystem" 으로 지정
      + 하드디스크를 사용한다는 의미
    + buildDependencies 의 config 에 파일 네임 정도만 정해주면 된다. 
      + 이렇게 해주면 더 안전하게 사용할 수 있다. 
+ 이렇게 좋은걸 왜 default로 하지 않았을까요?
  + 캐시의 무효화 정책이 상황에 따라 다르게 적용되야 하기 때문이다.
+ 상황에 따라 다른 캐시 무효화 정책?
  + cache options
    + ![img.png](/assets/img/elegant-tekotok/persistentCache3.png)
      + type은 "filesystem" 으로 저장해서 옵셥을 켜주고 buildDependencies는 webpack이 빌드 할때 사용하는 dependencies(의존성)를 의미한다. 
      + defaultWebpack
        + 빌드시에 사용하는 dependencies 파일들이 변했을 때 모든 캐시를 무효화하는 것이다.
      + config 
        + prod.js 파일이 바뀌었을때 모든 캐시를 무효화하는 것이다.
      + 이런 파일들은 빌드 전체 프로세스의 기반이 되기 때문에 항상 모든 캐시를 삭제해줘야 한다. 
  + snapshot options
    + ![img.png](/assets/img/elegant-tekotok/persistentCache4.png)
      + 캐시 말고도 snapshot 옵션을 지정할 수 있다. 
      + module
        + module 에 timestamp 를 true 로 한다는 것은 파일들의 timestamp 가 snapshot 과 비교해서 달라졌을 때는 캐시 데이터를 무효화하고 같은면 재활용한다는 의미이다.
        + module 에 hash 를 true 로 한다는 것은 파일들의 content hash 가 snapshot 과 비교해서 달라졌을 때는 캐시 데이터를 무효화하고 같은면 재활용한다는 의미이다.
      + buildDependencies
        + webpack 이 빌드할 때 필요한 dependencies 파일들의 timestamp 가 바뀐 경우에는 전체 캐시를 무효화 하고 같은 경우에는 캐시를 재활용한다는 옵션이다.
      + managedPaths
        + 보통 "node_modules" 가 기본 갑이 되어 있다.
        + yarn berry 나 다른 package manager 를 쓴다면 그에 따라 다시 바뀌게 된다.
        + 이것이 의미하는 바는 webpack 이 node_modules 안에 있는 모든 파일들의 snapshot 을 다 만들고 그 snapshot 을 관리하지 않겠다는 의미이다. 왜냐하면 비용이 너무 
        많아 들기 때문이다. 그래서 package manager 가 node_modules 의 버전을 업그레이드 하거나 이름이 바뀌었을 때만 캐스를 무효화 한다. 퍼포먼스를 위해서이다.
    + snapshot 이란 
      + ![img.png](/assets/img/elegant-tekotok/snapshot.png)
        + 캐시 옵션을 켜고 빌드하면 node_modules/.cache 폴더 안에 이런 식으로 .pack 파일이 캐시되는데 캐시된 데이터에 붙어있는 캐시 데이터의 정보들이 바로 snapshot 이다.
        + snapshot 콘솔로 찍으면
          + b.js를 빌드했을 때 나온 캐시 데이터의 timestamp 가 이런 숫자고 contents hash 가 이런 값이다 라는 것이다. 이런 데이터들이 캐시 데이터에 붙어서 존재하게 된다.
          + 그리고 이 값은 identifier(식별자) 이다. webpack 이 a.js 를 빌드할 때 src/a.js 라는 identifier 를 동적으로 얻어내고 그것을 이 .pack 파일에서 찾아서 
          캐시 데이터를 찾는 키 같은 역활을 한다.  
    + timestamp vs content hash (= hash)
      + timestamp (속도 good, 안정성 bad)
        + 파일이 변경된 시간
        + 빌드시 파일의 meta data 로부터 timestamp 를 가져와서 snapshot 에 기록된 timestamp 와 비교한다.
          + timestamp 같다면 캐시 데이터를 가져와서 사용한다.
          + timestamp 달라졌다면 캐시 데이터를 무효화 한다. 
        + 메타데이터만 가져와서 비교를 하기 때문에 안전상이 떨어지고 속도는 좋다.
          + 파일 수정 없이 control + s 만 해도 timestamp 가 변경된다.
          + git 사용할때 쉽게 timestamp 가 변경된다
        + content hash (속도 bad, 안정성 good)
          + 파일의 content 를 바탕으로 hashing 한 string
          + 빌드시 파일의 content 를 가져와서 hashing 한 뒤 그 string 과 snapshot 에 기록된 content hash 와 비교한다.
            + content hash 같다면 캐시 데이터를 가져와서 사용한다.
            + content hash 달라졌다면 캐시 데이터를 무효화 한
          + 파일의 실제 content 를 갖고 와서 hashing 하는 작업이기 때문에 timestamp 를 가져오는 것보다는 속도가 더 느리다. 

### 상황별 추천 snapshot options
+ 로컬 개발 환경
  + 빌드가 자주 일어나기 때문에 빌드 과정 속에서 content hash 를 이용하게 되면 파일의 내요을 갖고 와서 hashing 하는 일이 추가 된다.
  속도가 느려져서 timestamp 만 사용하면 캐싱 비교작업이 빨리 이루어진다. 
  + buildDependencies: timestamp - true
    + 프로젝트 사이즈가 큰 경우에는 hash - true 도 추가한다.
  + module: timestamp - true
  + resolve: timestamp - true
+ CI Build
  + CI Build 할 때는 주로 git 에서 clone 해오기 때문에 파일의 timestamp 가 전부 다 바뀌어 버린다. 그런 경우에는 timestamp 를 true 하는 것이 별로 의미가 없다. 
  + buildDependencies: hash - true
  + module: hash - true
  + resolve: hash - true
+ CI Build with update
  + 즉 git pull 만 하는 경우에는 timestamp 와 hash 둘 다 true 로 해주면 효율적이다. 
  + buildDependencies: timestamp - true / hash - true
  + module: timestamp - true / hash - true
  + resolve: timestamp - true / hash - true