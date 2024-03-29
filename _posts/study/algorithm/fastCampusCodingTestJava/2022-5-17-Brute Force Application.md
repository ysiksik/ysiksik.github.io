---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 01.완전 탐색 (Brute Force) 응용편
date: '2022-5-17 11:45:51 +0900'
categories:
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
---

# [Part3 Ch02 알고리즘] 01.완전 탐색 (Brute Force) 응용편

# 완전 탐색 (Brute Force) 응용편
* toc
{:toc}




## [백준 14888번 - 연산자 키워넣기](https://www.acmicpc.net/problem/14888)
---
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

    // order[1...N-1] 에 연산자들이 순서대로 저장될 것이다.
    public static void dfs(int k, int value) {
        if (N == k) {
            // 완성된 식에 맞게 계산을 해서 정답에 갱신하는 작업
            MAX = Math.max(value, MAX);
            MIN = Math.min(value, MIN);
        } else {
            // k 번째 연산자는 무엇을 선택할 것인가?
            for (int i = 1; i <= 4; i++) {
                if (operatorNum[i] >= 1) {
                    operatorNum[i]--;
                    dfs(k + 1, calculation(value, i, num[k + 1]));
                    operatorNum[i]++;
                }
            }
        }

    }
    // 피연산자 2개와 연산자가 주어졌을 때 계산해주는 함수
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
***

## [백준 9663번 - N Queen](https://www.acmicpc.net/problem/9663)
---
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
***

## [백준 1182번 - 부분 수열의 합](https://www.acmicpc.net/problem/1182)
---
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

    // k번째 원소를 포함시킬 지 정하는 함수
    // value:= k-1 번째 원소까지 골라진 원소들의 합
    public static void dfs(int k, int value) {

        if (k == N + 1) { // 부분 수열을 하나 완성 시킨 상태
            // value 가 S 랑 같은 지 확인하기
            if (S == value) result++;
        } else {
            // k 번째 원소를 포함시킬 지 결정하고 재귀호출해주기
            // Include
            dfs(k + 1, value + arr[k]);
            // Not Include
            dfs(k + 1, value);

        }

    }
}
~~~
***

## [백준 1759번 - 암호 만들기](https://www.acmicpc.net/problem/1759)
---
~~~java
public class baekjoon1759 {

    static int L, C;
    static char[] arr;
    static int[] check;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        L = Integer.parseInt(st.nextToken());
        C = Integer.parseInt(st.nextToken());

        arr = new char[C + 1];
        check = new int[L + 1];


        st = new StringTokenizer(br.readLine(), " ");


        for (int i = 1; i <= C; i++) {
            arr[i] = st.nextToken().charAt(0);
        }

        Arrays.sort(arr, 1, C + 1);

        dfs(1);

        System.out.println(sb);
    }


    static boolean isVowel(char x) {
        return x == 'a' || x == 'e' || x == 'i' || x == 'o' || x == 'u';
    }


    public static void dfs(int k) {

        if (k == L + 1) {

            int vower = 0, consonant = 0;


            for(int i = 1 ; i <= L; i++){
                if(isVowel(arr[check[i]])){
                    vower++;
                }else {
                    consonant++;
                }
            }
            if (vower >= 1 && consonant >= 2) {
                for(int i = 1 ; i <= L; i++){
                    sb.append(arr[check[i]]);
                }
                sb.append("\n");
            }
        } else {
            for (int i = check[k - 1] + 1; i <= C; i++) {
                check[k] = i;
                dfs(k + 1);
                check[k] = 0;
            }
        }

    }


}
~~~
***

## [백준 15663번 - N과 M(9)](https://www.acmicpc.net/problem/15663)
---
~~~java
public class baekjoon15663 {

    static int N, M;
    static int[] arr;
    static int[] selected, used;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        arr = new int[N + 1];
        used = new int[N + 1];
        selected = new int[M + 1];


        st = new StringTokenizer(br.readLine(), " ");


        for (int i = 1; i <= N; i++) {
            arr[i] = Integer.parseInt(st.nextToken());
        }


        Arrays.sort(arr, 1, N + 1);


        dfs(1);

        System.out.println(sb);
    }

    public static void dfs(int k) {
        if (k == M + 1) {
            for (int i = 1; i <= M; i++) {
                sb.append(selected[i]).append(" ");
            }
            sb.append("\n");

        } else {
            int last = 0;
            for (int i = 1; i <= N; i++) {
                if (used[i] == 1) continue;
                if (last == arr[i]) continue;

                last = arr[i];
                used[i] = 1;

                selected[k] = arr[i];

                dfs(k + 1);

                selected[k] = 0;
                used[i] = 0;
            }
        }
    }


}
~~~
***
