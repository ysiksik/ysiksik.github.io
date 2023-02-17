---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 07.위상 정렬 (Topological Sort)
date: '2022-09-06 00:00:00 +0900'
categories:
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 07.위상 정렬 (Topological Sort)

# 07.위상 정렬 (Topological Sort)
* toc
{:toc}

## 위상 정렬 (Topological Sort)란?
+ 위상 정렬 = 위상 + 정렬
+ Directed Acyclic Graph (DAG)
  + Directed := 간선에 방향성이 있다.
    + A -> B := A 에서 B 로
  + Acyclic := Cyclic 이 없다.
  + Graph := 정점(V) + 간선(E)
  + 정점들을 위상에 맞춰 정렬
+ 차수(Degree) 란?
  + 방향성(Directed) Graph 에서는?
    + Indegree / Outdgree 로 구별
+ 제일 먼저 올 수 있는 정점은?
  + 들어오는 간선이 없는 정점
+ 하나씩 정렬시켜 버리면서 그래프에서 삭제하기
+ 정리
  1. 정점들의 Indegree, indeg[1...N] 계산하기
  2. 들어오는 간선이 0개인 (indeg[i] == 0) 정점들을 찾아서 자료구조 D 에 넣기
  3. D 가 빌 때까지
     1. D 에서 원소 x를 꺼내서 __정렬__ 시키기
     2. Graph 에서 정점 x __제거__ 하기
     3. __새로게 정렬 가능한 점__ 을 찾아서 D에 넣기
  4. O(V + E)
+ 자료구조 D 에 필요한 연산은?
  + 원소를 추가하기
  + 원소를 꺼내기
    + 두 연산을 __빠르게__ 해주는 것은 -> Queue

## [백준 2252번 - 즐 세우기](https://www.acmicpc.net/problem/2252)
---

+ 시간, 공간 복잡도 계산하기
  + 인접 리스트를 쓴다면 O(V + E)

* __구현__

~~~java

public class baekjoon2252 {

  static int N, M;
  static ArrayList<Integer>[] graph;
  static int[] indeg;

  static StringBuilder sb = new StringBuilder();

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());

    graph = new ArrayList[N + 1];
    indeg = new int[N + 1];


    for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();

    for (int i = 0; i < M; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      int x = Integer.parseInt(st.nextToken());
      int y = Integer.parseInt(st.nextToken());

      graph[x].add(y);
      indeg[y]++;

    }

    bfs2252();
    System.out.println(sb);

  }

  private static void bfs2252() {
    Queue<Integer> queue = new LinkedList<>();

    for (int i = 1; i <= N; i++) {
      if (indeg[i] == 0) queue.add(i);
    }

    while (!queue.isEmpty()) {
      int cur = queue.poll();
      sb.append(cur).append(" ");

      for (int y : graph[cur]) {
        indeg[y]--;
        if (indeg[y] == 0) queue.add(y);
      }

    }


  }

}

~~~
***


## [백준 2623번 - 음악 프로그램](https://www.acmicpc.net/problem/2623)
---

* __구현__

~~~java

public class baekjoon2623 {

  static int N, M;
  static ArrayList<Integer>[] graph;
  static int[] indeg;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());

    graph = new ArrayList[N + 1];
    indeg = new int[N + 1];

    for (int i = 1; i <= N; i++) graph[i] = new ArrayList<>();

    for (int i = 0; i < M; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      int count, x, y;

      count = Integer.parseInt(st.nextToken());
      x = Integer.parseInt(st.nextToken());

      for (int j = 2; j <= count; j++) {
        y = Integer.parseInt(st.nextToken());
        graph[x].add(y);
        indeg[y]++;
        x = y;
      }
    }

    bfs2623();
  }

  private static void bfs2623() {

    Deque<Integer> queue = new LinkedList<>();

    for (int i = 1; i <= N; i++) {
      if (indeg[i] == 0) {
        queue.add(i);
      }
    }

    ArrayList<Integer> result = new ArrayList<>();
    while (!queue.isEmpty()) {
      int x = queue.poll();
      result.add(x);
      for (int y : graph[x]) {
        indeg[y]--;
        if (indeg[y] == 0) queue.add(y);
      }
    }

    if (result.size() == N) {
      for (int x : result) {
        System.out.println(x);
      }
    } else {
      System.out.println(0);
    }

  }

}

~~~

***


## [백준 9470번 - Strahler 순서](https://www.acmicpc.net/problem/9470)
---

* __구현__

~~~java

public class baekjoon9470 {


  static int M, K, P;

  static ArrayList<Integer>[] graph;
  static int[] indeg, order, maxCnt;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    int T = Integer.parseInt(br.readLine());

