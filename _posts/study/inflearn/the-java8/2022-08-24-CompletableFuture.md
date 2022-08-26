---
layout: post
bigtitle: '더 자바, Java 8'
subtitle: CompletableFuture
date: '2022-08-24 00:00:00 +0900'
categories:
    - study
    - inflearn
    - the-java8
comments: true
---

# CompletableFuture

# CompletableFuture
* toc
{:toc}


## 자바 Concurrent 프로그래밍 소개

### Concurrent 소프트웨어
+ 동시에 여러 작업을 할 수 있는 소프트웨어

### 자바에서 지원하는 컨커런트 프로그래밍
+ 멀티프로세싱 (ProcessBuilder)
+ 멀티쓰레드

### 자바 멀티쓰레드 프로그래밍
+ Tread / Runnable

### Thread 상속

~~~java

    public static void main(String[] args) {
        HelloThread helloThread = new HelloThread();
        helloThread.start();
        System.out.println("hello : " + Thread.currentThread().getName());
    }

    static class HelloThread extends Thread {
        @Override
        public void run() {
            System.out.println("world : " + Thread.currentThread().getName());
        }
    }

~~~


### Runnable 구현 또는 람다

~~~java

Thread thread = new Thread(() -> System.out.println("world : " + Thread.currentThread().getName()));
thread.start();
System.out.println("hello : " + Thread.currentThread().getName());

~~~

### 쓰레드 주요 기능
+ 현재 쓰레드 멈춰 두기 (sleep): 다른 쓰레드가 처리할 수 있도록 기회를 주지만 그렇다고 락을 놔주진 않는다.(잘못하면 데드락 걸릴 수 있다.)
+ 다른 쓰레드 깨우기 (interupt): 다른 쓰레드를 깨워서 interruptedException 을 발생 시킨다. 그 에러가 발생 했을 때 할 일은 코딩하기 나름이다. 종료 시킬 수도 있고 계속 하던 일 할 수도 있다.
+ 다른 쓰레드 기다리기 (join): 다른 쓰레드가 끝날 때까지 기다린다.

~~~java

        Thread thread = new Thread(() -> {

            System.out.println("Thread: " + Thread.currentThread().getName());

            try {
                Thread.sleep(1000L);
            } catch (InterruptedException e) {
                System.out.println("끝!");
                return;
            }

        });

        thread.start();
        System.out.println("Hello: " + Thread.currentThread().getName());
        
        Thread.sleep(3000L);
        
        thread.interrupt();

~~~

~~~java

        Thread thread = new Thread(() -> {
            System.out.println("Thread: " + Thread.currentThread().getName());
            try {
                Thread.sleep(3000L);
            } catch (InterruptedException e) {
                throw new IllegalStateException(e);
            }
        });
        thread.start();

        System.out.println("Hello: " + Thread.currentThread().getName());
        try {
            thread.join();
        } catch (InterruptedException e) {
            e.printStackTrace();
        }
        System.out.println(thread + " is finished");

~~~

## Executors

### 고수준 (High-Level) Concurrency 프로그래밍
+ 쓰레드를 만들고 관리하는 작업을 애플리케이션에서 분리.
+ 쓰레드를 만들고 관리하는 작업을 Executors 에게 위임.

### Executors 가 하는 일
+ 쓰레드 만들기: 애플리케이션이 사용할 쓰레드 풀을 만들어 관리한다.
+ 쓰레드 관리: 쓰레드 생명 주기를 관리한다.
+ 작업 처리 및 실행: 쓰레드로 실행할 작업을 제공할 수 있는 API 를 제공한다.

### 주요 인터페이스
+ Executor: execute(Runnable)
+ ExecutorService: Executor 상속 받은 인터페이스로, Callable 도 실행할 수 있으며, Executor 를 종료 시키거나, 여러 Callable 을 동시에 실행하는 등의 기능을 제공한다.
+ ScheduledExecutorService: ExecutorService 를 상속 받은 인터페이스로 특정 시간 이후에 또는 주기적으로 작업을 실행할 수 있다. 

### ExecutorService 로 작업 실행하기
+ 여러 개의 요청을 보낼 시에 현재 지정한 개수의 스레드 풀에서 작업 중인 요청 말도 다른 요청들은 Blocking Queue에 쌓아 놓아서 대기한다.

~~~java

