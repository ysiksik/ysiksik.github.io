---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 05.그래프와 탐색 (Graph & Search) - 응용편
date: '2022-08-05 00:00:00 +0900'
categories:
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 05.그래프와 탐색 (Graph & Search) - 응용편

# 05.그래프와 탐색 (Graph & Search) - 응용편
* toc
{:toc}

## 05.그래프와 탐색 (Graph & Search) - 응용편


## [백준 2667번 - 단지번호 붙이기](https://www.acmicpc.net/problem/2667)
---

* __시간, 공간 복잡도 계산하기__
> + 격자형 그래프
>   + 정점 : $$ O(N^2) $$
>   + 간선 : $$ O(N^2 \times 4) $$
>   + BFS 이든 DFS 이든, 시간 복잡도는 모두 $$ O(N^2) $$ 

* __구현__

~~~java

public class baekjoon2667_DFS {

    static int N, count;
    static int[][] graph;
    static boolean[][] visited;

    static ArrayList<Integer> result = new ArrayList<>();

    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        graph = new int[N][N];
        visited = new boolean[N][N];

        for (int i = 0; i < N; i++) {
            char[] charArr = br.readLine().toCharArray();
            for (int j = 0; j < N; j++) {
                graph[i][j] = Integer.parseInt(String.valueOf(charArr[j]));
            }
        }

        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                if (visited[i][j] || graph[i][j] == 0) continue;
                count = 0;
                dfs2667(i, j);
                result.add(count);
            }
        }

        Collections.sort(result);

        System.out.println(result.size());

        for (int x : result) {
            System.out.println(x);
        }


    }

    private static void dfs2667(int x, int y) {

        visited[x][y] = true;
        count++;

        for (int i = 0; i < move.length; i++) {
            int nextX = x + move[i][0];
            int nextY = y + move[i][1];
            if (0 > nextX || 0 > nextY || nextX >= N || nextY >= N) continue;

            if (visited[nextX][nextY]) continue;

            if (graph[nextX][nextY] == 1) {
                dfs2667(nextX, nextY);
            }
        }
    }

}

~~~

~~~java

public class baekjoon2667_BFS {

    static int N, count;
    static int[][] graph;
    static boolean[][] visited;

    static ArrayList<Integer> result = new ArrayList<>();

    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        graph = new int[N][N];
        visited = new boolean[N][N];

        for (int i = 0; i < N; i++) {
            char[] charArr = br.readLine().toCharArray();
            for (int j = 0; j < N; j++) {
                graph[i][j] = Integer.parseInt(String.valueOf(charArr[j]));
            }
        }

        for (int i = 0; i < N; i++) {
            for (int j = 0; j < N; j++) {
                if (visited[i][j] || graph[i][j] == 0) continue;
                count = 0;
                bfs2667(i, j);
                result.add(count);
            }
        }

        Collections.sort(result);

        System.out.println(result.size());

        for (int x : result) {
            System.out.println(x);
        }


    }

    private static void bfs2667(int x, int y) {

        Queue<int[]> que = new LinkedList<>();
        que.add(new int[]{x, y});
        visited[x][y] = true;
        count++;

        while (!que.isEmpty()) {

            int[] cur = que.poll();

            int curX = cur[0];
            int curY = cur[1];

            for (int i = 0; i < move.length; i++) {

                int nextX = curX + move[i][0];
                int nextY = curY + move[i][1];

                if (nextX < 0 || nextY < 0 || nextX >= N || nextY >= N) continue;
                if (visited[nextX][nextY]) continue;

                if (graph[nextX][nextY] == 1) {
                    que.add(new int[]{nextX, nextY});
                    visited[nextX][nextY] = true;
                    count++;
                }

            }

        }


    }

}

~~~

***


## [백준 1012번 - 유기농 배추](https://www.acmicpc.net/problem/1012)
---

~~~java

public class baekjoon1012_DFS {

    static int T, N, M, K, count;
    static int[][] graph;
    static boolean[][] visited;

    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        T = Integer.parseInt(br.readLine());

