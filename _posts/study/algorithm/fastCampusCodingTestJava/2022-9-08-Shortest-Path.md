---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 08.최단 거리 (Shortest Path)
date: '2022-09-08 00:00:00 +0900'
categories:
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 08.최단 거리 (Shortest Path)

# 08.최단 거리 (Shortest Path)
* toc
{:toc}

## 최단 거리 (Shortest Path) 란?
+ 그래프의 시작점에서 다른 지점 까지의 최단 거리 

## [백준 1916번 - 최소비용 구하기](https://www.acmicpc.net/problem/1916)
---

* __구현__

~~~java

public class baekjoon1916 {

    static int N, M, start, end;
    static int[] dist;
    static ArrayList<int[]>[] graph;


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        M = Integer.parseInt(br.readLine());

        dist = new int[N + 1];
        graph = new ArrayList[N + 1];

        for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();

        for (int i = 0; i < M; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            int from = Integer.parseInt(st.nextToken());
            int to = Integer.parseInt(st.nextToken());
            int weight = Integer.parseInt(st.nextToken());

            graph[from].add(new int[]{to, weight});
        }

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        start = Integer.parseInt(st.nextToken());
        end = Integer.parseInt(st.nextToken());


        bfs1916();
        System.out.print(dist[end]);
    }

    private static void bfs1916() {

        for (int i = 1; i <= N; i++) dist[i] = Integer.MAX_VALUE;

        PriorityQueue<int[]> queue = new PriorityQueue<>((o1, o2) -> o1[1] - o2[1]);

        queue.add(new int[]{start, 0});
        dist[start] = 0;

        while (!queue.isEmpty()) {

            int[] cur = queue.poll();

            if (dist[cur[0]] != cur[1]) continue;

            for (int[] edge : graph[cur[0]]) {

                if (dist[cur[0]] + edge[1] >= dist[edge[0]]) continue;

                dist[edge[0]] = dist[cur[0]] + edge[1];
                queue.add(new int[]{edge[0], dist[edge[0]]});
            }

        }

    }


}

~~~
***

## [백준 1753번 - 최단 경로](https://www.acmicpc.net/problem/1753)
---

* __구현__

~~~java

public class baekjoon1753 {

    static int N, M, K;
    static int[] dist;
    static ArrayList<int[]>[] graph;


    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());
        K = Integer.parseInt(br.readLine());


        dist = new int[N + 1];
        graph = new ArrayList[N + 1];

        for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();

        for (int i = 0; i < M; i++) {
            st = new StringTokenizer(br.readLine(), " ");

            int u = Integer.parseInt(st.nextToken());
            int v = Integer.parseInt(st.nextToken());
            int w = Integer.parseInt(st.nextToken());

            graph[u].add(new int[]{v, w});

        }

        bfs1753();
    }

    private static void bfs1753() {

        PriorityQueue<int[]> queue = new PriorityQueue<>(Comparator.comparingInt(o -> o[1]));

        for (int i = 1; i <= N; i++) dist[i] = Integer.MAX_VALUE;

        queue.add(new int[]{K, 0});
        dist[K] = 0;

        while (!queue.isEmpty()) {

            int[] cur = queue.poll();

            if (cur[1] != dist[cur[0]]) continue;

            for (int[] edge : graph[cur[0]]) {

                if (dist[cur[0]] + edge[1] >= dist[edge[0]]) continue;

                dist[edge[0]] = dist[cur[0]] + edge[1];

                queue.add(new int[]{edge[0], dist[edge[0]]});
            }
        }

        for (int i = 1; i <= N; i++) {

            if (Integer.MAX_VALUE == dist[i]) {
                System.out.println("INF");
            } else {
                System.out.println(dist[i]);
            }
        }
    }


}

~~~
***
