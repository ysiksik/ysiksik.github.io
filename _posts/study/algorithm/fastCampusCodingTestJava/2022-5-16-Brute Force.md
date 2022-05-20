---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 01.완전 탐색 (Brute Force)
date: '2022-5-16 11:45:51 +0900'
categories:
    - study
    - algorithm
    - fastCampusCodingTestJava
tags:
    - paper
comments: true
published: true
---

# [Part3 Ch02 알고리즘] 01.완전 탐색 (Brute Force)

# 완전 탐색 (Brute Force)
* toc
{:toc}


## 정답을 무조건 구하는 치트키
---
    1. 문제를 해결하기 위해 확인해야 하는 모든 경우를 전부 탐색하는 방법.
    2. Back-Tracking 중요.
    3. 많은 연습이 필요.
    4. 완전 탐색은 함수 정의가 50% (함수 정의가 중요하다.)
    5. 장점: 부분 점수를 얻기 좋다.
    6. 단점: 전부 탐색하기에 시간 복잡도가 일반적으로 높음

***
<br>

## 코딩 테스트에 나오는 완전 탐색 종류
---
<div class="mermaid">
graph LR;
    N개중-->1.중복허용;
    N개중-->2.중복없이;
    M개를-->A.순서있게나열;
    M개를-->B.고르기;
</div>
***
<br>

## 구현
---
* ### 1 + A

<div class="mermaid">
graph LR;
    N개중-->1.중복허용;
    M개를-->A.순서있게나열;
</div>

 [백준 15651번 - N과 M (3)](https://www.acmicpc.net/problem/15651)

   ~~~java
   public class baekjoon15651 {

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
               for (int i = 1; i <= N; i++) {
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
> $$시간 : O \left(N^M\right) \Rightarrow 7^7 \simeq 82만$$
> $$공간 : O \left(M\right)$$


* ### 2 + A

<div class="mermaid">
graph LR;
    N개중-->2.중복없이;
    M개를-->A.순서있게나열;
</div>

[백준 15649번 - N과 M (1)](https://www.acmicpc.net/problem/15649)

~~~java
public class baekjoon15649 {

    static int N, M;
    static int[] selected, visited;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        selected = new int[M + 1];
        visited = new int[N+1];

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
            for (int i = 1; i <= N; i++) {
                if(visited[i] == 0){
                    selected[k] = i;
                    visited[i] = 1;
                    dfs(k + 1);
                    selected[k] = 0;
                    visited[i] = 0;
                }
            }
        }

    }


}
~~~

> 시간, 공간 복잡도 계산
> ```
> N=4, M=3
> ```
> $$4 \times 3 \times 2 = 4!$$
> $$시간 : O \left(\frac{N!}{(N-M)!}\right) \Rightarrow \frac{8!}{0!} = 40,320$$
> $$공간 : O \left(M\right)$$

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
| -- | -- | -- | -- |
| YES | YES | $O \left(N^M\right)$ | $O \left(M\right)$ |
| NO | YES | $ O \left(\frac{N!}{(N-M)!}\right) $| $O \left(M\right)$ |
| YES | NO | $O \left(N^M\right)$ 보다 작음| $O \left(M\right)$ |
| NO | NO | $O \left(\frac{N!}{M!(N-M)!}\right)$| $O \left(M\right)$ |

> 완전 탐색 문제 접근 팁
> > * 고를 수 있는 값의 종류 파악
> > * 중복 허용 여부
> > * 순서가 중요 한지

***