        for (int i = 0; i < T; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            M = Integer.parseInt(st.nextToken());
            N = Integer.parseInt(st.nextToken());
            K = Integer.parseInt(st.nextToken());

            graph = new int[N][M];
            visited = new boolean[N][M];
            count = 0;

            for (int j = 0; j < K; j++) {
                st = new StringTokenizer(br.readLine(), " ");
                int m = Integer.parseInt(st.nextToken());
                int n = Integer.parseInt(st.nextToken());
                graph[n][m] = 1;
            }

            for (int x = 0; x < N; x++) {
                for (int y = 0; y < M; y++) {

                    if (graph[x][y] == 1 && !visited[x][y]) {
                        count++;
                        dfs1012(x, y);
                    }


                }
            }

            System.out.println(count);

        }


    }

    private static void dfs1012(int x, int y) {

        visited[x][y] = true;

        for (int i = 0; i < move.length; i++) {

            int nextX = x + move[i][0];
            int nextY = y + move[i][1];

            if (nextX < 0 || nextY < 0 || nextY >= M || nextX >= N) continue;
            if (visited[nextX][nextY]) continue;

            if (graph[nextX][nextY] == 1) {
                dfs1012(nextX, nextY);
            }


        }

    }


}

~~~

~~~java

public class baekjoon1012_BFS {

    static int T, N, M, K, count;
    static int[][] graph;
    static boolean[][] visited;

    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        T = Integer.parseInt(br.readLine());

        for (int i = 0; i < T; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            M = Integer.parseInt(st.nextToken());
            N = Integer.parseInt(st.nextToken());
            K = Integer.parseInt(st.nextToken());

            graph = new int[N][M];
            visited = new boolean[N][M];
            count = 0;

            for (int j = 0; j < K; j++) {
                st = new StringTokenizer(br.readLine(), " ");
                int m = Integer.parseInt(st.nextToken());
                int n = Integer.parseInt(st.nextToken());
                graph[n][m] = 1;
            }

            for (int x = 0; x < N; x++) {
                for (int y = 0; y < M; y++) {

                    if (graph[x][y] == 1 && !visited[x][y]) {
                        count++;
                        bfs1012(x, y);
                    }


                }
            }

            System.out.println(count);

        }


    }

    private static void bfs1012(int x, int y) {

        Queue<int[]> queue = new LinkedList<>();
        queue.add(new int[]{x, y});
        visited[x][y] = true;

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();
            int curX = cur[0];
            int curY = cur[1];

            for (int i = 0; i < move.length; i++) {
                int nx = curX + move[i][0];
                int ny = curY + move[i][1];

                if (nx < 0 || ny < 0 || nx >= N || ny >= M) continue;
                if (visited[nx][ny]) continue;
                if (graph[nx][ny] == 0) continue;

                queue.add(new int[]{nx, ny});
                visited[nx][ny] = true;

            }

        }


    }


}

~~~

***


## [백준 11724번 - 연결 요소의 개수](https://www.acmicpc.net/problem/11724)
---

~~~java

public class baekjoon11724_DFS {

    static int N, M, count;
    static ArrayList<Integer>[] graph;
    static boolean[] visited;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        graph = new ArrayList[N + 1];
        for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();


        for (int i = 0; i < M; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            graph[x].add(y);
            graph[y].add(x);
        }

        visited = new boolean[N + 1];
        for (int i = 1; i <= N; i++) {
            if (visited[i]) continue;
            dfs11724(i);
            count++;
        }
        System.out.println(count);


    }

    private static void dfs11724(int i) {
        visited[i] = true;

        for (int x : graph[i]) {
            if (visited[x]) continue;
            dfs11724(x);
        }

    }

}

~~~

~~~java

public class baekjoon11724_BFS {

    static int N, M, count;
    static ArrayList<Integer>[] graph;
    static boolean[] visited;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        graph = new ArrayList[N + 1];
        for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();


        for (int i = 0; i < M; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            graph[x].add(y);
            graph[y].add(x);
        }

