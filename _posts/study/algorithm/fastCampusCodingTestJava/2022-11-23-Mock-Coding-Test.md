---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 류호석배 1회 모의 코테
date: '2022-11-23 00:00:00 +0900'
categories:
- study
- algorithm
- fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm

# related_posts:

# -
---

# [Part3 Ch03 류호석배 코딩테스트 모의고사] 류호석배 1회 모의 코테

# [Part3 Ch03 류호석배 코딩테스트 모의고사] 류호석배 1회 모의 코테
* toc
  {:toc}

## [백준 20164번 - 홀수 홀릭 호석](https://www.acmicpc.net/problem/20164)
---

__출제 의도__

* 완전 탐색 접근을 통해서 모든 경우 직접 하나하나 찾아내 보자
* 본 문제에서 "경우"란, 조건을 만족하게 매 순간 수를 잘라서 시뮬레이션 하는 것을 의미한다.
* 수가 길이가 9자리 이기 때문에 전부 다 해보아도 경우의 수가 많지 않음을 알 수 있다.

__완전 탐색 접근__

+ 완전 탐색은 재귀 함수가 제 맛이다.
+ 함수 디자인을 먼저 해보자.
  1. 매 순간 들고 있는 수: x
  2. 시작부터 지금까지 얻은 점수: total_odd_cnt

~~~java

static void dfs(int x,total_odd_cnt){

}

~~~

+ 재귀 함수 조건
  1. 종료 조건 : x가 한 자리 수인 경우
  2. 아닌 경우: 가능한 경우로 모두 잘라서 다음 수에 대해 재귀 호출

__시간, 공간 복잡도 계산하기__
> 수가 3개로 나눠지고 합쳐질 때마다 크기가 매우 작아지기 때문에 <br>
> 모든 경우의 수가 1억을 절대 넘지 않음을 알 수 있다.

__구현__

~~~java

public class baekjoon20164 {

  static int N;
  static int max = Integer.MIN_VALUE;
  static int min = Integer.MAX_VALUE;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    N = Integer.parseInt(br.readLine());
    dfs20164(N, get_odd_cnt(N));
    System.out.println(min + " " + max);
  }

  private static void dfs20164(int n, int total_old_cnt) {

    if (n <= 9) {
      max = Math.max(max, total_old_cnt);
      min = Math.min(min, total_old_cnt);

      return;
    }

    if (n <= 99) {
      int next = (n / 10) + (n % 10);
      dfs20164(next, total_old_cnt + get_odd_cnt(next));
    }

    String s = Integer.toString(n);

    for (int i = 0; i <= s.length() - 3; i++) {
      for (int j = i + 1; j <= s.length() - 2; j++) {
        String x1 = s.substring(0, i + 1);
        String x2 = s.substring(i + 1, j + 1);
        String x3 = s.substring(j + 1);

        int next = Integer.parseInt(x1) + Integer.parseInt(x2) + Integer.parseInt(x3);

        dfs20164(next, get_odd_cnt(next) + total_old_cnt);
      }
    }

  }

  private static int get_odd_cnt(int n) {
    int res = 0;

    while (n > 0) {
      int digit = n % 10;
      if (digit % 2 != 0) res++;
      n /= 10;
    }

    return res;
  }


}

~~~

***

## [백준 20165번 - 인내의 도미노 장인 호석](https://www.acmicpc.net/problem/20165)
---

__출제 의도__
+ 문제를 해결하는 행위 자체가 "모든 순간을 올바르게 재현하기" 즉 시뮬레이션 이다.
+ 문제에서 주어지는 상황을 올바르게 이해하고, 구현해내는 연습이 필요하다.

__시뮬레이션의 핵심__
+ 상태를 표현하는 방법 정하기
  + 게임판의 상태를 표현하기
+ 문제에 필요한 행위를 함수로 표현하기
  + 필요한 행위
    + 공격
      + 넘어뜨린 도미노의 위치 (x,y)
      + 특정 방향, dir 으로 도미노를 밀기
      + 밀린 도미노 높이를 이용해 연쇄적으로 밀기
    + 수비
      + 특정 위치의 상태를 복원하기 

__시간, 공간 복잡도 계산하기__
> 한 번의 공격은 O(N)의 시간이 <br>
> 한번의 수비는 O(1)의 시간이 <br>
> 총 시간 복잡도는 O(R*N)이 된다.

__구현__

~~~java

public class baekjoon20165 {

