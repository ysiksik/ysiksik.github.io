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

## [백준 1309번 - 동물원](https://www.acmicpc.net/problem/1309)
---

* __구현__

~~~java

public class baekjoon1309 {


    static int[][] Dy;
    static int N;

    static final int MOD = 9901;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        Dy = new int[N + 1][3];


        Dy[1][0] = Dy[1][1] = Dy[1][2] = 1;

        for (int i = 2; i <= N; i++) {

            Dy[i][0] = (Dy[i - 1][0] + Dy[i - 1][1] + Dy[i - 1][2]) % MOD;
            Dy[i][1] = (Dy[i - 1][0] + Dy[i - 1][2]) % MOD;
            Dy[i][2] = (Dy[i - 1][0] + Dy[i - 1][1]) % MOD;

        }

        System.out.println((Dy[N][0] + Dy[N][1] + Dy[N][2]) % MOD);


    }


}
}


~~~
***

## [백준 2688번 - 줄어들지 않아](https://www.acmicpc.net/problem/2688)
---

* __구현__

~~~java

public class baekjoon2688 {


    public static void main(String[] args) throws IOException {


        long[][] Dy = new long[65][10];

        for (int i = 0; i <= 9; i++) {
            Dy[1][i] = 1;
        }

        for (int i = 2; i <= 64; i++) {
            for (int j = 0; j <= 9; j++) {
                for (int k = j; k <= 9; k++) {
                    Dy[i][j] += Dy[i - 1][k];
                }
            }

        }

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int T = Integer.parseInt(br.readLine());

        while (T-- > 0) {
            int N = Integer.parseInt(br.readLine());

            long sum = 0;
            for (int i = 0; i <= 9; i++) {
                sum += Dy[N][i];
            }

            System.out.println(sum);

        }


    }


}


~~~
***


## [백준 11057번 - 오르막 수 ](https://www.acmicpc.net/problem/11057)
---

__정답의 최대치__
+ 정답을 10,007로 누눈 나머지를 출력해야 한다.
+ 즉, 문제를 푸는 과정에서 계속 나눈 나머지만 가지고 있다면 Integer 범위로도 충분할 것이다.


__시간, 공간 복잡도 계산하기__
+ 완전 탐색을 통해 모든 경우를 세면 정답의 개수만큼의 시간이 걸리지만, Dy 배열을 채우는 것은O(N*10^2)이라는 시간 복잡도면 충분하다

* __구현__

~~~java

public class baekjoon11057 {


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        int N = Integer.parseInt(br.readLine());

        int[][] Dy = new int[N + 1][10];

        for (int i = 0; i <= 9; i++) {
            Dy[1][i] = 1;
        }

        for (int i = 2; i <= N; i++) {
            for (int j = 0; j <= 9; j++) {
                for (int k = 0; k <= j; k++) {
                    Dy[i][j] += Dy[i - 1][k];
                    Dy[i][j] %= 10007;
                }
            }
        }

        int result = 0;

        for (int i = 0; i <= 9; i++) {
            result += Dy[N][i];
            result %= 10007;
        }

        System.out.println(result);

    }


}

~~~
***


## [백준 1562번 - 계단 수 ](https://www.acmicpc.net/problem/1562)
---

* __구현__

~~~java

public class baekjoon1562 {

    static final int MOD = 1000000000;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        int N = Integer.parseInt(br.readLine());

        long[][][] Dy = new long[N + 1][10][1 << 10];

        for (int i = 1; i <= 9; i++) {
            Dy[1][i][1 << i] = 1;
        }

        for (int i = 2; i <= N; i++) {
            for (int k = 0; k <= 9; k++) {
                for (int visit = 0; visit < (1 << 10); visit++) {
                    int newVisit = visit | (1 << k);
                    if (k == 0) {
                        Dy[i][k][newVisit] += Dy[i - 1][k + 1][visit] % MOD;
                    } else if (k == 9) {
                        Dy[i][k][newVisit] += Dy[i - 1][k - 1][visit] % MOD;
                    } else {
                        Dy[i][k][newVisit] += Dy[i - 1][k - 1][visit] % MOD + Dy[i - 1][k + 1][visit] % MOD;
                    }

                }
            }
        }

        long sum = 0;

        for (int i = 0; i <= 9; i++) {
            sum += Dy[N][i][(1 << 10) - 1] % MOD;
            sum %= MOD;
        }

        System.out.println(sum);


    }


}

~~~
***

## [백준 2096번 - 내려가기 ](https://www.acmicpc.net/problem/2096)
---

* __구현__

~~~java

public class baekjoon2096 {


    static int[] Dy;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st;

        int[] maxDp = new int[3];
        int[] minDp = new int[3];

        int N = Integer.parseInt(br.readLine());