        visited = new boolean[N + 1];
        for (int i = 1; i <= N; i++) {
            if (visited[i]) continue;
            bfs11724(i);
            count++;
        }
        System.out.println(count);


    }

    private static void bfs11724(int i) {
        Queue<Integer> queue = new LinkedList<>();

        queue.offer(i);
        visited[i] = true;

        while (!queue.isEmpty()){

            int cur = queue.poll();

            for (int x : graph[cur]){
                if (visited[x]) continue;

                queue.offer(x);
                visited[x] = true;
            }

        }

    }

}

~~~

***


## [백준 4963번 - 섬의 개수](https://www.acmicpc.net/problem/4963)

---


~~~java


public class baekjoon4963_DFS {


    static int w, h, count;

    static int[][] graph;

    static boolean[][] visited;


    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 1}, {1, 1}, {1, -1} };


    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        while (true) {


            StringTokenizer st = new StringTokenizer(br.readLine(), " ");


            w = Integer.parseInt(st.nextToken());

            h = Integer.parseInt(st.nextToken());


            if (w == 0 && h == 0) break;


            graph = new int[h][w];

            count = 0;


            for (int i = 0; i < h; i++) {

                st = new StringTokenizer(br.readLine(), " ");


                for (int j = 0; j < w; j++) {

                    graph[i][j] = Integer.parseInt(st.nextToken());

                }

            }

            visited = new boolean[h][w];


            for (int i = 0; i < h; i++) {


                for (int j = 0; j < w; j++) {

                    if (graph[i][j] == 0 || visited[i][j]) continue;


                    dfs4963(i, j);

                    count++;


                }


            }


            System.out.println(count);

        }


    }


    private static void dfs4963(int x, int y) {


        visited[x][y] = true;


        for (int i = 0; i < move.length; i++) {


            int nx = x + move[i][0];

            int ny = y + move[i][1];


            if (nx < 0 || ny < 0 || nx >= h || ny >= w) continue;

            if (visited[nx][ny]) continue;

            if (graph[nx][ny] == 0) continue;


            dfs4963(nx, ny);


        }


    }

}


~~~



~~~java


public class baekjoon4963_BFS {


    static int w, h, count;

    static int[][] graph;

    static boolean[][] visited;


    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 1}, {1, 1}, {1, -1} };


    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        while (true) {


            StringTokenizer st = new StringTokenizer(br.readLine(), " ");


            w = Integer.parseInt(st.nextToken());

            h = Integer.parseInt(st.nextToken());


            if (w == 0 && h == 0) break;


            graph = new int[h][w];

            count = 0;


            for (int i = 0; i < h; i++) {

                st = new StringTokenizer(br.readLine(), " ");


                for (int j = 0; j < w; j++) {

                    graph[i][j] = Integer.parseInt(st.nextToken());

                }

            }

            visited = new boolean[h][w];


            for (int i = 0; i < h; i++) {


                for (int j = 0; j < w; j++) {

                    if (graph[i][j] == 0 || visited[i][j]) continue;


                    bfs4963(i, j);

                    count++;


                }


            }


            System.out.println(count);

        }


    }


    private static void bfs4963(int x, int y) {


        Queue<int[]> queue = new LinkedList<>();


        queue.offer(new int[]{x, y});

        visited[x][y] = true;


        while (!queue.isEmpty()) {

            int[] cur = queue.poll();

            int cx = cur[0];

            int cy = cur[1];


            for (int i = 0; i < move.length; i++) {


                int nx = cx + move[i][0];

                int ny = cy + move[i][1];


                if (nx < 0 || ny < 0 || nx >= h || ny >= w) continue;

                if (visited[nx][ny]) continue;

                if (graph[nx][ny] == 0) continue;


                queue.offer(new int[]{nx, ny});

                visited[nx][ny] = true;


            }


        }



    }

}


~~~


***


## [백준 3184번 - 양](https://www.acmicpc.net/problem/3184)

---


~~~java


public class baekjoon3184_DFS {


    static int r, c, v, o;

    static int rv = 0, ro = 0;

    static char[][] graph;

