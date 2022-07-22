---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 05.그래프와 탐색 (Graph & Search)
date: '2022-07-22 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 05.그래프와 탐색 (Graph & Search)

# 05.그래프와 탐색 (Graph & Search)
* toc
{:toc}

## 05.그래프와 탐색 (Graph & Search)
+ Graph = 정점(Vertex) + 간선(Edge)
+ 간선(Edge)
  + 무방향
  + 방향
+ Degree = 정점에 차수 , 정점에 연결된 간선의 수
+ 모든 정점의 차수의 합 = 간선의 개수의 2배 
+ 그래프를 저장하는 대표적인 두 가지 방법
  + 인접 행렬(Adjacency Matrix)
    + $$ O(V^2) $$ 만큼의 공간 필요
    + A에서 B로 이동 가능? 가중치 얼마? 
        + O(1)
    + 정점 A에서 갈수 있는 정점들은?
        + O(V)
  + 인접 리스트(Adjacency List)
    + O(E) 만큼의 공간이 필요
    + A에서 B로 이동 가능? 가중치 얼마? 
        + O(min(deg(A), deg(B)))
    + 정점 A에서 갈 수 있는 정점들은?
        + O(deg(A))
+ 그래프(Graph)를 저장하는 방법 - 요약

|                        | 인접 행렬 |         인접 리스트         |
|:----------------------:|:-----:|:----------------------:|
|  A와 B를 잇는 간선 존재 여부 확인  | O(1)  | O(min(deg(A), deg(B))) |
| A와 연결된 모든 정점 확인 | O(V)  |       O(deg(A))        |
| 공간 복잡도 | O(V^2) |          O(E)          |

+ 그래프(Graph) 문제의 핵심
  + 정점(Vertex) & 간선(Edge)에 대한 정확한 정의
  + 간선 저장 방식을 확인하기

+ 그래프(Graph)에서의 탐색(Search)이란?
  + 깊이 우선 탐색(Depth First Search)
  + 너비 우선 탐색(Breadth First Search)

## [백준 1260번 - DFS와 BFS](https://www.acmicpc.net/problem/1260)
---

* __시간, 공간 복잡도 계산하기__
> + 인접행렬
>   + 시간 : $$ O(V^2) $$
>   + 공간 : $$ O(V^2) $$ 
> + 인접리스트
>   + 시간 : $$ O(E \log E) $$
>   + 공간 : $$ O(E) $$


* __구현__

~~~java
public class baekjoon1260_list {

    static int N, M, V;
    static ArrayList<Integer>[] graph;
    static boolean[] visited;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());
        V = Integer.parseInt(st.nextToken());

        graph = new ArrayList[N + 1];
        visited = new boolean[N + 1];

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
            Collections.sort(graph[i]);
        }

        dfs1260(V);
        sb.append("\n");
        for (int i = 1; i <= N; i++) {
            visited[i] = false;
        }
        bfs1260(V);

        System.out.println(sb);
    }

    private static void bfs1260(int v) {
        Queue<Integer> queue = new LinkedList<>();

        queue.add(v);
        visited[v] = true;

        while (!queue.isEmpty()) {
            int x = queue.poll();
            sb.append(x).append(' ');

            for (int y : graph[x]) {
                if (visited[y]) continue;
                queue.add(y);
                visited[y] = true;
            }
        }

    }

    private static void dfs1260(int v) {
        sb.append(v).append(' ');
        visited[v] = true;

        for (int y : graph[v]) {
            if (visited[y]) continue;
            dfs1260(y);
        }
    }
}
~~~

~~~java

public class baekjoon1260_matrix {

    static int N, M, V;
    static int[][] graph;
    static boolean[] visited;

    static StringBuilder sb = new StringBuilder();

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());
        V = Integer.parseInt(st.nextToken());

        graph = new int[N + 1][N + 1];

        for (int i = 1; i <= M; i++) {
            st = new StringTokenizer(br.readLine(), " ");

            int x = Integer.parseInt(st.nextToken());
            int y = Integer.parseInt(st.nextToken());

            graph[x][y] = graph[y][x] = 1;
        }

        visited = new boolean[N + 1];

        dfs1260Matrix(V);

        sb.append("\n");

        for (int i = 1; i <= N; i++) {
            visited[i] = false;
        }

        bfs1260Matrix(V);

        System.out.println(sb);
    }

    private static void bfs1260Matrix(int v) {
        Queue<Integer> queue = new LinkedList<>();
        queue.add(v);
        visited[v] = true;

        while (!queue.isEmpty()) {
            int x = queue.poll();
            sb.append(x).append(' ');

            for (int y = 1; y <= N; y++) {
                if (graph[x][y] == 0) continue;
                if (visited[y]) continue;
                queue.add(y);
                visited[y] = true;
            }

        }

    }

    private static void dfs1260Matrix(int v) {

        visited[v] = true;
        sb.append(v).append(' ');

        for (int y = 1; y <= N; y++) {
            if (graph[v][y] == 0) continue;

            if (visited[y]) continue;

            dfs1260Matrix(y);
        }

    }

}

~~~

***


