---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 류호석배 3회 모의 코테
date: '2022-12-26 00:00:00 +0900'
categories:
- study
- algorithm
- fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
---

# [Part3 Ch03 류호석배 코딩테스트 모의고사] 류호석배 3회 모의 코테

# [Part3 Ch03 류호석배 코딩테스트 모의고사] 류호석배 3회 모의 코테
* toc
{:toc}

## [백준 22251번 - 빌런 호석](https://www.acmicpc.net/problem/22251)
---

__출제 의도__
* 올바른 접근 방법을 떠올리는가?
* 시간 & 공간 복잡도는 제대로 계산하였는가?
* 문제를 편하게 구현하였는가?

__접근 방법__
+ X층을 Y층으로 바꿀 수 있는가?


__총 정리__
+ diff_one 함수 구현하기
+ 이른 이용한 diff 함수 구현
+ Y를 1부터 N까지 바꿔보면서 변환 횟수가 P 이하인지 확인하기
+ 총 시간 복잡도는 O(N * K) 이다.

__구현__

~~~java

public class baekjoon22251 {

  static int N, K, P, X;


  static int[][] num_flag = {
          {1, 1, 1, 0, 1, 1, 1},
          {0, 0, 1, 0, 0, 1, 0},
          {1, 0, 1, 1, 1, 0, 1},
          {1, 0, 1, 1, 0, 1, 1},
          {0, 1, 1, 1, 0, 1, 0},
          {1, 1, 0, 1, 0, 1, 1},
          {1, 1, 0, 1, 1, 1, 1},
          {1, 0, 1, 0, 0, 1, 0},
          {1, 1, 1, 1, 1, 1, 1},
          {1, 1, 1, 1, 0, 1, 1}
  };

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken()); // 층수
    K = Integer.parseInt(st.nextToken()); // 자리수
    P = Integer.parseInt(st.nextToken()); // LED 변경
    X = Integer.parseInt(st.nextToken()); // 현재 층수


    int result = 0;

    for (int i = 1; i <= N; i++) {

      if (i == X) continue;

      if (numericConversion(i, X) <= P) result++;

    }

    System.out.println(result);


  }

  private static int numericConversion(int x, int y) {

    int n = 0;

    for (int i = 1; i <= K; i++) {

      n += numberOfConversions(x % 10, y % 10);

      x /= 10;
      y /= 10;
    }

    return n;
  }

  private static int numberOfConversions(int x, int y) {

    int n = 0;

    for (int i = 0; i < 7; i++) n += num_flag[x][i] != num_flag[y][i] ? 1 : 0;

    return n;
  }
}
~~~

***

## [백준 22252번 - 정보 상인 호석](https://www.acmicpc.net/problem/22252)
---

__출제 의도__
+ 문제가 요구하는 상황을 이해 했는가?
+ 문자열을 잘 다루는가?
+ 필요한 연산을 정의할 줄 아는가?
+ 자료구조를 나열하고 시간 복잡도를 따져서 최선의 자료구조를 선택할 수 있는가?

__접근 방법__
+ 먼저, 고릴라들의 이름을 어떻게 다룰 것인가?
1. 문자열 그 자체를 이용하는 경우
2. 숫자로 변경해서 이용하는 경우

+ 사람마다 익숙한 것으로

__총 정리__
+ 고릴라 마다 가지고 있는 정보의 가치들을 자료 구조(Max Heap)에 담아두고 있다.
+ 총 시간은 정보를 삽입하고 삭제하는 과정에서 소모되는 시간이다. 정보가 많아야 100만개 삽입 & 삭제 되기 때문에 O(100만 log 100만)에 비례하는 시간이 걸리고, 시간 안에 충분히 나온다


__구현__

~~~java

public class baekjoon22252 {

  static HashMap<String, Integer> map = new HashMap<>();
  static PriorityQueue<Integer>[] queues = new PriorityQueue[100005];
  static int keyNum = 0;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    int Q = Integer.parseInt(br.readLine());

