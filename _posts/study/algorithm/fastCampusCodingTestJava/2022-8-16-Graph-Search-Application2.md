---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 05.그래프와 탐색 (Graph & Search) - 응용편2
date: '2022-08-16 00:00:00 +0900'
categories:
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 05.그래프와 탐색 (Graph & Search) - 응용편2

# 05.그래프와 탐색 (Graph & Search) - 응용편2
* toc
{:toc}

## 05.그래프와 탐색 (Graph & Search) - 응용편2
+ BFS의 부가 효과
  + 탐색(Search) = 시작점에서 갈 수 있는 정점들은?
    + 몇 번의 이동이 필요한가?
    + 다른 정점까지 최소 이동 횟수도 계산 가능하다.
+ 키워드
  + 최소 이동 횟수, 최단 시간
  + 최소 이동 횟수와 관련된 것이기 때문에, 가중치에 대한 개념이 없는 문제에서만 생기는 부가효과

## [백준 2178번 - 미로 탐색](https://www.acmicpc.net/problem/2178)
---

+ 정답의 최대치
  + 밟게 되는 최대 개수 $$ O(N^2) $$ 

+ 시간, 공간 복잡도 계산하기
  + 격자형 그래프
    + 정점 : $$ O(N^2) $$
    + 간선 : $$ O(N^2 \times 4) $$
    + BFS를 사용하므로 시간, 공간 복잡도는 모두 $$ O(N^2) $$ 

* __구현__

~~~java

public class baekjoon2178 {

    static int N, M;
    static char[][] graph;
    static boolean[][] visited;
    static int[][] dist;
    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        graph = new char[N][M];

        for (int i = 0; i < N; i++) {
            graph[i] = br.readLine().toCharArray();
        }

        visited = new boolean[N][M];
        dist = new int[N][M];


        bfs2178(0, 0);

        System.out.println(dist[N - 1][M - 1]);

    }

    private static void bfs2178(int x, int y) {

        for (int i = 0; i < N; i++) {
            Arrays.fill(dist[i], -1);
        }

        Queue<int[]> queue = new LinkedList<>();

        queue.add(new int[]{x, y});
        visited[x][y] = true;
        dist[x][y] = 1;

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {
                int nx = cur[0] + move[i][0];
                int ny = cur[1] + move[i][1];

                if (nx < 0 || ny < 0 || nx >= N || ny >= M) continue;
                if (visited[nx][ny]) continue;
                if (graph[nx][ny] == '0') continue;

                queue.add(new int[]{nx, ny});
                visited[nx][ny] = true;
                dist[nx][ny] = dist[cur[0]][cur[1]] + 1;
            }

        }

    }
}

~~~
***


## [백준 7562번 - 나이트의 이동](https://www.acmicpc.net/problem/7562)
---

* __구현__

~~~java

public class baekjoon7562 {

    static int T, I, X, Y, RX, RY;
    static boolean[][] visited;
    static int[][] dist, graph;

    static int[][] move = { {-1, -2}, {-2, -1}, {-2, 1}, {-1, 2}, {1, 2}, {2, 1}, {2, -1}, {1, -2} };


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        T = Integer.parseInt(br.readLine());

        for (int t = 0; t < T; t++) {
            I = Integer.parseInt(br.readLine());
            graph = new int[I][I];
            visited = new boolean[I][I];
            dist = new int[I][I];

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");

            X = Integer.parseInt(st.nextToken());
            Y = Integer.parseInt(st.nextToken());

            st = new StringTokenizer(br.readLine(), " ");

            RX = Integer.parseInt(st.nextToken());
            RY = Integer.parseInt(st.nextToken());

            bfs7562(X, Y);
            System.out.println(dist[RX][RY]);
        }


    }

    private static void bfs7562(int x, int y) {
        Queue<int[]> queue = new LinkedList<>();
        queue.add(new int[]{x, y});
        visited[x][y] = true;
        dist[x][y] = 0;

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {
                int nx = cur[0] + move[i][0];
                int ny = cur[1] + move[i][1];

                if (nx < 0 || ny < 0 || nx >= I || ny >= I) continue;
                if (visited[nx][ny]) continue;

                queue.add(new int[]{nx, ny});
                visited[nx][ny] = true;
                dist[nx][ny] = dist[cur[0]][cur[1]] + 1;
            }


        }

    }


}

~~~

***


## [백준 2644번 - 촌수 계산](https://www.acmicpc.net/problem/2644)
---

