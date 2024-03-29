---
layout: post
bigtitle: '우아한테크코스 테코톡'
subtitle: 이스트의 로깅
date: '2022-11-03 00:00:00 +0900'
categories:
    - elegant-tekotok
comments: true
---

# 이스트의 로깅 
[https://youtu.be/1IMJCg68-lU](https://youtu.be/1IMJCg68-lU)

# 이스트의 로깅
* toc
{:toc}

## 로깅의 역사
+ 로깅이 나오기 전에는 println()을 사용했다. 
  + System.out.println()
  + System.err.println()
  + 문제점
    + 어떤 환경이든 똑같이 동작하게 된다 
+ log4j 등장 
  + log4j는 println()의 어떤 환경에서든 똑같이 동작하는 성질을 로그레벨을 통해서 해결했다.
  + 환경마다 다르게 로그레벨을 설정해서 개발환경에서 로깅한 정보와 운영환경에서 로깅한 정보를 구분했다.
  + 레벨 : FATAL, ERROR, WARN, INFO, DEBUG, TRACE
+ 자카르타 프로젝트에 사용하던 로깅 프레임워크가 있었는데 jdk 1.4 배포와 함께 java.util.logging - JUL 패키지가 되어 같이 배포가 되었다
  + log4j와 경쟁을 했는데 log4j는 이미 많은 사람들이 쓰고 있었고 JUL과 log4j는 로그 레벨이 달랐기 때문에 매핑이 되지 않았다 그렇기 때문에 JUL은 log4j에 비해 뒤처질 수밖에 없었다.
  + 일부 라이브러리들은 JUL 패키지로 마이그레이션을 했고 두 프레임워크를 모두 사용한 라이브러리를 이용해서 어플리케이션을 개발하는 개발자는 두 프레임워크를 모두 설정해 줘야 했다.
    + 이런 설정의 번거로움을 줄이기 위해서 Java Commons Logging JCL이 등장했다.
+ JCL
  + 동적 바인딩을 통해서 런타임에 구현체를 로드하는 방법으로 여러 구현체들을 연결시켜주었다.
  + JCL은 결국 스프링의 기본 설정이 되었고 JCL에는 치명적인 문제가 있었다. 
    + 클래스 로더 이슈
      + 다중 클래스 로더 환경에서 예외가 발생하는 문제가 있었고 메모리 누수 문제도 있었다. 
      + 레거시로 남아있는 로깅 프레임워크를 그대로 사용하지 못하고 JCL로 변경해줘야 한다는 단점이 있었다.
      + 결국에 JCL도 JUL과 log4j와 마찬가지로 같은 경쟁선상에서 놓이게 됐다.
  + log4j 메인 컨트리뷰터인 개발자가 새로운 로깅 프레임워크를 개발 - slf4j 
+ slf4j
  + 정적 바인딩을 통해 동적 바인딩으로 인한 클래스 로더 이슈를 해결했다. 
  + JCL과 마찬가지로 여러 로깅 프레임워크들을 연결시켜 주었다. 
  + 브릿지라는 기능을 제공했다. 
    + 레거시로 남아있던 프레임워크들을 호출했을 때 slf4j로 리다이렉션을 시켜주어 slf4j를 이용하는 것처럼 사용할 수 있었다. 

## 로그 LEVEL

| 레벨    | 설명                                                                    |
|-------|-----------------------------------------------------------------------|
| FATAL | 어플리케이션이 꺼질 수 있는 심각한 오류                                                |
| ERROR | 어플리케이션이 계속 실행은 되지만, 기능이 정상적으로 동작하지 않는 오류                              |
| WARN  | 당장 피해는 없지만, 잠재적으로 위험이 될 수 있는 상황에 대한 경고                                |
| INFO  | 프로그램의 진행상황을 알려주는 정보성 로그 레벨                                            |
| DEBUG | 자세한 진단 정보를 보여줌                                                        |
| TRACE | DEBUG 레벨보다 더 자세함. 애플리케이션의 문제 해결 또는 써드파티 라이브럴리에서 발생한 일을 확인해야 하는 경우 사용  |

+ FATAL
  + 프로그램이 정상적으로 동작하지 않기 때문에 로그 레벨이 정상적으로 기록되지 않을 확률이 있어 실제로는 잘 쓰이지 않는 것이 좋다
+ ERROR
  + 개발자가 의도하지 않는 예외를 기록하고 싶을때 사용 
+ DEBUG 
  + 개발 단계에서 디버깅을 위해서 사용되는데 굉장히 자세한 정보가 나타나기 때문에 운영환경에서는 사용하지 않는 것이 좋다. 
+ TRACE
  + TRACE 레벨은 절대로 운영환경에서 쓰면 안된다. 
+ 로그레벨을 설정하면 설정한 레벨에 하위레벨은 기록되지 않는다.

## logback 설정
+ Appender: 로그를 어디에 쓸 것인지를 정하는 인터페이스 
  + OutputStreamAppender: 콘솔이나 파일에 출력 
    + ConsoleAppender: 콘솔에 로그를 출력하겠다는 뜻 
    + FileAppender: 로그를 파일에 출력하겠다는 뜻
    + RollingFileAppender: 어떤 특정 조건에 맞춰 각기 다른 파일에 로그를 기록하겠다는 설정 
  + SMTPAppender: 로그를 메일로 보낼 수 있다.
  + SoketAppender: 로그를 원격 서버로 전송할 수 있다. 
+ 자바로도 설정 가능한데 왜 xml로?
  + 자동 리로딩 기능 때문이다.
    + 설정 xml 파일의 변경을 스캔해 자동으로 재설정
      + 서버 재시작 필요하지 않다.