    long result = 0;
    while (Q-- > 0) {

      StringTokenizer st = new StringTokenizer(br.readLine(), " ");

      int kind = Integer.parseInt(st.nextToken());
      String name = st.nextToken();

      if (!map.containsKey(name)) {
        map.put(name, ++keyNum);
        queues[keyNum] = new PriorityQueue<>(Comparator.reverseOrder());
      }

      int key = map.get(name);

      if (kind == 1) {
        int k = Integer.parseInt(st.nextToken());
        while (k-- > 0) {
          queues[key].add(Integer.parseInt(st.nextToken()));
        }
      } else {
        int b = Integer.parseInt(st.nextToken());
        while (b-- > 0 && !queues[key].isEmpty()) {
          result += queues[key].poll();
        }
      }

    }

    System.out.println(result);


  }
}


~~~

***



## [백준 22253번 - 트리 디자이너 호석](https://www.acmicpc.net/problem/22253)
---

__출제 의도__
+ Rooted Tree 구조에 익숙한가?
+ 완전 탐색에서 동적 프로그래밍으로 연결을 지을수 있는가?
+ 동적 프로그래밍 풀이를 스스로 수행할 수 있는가?

__생각의 흐름 - 1. 정답의 최대치__
+ 가능한 경우가 가장 많은 입력은?
  + 정점 10만개가 일렬로 존재하고, 모두 0인 경우
+ 정점을 어떻게 선택해도 조건을 만족하므로 2^100000 가지 가능하다. 

__생각의 흐름 - 2. 동적 프로그래밍__
+ 모든 경우 하나씩 찾으면 당연히 "시간 초과"를 받을 것을 예상하기 쉽다.
  + 이런 경우 동적 프로그래밍 접근을 시도해 볼 가치가 있다.

__생각의 흐름 - 3. 문제 정의__
+ Dy[i][k] = i번 정점을 root로 하는 subtree에서, 조건을 만족하게 선택하면 마지막 숫자가 k인 경우의 수  
+ 정답 = Dy[1][0] + ... + Dy[1][9]
+ 초기화 = Dy[1][a[i]] = 1 (i번 정범만 선택하는 경우) 

__총 정리__
+ Rooted Tree 에서의 Dynamic Programming
+ 시간 복잡도는 모든 정점을 한 번씩 보기 때문에 O(N)이다

__구현__

~~~java

public class baekjoon22253 {

  static int N;
  static int[] a;
  static int[][] dy;
  static ArrayList<Integer>[] tree;

  static final int MOD = 1000000007;


  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    N = Integer.parseInt(br.readLine());

    a = new int[N + 1];
    dy = new int[N + 1][10];
    tree = new ArrayList[N + 1];

    for (int i = 1; i <= N; i++) tree[i] = new ArrayList<>();

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");
    for (int i = 1; i <= N; i++) {
      a[i] = Integer.parseInt(st.nextToken());
    }

    for (int i = 1; i < N; i++) {
      st = new StringTokenizer(br.readLine(), " ");

      int x = Integer.parseInt(st.nextToken());
      int y = Integer.parseInt(st.nextToken());

      tree[x].add(y);
      tree[y].add(x);

    }

    dfs22253(1, -1);

    int result = 0;
    for (int i = 0; i <= 9; i++) {
      result += dy[1][i];
      result %= MOD;
    }

    System.out.println(result);
  }

  private static void dfs22253(int x, int par) {
    dy[x][a[x]] = 1;

    for (int y : tree[x]) {
      if (par == y) continue;

      dfs22253(y, x);

      for (int i = 0; i <= 9; i++) {
        dy[x][i] += dy[y][i];
        dy[x][i] %= MOD;
      }

      for (int i = a[x]; i <= 9; i++) {
        dy[x][a[x]] += dy[y][i];
        dy[x][a[x]] %= MOD;
      }
    }

  }


}