    static boolean[][] visited;


    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };


    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        StringTokenizer st = new StringTokenizer(br.readLine(), " ");


        r = Integer.parseInt(st.nextToken());

        c = Integer.parseInt(st.nextToken());


        graph = new char[r][c];

        visited = new boolean[r][c];


        for (int i = 0; i < r; i++) {

            String str = br.readLine();

            graph[i] = str.toCharArray();

        }



        for (int i = 0; i < r; i++) {

            for (int j = 0; j < c; j++) {

                if (visited[i][j]) continue;

                if (graph[i][j] == 'v' || graph[i][j] == 'o') {

                    if (graph[i][j] == 'v') {

                        v = 1;

                        o = 0;

                    } else {

                        o = 1;

                        v = 0;

                    }

                    dfs3184(i, j);

                    if (v >= o) {

                        rv += v;

                    } else {

                        ro += o;

                    }

                }

            }

        }


        System.out.println(ro + " " + rv);


    }


    private static void dfs3184(int x, int y) {


        visited[x][y] = true;


        for (int i = 0; i < move.length; i++) {

            int nx = x + move[i][0];

            int ny = y + move[i][1];


            if (nx < 0 || ny < 0 || nx >= r || ny >= c) continue;

            if (visited[nx][ny]) continue;

            if (graph[nx][ny] == '#') continue;


            if (graph[nx][ny] == 'v') {

                v++;

            } else if (graph[nx][ny] == 'o') {

                o++;

            }

            dfs3184(nx, ny);

        }


    }


}


~~~


~~~java


public class baekjoon3184_BFS {


    static int r, c, v, o;

    static int rv = 0, ro = 0;

    static char[][] graph;

    static boolean[][] visited;


    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} };


    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        StringTokenizer st = new StringTokenizer(br.readLine(), " ");


        r = Integer.parseInt(st.nextToken());

        c = Integer.parseInt(st.nextToken());


        graph = new char[r][c];

        visited = new boolean[r][c];


        for (int i = 0; i < r; i++) {

            String str = br.readLine();

            graph[i] = str.toCharArray();

        }



        for (int i = 0; i < r; i++) {

            for (int j = 0; j < c; j++) {

                if (visited[i][j]) continue;

                if (graph[i][j] == 'v' || graph[i][j] == 'o') {

                    if (graph[i][j] == 'v') {

                        v = 1;

                        o = 0;

                    } else {

                        o = 1;

                        v = 0;

                    }

                    bfs3184(i, j);

                    if (v >= o) {

                        rv += v;

                    } else {

                        ro += o;

                    }

                }

            }

        }


        System.out.println(ro + " " + rv);


    }


    private static void bfs3184(int x, int y) {


        Queue<int[]> queue = new LinkedList<>();

        queue.offer(new int[]{x, y});

        visited[x][y] = true;


        while (!queue.isEmpty()) {

            int[] cur = queue.poll();

            for (int i = 0; i < move.length; i++) {

                int nx = cur[0] + move[i][0];

                int ny = cur[1] + move[i][1];


                if (nx < 0 || ny < 0 || nx >= r || ny >= c) continue;

                if (visited[nx][ny]) continue;

                if (graph[nx][ny] == '#') continue;

                queue.offer(new int[]{nx, ny});

                visited[nx][ny] = true;

                if (graph[nx][ny] == 'v') v++;

                if (graph[nx][ny] == 'o') o++;

            }

        }


    }


}


~~~


***


## [백준 2606번 - 바이러스](https://www.acmicpc.net/problem/2606)

---


~~~java

public class baekjoon2606_DFS {


    static int n, m, count = 0;


    static ArrayList<Integer>[] graph;

    static boolean[] visited;



    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        n = Integer.parseInt(br.readLine());

        m = Integer.parseInt(br.readLine());


        graph = new ArrayList[n + 1];

        for (int i = 1; i <= n; i++) graph[i] = new ArrayList<>();

        visited = new boolean[n + 1];


        for (int i = 0; i < m; i++) {

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");

            int x = Integer.parseInt(st.nextToken());

            int y = Integer.parseInt(st.nextToken());


            graph[x].add(y);

            graph[y].add(x);

        }


        dfs2606(1);


        System.out.println(count - 1);

    }


    private static void dfs2606(int i) {

        visited[i] = true;

        count++;


        for (int x : graph[i]) {

            if (visited[x]) continue;

            dfs2606(x);

        }


    }



}


~~~


~~~java


