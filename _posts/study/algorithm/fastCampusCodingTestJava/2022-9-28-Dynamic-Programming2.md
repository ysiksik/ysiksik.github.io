---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 09.동적 프로그래밍 (Dynamic Programming) - 2
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

# [Part3 Ch02 알고리즘] 09.동적 프로그래밍 (Dynamic Programming) - 2

# 09.동적 프로그래밍 (Dynamic Programming) - 2
* toc
{:toc}

## [백준 2579번 - 계단 오르기](https://www.acmicpc.net/problem/2579)
---

1. 계단은 한 번에 한 계단씩 또는 두 계단씩 오를 수 있다. 즉, 한 계단을 밟으면서 이어서다음 계단이나, 다음 다음 계단으로 오를 수 있다.
2. 연속된 세 개의 계단을 모두 밟아서는 안 된다. 단, 시작점은 계단에 포함되지 않는다
3. 마지막 도착 계단은 반드시 밟아야 한다.

__정답의 최대치__
+ N 개의 계단을 모두 밟는다 치더라도 
  + N * 최대 점수 = 300 * 10,000 = 300만 이기 때문에, 정답은 Integer 범위 내에 들어온다.

__시간, 공간 복잡도 계산하기__
+ 완전 탐색을 통해 모든 경우를 세면 정답의 개수만큼의 시간이 걸리기지만, Dy 배열을 1번지부터 N번지 까지 채우는 것은 O(N) 이라는 시간 복잡도면 충분하다.

* __구현__

~~~java

public class baekjoon2579 {
    static int[][] Dy;
    static int N;

    static int[] score;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        score = new int[N + 1];
        Dy = new int[N + 1][2];

        for (int i = 1; i <= N; i++) {
            score[i] = Integer.parseInt(br.readLine());
        }

        Dy[1][0] = 0;
        Dy[1][1] = score[1];

        if (N >= 2) {
            Dy[2][0] = score[2];
            Dy[2][1] = score[1] + score[2];
        }


        for (int i = 3; i <= N; i++) {
            Dy[i][0] = Math.max(Dy[i - 2][0] + score[i], Dy[i - 2][1] + score[i]);
            Dy[i][1] = Dy[i - 1][0] + score[i];
        }

        System.out.println(Math.max(Dy[N][0], Dy[N][1]));
    }
}

~~~
***

## [백준 1149번 - RGB 거리](https://www.acmicpc.net/problem/1149)
---

* __구현__

~~~java

public class baekjoon1149 {

    static int N;

    static int[] A;
    static int[][] Dy;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        Dy = new int[N + 1][3];

        A = new int[3];

        for (int i = 1; i <= N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            for (int j = 0; j < 3; j++) {
                A[j] = Integer.parseInt(st.nextToken());
            }

            Dy[i][0] = Integer.min(Dy[i - 1][1], Dy[i - 1][2]) + A[0];
            Dy[i][1] = Integer.min(Dy[i - 1][0], Dy[i - 1][2]) + A[1];
            Dy[i][2] = Integer.min(Dy[i - 1][0], Dy[i - 1][1]) + A[2];
        }

        System.out.println(Integer.min(Dy[N][0], Integer.min(Dy[N][1], Dy[N][2])));


    }
}

~~~
***

## [백준 2156번 - 포도주 시식](https://www.acmicpc.net/problem/2156)
---

* __구현__

~~~java

public class baekjoon2156 {

    static int N;

    static int[] A;
    static int[][] Dy;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        A = new int[N + 1];
        Dy = new int[N + 1][2];

        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(br.readLine());
        }

        Dy[1][0] = 0;
        Dy[1][1] = A[1];

        if (N >= 2) {
            Dy[2][0] = A[2];
            Dy[2][1] = A[1] + A[2];
        }


        for (int i = 3; i <= N; i++) {
            Dy[i][0] = Math.max(Dy[i - 2][0] + A[i], Dy[i - 2][1] + A[i]);
            Dy[i][0] = Math.max(Dy[i][0], Math.max(Dy[i - 3][0], Dy[i - 3][1]) + A[i]);
            Dy[i][1] = Dy[i - 1][0] + A[i];
        }

        System.out.println(Math.max(Math.max(Dy[N][0], Dy[N][1]), Math.max(Dy[N - 1][0], Dy[N - 1][1])));
    }
}

~~~
***


## [백준 2193번 - 이친수](https://www.acmicpc.net/problem/2193)
---

* __구현__

~~~java

public class baekjoon2193 {

    static int N;

    static long[][] Dy;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        Dy = new long[N + 1][2];

        Dy[1][1] = 1;

        for (int i = 2; i <= N; i++) {
            Dy[i][0] = Dy[i - 1][0] + Dy[i - 1][1];
            Dy[i][1] = Dy[i - 1][0];
        }

        System.out.println(Dy[N][0] + Dy[N][1]);

    }
}


~~~
***

## [백준 9465번 - 스티커](https://www.acmicpc.net/problem/9465)
---

* __구현__

~~~java

public class baekjoon9465 {

    static int T;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        T = Integer.parseInt(br.readLine());

        while (T-- > 0) {
            int N = Integer.parseInt(br.readLine());
            int[][] sticker = new int[2][N + 1];
            int[][] Dy = new int[2][N + 1];

            for (int i = 0; i < 2; i++) {
                StringTokenizer st = new StringTokenizer(br.readLine(), " ");
                for (int j = 1; j <= N; j++) {
                    sticker[i][j] = Integer.parseInt(st.nextToken());
                }
            }

            Dy[0][1] = sticker[0][1];
            Dy[1][1] = sticker[1][1];

            for (int i = 2; i <= N; i++) {
                Dy[0][i] = Math.max(Dy[1][i - 1], Dy[1][i - 2]) + sticker[0][i];
                Dy[1][i] = Math.max(Dy[0][i - 1], Dy[0][i - 2]) + sticker[1][i];
            }

            System.out.println(Math.max(Dy[1][N], Dy[0][N]));

        }

    }
}


~~~
***