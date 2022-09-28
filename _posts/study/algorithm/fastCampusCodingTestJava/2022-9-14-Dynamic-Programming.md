---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 09.동적 프로그래밍 (Dynamic Programming)
date: '2022-09-14 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 09.동적 프로그래밍 (Dynamic Programming)

# 09.동적 프로그래밍 (Dynamic Programming)
* toc
{:toc}

## 동적 프로그래밍 (Dynamic Programming) 란?
+ Dynamic = 동적인, 변화하는
+ Programming = 문제를 해결하는
+ 문제의 크기를 변화하면서 정답을 계산하는데, 작은 문제의 결과를 이용해서 큰 문제의 정답을 빠르게 계산하는 알고리즘
+ 
## 동적 프로그래밍 (Dynamic Programming) 시나리오
1. 문제가 원하는 정답을 찾기 위해 가장 먼저 완전 탐색(Brute-Force Search) 접근을 시도해본다.
2. 근데, 완전 탐색 과정에서 탐색하게 되는 경우가 지나치게 많아서 도저히 안 될 것 같다.
3. 이럴 때, 모든 경우를 빠르게 탐색하는 방법으로 Dynamic Programming 접근을 시도해볼 수 있다. 

## 동적 프로그래밍 (Dynamic Programming) 풀이 스텝
<div class="language-mermaid">
graph TD;
    A[1.풀고싶은 가짜 문제 정의]-->B[2.가짜 문제를 풀면 진짜 문제를 풀 수 있는가?];
    B-->C[3.초기값은 어떻게 되는가?];
    C-->D[4.점화식 구해내기];
    D-->E[5.진짜 문제 정답 출력하기];
    B-.->A;
    C-.->A;
    D-.->A;
</div>

1. 풀고싶은 가짜 문제 정의
   + Dy[i] = 1 ~ i 번 원소에 대해서 조건을 만족하는 경우의 수
   + Dy[i][j] = i ~ j 번 원소에 대해서 조건을 만족하는 최댓값
   + Dy[i][j] = 수열 A[1...i] 와 수열 B[1...i] 에 대해서 무언가를 계산한 값
2. 가짜 문제를 풀면 진짜 문제를 풀 수 있는가?
   + 진짜 문제 : 수열 A[1...N] 에서 조건을 만족하는 부분 수열의 개수
   + 가짜 문제 : Dy[i] = 수열 A[1...N] 에서 조건을 만족한는 부분 수영ㄹ의 개수
   + 가짜 문제를 푼다면 Dy[1],Dy[2], ...Dy[N]을 모두 계산했을것이니까, Dy[N]에 적혀있는 값이 곧 진짜 문제가 원하는 값이다. 
3. 초기값은 어떻게 되는가?
   + 가장 작은 문제 해결하기
4. 점화식 구해내기
   + 3에서 계산한 것을 기반으로, 점점 더 큰 문제들을 해결하면서 Dy 배열을 가득 계산하는 과정
5. 진짜 문제 정답 출력하기
   + 1 ~ 4 가 성공적으로 끝난다면 Dy 배열을 이용하여 진짜 문제 해결하기


## [백준 9095번 - 1,2,3 더하기](https://www.acmicpc.net/problem/9095)
---

1. 풀고 싶은 가짜 문제 정의
   + 진짜 문제 : 주어진 N에 대해서 N을 1,2,3의 합으로 표현하는 경우의 수
   + 가짜 문제 : Dy[i] = i 를 1,2,3의 합으로 표현하는 경우의 수 
2. 가짜 문제를 풀면 진짜 문제를 풀 수 있는가?
   + Dy 배열을 가득 채울 수만 있다면 진짜 문제에 대한 정답은 Dy[N] 이다.
3. 초기값은 어떻게 되는가?
   + 초기값: 쪼개지 않아도 풀 수 있는 __작은 문제__ 들에 대한 정답 
4. 점화식 구해내기
   1. Dy[i] 계산에 필요한 탐색 경우를 공통점끼리 묶어내기 (Partitioning)
   2. 묶어낸 부분의 정답을 Dy 배열을 이용해서 빠르게 계산해보기
   3. 점화식 : Dy[i] = Dy[i-1] + Dy[i-2] + Dy[i-3] 
   