public class baekjoon2606_BFS {


    static int n, m, count = 0;


    static ArrayList<Integer>[] graph;

    static boolean[] visited;



    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        n = Integer.parseInt(br.readLine());

        m = Integer.parseInt(br.readLine());


        graph = new ArrayList[n + 1];

        for (int i = 1; i <= n; i++) graph[i] = new ArrayList<>();

        visited = new boolean[n + 1];


        for (int i = 0; i < m; i++) {

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");

            int x = Integer.parseInt(st.nextToken());

            int y = Integer.parseInt(st.nextToken());


            graph[x].add(y);

            graph[y].add(x);

        }


        bfs2606(1);


        System.out.println(count);

    }


    private static void bfs2606(int i) {

        Queue<Integer> queue = new LinkedList<>();

        queue.offer(i);

        visited[i] = true;


        while (!queue.isEmpty()) {


            int cur = queue.poll();


            for (int x : graph[cur]) {

                if (visited[x]) continue;

                queue.offer(x);

                visited[x] = true;

                count++;

            }

        }



    }



}


~~~


***



## [백준 11403번 - 경로 찾기](https://www.acmicpc.net/problem/11403)

---


~~~java


public class baekjoon11403_DFS {


    static int n;


    static int[][] graph;

    static boolean[] visited;


    static StringBuilder sb = new StringBuilder();



    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        n = Integer.parseInt(br.readLine());


        graph = new int[n + 1][n + 1];

        for (int i = 1; i <= n; i++) {

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");

            for (int j = 1; j <= n; j++) {

                graph[i][j] = Integer.parseInt(st.nextToken());

            }

        }


        for (int i = 1; i <= n; i++) {

            visited = new boolean[n + 1];

            dfs11403(i);

            for (int j = 1; j <= n; j++) {

                sb.append(visited[j] ? 1 : 0).append(' ');

            }

            sb.append('\n');

        }


        System.out.println(sb);

    }


    private static void dfs11403(int x) {


        for (int y = 1; y <= n; y++) {


            if (visited[y]) continue;

            if (graph[x][y] == 0) continue;

            visited[y] = true;

            dfs11403(y);

        }

    }



}


~~~


~~~java


public class baekjoon11724_BFS {


    static int N, M, count;

    static ArrayList<Integer>[] graph;

    static boolean[] visited;


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");


        N = Integer.parseInt(st.nextToken());

        M = Integer.parseInt(st.nextToken());


        graph = new ArrayList[N + 1];

        for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();



        for (int i = 0; i < M; i++) {

            st = new StringTokenizer(br.readLine(), " ");

            int x = Integer.parseInt(st.nextToken());

            int y = Integer.parseInt(st.nextToken());


            graph[x].add(y);

            graph[y].add(x);

        }


        visited = new boolean[N + 1];

        for (int i = 1; i <= N; i++) {

            if (visited[i]) continue;

            bfs11724(i);

            count++;

        }

        System.out.println(count);



    }


    private static void bfs11724(int i) {

        Queue<Integer> queue = new LinkedList<>();


        queue.offer(i);

        visited[i] = true;


        while (!queue.isEmpty()){


            int cur = queue.poll();


            for (int x : graph[cur]){

                if (visited[x]) continue;


                queue.offer(x);

                visited[x] = true;

            }


        }


    }


}


~~~


***


## [백준 11725번 - 트리의 부모 찾기](https://www.acmicpc.net/problem/11725)

---


~~~java


public class baekjoon11725_DFS {


    static int n;


    static ArrayList<Integer>[] graph;

    static int[] parent;

    static boolean[] visited;


    static StringBuilder sb = new StringBuilder();



    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        n = Integer.parseInt(br.readLine());


        graph = new ArrayList[n + 1];


        for (int i = 1; i <= n; i++) {

            graph[i] = new ArrayList<>();

        }


        for (int i = 0; i < n - 1; i++) {

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");


            int x = Integer.parseInt(st.nextToken());

            int y = Integer.parseInt(st.nextToken());


            graph[x].add(y);

            graph[y].add(x);


        }


        visited = new boolean[n + 1];

        parent = new int[n + 1];