    for (int t = 0; t < T; t++) {
      StringTokenizer st = new StringTokenizer(br.readLine(), " ");
      K = Integer.parseInt(st.nextToken());
      M = Integer.parseInt(st.nextToken());
      P = Integer.parseInt(st.nextToken());

      graph = new ArrayList[M + 1];
      indeg = new int[M + 1];
      order = new int[M + 1];
      maxCnt = new int[M + 1];

      for (int i = 1; i <= M; i++) {
        graph[i] = new ArrayList<>();
      }

      for (int i = 0; i < P; i++) {
        st = new StringTokenizer(br.readLine(), " ");
        int A = Integer.parseInt(st.nextToken());
        int B = Integer.parseInt(st.nextToken());
        graph[A].add(B);
        indeg[B]++;
      }

      bfs9470();

    }


  }

  private static void bfs9470() {

    Deque<Integer> queue = new LinkedList<>();


    for (int i = 1; i <= M; i++) {
      if (indeg[i] == 0) {
        queue.add(i);
        order[i] = maxCnt[i] = 1;
      }

    }
    int ans = 0;
    while (!queue.isEmpty()) {
      int x = queue.poll();

      if (maxCnt[x] >= 2) order[x]++;
      ans = Math.max(ans, order[x]);
      for (int y : graph[x]) {
        indeg[y]--;
        if (indeg[y] == 0) {
          queue.add(y);
        }

        if (order[x] == order[y]) maxCnt[y]++;
        else if (order[y] < order[x]) {
          order[y] = order[x];
          maxCnt[y] = 1;
        }
      }

    }

    System.out.println(K + " " + ans);
  }

}

~~~

***


## [백준 14676번 - 영우는 사기꾼?](https://www.acmicpc.net/problem/14676)

---

* __구현__

~~~java

public class baekjoon14676 {


  static int N, M, K;

  static ArrayList<Integer>[] graph;

  static int[] indeg, checked, cnt;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());
    K = Integer.parseInt(st.nextToken());

    graph = new ArrayList[N + 1];
    indeg = new int[N + 1];
    checked = new int[N + 1];
    cnt = new int[N + 1];

    for (int i = 1; i <= N; i++) {
      graph[i] = new ArrayList<>();
    }

    for (int i = 0; i < M; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      int x = Integer.parseInt(st.nextToken());
      int y = Integer.parseInt(st.nextToken());

      graph[x].add(y);
      indeg[y]++;
    }

    boolean abnormal = false;

    while (K-- > 0) {
      st = new StringTokenizer(br.readLine(), " ");
      int t = Integer.parseInt(st.nextToken());
      int x = Integer.parseInt(st.nextToken());

      if (t == 1) {
        if (checked[x] < indeg[x]) abnormal = true;

        cnt[x]++;

        if (cnt[x] == 1) {
          for (int y : graph[x]) {
            checked[y]++;
          }
        }

      } else {
        if (cnt[x] == 0) abnormal = true;

        cnt[x]--;

        if (cnt[x] == 0) {
          for (int y : graph[x]) {
            checked[y]--;
          }
        }
      }
    }

    if (abnormal) System.out.println("Lier!");
    else System.out.println("King-God-Emperor");
  }


}

~~~

***


## [백준 1005번 - ACM Craft](https://www.acmicpc.net/problem/1005)

---

* __구현__

~~~java

public class baekjoon1005 {


  static int N, K, W;

  static ArrayList<Integer>[] graph;

  static int[] delay, indeg, time;


  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    int T = Integer.parseInt(br.readLine());

    while (T-- > 0) {

      StringTokenizer st = new StringTokenizer(br.readLine(), " ");

      N = Integer.parseInt(st.nextToken());
      K = Integer.parseInt(st.nextToken());

      time = new int[N + 1];
      indeg = new int[N + 1];
      delay = new int[N + 1];
      graph = new ArrayList[N + 1];


      st = new StringTokenizer(br.readLine(), " ");
      for (int i = 1; i <= N; i++) {
        delay[i] = Integer.parseInt(st.nextToken());
      }

      for (int i = 1; i <= N; i++) {
        graph[i] = new ArrayList<>();
      }

      for (int i = 0; i < K; i++) {
        st = new StringTokenizer(br.readLine(), " ");
        int x = Integer.parseInt(st.nextToken());
        int y = Integer.parseInt(st.nextToken());

        graph[x].add(y);
        indeg[y]++;

      }

      W = Integer.parseInt(br.readLine());

      bfs1005();

    }


  }

  private static void bfs1005() {

    Deque<Integer> deque = new LinkedList<>();

    for (int i = 1; i <= N; i++) {
      if (indeg[i] == 0) {
        deque.add(i);
        time[i] = delay[i];
      }
    }

    while (!deque.isEmpty()) {
      int x = deque.poll();

      for (int y : graph[x]) {
        indeg[y]--;
        if (indeg[y] == 0) deque.add(y);
        time[y] = Math.max(time[y], time[x] + delay[y]);
      }

    }

    System.out.println(time[W]);

  }


}

