---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 09.동적 프로그래밍 (Dynamic Programming) - 3
date: '2022-11-17 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 09.동적 프로그래밍 (Dynamic Programming) - 3

# 09.동적 프로그래밍 (Dynamic Programming) - 3
* toc
{:toc}

## [백준 11066번 - 파일 합치기](https://www.acmicpc.net/problem/11066)
---

* __접근__
+ 1.풀고 싶은 가짜 문제(i ≤ j)
  + Dy[i][j] = i번 ~ j번 파일을 하나로 합치는 최소 비용
+ 2.가짜 문제를 풀면 진짜 문제를 풀 수 있는가
  + Dy 배열을 가득 채울 수만 있다면? 진짜 문제에 대한 대답은 Dy[1][K] 이다.
+ 3.초기값은 어떻게 되는가?
  + 초기값: 쪼개지 않아도 풀 수 있는 “작은 문제”들에 대한 정답
+ 4.점화식 구해내기
  + Dy[i][j] 계산에 필요한 탐색 경우를 공통점끼리 묶어 내기 (Partitioning)
  + 묶어낸 부분의 정답을 Dy 배열을 이용해서 빠르게 계산해보기

  
* __구현__

~~~java

public class baekjoon11066 {


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int T = Integer.parseInt(br.readLine());

        while (T-- > 0) {
            int K = Integer.parseInt(br.readLine());
            int[][] sum = new int[K + 1][K + 1];
            int[] num = new int[K + 1];

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            for (int i = 1; i <= K; i++) {
                num[i] = Integer.parseInt(st.nextToken());
            }

            for (int i = 1; i <= K; i++) {
                for (int j = i; j <= K; j++) {
                    sum[i][j] = sum[i][j - 1] + num[j];
                }
            }

            int[][] Dy = new int[K + 1][K + 1];

            for (int len = 2; len <= K; len++) {
                for (int i = 1; i <= K - len + 1; i++) {
                    int j = i + len - 1;

                    Dy[i][j] = Integer.MAX_VALUE;

                    for (int k = i; k < j; k++) {
                        Dy[i][j] = Math.min(Dy[i][j], Dy[i][k] + Dy[k + 1][j] + sum[i][j]);
                    }

                }
            }

            System.out.println(Dy[1][K]);

        }


    }


}

~~~
***

## [백준 11049번 - 행렬 곱셈 순서](https://www.acmicpc.net/problem/11049)
---

* __구현__

~~~java

public class baekjoon11049 {


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());

        int[][] Dy = new int[N][N];

        int[][] mat = new int[N][2];

        for (int i = 0; i < N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            mat[i][0] = Integer.parseInt(st.nextToken());
            mat[i][1] = Integer.parseInt(st.nextToken());
        }

        for (int i = 0; i < N - 1; i++) {
            Dy[i][i + 1] = mat[i][0] * mat[i][1] * mat[i + 1][1];
        }

        for (int len = 2; len < N; len++) {
            for (int i = 0; i + len < N; i++) {
                int j = i + len;
                Dy[i][j] = Integer.MAX_VALUE;
                for (int k = i; k < j; k++) {
                    Dy[i][j] = Math.min(Dy[i][j], Dy[i][k] + Dy[k + 1][j] + (mat[i][0] * mat[k][1] * mat[j][1]));
                }
            }
        }

        System.out.println(Dy[0][N - 1]);

    }


}

~~~
***

## [백준 10942번 - 팰린드롬?](https://www.acmicpc.net/problem/10942)
---

* __구현__

~~~java

public class baekjoon10942 {

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int n = Integer.parseInt(br.readLine());

        int[] arr = new int[n + 1];
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= n; i++) {
            arr[i] = Integer.parseInt(st.nextToken());
        }

        boolean[][] dy = new boolean[n + 1][n + 1];

        for (int i = 1; i <= n; i++) {
            dy[i][i] = true;
        }

        for (int i = 1; i <= n - 1; i++) {
            if (arr[i] == arr[i + 1]) dy[i][i + 1] = true;
        }

        for (int i = 2; i < n; i++) {
            for (int j = 1; j <= n - i; j++) {
                if (arr[j] == arr[j + i] && dy[j + 1][j + i - 1]) {
                    dy[j][j + i] = true;
                }
            }
        }

        int m = Integer.parseInt(br.readLine());
        StringBuilder sb = new StringBuilder();
        while (m-- > 0) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            sb.append(dy[x][y] ? "1\n" : "0\n");
        }

        System.out.println(sb);

    }


}

~~~
***

## [백준 1509번 - 팰린드롬 분할](https://www.acmicpc.net/problem/1509)
---

* __구현__

~~~java

public class baekjoon1509 {

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        String str = br.readLine();
        int n = str.length();

        char[] arr = str.toCharArray();
        boolean[][] check = new boolean[n + 1][n + 1];
        int[] dy = new int[n + 1];