        dfs11725(1);


        for (int i = 2; i <= n; i++) {

            sb.append(parent[i]).append('\n');

        }


        System.out.println(sb);


    }


    private static void dfs11725(int start) {



        visited[start] = true;


        for (int y : graph[start]) {

            if (visited[y]) continue;

            parent[y] = start;

            dfs11725(y);

        }


    }


}


~~~


~~~java


public class baekjoon11725_BFS {


    static int n;


    static ArrayList<Integer>[] graph;

    static int[] parent;

    static boolean[] visited;


    static StringBuilder sb = new StringBuilder();



    public static void main(String[] args) throws IOException {


        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        n = Integer.parseInt(br.readLine());


        graph = new ArrayList[n + 1];


        for (int i = 1; i <= n; i++) {

            graph[i] = new ArrayList<>();

        }


        for (int i = 0; i < n - 1; i++) {

            StringTokenizer st = new StringTokenizer(br.readLine(), " ");


            int x = Integer.parseInt(st.nextToken());

            int y = Integer.parseInt(st.nextToken());


            graph[x].add(y);

            graph[y].add(x);


        }


        visited = new boolean[n + 1];

        parent = new int[n + 1];


        bfs11725(1);


        for (int i = 2; i <= n; i++) {

            sb.append(parent[i]).append('\n');

        }


        System.out.println(sb);


    }


    private static void bfs11725(int start) {

        Queue<Integer> queue = new LinkedList<>();


        queue.add(start);

        visited[start] = true;


        while (!queue.isEmpty()) {

            int cur = queue.poll();


            for (int y : graph[cur]) {

                if (visited[y]) continue;


                queue.add(y);

                parent[y] = cur;

                visited[y] = true;

            }


        }


    }

}


~~~
***

## [백준 2251번 - 물통](https://www.acmicpc.net/problem/2251)

---

* __시간, 공간 복잡도 계산하기__
> + 격자형 그래프
>   + 정점 : $$ O(8 \times 10^6) $$
>   + 간선 : $$ O(8 \times 10^6 \times 6) $$
>   + BFS 이든 DFS 이든, 시간 복잡도는 모두 $$ O(8 \times 10^6) $$

~~~java

public class baekjoon2251_DFS {

    static int[] limit;
    static boolean[][][] visit;
    static boolean[] possible;


    static StringBuilder sb = new StringBuilder();


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        limit = new int[3];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 0; i < 3; i++) {
            limit[i] = Integer.parseInt(st.nextToken());
        }

        visit = new boolean[205][205][205];
        possible = new boolean[205];

        State2251DFS state = new State2251DFS(new int[]{0, 0, limit[2]});
        visit[0][0][limit[2]] = true;
        dfs2251(state);

        for (int i = 0; i <= 200; i++)
            if (possible[i]) sb.append(i).append(' ');

        System.out.println(sb);

    }

    private static void dfs2251(State2251DFS state) {

        if (state.X[0] == 0) possible[state.X[2]] = true;

        for (int from = 0; from < 3; from++) {
            for (int to = 0; to < 3; to++) {
                if (from == to) continue;

                State2251DFS nst = state.move(from, to, limit);

                if (!visit[nst.X[0]][nst.X[1]][nst.X[2]]) {
                    visit[nst.X[0]][nst.X[1]][nst.X[2]] = true;
                    dfs2251(nst);
                }

            }
        }
    }


    private static class State2251DFS {
        int[] X;

        public State2251DFS(int[] ints) {
            X = new int[3];

            for (int i = 0; i < 3; i++) {
                X[i] = ints[i];
            }
        }

        public State2251DFS move(int from, int to, int[] limit) {

            int[] nx = new int[]{X[0], X[1], X[2]};

            if (X[from] + X[to] <= limit[to]) {
                nx[to] = nx[from] + nx[to];
                nx[from] = 0;
            } else {
                nx[from] -= limit[to] - nx[to];
                nx[to] = limit[to];
            }

            return new State2251DFS(nx);
        }
    }
}

~~~

~~~java

public class baekjoon2251_BFS {

    static int[] limit;
    static boolean[][][] visit;
    static boolean[] possible;