~~~

***


## [백준 1516번 - 게임 개발](https://www.acmicpc.net/problem/1516)

---

* __구현__

~~~java

public class baekjoon1516 {


  static int N;

  static ArrayList<Integer>[] graph;

  static int[] delay, indeg, time;


  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    N = Integer.parseInt(br.readLine());

    delay = new int[N + 1];
    indeg = new int[N + 1];
    time = new int[N + 1];

    graph = new ArrayList[N + 1];

    for (int i = 1; i <= N; i++) {
      graph[i] = new ArrayList<>();
    }

    for (int i = 1; i <= N; i++) {

      StringTokenizer st = new StringTokenizer(br.readLine(), " ");

      int time = Integer.parseInt(st.nextToken());
      delay[i] = time;

      int next;

      while ((next = Integer.parseInt(st.nextToken())) != -1) {
        graph[next].add(i);
        indeg[i]++;
      }
    }

    bfs1516();
  }

  private static void bfs1516() {
    Deque<Integer> deque = new LinkedList<>();

    for (int i = 1; i <= N; i++) {
      if (indeg[i] == 0) {
        deque.add(i);
        time[i] = delay[i];
      }
    }

    while (!deque.isEmpty()) {
      int x = deque.poll();

      for (int y : graph[x]) {

        indeg[y]--;
        if (indeg[y] == 0) deque.add(y);

        time[y] = Math.max(time[y], time[x] + delay[y]);
      }

    }


    for (int i = 1; i <= N; i++) System.out.println(time[i]);
  }


}

~~~

***



## [백준 2056번 - 작업](https://www.acmicpc.net/problem/2056)

---

* __구현__

~~~java

public class baekjoon2056 {

  static int N;
  static ArrayList<Integer>[] graph;
  static int[] indeg, delay, time;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    N = Integer.parseInt(br.readLine());

    indeg = new int[N + 1];
    delay = new int[N + 1];
    time = new int[N + 1];
    graph = new ArrayList[N + 1];

    for (int i = 1; i <= N; i++) {
      graph[i] = new ArrayList<>();
    }


    for (int i = 1; i <= N; i++) {
      StringTokenizer st = new StringTokenizer(br.readLine(), " ");
      int t = Integer.parseInt(st.nextToken());
      delay[i] = t;
      int c = Integer.parseInt(st.nextToken());

      for (int j = 0; j < c; j++) {
        int y = Integer.parseInt(st.nextToken());
        graph[i].add(y);
        indeg[y]++;
      }
    }

    bfs2056();

  }

  private static void bfs2056() {
    Deque<Integer> deque = new LinkedList<>();
    for (int i = 1; i <= N; i++) {
      if (indeg[i] == 0) {
        deque.add(i);
        time[i] = delay[i];
      }
    }

    while (!deque.isEmpty()) {
      int x = deque.poll();

      for (int y : graph[x]) {
        indeg[y]--;
        if (indeg[y] == 0) {
          deque.add(y);
        }

        time[y] = Math.max(time[y], time[x] + delay[y]);
      }

    }

    System.out.println(Arrays.stream(time).max().getAsInt());

  }


}


~~~

***


## [백준 2637번 - 장난감 조립](https://www.acmicpc.net/problem/2637)

---

* __구현__

~~~java

public class baekjoon2637 {

  static int N, M;

  static ArrayList<int[]>[] graph;

  static int[] indeg;

  static int[][] count;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    N = Integer.parseInt(br.readLine());

    indeg = new int[N + 1];
    count = new int[N + 1][N + 1];
    graph = new ArrayList[N + 1];

    for (int i = 1; i <= N; i++) {
      graph[i] = new ArrayList<>();
    }

    M = Integer.parseInt(br.readLine());

    for (int i = 0; i < M; i++) {
      StringTokenizer st = new StringTokenizer(br.readLine(), " ");
      int x = Integer.parseInt(st.nextToken());
      int y = Integer.parseInt(st.nextToken());
      int k = Integer.parseInt(st.nextToken());

      graph[y].add(new int[]{x, k});
      indeg[x]++;
    }


    bfs2637();

  }

  private static void bfs2637() {
    Deque<Integer> deque = new LinkedList<>();

    for (int i = 1; i <= N; i++) {
      if (indeg[i] == 0) {
        deque.add(i);
        count[i][i] = 1;
      }
    }

    while (!deque.isEmpty()) {
      int x = deque.poll();

      for (int[] info : graph[x]) {
        int y = info[0];
        int k = info[1];

        indeg[y]--;

        for (int i = 1; i <= N; i++) {
          count[y][i] += count[x][i] * k;
        }
        if (indeg[y] == 0) deque.add(y);

      }


    }

    for (int i = 1; i <= N; i++) {
      if (count[N][i] != 0) System.out.println(i + " " + count[N][i]);
    }

  }


}

~~~

***