ExecutorService executorService = Executors.newSingleThreadExecutor(); //쓰레드 한개
// ExecutorService executorService = Executors.newFixedThreadPool(2); //쓰레드 두개
executorService.submit(() -> {
    System.out.println("Hello :" + Thread.currentThread().getName());
});

~~~

~~~java

    public static void main(String[] args) {
        ScheduledExecutorService executorService = Executors.newSingleThreadScheduledExecutor();
        executorService.scheduleAtFixedRate(getRunnable("Hello"), 1, 2, TimeUnit.SECONDS); // 1초만 기다렷다가 2초에 한번씩 실행해라
            // executorService.schedule(getRunnable("Hello"), 3, TimeUnit.SECONDS); //3초 있다가 실행해라
    }

    private static Runnable getRunnable(String message) {
        return () -> System.out.println(message + Thread.currentThread().getName());
    }

~~~

### ExecutorService 로 멈추기
+ 어떤 작업을 실행하고 나면 다음 작업이 들어올 때까지 계속해서 대기하기 때문에 명시적으로 shutdown 을 해야 한다.

~~~java

executorService.shutdown(); // 처리중인 작업 기다렸다가 종료
executorService.shutdownNow(); // 당장 종료

~~~

### Fork/Join 프레임워크
+ ExecutorService 의 구현체로 손쉽게 멀티 프로세서를 활용할 수 있게끔 도와준다.

## Callable 과 Future

### Callable
+ Runnable 과 유사하지만 작업의 결과를 받을 수 있다.

### Future
+ 비동기적인 작업의 현재 상태를 조회하거나 결과를 가져올 수 있다.
+ [https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html](https://docs.oracle.com/javase/8/docs/api/java/util/concurrent/Future.html)

### 결과를 가져오기 get()

~~~java

    ExecutorService executorService = Executors.newSingleThreadExecutor();
    Future<String> helloFuture = executorService.submit(() -> {
        Thread.sleep(2000L);
        return "Callable";
    });
    System.out.println("Hello");
    String result = helloFuture.get();
    System.out.println(result);
    executorService.shutdown();

~~~

+ 블록킹 콜이다.
+ 타임아웃(최대한으로 기다릴 시간)을 설정할 수 있다.

### 작업 상태 확인하기 isDone()
+ 완료 했으면 true 아니 false 를 리턴한다.

### 작업 취소하기 cancel()
+ 취소 했으면 true 못했으면 false 를 리턴한다.
+ parameter 로 true 를 전달하면 현재 진행중인 쓰레드를 interrupt 하고 그러지 않으면 현재 진행중인 작업이 끝날때까지 기다린다.
+ cancel() 을 호출하면 get()을 해서 값을 가져올 수 없다. - 에러가 발생한다. 

### 여러 작업 동시에 실행하기 invokeAll()
+ 동시에 실행한 작업 중에 제일 오래 걸리는 작업 만큼 시간이 걸리단.
+ ex) 모든 주가의 정보를 조회해서 한꺼번에 반환을 해야 할 때

~~~java

public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(4);

        Callable<String> hello = () -> {
            Thread.sleep(2000L);
            return "Hello";
        };

        Callable<String> java = () -> {
            Thread.sleep(3000L);
            return "Java";
        };

        Callable<String> keesun = () -> {
            Thread.sleep(1000L);
            return "Keesun";
        };

        List<Future<String>> futures = executorService.invokeAll(Arrays.asList(hello, java, keesun));

        for (Future<String> f : futures) {
            System.out.println(f.get());
        }


        executorService.shutdown();
    }


~~~

### 여러 작업 중에 하나라도 먼저 응답이 오면 끝내기 invokeAny()
+ 동시에 실행한 작업 중에 제일 짧게 걸리는 작업 만큼 시간이 걸린다.
+ 블록킹 콜이다.
+ ex) 서버 3개에 똑같은 파일이 있는데 그걸 가져오라고 요청할 때 먼저 도착한 걸로 작업 끝낼 때

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        ExecutorService executorService = Executors.newFixedThreadPool(4);

        Callable<String> hello = () -> {
            Thread.sleep(2000L);
            return "Hello";
        };

        Callable<String> java = () -> {
            Thread.sleep(3000L);
            return "Java";
        };

        Callable<String> keesun = () -> {
            Thread.sleep(1000L);
            return "Keesun";
        };

        String s = executorService.invokeAny(Arrays.asList(hello, java, keesun));
        System.out.println(s);

        executorService.shutdown();
    }

