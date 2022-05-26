---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 02.완전 탐색 (Brute Force) 응용편
date: '2022-5-17 11:45:51 +0900'
categories:
    - study
    - algorithm
    - fastCampusCodingTestJava
tags:
    - paper
comments: true
published: true
---

# [Part3 Ch02 알고리즘] 02.완전 탐색 (Brute Force) 응용편

# 완전 탐색 (Brute Force) 응용편
* toc
{:toc}


## 연습
---
* [백준 14888번 - 연산자 키워넣기](https://www.acmicpc.net/problem/14888)

> N-1 개의 카드 중에서 중복 없이(같은 카드는 한 번 사용)
> N-1 개를 순서있게 나열

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

* [백준 9663번 - N Queen](https://www.acmicpc.net/problem/9663)

> N 개 중에서 중복을 허용
> N 개를 순서대로 나열하는 모든 경우 탐색

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

* ### 1 + B

<div class="mermaid">
graph LR;
    N개중-->1.중복허용;
    M개를-->B.고르기;
</div>

[백준 15652번 - N과 M (4)](https://www.acmicpc.net/problem/15652)

~~~java
public class baekjoon15652 {

    static int N, M;
    static int[] selected;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        selected = new int[M + 1];

        dfs(1);

        System.out.println(sb);

    }


    public static void dfs(int k) {
        if(k == M+1){
            for(int i = 1; i <= M; i++){
                sb.append(selected[i]).append(" ");
            }
            sb.append("\n");
        }else{
            int start = selected[k-1];
            if(start == 0) start = 1;
            for(int i = start; i <= N; i++){
                selected[k] = i;

                dfs(k+1);

                selected[k] = 0;

            }
        }

    }


}
~~~

> 시간, 공간 복잡도 계산
> ```
> N=4, M=3
> ```

> $$4 \times 4 \times 4 = 4^3$$

> $$시간 : O \left(N^M\right) \Rightarrow 8^8 \simeq 1677만 아래$$

> $$공간 : O \left(M\right)$$

* ### 2 + B

<div class="mermaid">
graph LR;
    N개중-->2.중복없이;
    M개를-->B.고르기;
</div>

[백준 15650번 - N과 M (2)](https://www.acmicpc.net/problem/15650)

~~~java
public class baekjoon15650 {

    static int N, M;
    static int[] selected;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        selected = new int[M + 1];

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
            for (int i = selected[k - 1] + 1; i <= N; i++) {
                selected[k] = i;

                dfs(k + 1);

                selected[k] = 0;

            }
        }

    }


}
~~~

> 시간, 공간 복잡도 계산
> ```
> N=4, M=3
> ```

> $$시간 : O \left(\frac{N!}{M!(N-M)!}\right) \Rightarrow \frac{8!}{4!4!} = 70$$

> $$공간 : O \left(M\right)$$


***

## 정리
---

| 중복 | 순서 | 시간 복잡도 | 공간 복잡도 |
| --- | ---| --- | --- |
| YES | YES | $$O \left(N^M\right)$$ | $$O \left(M\right)$$ |
| NO | YES | $$ O \left(\frac{N!}{(N-M)!}\right) $$| $$O \left(M\right)$$ |
| YES | NO | $$O \left(N^M\right)$$ 보다 작음| $$O \left(M\right)$$ |
| NO | NO | $$O \left(\frac{N!}{M!(N-M)!}\right)$$| $$O \left(M\right)$$ |

> 완전 탐색 문제 접근 팁
> > * 고를 수 있는 값의 종류 파악
> > * 중복 허용 여부
> > * 순서가 중요 한지

***