~~~

***

## [백준 22254번 - 공정 컨설턴트 호석](https://www.acmicpc.net/problem/22254)
---

__출제 의도__
+ 공정 라인의 개수와 마감 시간의 관계를 관찰했는가?
+ Parametric Search 기법을 떠올리고 올바르게 적용시켰는가?

__생각의 흐름 - 1. 정답의 최대치__
+ 어떤 입력이 주어져도 공정 라인이 선뭉릐 개수만큼 존재하면 성공적으로 제작할 수 있다.
+ 따라서 정답의 최대치는 N의 최대치인 10만이다.

__생각의 흐름 - 2. 관찰__
+ 공정 라인의 개수를 최소화 시켜야 한다.
+ 단, 총 제작 시간에 제한이 걸려 있다.
+ 그렇다면 공정 라인의 개수와 총 제작 시간은 무슨 관계인가?

__생각의 흐름 - 3. 문제 정의__
+ 공정 라인을 K개 사용하면 시간을 맞출 수 잇는가?

__생각의 흐름 - 4. Parametric Search__
+ 공정 라인 개수가 정해져 있는 경우에는 모든 것이 결정적으로 (deterministic 하게) 진행되기 때문에 "시뮬레이션" 문제로 변경된다.
+ 만약 한 번의 K에 대한 대답을 O(T)에 할 수 있다면?
+ 이분 탐색을 통해 O(log N)번의 수행이 이뤄지므로 O(T log N) 이면 K^* 를 계산할 수 있다.
+ K가 정해졌기 때문에, 1번부터 N번 선물을 차례대로 제작하면 된다.
+ 필요한 연산
  + 공정 라인 중에 사용 시간이 가장 적은 것을 찾는다.
  + 특정 공정 라인의 사용 시간을 X 만큼 증가 시킨다.
+ 두 연산을 모두 빠르게 (O(log K)) 해주는 Min Heap를 사용하자

__총 정리__
+ K^*를 Parametric Search를 통해 찾는다.
+ K에 대해서 
  + 공정 라인들의 사용 시간을 저장할 Min Heap 생성
  + 0을 K번 삽입
  + N개의 선물을 제작해보고 목표 시간 X와 비교
  + O(N log N)
+ 총 시간은 O(N log k log N) 이다

__구현__

~~~java

public class baekjoon22254 {

  static int N, X;
  static int[] a;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    X = Integer.parseInt(st.nextToken());

    a = new int[N + 1];

    st = new StringTokenizer(br.readLine(), " ");

    for (int i = 1; i <= N; i++) {
      a[i] = Integer.parseInt(st.nextToken());
    }

    int L = 1;
    int R = N;
    int result = N;

    while (L <= R) {

      int mid = (L + R) / 2;

      if (check(mid)) {
        R = mid - 1;
        result = mid;
      } else {
        L = mid + 1;
      }

    }

    System.out.println(result);


  }

  private static boolean check(int num) {

    PriorityQueue<Integer> queue = new PriorityQueue<>();

    for (int i = 1; i <= num; i++) {
      queue.add(0);
    }

    for (int i = 1; i <= N; i++) {
      int poll = queue.poll();
      if (poll + a[i] > X) return false;
      queue.add(poll + a[i]);
    }

    return true;
  }

}

~~~

***

## [백준 22255번 - 호석 사우로스](https://www.acmicpc.net/problem/22255)
---

__출제 의도__
+ 최단 시간 키워드를 통해 접근 방향을 잡았는가?
+ 문제의 요구 조건에 맞게 거리 배열 정의를 했는가?
+ 구현을 편하게 했는가?

__생각의 흐름 - 키워드 발견__
+ 자신의 철칙을 지키되, 아픈 건 싫어하는 호석사우루스를 도와서 탈출구까지의 최소 충격량을 구해주자
  + 주어진 문제를 "그래프 문제"로 변환시켜서 "최단 거리" 계산으로 방향을 잡아보자