~~~

## CompletableFuture 1

### 자바에서 비동기(Asynchronous) 프로그래밍을 가능케하는 인터페이스
+ Future 를 사용해서도 어느정도 가능했지만 하기 힘든 일들이 많았다.

### Future 로는 하기 어렵던 작업들
+ Future 를 외부에서 완료 시킬 수 없다. 취소하거나 , get()에 타입아웃을 설정 할 수는 있다.
+ 블록킹 코드(get())를 사용하지 않고서는 작업이 끝났을 때 콜백을 실행할 수 없다.
+ 여러 Future 를 조합할 수 없다. 
  + 예) Event 정보 가져온 다음 Event 에 참석하는 회원 목록 가져오기
+ 예외 처리용 API 를 제공하지 않는다.


### CompletableFuture
+ Implements Future
+ Implements Completion Stage
  + Completion : 외부에서 완료 시킬수 있다
  + 명시적으로  Executors 안만들어도 된다.

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {
    
        CompletableFuture<String> stringCompletableFuture = new CompletableFuture<>();
        stringCompletableFuture.complete("test"); // 기본값 지정
        System.out.println(stringCompletableFuture.get());


        CompletableFuture<String> stringCompletableFuture2 = CompletableFuture.completedFuture("test"); // 기본값 지정
        System.out.println(stringCompletableFuture2.get());
    }

~~~

### 비동기로 작업 실행하기
+ 리턴값이 없는 경우: runAsync()

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        // 리턴이 없어서 Void
        CompletableFuture<Void> stringCompletableFuture = CompletableFuture.runAsync(() -> {
            System.out.println("test" + Thread.currentThread().getName());
        });
        stringCompletableFuture.get() // get을 해야지 실행
    }

~~~

+ 리턴값이 있는 경우: supplyAsync()

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        CompletableFuture<String> stringCompletableFuture = CompletableFuture.supplyAsync(() -> {
            System.out.println("test" + Thread.currentThread().getName());
            return "test";
        });
    
        System.out.println(stringCompletableFuture.get());
    }

~~~

+ 원하는 Executor(쓰레드풀)를 사용해서 실행할 수도 있다. (기본은 ForkJoinPoll commonPool())

### 콜백 제공하기
+ thenApply(Function): 리턴값을 받아서 다른 값으로 바꾸는 콜백

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        
        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        }).thenApply((s) -> {
            System.out.println(Thread.currentThread().getName());
            return s.toUpperCase();
        });

        System.out.println(hello.get());

    }

~~~


+ thenAccept(Consumer): 리턴값을 또 다른 작업을 처리하는 콜백(리턴없이)

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        CompletableFuture<Void> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        }).thenAccept((s) -> {
            System.out.println(Thread.currentThread().getName());
            System.out.println(s.toUpperCase());
        });

        hello.get();
    }

~~~

+ thenRun(Runnable): 값을 받지 않고 다른 작업을 처리하는 콜백

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        CompletableFuture<Void> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        }).thenRun(() -> {
            System.out.println(Thread.currentThread().getName());
        });

        hello.get();

    }

~~~

+ 콜백 자체를 또 다른 쓰레드에서 실행할 수 있다.



결과

### ForkJoinPoll
+ 도대체 스레드 풀을 만들지 않고 어떻게 별도에 스레드에서 동작한 거냐
  + 별다른 Executor 사용하지 않아도 내부적으로 ForkJoinPoll.commonPool을 사용 - 원한다면 얼마든지 만들어서 줄 수 있다.
+ java 7에 들어옴
+ Executor 구현한 구현체 중 하나
+ 다큐를 사용 - 맨 마지막에 들어온 게 먼저 나감
  + 자기 스레드가 할 일이 없으면 스레드가 다큐에서 자기가 할 일을 가지고 옴
+ 작업 단위를 자기가 파생시킨 세부적인 서브 테스크가 있다면 그 서브 테스크들을 잘게 쪼개서 다른 스레드에 분산 시켜서 작업을 처리하고 모아서(join) 그 결과값을 도출한다.

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        ExecutorService executorService = Executors.newFixedThreadPool(4);

        CompletableFuture<Void> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        }, executorService).thenRun(() -> {
            System.out.println(Thread.currentThread().getName());
        });

        hello.get();

    }