    static StringBuilder sb = new StringBuilder();


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        limit = new int[3];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 0; i < 3; i++) {
            limit[i] = Integer.parseInt(st.nextToken());
        }

        visit = new boolean[205][205][205];
        possible = new boolean[205];

        bfs2251(0, 0, limit[2]);

        for (int i = 0; i <= 200; i++) {
            if (possible[i]) sb.append(i).append(' ');
        }
        System.out.println(sb);

    }

    private static void bfs2251(int a, int b, int c) {
        Queue<Status2251> queue = new LinkedList<>();
        queue.add(new Status2251(new int[]{a, b, c}));
        visit[a][b][c] = true;

        while (!queue.isEmpty()) {
            Status2251 status2251 = queue.poll();
            if (status2251.X[0] == 0) possible[status2251.X[2]] = true;

            for (int from = 0; from < 3; from++) {
                for (int to = 0; to < 3; to++) {
                    if (from == to) continue;

                    Status2251 move = status2251.move(from, to, limit);

                    if (!visit[move.X[0]][move.X[1]][move.X[2]]) {
                        visit[move.X[0]][move.X[1]][move.X[2]] = true;
                        queue.add(move);
                    }

                }
            }
        }

    }

    private static class Status2251 {

        int[] X;

        public Status2251(int[] ints) {
            X = new int[3];
            for (int i = 0; i < 3; i++) {
                X[i] = ints[i];
            }
        }

        public Status2251 move(int from, int to, int[] limit) {
            int[] nx = new int[]{X[0], X[1], X[2]};

            if (nx[from] + nx[to] <= limit[to]) {
                nx[to] = nx[to] + nx[from];
                nx[from] = 0;
            } else {
                nx[from] -= limit[to] - nx[to];
                nx[to] = limit[to];
            }
            return new Status2251(nx);
        }
    }
}


~~~
***

## [백준 14502번 - 연구소](https://www.acmicpc.net/problem/14502)

---

~~~java

public class baekjoon14502 {

    static int N, M, B, result;
    static int[][] map, blank;
    static boolean[][] visit;
    static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1} 
    };

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        map = new int[N + 1][M + 1];
        blank = new int[N * M + 1][2];
        visit = new boolean[N + 1][M + 1];

        for (int i = 1; i <= N; i++) {
            st = new StringTokenizer(br.readLine(), " ");
            for (int j = 1; j <= M; j++) {
                map[i][j] = Integer.parseInt(st.nextToken());
            }
        }

        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= M; j++) {
                if (map[i][j] == 0) {
                    B++;
                    blank[B][0] = i;
                    blank[B][1] = j;
                }
            }
        }

        dfs14502(1, 0);
        System.out.println(result);
    }

    private static void dfs14502(int idx, int selectIdx) {

        if (selectIdx == 3) {
            bfs14502();
            return;
        }

        if (idx > B) return;

        map[blank[idx][0]][blank[idx][1]] = 1;
        dfs14502(idx + 1, selectIdx + 1);

        map[blank[idx][0]][blank[idx][1]] = 0;
        dfs14502(idx + 1, selectIdx);


    }

    private static void bfs14502() {

        Queue<int[]> queue = new LinkedList<>();

        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= M; j++) {
                visit[i][j] = false;
                if (map[i][j] == 2) {
                    queue.add(new int[]{i, j});
                    visit[i][j] = true;
                }
            }
        }

        while (!queue.isEmpty()) {
            int[] cur = queue.poll();

            for (int m = 0; m < move.length; m++) {
                int nx = cur[0] + move[m][0];
                int ny = cur[1] + move[m][1];

                if (nx < 1 || ny < 1 || nx > N || ny > M) continue;
                if (visit[nx][ny]) continue;
                if (map[nx][ny] != 0) continue;

                queue.add(new int[]{nx, ny});
                visit[nx][ny] = true;
            }
        }

        int count = 0;
        for (int i = 1; i <= N; i++) {
            for (int j = 1; j <= M; j++) {
                if (map[i][j] == 0 && !visit[i][j]) {
                    count++;
                }
            }
        }

        result = Math.max(result, count);

    }


}

~~~

***