  static int N, M, R, result;
  static int[][] arr, backup;


  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());
    R = Integer.parseInt(st.nextToken());

    arr = new int[N + 1][M + 1];
    backup = new int[N + 1][M + 1];

    for (int i = 1; i <= N; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      for (int j = 1; j <= M; j++) {
        arr[i][j] = Integer.parseInt(st.nextToken());
        backup[i][j] = arr[i][j];
      }
    }

    for (int i = 1; i <= R; i++) {

      st = new StringTokenizer(br.readLine(), " ");

      int x = Integer.parseInt(st.nextToken());
      int y = Integer.parseInt(st.nextToken());
      String d = st.nextToken();

      attack(x, y, d);


      st = new StringTokenizer(br.readLine(), " ");
      x = Integer.parseInt(st.nextToken());
      y = Integer.parseInt(st.nextToken());

      arr[x][y] = backup[x][y];

    }

    System.out.println(result);

    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= M; j++) {
        if (arr[i][j] == 0) {
          System.out.print("F ");
        } else {
          System.out.print("S ");
        }
      }
      System.out.println();
    }

  }

  private static void attack(int x, int y, String d) {
    if (arr[x][y] == 0) return;


    int dx = 0, dy = 0;

    switch (d) {
      case "E":
        dy = 1;
        break;
      case "W":
        dy = -1;
        break;
      case "S":
        dx = 1;
        break;
      case "N":
        dx = -1;
        break;
    }

    int cnt = arr[x][y];
    while (x >= 1 && x <= N && y >= 1 && y <= M && cnt >= 1) {
      if (arr[x][y] != 0) result++;

      cnt = Math.max(cnt - 1, arr[x][y] - 1);

      arr[x][y] = 0;

      x += dx;
      y += dy;
    }

  }

}

~~~

***

## [백준 20165번 - 문자열 지옥에 빠진 호석](https://www.acmicpc.net/problem/20165)
---

__출제 의도__
+ 문제에 주어진 조건에 맞게 탐색하는 효율적인 구현하기 
+ 이동을 통해 얻을 수 있는 모든 문자열은?
  + 시작점 결정
  + 4번까지의 이동이 가능(신이 좋아하는 문자열은 최대 5글자)
  + 매 이동마다 8가지 방향 가능 

__생각의 흐름 - 필요한 자료구조는?__
+ 어떤 문제열이 몇번 등장할 수 있는지를 기록할 변수
  + M[문자열 S] = S의 등장 횟수
  + 모든 탐색을 미리 해서, M이라는 자료구조를 가득 채워 놓자
+ 신이 좋아하는 문자열을 입력 받을 때마다 등장 횟수 출력
  + 모든 문자열의 등장 횟수를 M에 모두 기록해버렸으니까, 신이 좋아하는 문자열을 입력 받으면 바로 출력이 가능하다
+ 그렇자면 M이라는 자료주고는 어떤 것을 지원해야 하는가?
  + M에 수행할 연산
    + 탐색: 문자열 S가 한 번 더 등장했어
    + 출력: 문자열 S는 몇 번 등장 했니?
  + HashMap<String, Integer> M을 사용하면 둘 모두 평균 O(1)

__탐색 경우의 수__
+ 시작 위치 * (4번의 이동, 매번 8방향 가능)
+ 1초 안에 충분히 수행이 가능하다.

__구현__

~~~java

public class baekjoon20166 {

  static int N, M, K;
  static String[] arr;

  static Map<String, Integer> map = new HashMap<>();

  static int[][] move = { {-1, 0}, {0, 1}, {1, 0}, {0, -1}, {-1, -1}, {-1, 1}, {1, 1}, {1, -1} };

  public static void main(String[] args) throws IOException {
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());
    K = Integer.parseInt(st.nextToken());

    arr = new String[N];

    for (int i = 0; i < N; i++) {
      arr[i] = br.readLine();
    }

    for (int i = 0; i < N; i++) {
      for (int j = 0; j < M; j++) {
        dfs20166(i, j, Character.toString(arr[i].charAt(j)), 1);
      }
    }


    while (K-- > 0) {
      String str = br.readLine();

      if (map.containsKey(str)) System.out.println(map.get(str));
      else System.out.println(0);

    }

  }

  private static void dfs20166(int x, int y, String path, int length) {
    if (map.containsKey(path)) map.put(path, map.get(path) + 1);
    else map.put(path, 1);

    if (length == 5) return;

    for (int i = 0; i < 8; i++) {
      int nx = (x + move[i][0]) % N;
      int ny = (y + move[i][1]) % M;
      if (nx < 0) nx += N;
      if (ny < 0) ny += M;

      dfs20166(nx, ny, path + arr[nx].charAt(ny), length + 1);
    }
  }


}

~~~

***

## [백준 20181번 - 꿈틀꿈틀 호석 애벌레](https://www.acmicpc.net/problem/20181)
---