* __구현__

~~~java

public class baekjoon2644 {


    static int N, P1, P2, M;
    static ArrayList<Integer>[] graph;
    static boolean[] visit;

    static int[] dist;


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());


        graph = new ArrayList[N + 1];

        for (int i = 1; i <= N; i++) {
            graph[i] = new ArrayList<>();
        }
        visit = new boolean[N + 1];
        dist = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        P1 = Integer.parseInt(st.nextToken());
        P2 = Integer.parseInt(st.nextToken());

        M = Integer.parseInt(br.readLine());

        for (int i = 0; i < M; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());
            graph[x].add(y);
            graph[y].add(x);
        }

        bfs2644();
        System.out.println(dist[P2]);
    }

    private static void bfs2644() {

        Arrays.fill(dist, -1);

        Queue<Integer> queue = new LinkedList<>();
        queue.add(P1);
        visit[P1] = true;
        dist[P1] = 0;

        while (!queue.isEmpty()) {

            int cur = queue.poll();

            for (int i = 0; i < graph[cur].size(); i++) {
                int next = graph[cur].get(i);
                if (visit[next]) continue;
                queue.add(next);
                visit[next] = true;
                dist[next] = dist[cur] + 1;
            }

        }

    }


}


~~~

***


## [백준 18404번 - 현명한 나이트](https://www.acmicpc.net/problem/18404)

---

* __구현__

~~~java

public class baekjoon18404 {

    static int N, M, X, Y;
    static int[][] target, graph, dist;
    static boolean[][] visit;

    static int[][] move = { {-2, -1}, {-2, 1}, {-1, -2}, {-1, 2}, {1, -2}, {1, 2}, {2, -1}, {2, 1} };


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        st = new StringTokenizer(br.readLine(), " ");

        X = Integer.parseInt(st.nextToken());
        Y = Integer.parseInt(st.nextToken());

        graph = new int[N + 1][N + 1];
        dist = new int[N + 1][N + 1];
        visit = new boolean[N + 1][N + 1];


        target = new int[M][2];

        for (int i = 0; i < M; i++) {

            st = new StringTokenizer(br.readLine(), " ");

            int A = Integer.parseInt(st.nextToken());
            int B = Integer.parseInt(st.nextToken());

            target[i] = new int[]{A, B};
        }

        dfs18404();

        for (int i = 0; i < M; i++) {
            System.out.print(dist[target[i][0]][target[i][1]] + " ");
        }

    }

    private static void dfs18404() {
        Queue<int[]> queue = new LinkedList<>();
        queue.add(new int[]{X, Y});
        visit[X][Y] = true;

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {
                int nx = cur[0] + move[i][0];
                int ny = cur[1] + move[i][1];

                if (nx < 0 || ny < 0 || nx > N || ny > N) continue;
                if (visit[nx][ny]) continue;

                queue.add(new int[]{nx, ny});
                visit[nx][ny] = true;
                dist[nx][ny] = dist[cur[0]][cur[1]] + 1;

            }

        }

    }


}


~~~

***


## [백준 1697번 - 숨바꼭질](https://www.acmicpc.net/problem/1697)

---

+ 정답의 최대치
  + 문데에 대한 관찰 연습 - 언제 가장 오래 걸릴까?
    + N > K 이라면, 갈 수 있는 방법이 1 씩 감소는것 뿐이다. 즉, N = 10만 K = 0 인 경우가 10만 초로 제일 오래 걸린다.
+ 시간, 공간 복잡도 계산하기
    + 새로 만든 그래프
        + 정점 : $$ O(N^5) $$
        + 간선 : $$ O(N^5 \times 4) $$
        + BFS를 사용하므로 시간, 공간 복잡도는 모두 $$ O(N^6) $$

* __구현__

~~~java

public class baekjoon1697 {

    static int N, K;
    static int[] dist;
    static boolean[] visit;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        K = Integer.parseInt(st.nextToken());

        dist = new int[100005];
        visit = new boolean[100005];

        bfs1697();