        for (int i = 0; i < N; i++) {
            st = new StringTokenizer(br.readLine(), " ");

            int x1 = Integer.parseInt(st.nextToken());
            int x2 = Integer.parseInt(st.nextToken());
            int x3 = Integer.parseInt(st.nextToken());

            if (i == 0) {
                maxDp[0] = minDp[0] = x1;
                maxDp[1] = minDp[1] = x2;
                maxDp[2] = minDp[2] = x3;
            } else {
                int temp1 = maxDp[0];
                int temp2 = maxDp[2];

                maxDp[0] = Math.max(maxDp[0], maxDp[1]) + x1;
                maxDp[2] = Math.max(maxDp[1], maxDp[2]) + x3;
                maxDp[1] = Math.max(Math.max(maxDp[1], temp1), temp2) + x2;


                int temp3 = minDp[0];
                int temp4 = minDp[2];

                minDp[0] = Math.min(minDp[0], minDp[1]) + x1;
                minDp[2] = Math.min(minDp[1], minDp[2]) + x3;
                minDp[1] = Math.min(Math.min(minDp[1], temp3), temp4) + x2;
            }
        }


        System.out.println(Math.max(Math.max(maxDp[0], maxDp[1]), maxDp[2]) + " " + Math.min(Math.min(minDp[1], minDp[2]), minDp[0]));

    }


}

~~~
***

## [백준 5557번 - 1학년 ](https://www.acmicpc.net/problem/5557)
---

* __구현__

~~~java

public class baekjoon5557 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        int N = Integer.parseInt(br.readLine());
        long[][] Dy = new long[N + 1][21];
        int[] A = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(st.nextToken());
        }

        Dy[1][A[1]] = 1;

        for (int i = 2; i < N; i++) {
            for (int j = 0; j <= 20; j++) {
                for (int cur : new int[]{j - A[i], j + A[i]}) {
                    if (cur < 0 || cur > 20) continue;
                    Dy[i][cur] += Dy[i - 1][j];
                }
            }
        }


        System.out.println(Dy[N - 1][A[N]]);
    }


}

~~~
***

## [백준 1495번 - 기타리스트 ](https://www.acmicpc.net/problem/1495)
---

* __구현__

~~~java

public class baekjoon1495 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());
        int S = Integer.parseInt(st.nextToken());
        int M = Integer.parseInt(st.nextToken());

        boolean[][] Dy = new boolean[N + 1][M + 1];

        int[] A = new int[N + 1];
        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(st.nextToken());
        }

        Dy[0][S] = true;

        int result = 0;

        for (int i = 1; i <= N; i++) {
            boolean flag = false;
            result = 0;
            for (int j = 0; j <= M; j++) {
                if (!Dy[i - 1][j]) continue;
                for (int cur : new int[]{j - A[i], j + A[i]}) {
                    if (cur < 0 || cur > M) continue;
                    Dy[i][cur] = true;
                    result = Math.max(result, cur);
                    flag = true;
                }
            }
            if (!flag) {
                System.out.println(-1);
                return;
            }
        }

        System.out.println(result);

    }

}

~~~
***

## [백준 9095번 - 1, 2, 3 더하기 ](https://www.acmicpc.net/problem/9095)
---

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

## [백준 15988번 - 1, 2, 3 더하기 3 ](https://www.acmicpc.net/problem/15988)
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

## [백준 15990번 - 1, 2, 3 더하기 5 ](https://www.acmicpc.net/problem/15990)
---

* __구현__

~~~java

public class baekjoon15990 {

    public static void main(String[] args) throws IOException {

        int MOD = 1000000009;

        int[][] Dy = new int[100005][4];

        Dy[1][1] = 1;
        Dy[2][2] = 1;
        Dy[3][1] = 1;
        Dy[3][2] = 1;
        Dy[3][3] = 1;


        for (int i = 4; i <= 100000; i++) {
            for (int cur = 1; cur <= 3; cur++) {
                for (int prev = 1; prev <= 3; prev++){
                    if (cur == prev) continue;
                    Dy[i][cur] += Dy[i - cur][prev];
                    Dy[i][cur] %= MOD;
                }
            }
        }

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int T = Integer.parseInt(br.readLine());

        while (T-- > 0) {
            int N = Integer.parseInt(br.readLine());
            int result = 0;

            for (int i = 1; i <= 3; i++){
                result += Dy[N][i];
                result %= MOD;
            }
            System.out.println(result);
        }
    }
}

~~~
***

## [백준 1949번 - 우수마을 ](https://www.acmicpc.net/problem/1949)
---

* __구현__

~~~java

public class baekjoon1949 {

    static int N;
    static int[] A;
    static ArrayList<Integer>[] tree;
    static int[][] Dy;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        A = new int[N + 1];
        tree = new ArrayList[N + 1];
        Dy = new int[N + 1][2];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(st.nextToken());
            tree[i] = new ArrayList<>();
        }

        for (int i = 1; i < N; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            tree[x].add(y);
            tree[y].add(x);
        }

        dfs1949(1, -1);

        System.out.println(Math.max(Dy[1][0], Dy[1][1]));

    }

    private static void dfs1949(int x, int prev) {
        Dy[x][1] = A[x];

        for (int y : tree[x]) {
            if (y == prev) continue;

            dfs1949(y, x);

            Dy[x][0] += Math.max(Dy[y][0], Dy[y][1]);
            Dy[x][1] += Dy[y][0];
        }


    }
}


~~~
***