        for (int i = 1; i <= n; i++) {
            dy[i] = Integer.MAX_VALUE;
        }

        for (int i = 1; i <= n; i++) {
            check[i][i] = true;
        }

        for (int i = 1; i <= n - 1; i++) {
            if (arr[i - 1] == arr[i]) check[i][i + 1] = true;
        }

        for (int i = 2; i < n; i++) {
            for (int j = 1; j <= n - i; j++) {
                if (arr[j - 1] == arr[j + i - 1] && check[j + 1][j + i - 1]) check[j][j + i] = true;
            }
        }

        for (int i = 1; i <= n; i++) {
            for (int j = 1; j <= i; j++) {
                if (check[j][i]) {
                    dy[i] = Math.min(dy[i], dy[j - 1] + 1);
                }
            }
        }

        System.out.println(dy[n]);

    }

}

~~~
***

## [백준 15681번 - 트리와 쿼리](https://www.acmicpc.net/problem/15681)
---

* __접근__
* 작은 문제 -> 큰 문제
* 1) 풀고 싶은 문제 정의
  * Dy[i] := i를 root로 하는 subtree의 정점 개수
* 2) 초기값은 어떻게 되는가?
  * 초기값: “단말 노드”가 제일 작은 문제이다. (정점이 한 개 뿐이라서)
* 3) 점화식 구해내기
  * Rooted Tree이므로 부모, 자식 관계가 존재한다.
  * 자식 노드에 대해 문제를 해결한다면, 부모 노드는 그걸 이용해서 문제를 풀면 된다.
  * Dy[부모 노드] = ∑ Dy[자식 노드들] + 1

* __시간, 공간 복잡도 계산하기__
* Rooted Tree 문제를 DP 로 풀 경우 대부분 DFS 한 번에
  해결한다. 따라서 DFS의 시간복잡도인 O(V + E)=O(N)
  만에 문제를 풀 수 있다.

* __구현__

~~~java

public class baekjoon15681 {


    static int[] Dy;
    static int N, R, Q;
    static ArrayList<Integer>[] graph;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        R = Integer.parseInt(st.nextToken());
        Q = Integer.parseInt(st.nextToken());

        graph = new ArrayList[N + 1];
        Dy = new int[N + 1];

        for (int i = 1; i <= N; i++) {
            graph[i] = new ArrayList<>();
        }

        for (int i = 1; i < N; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            graph[x].add(y);
            graph[y].add(x);
        }

        dfs15681(R, -1);

        StringBuilder sb = new StringBuilder();
        for (int i = 1; i <= Q; i++) {
            int U = Integer.parseInt(br.readLine());
            sb.append(Dy[U]).append('\n');
        }
        System.out.println(sb);
    }

    private static void dfs15681(int x, int prev) {
        Dy[x] = 1;
        for (int y : graph[x]) {
            if (prev == y) continue;
            dfs15681(y, x);
            Dy[x] += Dy[y];
        }
    }

}


~~~
***

## [백준 1949번 - 우수 마을](https://www.acmicpc.net/problem/1949)
---

* __정답의 최대치__ <br>
일단 모든 마을에 최대 인원이 존재해야 할 것이므로 모든 마을에 1만 명의 주민이 존
재할 것이다.
마을을 최대한 많이 고르기 위해서는 최대 개수(1만 개)의 마을이 일렬로 존재해서 약
9,999 개의 마을을 선택할 경우이다.
즉, 약 1억 명을 고르는 것이 최대이므로 Integer 범위임이 보장된다.


* __접근__
* 작은 문제 -> 큰 문제
* 1) 풀고 싶은 문제 정의
  * Dy[i][0] := i를 root로 하는 subtree에서 root를 선택하지 않고서 가능한 최대 주민 수
  * Dy[i][1] := i를 root로 하는 subtree에서 root를 선택하고서 가능 한 최대 주민 수
* 2) 가짜 문제를 풀면 진짜 문제를 풀 수 있는가?
  * Dy 배열을 가득 채울 수만 있다면? 진짜 문제에 대한 대답은 실제 루트를 고르 거나 안 고르는 것 중 최대이므로 max(Dy[1][0] ,Dy[1][1]) 이다.
* 3) 초기값은 어떻게 되는가?
  * 초기값: “단말 노드”가 제일 작은 문제이다. (정점이 한 개 뿐이라서)
* 4) 점화식 구해내기
  * Rooted Tree이므로 부모, 자식 관계가 존재한다.
  * 자식 노드에 대해 문제를 해결한다면, 부모 노드는 그걸 이용해서 문제를 풀면 된다.

* __시간, 공간 복잡도 계산하기__ <br>
Rooted Tree 문제를 DP 로 풀 경우 대부분 DFS 한 번에
해결한다. 따라서 DFS의 시간복잡도인 O(V + E)=O(N)
만에 문제를 풀 수 있다.

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