        System.out.println(dist[K]);
    }

    private static void bfs1697() {
        Queue<Integer> queue = new LinkedList<>();
        queue.add(N);
        visit[N] = true;

        while (!queue.isEmpty()) {
            int c = queue.poll();

            if (c - 1 >= 0 && !visit[c - 1]) {
                queue.add(c - 1);
                visit[c - 1] = true;
                dist[c - 1] = dist[c] + 1;
            }

            if (c + 1 <= 100000 && !visit[c + 1]) {
                queue.add(c + 1);
                visit[c + 1] = true;
                dist[c + 1] = dist[c] + 1;
            }

            if (c * 2 <= 100000 && !visit[c * 2]) {
                queue.add(c * 2);
                visit[c * 2] = true;
                dist[c * 2] = dist[c] + 1;
            }

        }

    }

}

~~~

***


## [백준 1389번 - 케빈 베이컨의 6간계 법칙](https://www.acmicpc.net/problem/1389)

---

* __구현__

~~~java

public class baekjoon1389 {

    static int N, M;
    static int[] dist, result;
    static boolean[] visited;
    static ArrayList<Integer>[] graph;

    static int min = Integer.MAX_VALUE;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        result = new int[N + 1];
        graph = new ArrayList[N + 1];
        for (int i = 1; i <= N; i++) {
            graph[i] = new ArrayList<>();
        }

        for (int i = 1; i <= M; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            graph[x].add(y);
            graph[y].add(x);
        }

        for (int i = 1; i <= N; i++) {

            dist = new int[N + 1];
            visited = new boolean[N + 1];


            bfs1389(i);

            int sum = 0;
            for (int j = 1; j <= N; j++) {
                sum += dist[j];
            }
            min = Integer.min(min, sum);
            result[i] = sum;
        }

        for (int i = 1; i <= N; i++) {

            if (result[i] == min) {
                System.out.println(i);
                break;
            }

        }


    }

    private static void bfs1389(int start) {

        Queue<Integer> queue = new LinkedList<>();

        queue.add(start);
        visited[start] = true;

        while (!queue.isEmpty()) {
            int cur = queue.poll();

            for (int x : graph[cur]) {

                if (visited[x]) continue;

                queue.add(x);
                visited[x] = true;
                dist[x] = dist[cur] + 1;
            }
        }


    }


}

~~~

***



## [백준 5567번 - 결혼식](https://www.acmicpc.net/problem/5567)

---

* __구현__

~~~java

public class baekjoon5567 {

    static int N, M;
    static ArrayList<Integer>[] graph;

    static int[] dist;
    static boolean[] visit;


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        M = Integer.parseInt(br.readLine());


        dist = new int[N + 1];
        visit = new boolean[N + 1];
        graph = new ArrayList[N + 1];

        for (int i = 1; i <= N; i++) {
            graph[i] = new ArrayList<>();
        }
        for (int i = 1; i <= M; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            graph[x].add(y);
            graph[y].add(x);
        }

        bfs5567();

        int result = 0;
        for (int i = 1; i <= N; i++) {
            if (dist[i] == 1 || dist[i] == 2) result++;
        }
        System.out.println(result);

    }

    private static void bfs5567() {
        Queue<Integer> queue = new LinkedList<>();
        queue.add(1);
        visit[1] = true;

        while (!queue.isEmpty()) {
            int cur = queue.poll();

            for (int x : graph[cur]) {

                if (visit[x]) continue;
                queue.add(x);
                visit[x] = true;
                dist[x] = dist[cur] + 1;
            }

        }

    }


}

~~~

***


## [백준 3055번 - 탈출](https://www.acmicpc.net/problem/3055)

---

+ 정답의 최대치
    + 밟게 되는 최대 개수 $$ O(N^2) $$
+ 시간, 공간 복잡도 계산하기
  + 총 2 번의 BFS를 이용

* __구현__

~~~java


public class baekjoon3055 {

    static int R, C;
    static boolean[][] visit;
    static String[] graph;
    static int[][] dist_water, dist_hedgehog;

    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        R = Integer.parseInt(st.nextToken());
        C = Integer.parseInt(st.nextToken());

        visit = new boolean[R][C];
        dist_water = new int[R][C];
        dist_hedgehog = new int[R][C];

        graph = new String[R];

        for (int i = 0; i < R; i++) {
            graph[i] = br.readLine();
        }

        dfs3055_water();
        dfs3055_hedgehog();

