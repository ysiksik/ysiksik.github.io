---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 02.완전 탐색 (Brute Force) 응용편
date: '2022-5-17 11:45:51 +0900'
categories:
    - study
    - algorithm
    - fastCampusCodingTestJava
comments: true
published: true
---

# [Part3 Ch02 알고리즘] 02.완전 탐색 (Brute Force) 응용편

# 완전 탐색 (Brute Force) 응용편
* toc
{:toc}


## 연습
---
### [백준 14888번 - 연산자 키워넣기](https://www.acmicpc.net/problem/14888)

      1. 연산자를 어떻게 끼워 넣어도 항상 -10억보다 크거나 같고, 10억보다 작거나 같다.
      2. 중간에 계산되는 식의 결과도 항상 -10억보다 크거나 같고, 10억보다 작거나 같다.
      3. int의 범위 : -21억 ~ 21억 (int 형 변수를 쓰면 됨)


> * N-1 개의 카드 중에서 중복 없이(같은 카드는 한 번 사용)
> * N-1 개를 순서있게 나열

| 중복 | 순서 | 시간 복잡도 | 공간 복잡도 |
| --- | ---| --- | --- |
| YES | YES | $$O \left(N^M\right)$$ | $$O \left(M\right)$$ |
| <mark>NO</mark> | <mark>YES</mark> | $$O \left(\frac{N!}{(N-M)!}\right)$$ |  $$O \left(M\right)$$  |
| YES | NO | $$O \left(N^M\right)$$ 보다 작음| $$O \left(M\right)$$ |
| NO | NO | $$O \left(\frac{N!}{M!(N-M)!}\right)$$| $$O \left(M\right)$$ |

~~~java
public class baekjoon14888 {

    static int N, MAX, MIN;

    static int[] operatorNum = new int[5];
    static int[] num;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        MAX = Integer.MIN_VALUE;
        MIN = Integer.MAX_VALUE;

        num = new int[N + 1];

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            num[i] = Integer.parseInt(st.nextToken());
        }

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= 4; i++) {
            operatorNum[i] = Integer.parseInt(st.nextToken());
        }

        dfs(1, num[1]);
        System.out.println(MAX);
        System.out.println(MIN);
    }


    public static void dfs(int k, int value) {
        if (N == k) {
            MAX = Math.max(value, MAX);
            MIN = Math.min(value, MIN);
        } else {
            for (int i = 1; i <= 4; i++) {
                if (operatorNum[i] >= 1) {
                    operatorNum[i]--;
                    dfs(k + 1, calculation(value, i, num[k + 1]));
                    operatorNum[i]++;
                }
            }
        }

    }

    public static int calculation(int first, int operator, int second) {
        switch (operator) {
            case 1:
                return first + second;
            case 2:
                return first - second;
            case 3:
                return first * second;
            default:
                return first / second;
        }

    }

}
  ~~~

### [백준 9663번 - N Queen](https://www.acmicpc.net/problem/9663)

    1. N의 최댓값 14 일 때 21억을 넘는지 모름.
    2. int로 정해 놓고 N을 14로 입력하고 확인하거나
    3. 백 트래킹은 모든 방법을 일일이 확인하는 거기 때문에 정답이 21억을 넘는다는 것은 수행 연산 시간도 21억을 넘는다는 것이기 때문에
    int 범위라는 것을 간접적으로 유추할 수 있음

> * N 개 중에서 중복을 허용
> * N 개를 순서대로 나열하는 모든 경우 탐색
> * $$14^{14} > 10^{16}$$ 시간 초과 발생
> * 해결 방법으로 가능한 위치에만 퀸을 놓자

| 중복 | 순서 | 시간 복잡도 | 공간 복잡도 |
| --- | ---| --- | --- |
| <mark>YES</mark> | <mark>YES</mark> | $$O \left(N^M\right)$$ | $$O \left(M\right)$$ |
| NO | YES | $$ O \left(\frac{N!}{(N-M)!}\right) $$ | $$O \left(M\right)$$ |
| YES | NO | $$O \left(N^M\right)$$ 보다 작음| $$O \left(M\right)$$ |
| NO | NO | $$O \left(\frac{N!}{M!(N-M)!}\right)$$| $$O \left(M\right)$$ |

~~~java
public class baekjoon9663 {

    static int N, result = 0;
    static int[] map;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        map = new int[N + 1];

        dfs(1);

        System.out.println(result);
    }


    public static void dfs(int x) {
        if (x == N + 1) {
            result++;
        } else {
            for (int i = 1; i <= N; i++) {

                if (check(x, i)) {
                    map[x] = i;

                    dfs(x + 1);

                    map[x] = 0;
                }

            }
        }

    }

    public static boolean check(int x, int y) {
        for (int i = 1; i <= x - 1; i++) {
            if (y == map[i]) {
                return false;
            }
            if (x - y == i - map[i]) {
                return false;
            }
            if (x + y == i + map[i]) {
                return false;
            }
        }
        return true;
    }

}
~~~

### [백준 1182번 - 부분 수열의 합](https://www.acmicpc.net/problem/1182)

    1. 부분 수열 : 수열의 일부 항을 선택해서 원래 순서대로 나열
    2. 진부분 수열 : 아무것도 안 고르는 경우는 뺀 부분 수열
    3. 부분 수열의 개수 상한 : 2^20 <= 1,048,576 정답 변수는 int 형 변수 사용
    4. 부분 수열의 합 상한 : 20*1,000,000 합을 기록하는 변수 int 형 변수 사용

> * 부분 수열에 포함시키지 않느다.
> * 부분 수열에 포함시킨다
> * $$2^{20} \simeq 100만$$

| 중복 | 순서 | 시간 복잡도 | 공간 복잡도 |
| --- | ---| --- | --- |
| <mark>YES</mark> | <mark>YES</mark> | $$O \left(N^M\right)$$ | $$O \left(M\right)$$ |
| NO | YES | $$ O \left(\frac{N!}{(N-M)!}\right) $$ | $$O \left(M\right)$$ |
| YES | NO | $$O \left(N^M\right)$$ 보다 작음| $$O \left(M\right)$$ |
| NO | NO | $$O \left(\frac{N!}{M!(N-M)!}\right)$$| $$O \left(M\right)$$ |

~~~java
public class baekjoon1182 {

    static int N, S, result = 0;
    static int[] arr;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        S = Integer.parseInt(st.nextToken());

        arr = new int[N + 1];

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            arr[i] = Integer.parseInt(st.nextToken());
        }

        dfs(1, 0);

        if (S == 0) {
            result--;
        }

        System.out.println(result);

    }


    public static void dfs(int k, int value) {

        if (k == N + 1) {
            if (S == value) result++;
        } else {

            dfs(k + 1, value + arr[k]);

            dfs(k + 1, value);

        }

    }
}
~~~