__생각의 흐름 - 최단 거리 알고리즘__
+ 최단 거리 알고리즘 복기
+ 입력
  + 그래프 & 시작점 & 도착점
+ 출력
  + 최단 거리
+ 배운 것 중에는 BFS & Dijkstra 존재
+ 그중 간선의 가중치가 다를 수 있다는 점을 통해 Dijkstra 선택

__생각의 흐름 - Dijkstra 알고리즘 거리 정의 __
+ Dijkstra 알고리즘은 distance 배열이 필요하다.
+ dist[i][j] = i 행 j 열까지의 최소 충격량(최단 거리) 으로 정의하면 되는가?
  + 같은 위치에 대해서도 몇 번째 도착지인지가 중요하기 때문에 정보에 손실이 생긴다
+ dist[i][j][move] = i 행 j 열에 (3K+move) 번의 이동으로 도착하는 방법 중에서 최소 충격량(최단 거리)

__시간, 공간 복잡도 계산하기__
+ 정점의 개수 N * M 3 개라고 생각하면 된다.
+ 즉 총 시간 복잡도는 O(NMlogNM)이다.

__구현__

~~~java

public class baekjoon22255 {


  static int N, M, SX, SY, EX, EY;
  static int[][] a;
  static int[][][] dy;

  static int dir[][][] = {
          { { 1, 0 }, { -1, 0 } },
          { { 0, 1 }, { 0, -1 } },
          { { 1, 0 }, { -1, 0 }, { 0, -1 }, { 0, 1 } }
  };

  static class Info {
    int x, y, move, dist;

    public Info(int x, int y, int move, int dist) {
      this.x = x;
      this.y = y;
      this.move = move;
      this.dist = dist;
    }
  }

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());

    st = new StringTokenizer(br.readLine(), " ");

    SX = Integer.parseInt(st.nextToken());
    SY = Integer.parseInt(st.nextToken());
    EX = Integer.parseInt(st.nextToken());
    EY = Integer.parseInt(st.nextToken());

    a = new int[N + 2][M + 2];
    dy = new int[N + 2][M + 2][3];

    for (int i = 1; i <= N; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      for (int j = 1; j <= M; j++) {
        a[i][j] = Integer.parseInt(st.nextToken());
      }
    }

    for (int i = 1; i <= N; i++) {
      for (int j = 1; j <= M; j++) {
        for (int k = 0; k < 3; k++) {

          dy[i][j][k] = Integer.MAX_VALUE;

        }
      }
    }

    dy[SX][SY][0] = 0;

    PriorityQueue<Info> queue = new PriorityQueue<>(Comparator.comparing(info -> info.dist));

    queue.add(new Info(SX, SY, 0, 0));


    while (!queue.isEmpty()) {

      Info poll = queue.poll();

      int x = poll.x, y = poll.y, move = poll.move, dist = poll.dist;

      if (dist != dy[x][y][move]) continue;

      int choice = move == 2 ? 4 : 2;

      for (int k = 0; k < choice; k++) {

        int nx = x + dir[move][k][0];
        int ny = y + dir[move][k][1];

        if (nx < 0 || nx > N || ny < 0 || ny > M) continue;
        if (a[nx][ny] == -1) continue;

        int nmove = (move + 1) % 3;
        int ndist = dist + a[nx][ny];

        if (ndist >= dy[nx][ny][nmove]) continue;

        dy[nx][ny][nmove] = ndist;

        queue.add(new Info(nx, ny, nmove, ndist));

      }

    }


    int result = Integer.MAX_VALUE;
    for (int i = 0; i < 3; i++) {
      result = Math.min(result, dy[EX][EY][i]);
    }

    if (result == Integer.MAX_VALUE) result = -1;

    System.out.println(result);


  }


}

~~~

***