__출제 의도__
+ 기능성
  + 문제의 상황을 시뮬레이션으로 바꿔서 모든 가능한 경우를 수행해보기
+ 효율성
  + 탐색해야 하는 경우가 너무 많다. => DP
  + 추가로, 점화식에 필요한 값을 빠르게 계산해 내는 방법으로 Two Pointer 기법

__생각의 흐름 - 음식을 먹게 되는 구간들__
+ 음식을 먹기로 결정하면 그 순간부터 어디까지 먹게 되는 지를 무조건 정해진다는 것을 알게된다.
+ L 번째 음식에서 먹기 시작했을 때, 어디까지 먹으면 만족도는 얼마를 얻을 수 있을까?
+ L을 1부터 N까지 이동시키면서 매번 R을 계산한다고 하자.
  + L이 1만큼 증가하면 R은 어떻게 될까?
    + 모든 음식이 양수의 만조도를 가지기 때문에, L이 커지면 R은 절대로 작아질 수 없다.
    + 즉, 이전의 L에 대한 R값을 이용해서 다음 L에 대한 R을 계산할 수 있다.

__생각의 흐름 - DP라면?__
+ 정직한 순서로 문제를 풀어나가면 된다.
+ 먼저, DP Table을 정의하자
  + Dy[i] = i번 위치까지 도착했을 때, 가능한 최대 만족도
  + 정답 : Dy[N]
  + 초기값 : Dy[0] = 0
  + 점화식: Dy[i] = max(i번 음식 안먹기, i번 음식까지 먹어서 만족도 얻기)

__생각의 흐름 - 전체 흐름__
1. 음식을 먹게 되는 구간 [L, R] 을 찾고, 같은 R에 대해서는 뭉쳐서 저장해 놓는다.
2. R을 1씩 증가시키면서, Dy[R]의 값을 계산해 나아간다.
3. 이때 점화식은, max(Dy[R-1], max[L-1] + Eat(L,R)) 이다.
4. 구간을 Two Pointer로 찾고 저장해 놓는다면 시간 복잡도는 O(N)이 된다.


__구현__

~~~java

public class baekjoon20181 {

  static int N, K;
  static long[] arr;
  static long[] dy;

  static ArrayList<long[]>[] list;

  public static void main(String[] args) throws IOException {
    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    K = Integer.parseInt(st.nextToken());

    arr = new long[N + 1];
    dy = new long[N + 1];

    st = new StringTokenizer(br.readLine(), " ");
    for (int i = 1; i <= N; i++) {
      arr[i] = Long.parseLong(st.nextToken());
    }


    list = new ArrayList[N + 1];

    for (int i = 1; i <= N; i++) {
      list[i] = new ArrayList<>();
    }


    long sum = 0;
    for (int L = 1, R = 0; L <= N; L++) {

      while (R + 1 <= N && sum < K) sum += arr[++R];

      if (K <= sum) {
        list[R].add(new long[]{L, sum - K});
      }

      sum -= arr[L];

    }


    for (int R = 1; R <= N; R++) {

      dy[R] = dy[R - 1];

      for (long[] x : list[R]) {

        dy[R] = Math.max(dy[R], dy[(int) (x[0]) - 1] + x[1]);
      }
    }


    System.out.println(dy[N]);

  }


}


~~~

~~~java

public class baekjoon20181_2 {

    static int N, K;
    static long[] arr;
    static long[] dy;

    public static void main(String[] args) throws IOException {

        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        K = Integer.parseInt(st.nextToken());

        arr = new long[N + 1];
        dy = new long[N + 1];

        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            arr[i] = Long.parseLong(st.nextToken());
        }

        int right = 1;
        long sum = 0, dyLeftMax = 0;

        for (int left = 1; left <= N; left++) {
            dyLeftMax = Math.max(dyLeftMax, dy[left - 1]);

            while (right <= N && sum < K) {
                sum += arr[right++];
            }

            if (sum >= K) {
                dy[right - 1] = Math.max(dy[right - 1], dyLeftMax + (sum - K));
            } else {
                break;
            }

            sum -= arr[left];

        }

        long result = 0;

        for (int i = 1; i <= N; i++) {
            result = Math.max(result, dy[i]);
        }

        System.out.println(result);


    }
    
}

~~~

***

## [백준 20182번 - 골목대장 호석](https://www.acmicpc.net/problem/20182)
---
+ 수가 크다, 꼭 정답의 최대치를 확인하자, Long이 필요함을 미리 깨달아야 한다.

__출제 의도__
+ 기능성
  + 완전 탐색
+ 효율성
  + Dijkstra 알고르즘 활용
  + Dijkstra 알고르즘 활용 + 이분 탐색