        for (int i = 0; i < R; i++) {
            for (int j = 0; j < C; j++) {
                if (graph[i].charAt(j) == 'D') {
                    if (dist_hedgehog[i][j] == -1) System.out.println("KAKTUS");
                    else System.out.println(dist_hedgehog[i][j]);
                }
            }
        }
    }

    private static void dfs3055_hedgehog() {

        Queue<int[]> queue = new LinkedList<>();

        for (int i = 0; i < R; i++) {
            for (int j = 0; j < C; j++) {
                visit[i][j] = false;
                dist_hedgehog[i][j] = -1;

                if (graph[i].charAt(j) == 'S') {
                    queue.add(new int[]{i, j});
                    visit[i][j] = true;
                    dist_hedgehog[i][j] = 0;
                }

            }
        }

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {
                int nx = cur[0] + move[i][0];
                int ny = cur[1] + move[i][1];

                if (nx < 0 || ny < 0 || nx >= R || ny >= C) continue;
                if (visit[nx][ny]) continue;
                if (graph[nx].charAt(ny) != '.' && graph[nx].charAt(ny) != 'D') continue;
                if (dist_water[nx][ny] != -1 && dist_water[nx][ny] <= dist_hedgehog[cur[0]][cur[1]] + 1) continue;

                queue.add(new int[]{nx, ny});
                visit[nx][ny] = true;
                dist_hedgehog[nx][ny] = dist_hedgehog[cur[0]][cur[1]] + 1;

            }

        }


    }

    private static void dfs3055_water() {

        Queue<int[]> queue = new LinkedList<>();

        for (int i = 0; i < R; i++) {
            for (int j = 0; j < C; j++) {
                visit[i][j] = false;
                dist_water[i][j] = -1;
                if (graph[i].charAt(j) == '*') {
                    queue.add(new int[]{i, j});
                    visit[i][j] = true;
                    dist_water[i][j] = 0;
                }
            }
        }

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {
                int nx = cur[0] + move[i][0];
                int ny = cur[1] + move[i][1];

                if (nx < 0 || ny < 0 || nx >= R || ny >= C) continue;
                if (visit[nx][ny]) continue;
                if (graph[nx].charAt(ny) != '.') continue;

                queue.add(new int[]{nx, ny});
                visit[nx][ny] = true;
                dist_water[nx][ny] = dist_water[cur[0]][cur[1]] + 1;
            }

        }

    }
}


~~~

***

## [백준 7569번 - 토마토](https://www.acmicpc.net/problem/7569)

---

* __구현__

~~~java

public class baekjoon7569 {


    static int M, N, H;
    static int[][][] graph;
    static int[][] move = { {1, 0, 0}, {-1, 0, 0}, {0, -1, 0}, {0, 0, 1}, {0, 1, 0}, {0, 0, -1} };
    static int[][][] disk;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        M = Integer.parseInt(st.nextToken());
        N = Integer.parseInt(st.nextToken());
        H = Integer.parseInt(st.nextToken());


        disk = new int[H + 1][N + 1][M + 1];

        graph = new int[H + 1][N + 1][M + 1];

        for (int h = 1; h <= H; h++) {
            for (int i = 1; i <= N; i++) {
                st = new StringTokenizer(br.readLine(), " ");
                for (int j = 1; j <= M; j++) {
                    graph[h][i][j] = Integer.parseInt(st.nextToken());
                }
            }
        }

        dfs7569();


        int result = 0;
        for (int h = 1; h <= H; h++) {
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= M; j++) {
                    if (graph[h][i][j] == -1) continue;
                    if (disk[h][i][j] == -1) {
                        System.out.println(-1);
                        return;
                    }
                    result = Math.max(result, disk[h][i][j]);
                }
            }
        }

        System.out.println(result);

    }

    private static void dfs7569() {

        Queue<int[]> queue = new LinkedList<>();

        for (int h = 1; h <= H; h++) {
            for (int i = 1; i <= N; i++) {
                for (int j = 1; j <= M; j++) {
                    disk[h][i][j] = -1;
                    if (graph[h][i][j] == 1) {
                        queue.add(new int[]{h, i, j});
                        disk[h][i][j] = 0;
                    }
                }
            }
        }

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {
                int nh = cur[0] + move[i][0];
                int nx = cur[1] + move[i][1];
                int ny = cur[2] + move[i][2];

                if (nh < 1 || nx < 1 || ny < 1 || nh > H || nx > N || ny > M) continue;
                if (graph[nh][nx][ny] == -1) continue;
                if (disk[nh][nx][ny] != -1) continue;

                queue.add(new int[]{nh, nx, ny});
                disk[nh][nx][ny] = disk[cur[0]][cur[1]][cur[2]] + 1;

            }


        }


    }
}


~~~

***