__시간, 공간 복잡도 계산하기__
+ 완전 탐색을 통해 모든 경우를 세면 정답의 개수만큼의 시간이 걸리기지만, Dy 배열을 1번지부터 N번지 까지 채우는 것은 O(N) 이라는 시간 복잡도면 충분하다.
+ 다수의 테스트 케이스를 처리하기 전에 모든 N에 대해 정답을 구해놓자.

* __구현__

~~~java

public class baekjoon9095 {

   static int[] Dy;


   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      int T = Integer.parseInt(br.readLine());


      preprocess();

      while (T-- > 0) {

         int N = Integer.parseInt(br.readLine());

         System.out.println(Dy[N]);
      }

   }

   private static void preprocess() {
      Dy = new int[15];

      Dy[1] = 1;
      Dy[2] = 2;
      Dy[3] = 4;

      for (int i = 4; i <= 11; i++) {
         Dy[i] = Dy[i - 1] + Dy[i - 2] + Dy[i - 3];
      }

   }


}
~~~
***

## [백준 11726번 - 2xN 타일링](https://www.acmicpc.net/problem/11726)
---

1. 풀고 싶은 가짜 문제 정의
   + 진짜 문제 : 주어진 N에 대해서 2xN 타일링 경우의 수
   + 가짜 문제 : Dy[i] = 2xi 타일링 경우의 수
2. 가짜 문제를 풀면 진짜 문제를 풀 수 있는가?
   + Dy 배열을 가득 채울 수만 있다면 진짜 문제에 대한 정답은 Dy[N] 이다.
3. 초기값은 어떻게 되는가?
   + 초기값: 쪼개지 않아도 풀 수 있는 __작은 문제__ 들에 대한 정답
4. 점화식 구해내기
   1. Dy[i] 계산에 필요한 탐색 경우를 공통점끼리 묶어내기 (Partitioning)
   2. 묶어낸 부분의 정답을 Dy 배열을 이용해서 빠르게 계산해보기

__시간, 공간 복잡도 계산하기__
+ 완전 탐색을 통해 모든 경우를 세면 정답의 개수만큼의 시간이 걸리기지만, Dy 배열을 1번지부터 N번지 까지 채우는 것은 O(N) 이라는 시간 복잡도면 충분하다.
+ 다수의 테스트 케이스를 처리하기 전에 모든 N에 대해 정답을 구해놓자.

* __구현__

~~~java

public class baekjoon11726 {


   static int N;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

      N = Integer.parseInt(br.readLine());

      pro();

   }

   private static void pro() {
      int[] Dy = new int[1005];

      Dy[1] = 1;
      Dy[2] = 2;

      for (int i = 3; i <= N; i++) {
         Dy[i] = (Dy[i - 1] + Dy[i - 2]) % 10007;
      }

      System.out.println(Dy[N]);
   }


}

~~~
***

## [백준 1003번 - 피보나치 함수](https://www.acmicpc.net/problem/1003)
---

* __구현__

~~~java

public class baekjoon1003 {
   static long[][] Dy;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

      pro();

      int T = Integer.parseInt(br.readLine());

      while (T-- > 0) {

         int N = Integer.parseInt(br.readLine());

         System.out.println(Dy[N][0] + " " + Dy[N][1]);

      }

   }

   private static void pro() {
      Dy = new long[40 + 1][2];

      Dy[0][0] = 1;
      Dy[1][1] = 1;

      for (int i = 2; i <= 40; i++) {
         Dy[i][0] = Dy[i - 1][0] + Dy[i - 2][0];
         Dy[i][1] = Dy[i - 1][1] + Dy[i - 2][1];
      }
   }


}

~~~
***

## [백준 10870번 - 피보나치 수 5](https://www.acmicpc.net/problem/10870)
---

* __구현__

~~~java

public class baekjoon10870 {


   static int N;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

      N = Integer.parseInt(br.readLine());