__생각의 흐름 - 완전 탐색 먼저__
+ 항상, 완전 탐색 방법 부터 먼저 생각해보자.
+ DFS를 통해 가진 돈으로 시작점에서 도착점까지 갈 수 있는 모든 경로를 시도해보자.
+ 가능한 경로는 최대 N! 까지 가능하기 때문에 완전 탬색이 가능하다.

__생각의 흐름 - 정답을 변수로 만들어보자.__
+ 최단경로 -> Dijkstra 알고리즘
+ But, 문제에서 요구하는 "최대 골목 비용"이란 것을 고려할 수가 없다.
+ 따라서, Dijkstra 알고르즘을 쓰기 위해서 최대 골목 비용 X를 결정해 보자

__생각의 흐름 - 정답을 변수로 만들어보자__
+ 골목 최대치 X가 늘어나면 사용 가능한 간선도 늘어나기 때문에, 최단거리는 점점 줄어들게 된다.
+ 그렇다면, 모든 X에 대해 확인하지 말고 이분탐색을 통해 X를 찾을 수 있지 않을까? 즉, Parametric Search이다

__구현__

~~~java

public class baekjoon20168 {

  static int N, M, A, B, C, result;

  static boolean[] visited;

  static ArrayList<int[]>[] list;


  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());
    A = Integer.parseInt(st.nextToken());
    B = Integer.parseInt(st.nextToken());
    C = Integer.parseInt(st.nextToken());

    list = new ArrayList[N + 1];
    visited = new boolean[N + 1];

    result = Integer.MAX_VALUE;

    for (int i = 1; i <= N; i++) {
      list[i] = new ArrayList<>();
    }

    for (int i = 1; i <= M; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      int a = Integer.parseInt(st.nextToken());
      int b = Integer.parseInt(st.nextToken());
      int c = Integer.parseInt(st.nextToken());

      list[a].add(new int[]{b, c});
      list[b].add(new int[]{a, c});
    }

    visited[A] = true;
    dfs20168(A, C, -1);

    if (result == Integer.MAX_VALUE) result = -1;

    System.out.println(result);

  }

  private static void dfs20168(int node, int money, int cost) {
    if (node == B) {
      result = Math.min(result, cost);
      return;
    }

    if (money <= 0) return;

    for (int[] next : list[node]) {

      if (visited[next[0]] || next[1] > money) continue;

      visited[next[0]] = true;

      dfs20168(next[0], money - next[1], Math.max(cost, next[1]));

      visited[next[0]] = false;

    }


  }


}

~~~

~~~java

public class baekjoon20182 {

  static int N, M, A, B;
  static long C;

  static ArrayList<Info>[] list;

  static long max = Long.MAX_VALUE;

  static long[] d;


  static class Info implements Comparable<Info> {

    int idx;
    long cost;

    public Info(int idx, long cost) {
      this.idx = idx;
      this.cost = cost;
    }

    @Override
    public int compareTo(Info o) {

      if (cost > o.cost) return 1;
      if (cost == o.cost) return 0;
      return -1;
    }
  }

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());
    A = Integer.parseInt(st.nextToken());
    B = Integer.parseInt(st.nextToken());
    C = Long.parseLong(st.nextToken());

    list = new ArrayList[N + 1];
    d = new long[N + 1];

    for (int i = 1; i <= N; i++) {
      list[i] = new ArrayList<>();
    }

    for (int i = 1; i <= M; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      int a = Integer.parseInt(st.nextToken());
      int b = Integer.parseInt(st.nextToken());
      int c = Integer.parseInt(st.nextToken());

      list[a].add(new Info(b, c));
      list[b].add(new Info(a, c));
    }


    long left = 1;
    long right = 1000000001;
    long result = right;

    while (left <= right) {
      long mid = (left + right) / 2;

      if (dijkstra(mid)) {
        result = mid;
        right = mid - 1;
      } else {
        left = mid + 1;
      }

    }

    if (result == 1000000001) System.out.println(-1);
    else System.out.println(result);


  }

  private static boolean dijkstra(long x) {

    PriorityQueue<Info> queue = new PriorityQueue<>();

    Arrays.fill(d, max);
    d[A] = 0;
    queue.add(new Info(A, 0));
    while (!queue.isEmpty()) {

      Info cur = queue.poll();

      if (cur.cost != d[cur.idx]) continue;

      for (Info next : list[cur.idx]) {
        if (next.cost > x) continue;

        if (d[next.idx] > d[cur.idx] + next.cost) {
          d[next.idx] = d[cur.idx] + next.cost;
          queue.add(new Info(next.idx, d[next.idx]));
        }

      }

    }

    return d[B] <= C;
  }


}

~~~

***