~~~

## CompletableFuture 2

### 조합하기 
+ thenCompose(): 두 작업이 서로 이어서 실행하도록 조합

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {
    
        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        });

        CompletableFuture<String> stringCompletableFuture = hello.thenCompose(App::getWorld);


        System.out.println(stringCompletableFuture.get());

    }

    private static CompletableFuture<String> getWorld(String s) {
        return CompletableFuture.supplyAsync(() -> {
            System.out.println( "World " + Thread.currentThread().getName());
            return s + " World";
        });
    }

~~~

+ thenCombine(): 두 작업을 독립적으로 실행하고 둘 다 종료 했을 때 콜백 실행

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {
        
        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        });

        CompletableFuture<String> world = CompletableFuture.supplyAsync(() -> {
            System.out.println("World " + Thread.currentThread().getName());
            return "World";
        });


        CompletableFuture<String> stringCompletableFuture = hello.thenCombine(world, (s, s2) -> s + " " + s2);

        System.out.println(stringCompletableFuture.get());

    }

~~~

+ allOf(): 여러 작업을 모두 실행하고 모든 작업 결과에 콜백 실행
  + 결과를 가져 올 수 없다.
    + 모든 테스크가 동일한 타입이라는 보장이 없다.
    + 그중에 어떤 거는 에러가 날 수도 있다.
    + 결과가 null이다.

~~~java

    public static void main(String[] args) throws ExecutionException, InterruptedException {

        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        });

        CompletableFuture<String> world = CompletableFuture.supplyAsync(() -> {
            System.out.println("World " + Thread.currentThread().getName());
            return "World";
        });


        CompletableFuture<Void> voidCompletableFuture = CompletableFuture.allOf(hello, world).thenAccept(System.out::println);

        voidCompletableFuture.get();

    }

~~~

+ 
  + 
     + 아래와 처럼 구현하면 결과를 받아 올 수 있다.
       + 이렇게 하면 아무것도 블로킹이 되지 않는다.

~~~java

public static void main(String[] args) throws ExecutionException, InterruptedException {

        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        });

        CompletableFuture<String> world = CompletableFuture.supplyAsync(() -> {
            System.out.println("World " + Thread.currentThread().getName());
            return "World";
        });


        List<CompletableFuture<String>> futures = Arrays.asList(hello, world);
        CompletableFuture[] futuresArray = futures.toArray(new CompletableFuture[futures.size()]);

        // get은 CheckedException을 발생 시킨다 그래서 join을 사용한다. join은 UnCheckedException을 발생 시킨다.
        CompletableFuture<List<String>> listCompletableFuture = CompletableFuture.allOf(futuresArray).thenApply(v -> futures.stream().map(CompletableFuture::join).collect(Collectors.toList()));


        listCompletableFuture.get().forEach(System.out::println);

}

~~~

+ anyOf(): 여러 작읍 중에 가장 빨리 끝난 하나의 결과에 콜백 실행

~~~java

public static void main(String[] args) throws ExecutionException, InterruptedException {

        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {
            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        });

        CompletableFuture<String> world = CompletableFuture.supplyAsync(() -> {
            System.out.println("World " + Thread.currentThread().getName());
            return "World";
        });

        CompletableFuture<Void> voidCompletableFuture = CompletableFuture.anyOf(hello, world).thenAccept(System.out::println);

        voidCompletableFuture.get();

}

~~~

### 예외처리
+ exceptionally(Function)

~~~java

public static void main(String[] args) throws ExecutionException, InterruptedException {

        boolean throwError = true;

        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {

            if (throwError) {
                throw new IllegalArgumentException();
            }

            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        }).exceptionally(throwable -> {
            System.out.println(throwable);
            return "Error!";
        });

        System.out.println(hello.get());

}

~~~

+ handle(BiFunction)

~~~java

public static void main(String[] args) throws ExecutionException, InterruptedException {

        boolean throwError = true;

        CompletableFuture<String> hello = CompletableFuture.supplyAsync(() -> {

            if (throwError) {
                throw new IllegalArgumentException();
            }

            System.out.println("Hello " + Thread.currentThread().getName());
            return "Hello";
        }).handle((result, ex) -> { //(성공 했을때 결과값, 에러)
            if (ex != null) {
                System.out.println(ex);
                return "Error!";
            }
            return result;
        });

        System.out.println(hello.get());

}

~~~


