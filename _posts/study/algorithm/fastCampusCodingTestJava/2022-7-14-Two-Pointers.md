---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 04.두 포인터 (Two Pointer)
date: '2022-07-14 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 04.두 포인터 (Two Pointer)

# 두 포인터 (Two Pointer)
* toc
{:toc}

## 두 포인터 (Two Pointer)
---
+ 핵심
> 정답을 찾기 위해 봐야하는것들 중에서 꼭 봐야 하는 부분만 추리는게 핵심이다.

+ 화살표 두 개에 의미를 부여해서 탐색 범위를 압축하는 방법
  + 2개의 포인터가 모두 왼쪽에서 시작해서 같은 방향으로 이동
  + 2개의 포인터가 양 끝에서 서로를 향해 이동
+ 관찰을 통해서 문제에 등장하는 변수 2개의 값을 두 포인터로 표현하는 경우

+ 꿀팁 키워드
  + 1차원 배열에서의 "연속 부분 수열" 또는 "순서를 지키며 차례대로"
  + 곱의 최소
    
        Two Pointer 접근을 시도해 볼 가치가 있다. 

***

## [백준 1806번 - 부분합](https://www.acmicpc.net/problem/1806)
---

* __정답의 최대치__      
> + $$ N = 100,000 $$
> + $$ S = 10^8 $$
> + 정답이 N 이하이므로 Integer 범위
> + 모든 원소의 총합도 $$ 10^9 $$ 이므로 Integer 범위 

* __키워드 체크하기__      
> + 이 수열에서 __연속된 수들의__ 부분합 중에서 그 합이 S 이상이 되는 것 중, 가장 짧은 것의 길이를 구하는 프로그램

* __시간, 공간 복잡도 계산하기__
> + 왼쪽 시작 L의 이동 횟수 N번
> + 오른쪽 끝을 R을 이전의 R부터 시작해서 이동
> + L,R이 각자 최대 N번 이동하니까 $$O\left(\log N \right)$$


* __구현__

~~~java
public class baekjoon1806 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());
        int[] arr = new int[N + 1];

        int S = Integer.parseInt(st.nextToken());

        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            arr[i] = Integer.parseInt(st.nextToken());
        }


        int R = 0, sum = 0, result = N + 1;

        for (int L = 1; L <= N; L++) {

            sum -= arr[L - 1];

            while (R + 1 <= N && sum < S) {
                sum += arr[++R];
            }

            if (sum >= S) {
                result = Math.min(result, R - L + 1);
            }

        }

        if (N + 1 == result) {
            System.out.println(0);
        } else {
            System.out.println(result);
        }

    }
}
~~~
***

## [백준 2003번 - 수들의 합2](https://www.acmicpc.net/problem/2003)
---

* __구현__

~~~java
public class baekjoon2003 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());
        int[] a = new int[N + 1];
        int M = Integer.parseInt(st.nextToken());

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }

        int R = 0, result = 0, sum = 0;

        for (int L = 1; L <= N; L++) {

            sum -= a[L - 1];

            while (R + 1 <= N && sum < M) {
                sum += a[++R];
            }

            if (sum == M) {
                result++;
            }

        }

        System.out.println(result);

    }
}

~~~
***


## [백준 2559번 - 수열](https://www.acmicpc.net/problem/2559)
---

* __구현__

~~~java
public class baekjoon2559 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());
        int[] A = new int[N + 1];
        int K = Integer.parseInt(st.nextToken());

        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(st.nextToken());
        }


        int R = 0, result = Integer.MIN_VALUE, sum = 0;
        for (int L = 1; L + K - 1 <= N; L++) {

            sum -= A[L - 1];


            while (R + 1 <= L + K - 1) {
                sum += A[++R];
            }


            result = Math.max(result, sum);

        }

        System.out.println(result);

    }
}
~~~
***

## [백준 15565번 - 귀여운 라이언](https://www.acmicpc.net/problem/15565)
---

* __구현__

~~~java
public class baekjoon15565 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());

        int[] a = new int[N + 1];

        int K = Integer.parseInt(st.nextToken());

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }

        int R = 0, count = 0, length = Integer.MAX_VALUE;

        for (int L = 1; L <= N; L++) {

            if (a[L - 1] == 1) count--;

            while (K > count && R + 1 <= N) {
                if (a[++R] == 1) count++;
            }

            if (K == count) {
                length = Math.min(length, R - L + 1);
            }

        }

        if (length == Integer.MAX_VALUE) {
            System.out.println(-1);
        } else {
            System.out.println(length);
        }


    }
}

  ~~~
***

## [백준 11728번 - 배열 합치기](https://www.acmicpc.net/problem/11728)
---

* __구현__

~~~java
public class baekjoon11728 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());

        int[] A = new int[N + 1];

        int M = Integer.parseInt(st.nextToken());

        int[] B = new int[M + 1];


        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(st.nextToken());
        }
        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= M; i++) {
            B[i] = Integer.parseInt(st.nextToken());
        }


        StringBuilder sb = new StringBuilder();
        int L = 1, R = 1;

        while (L <= N && R <= M) {
            if (A[L] < B[R]) sb.append(A[L++]).append(" ");
            else sb.append(B[R++]).append(" ");
        }

        while (L <= N) sb.append(A[L++]).append(" ");
        while (R <= M) sb.append(B[R++]).append(" ");

        System.out.println(sb);
    }
}

~~~
***

## [백준 2230번 - 수 고르기](https://www.acmicpc.net/problem/2230)
---

* __구현__

~~~java
public class baekjoon2230 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());

        int[] a = new int[N + 1];

        int M = Integer.parseInt(st.nextToken());


        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(br.readLine());
        }


        Arrays.sort(a, 1, N + 1);

        int R = 1, result = Integer.MAX_VALUE;
        for (int L = 1; L <= N; L++) {

            while (R + 1 <= N && a[R] - a[L] < M) ++R;

            if (a[R] - a[L] >= M) result = Math.min(result, a[R] - a[L]);

        }

        System.out.println(result);

    }
}

  ~~~
***

## [백준 2470번 - 두 용액](https://www.acmicpc.net/problem/2470)
---

+ __시간, 공간 복잡도 계산하기__
  + 배열 정렬 한번
      + $$O\left(N \log N \right)$$
  + 매 순간 L,R로 계산한 후에, 이동시키기
      + $$O\left(N \right)$$
  + 총 시간 복잡도 
      + $$O\left(N \log N \right)$$

* __구현__

~~~java
public class baekjoon2470 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());
        int[] a = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }

        Arrays.sort(a, 1, N + 1);

        int L = 1, R = N, result = Integer.MAX_VALUE;
        int resultL = 0, resultR = 0;

        while (L < R) {
            if (result > Math.abs(a[R] + a[L])) {
                result = Math.abs(a[R] + a[L]);
                resultL = a[L];
                resultR = a[R];
            }

            if (a[L] + a[R] > 0) R--;
            else L++;

        }

        System.out.println(resultL + " " + resultR);


    }
}

~~~
***

## [백준 3273번 - 두 수의 합](https://www.acmicpc.net/problem/3273)
---

* __구현__

~~~java
public class baekjoon3273 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());
        int[] a = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }

        int X = Integer.parseInt(br.readLine());

        Arrays.sort(a, 1, N + 1);

        int L = 1, R = N, result = 0;

        while (L < R) {
            int sum = a[L] + a[R];

            if (X == sum) {
                result++;
            }
            if (X <= sum) {
                R--;
            } else {
                L++;
            }
        }

        System.out.println(result);


    }
}

~~~
***