      pro();

   }

   private static void pro() {
      int[] Dy = new int[25];

      Dy[0] = 0;
      Dy[1] = 1;
      Dy[2] = 1;
      Dy[3] = 2;

      for (int i = 4; i <= N; i++) {
         Dy[i] = Dy[i - 1] + Dy[i - 2];
      }

      System.out.println(Dy[N]);
   }


}


~~~
***

## [백준 15988번 - 1, 2, 3 더하기 3](https://www.acmicpc.net/problem/15988)
---

* __구현__

~~~java

public class baekjoon15988 {


   static int N;
   static int[] Dy;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


      pro();

      int T = Integer.parseInt(br.readLine());

      while (T-- > 0) {
         N = Integer.parseInt(br.readLine());
         System.out.println(Dy[N]);
      }


   }

   private static void pro() {
      Dy = new int[1000005];

      Dy[1] = 1;
      Dy[2] = 2;
      Dy[3] = 4;

      for (int i = 4; i <= 1000000; i++) {
         Dy[i] = Dy[i - 1];
         Dy[i] += Dy[i - 2];
         Dy[i] %= 1000000009;
         Dy[i] += Dy[i - 3];
         Dy[i] %= 1000000009;
      }
   }


}

~~~
***

## [백준 15991번 - 1, 2, 3 더하기 6](https://www.acmicpc.net/problem/15991)
---

* __구현__

~~~java

public class baekjoon15991 {


   static int[] Dy;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


      pro();

      int T = Integer.parseInt(br.readLine());

      while (T-- > 0) {
         int x = Integer.parseInt(br.readLine());

         int res = 0;
         for (int mid = 1; mid <= 3; mid++)
            if (x - mid >= 0 && (x - mid) % 2 == 0) {
               res += Dy[(x - mid) / 2];
               res %= 1000000009;
            }

         if (x % 2 == 0) {
            res += Dy[x / 2];
            res %= 1000000009;
         }

         System.out.println(res);
      }


   }

   private static void pro() {
      Dy = new int[100005];

      Dy[0] = 1;

      for (int i = 1; i <= 100000; i++) {
         Dy[i] = Dy[i - 1];
         if (i - 2 >= 0) Dy[i] += Dy[i - 2];
         Dy[i] %= 1000000009;
         if (i - 3 >= 0) Dy[i] += Dy[i - 3];
         Dy[i] %= 1000000009;
      }
   }


}

~~~
***

## [백준 11052번 - 카드 구매하기](https://www.acmicpc.net/problem/11052)
---

* __구현__

~~~java

public class baekjoon11052 {


   static int N;
   static int[] P, Dy;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
      N = Integer.parseInt(br.readLine());

      P = new int[N + 1];
      Dy = new int[N + 1];

      StringTokenizer st = new StringTokenizer(br.readLine(), " ");

      for (int i = 1; i <= N; i++) {
         P[i] = Integer.parseInt(st.nextToken());
      }

      for (int i = 1; i <= N; i++) {
         for (int cnt = 1; cnt <= i; cnt++) {
            Dy[i] = Math.max(Dy[i], Dy[i - cnt] + P[cnt]);
         }
      }

      System.out.println(Dy[N]);

   }


}


~~~
***

## [백준 2011번 - 암호 코드](https://www.acmicpc.net/problem/2011)
---

* __구현__

~~~java

public class baekjoon2011 {


   static int N, M = 1000000;
   static long[] Dy;
   static String str;

   public static void main(String[] args) throws IOException {

      BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

      str = br.readLine();
      N = str.length();

      Dy = new long[N];

      if (N == 0 || str.charAt(0) == '0') {
         System.out.println(0);
         return;
      }

      Dy[0] = 1;
      for (int i = 1; i < N; i++) {
         if (str.charAt(i) != '0') Dy[i] = Dy[i - 1];

         if (check(str.charAt(i - 1), str.charAt(i))) {
            if (i >= 2) Dy[i] += Dy[i - 2];
            else Dy[i] += 1;
            Dy[i] %= M;
         }
      }

      System.out.println(Dy[N - 1]);
   }

   private static boolean check(char A, char B) {
      if (A == '0') return false;
      if (A == '1') return true;
      if (A >= '3') return false;

      return B <= '6';
   }


}

~~~
***