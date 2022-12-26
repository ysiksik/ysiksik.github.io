---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 류호석배 2회 모의 코테
date: '2022-11-24 00:00:00 +0900'
categories:
- study
- algorithm
- fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
---

# [Part3 Ch03 류호석배 코딩테스트 모의고사] 류호석배 2회 모의 코테

# [Part3 Ch03 류호석배 코딩테스트 모의고사] 류호석배 2회 모의 코테
* toc
{:toc}

## [백준 21275번 - 폰 호석만](https://www.acmicpc.net/problem/21275)
---

__출제 의도__

* 완전 탐색 접근을 통해서 모든 경우 직접 하나하나 찾아내 보자. 본 문제에서 "경우"란, 조건을 만족하게 A,B를 모두 결정해보는 것이다.
* 진법 변환을 구현할 수 있는가?

__완전 탐색 접근__

+ 가능한 A,B의 조합: (2,2),(2,3),...(36,36)
+ 매 조합 마다 진법 변환을 수행하면 된다.
+ 주의할 점
  1. 변환 시에 2^63을 넘어가지 않는가?
  2. 등장하는 문자가 진법으로 올바른가?


__시간, 공간 복잡도 계산하기__
> A,B의 조합의 경우의 수가 35 * 35 = 1,255 개이다 <br>
> 진법 변환은 문자열의 길이만큼 소요되므로, 연산 횟누는 약 35 * 35 * 75 = 85,750에 비례한다.

__구현__

~~~java

public class baekjoon21275 {

  static long[] limit = new long[38];
  static long MAX = Long.MAX_VALUE;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    for (int i = 2; i <= 36; i++) limit[i] = MAX / i;

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    String str1 = st.nextToken();
    String str2 = st.nextToken();

    int aa = -1;
    int bb = -1;

    for (int a = 2; a <= 36; a++) {
      long v1 = calc(str1, a);
      if (v1 == -1L) continue;

      for (int b = 2; b <= 36; b++) {
        if (a == b) continue;

        long v2 = calc(str2, b);

        if (v1 == v2) {
          if (aa != -1L) {
            System.out.println("Multiple");
            return;
          }

          aa = a;
          bb = b;
        }

      }

    }

    if (aa == -1) System.out.println("Impossible");
    else System.out.println(calc(str1, aa) + " " + aa + " " + bb);

  }

  private static long calc(String str, int n) {

    long ret = 0;

    for (int i = 0; i < str.length(); i++) {
      if (limit[n] < ret) return -1L;
      ret *= n;

      if (trans(str.charAt(i)) >= n || limit[n] - trans(str.charAt(i)) < ret) return -1L;
      ret += trans(str.charAt(i));
    }

    return ret;

  }

  private static long trans(char x) {
    if ('0' <= x && x <= '9') return (x - '0');
    return 10L + x - 'a';
  }

}

~~~

***

## [백준 21276번 - 계보 복원가 호석](https://www.acmicpc.net/problem/21276)
---

__출제 의도__
+ 그래프의 장점이 문자열인 경우는 어떻게 하는가?
+ 그래프,그 중에서도 Rooted Tree에 대한 올바른 이해를 했는가?

__생각의 흐름 - 1. 정점을 번호를 바라보기__
+ 정점마다 주어지는 이름을 숫자로 바꾸고 싶다.
+ 자료구조 중 HashMap<String, Integer> 을 사용하자!
+ 문자열을 숫자로 바꿔서 저장하고, 원하는 문자열을 탐색하는 행위를 모두 O(1) 에 수행해주기 때문에 이와 같은 상황에서 매우 좋은 자료구조이다.

__생각의 흐름 - 2. Root 찾기__
+ 모든 정점이 자신의 조상을 기억하고 있다.
+ 한 가문의 시조, 즉, Root 정점들은 조상이 존재 하지 않는다.
+ 즉, 조상이 없는 정점들을 Root라고 판단하면 된다.

__생각의 흐름 - 3. 직속 부모, 자식 관계 찾기__
+ 어떤 정점이 자신의 조상을 전부 기억한다면?
  + 자신의 Depth를 계산할 수 있다.
+ 모든 정점이 자신의 Depth를 안다면, 부모의 정점은?
  + 당연하게도 자신보다 Depth가 1 낮은 정점일 것이다.
+ 즉, Depth를 통해 조상들 중에 부모를 찾을 수 있다.

__생각의 흐름__
1. 정점을 번호를 나타내기 (문자열과 자료구조에 능숙하면 회피 가능)
2. 각 가문의 시조, Root 찾기
3. Depth를 이용해서 부모 자식 관계를 통해 그래프 복원하기 

__구현__

~~~java

public class baekjoon21276 {


  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    int N = Integer.parseInt(br.readLine());
    ArrayList<String> list = new ArrayList<>();

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");
    for (int i = 1; i <= N; i++) {
      list.add(st.nextToken());
    }
    Collections.sort(list);


    String[] currentPeople = new String[N + 1];
    HashMap<String, Integer> map = new HashMap<>();

    for (int i = 1; i <= N; i++) {
      currentPeople[i] = list.get(i - 1);
      map.put(currentPeople[i], i);
    }


    int M = Integer.parseInt(br.readLine());
    int[] numberOfAncestors = new int[N + 1];
    boolean[][] ancestralCheck = new boolean[N + 1][N + 1];

    for (int i = 1; i <= M; i++) {
      st = new StringTokenizer(br.readLine(), " ");
      String str1 = st.nextToken();
      String str2 = st.nextToken();

      int u = map.get(str1);
      int v = map.get(str2);

      numberOfAncestors[u]++;
      ancestralCheck[u][v] = true;

    }

    ArrayList<String> familyEponyms = new ArrayList<>();

    for (int i = 1; i <= N; i++) {
      if (numberOfAncestors[i] == 0) familyEponyms.add(currentPeople[i]);
    }

    int[] numberOfChild = new int[N + 1];
    boolean[][] childCheck = new boolean[N + 1][N + 1];
    for (int i = 0; i < N; i++) {
      int index = 1;
      while (numberOfAncestors[index] > 0) index++;

      for (int j = 1; j <= N; j++) {

        if (ancestralCheck[j][index]) {
          numberOfAncestors[j]--;

          if (numberOfAncestors[j] == 0) {
            numberOfChild[index]++;
            childCheck[index][j] = true;
          }

        }

        numberOfAncestors[index] = 99999;

      }

    }

    System.out.println(familyEponyms.size());
    for (String s : familyEponyms) {
      System.out.print(s + " ");
    }
    System.out.println();

    for (int i = 1; i <= N; i++) {
      System.out.print(currentPeople[i] + " ");
      System.out.print(numberOfChild[i] + " ");
      for (int j = 1; j <= N; j++) {
        if (childCheck[i][j]) System.out.print(currentPeople[j] + " ");
      }
      System.out.println();
    }

  }


}

~~~

***

## [백준 21277번 - 짠돌이 호석](https://www.acmicpc.net/problem/21277)
---

__출제 의도__
+ 2차원 배열이 주어졌을 때
  1. 배열 평행 이동이 능숙한가?
  2. 배열 돌리기가 능숙한가?

__생각의 흐름 - 1. 비교 순서__
+ 먼저, 두 퍼증르 모두 회전시켜 볼 필요가 있을까?
+ 아니다. 첫번째 퍼즐은 고정시키고 두번째 퍼질만 4방향 회정르 시켜도 된다.

__시간, 공간 복잡도 계산하기__
1. 4번의 회전
2. 가로 방향으로 약 100 번의 이동 가능성
3. 세로 방향으로 약 100 번의 이동 가능성
4. 배열 전체에 대해 겹치는 부분 확인 O(NM)

+ 즉 총 연산 횟수는 4 * 100 * 100 * 50 * 50 = 1억에 비례한다.

__구현__

~~~java

public class baekjoon21277 {


  static int n1, m1, n2, m2;
  static char[][] arr1 = new char[100][100];
  static char[][] arr2 = new char[100][100];

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    n1 = Integer.parseInt(st.nextToken());
    m1 = Integer.parseInt(st.nextToken());

    for (int i = 0; i < n1; i++) {
      arr1[i] = br.readLine().toCharArray();
    }
    st = new StringTokenizer(br.readLine(), " ");

    n2 = Integer.parseInt(st.nextToken());
    m2 = Integer.parseInt(st.nextToken());

    for (int i = 0; i < n2; i++) {
      arr2[i] = br.readLine().toCharArray();
    }


    int result = 99999999;

    for (int rotation = 0; rotation < 4; rotation++) {
      for (int x = -100; x <= 100; x++) {
        for (int y = -100; y <= 100; y++) {
          int v1, v2;
          int l, r;

          l = Math.min(1, 1 + x);
          r = Math.max(n2, n1 + x);
          v1 = r - l + 1;

          l = Math.min(1, 1 + y);
          r = Math.max(m2, m1 + y);
          v2 = r - l + 1;

          if (v1 * v2 >= result) continue;

          if (chk(x, y)) {
            result = v1 * v2;
          }
        }
      }

      rotation();
      int tmp = n1;
      n1 = m1;
      m1 = tmp;
    }

    System.out.println(result);

  }

  private static void rotation() {
    char[][] tmp = new char[n1][m1];
    for (int i = 0; i < n1; i++) for (int j = 0; j < m1; j++) tmp[i][j] = arr1[i][j];

    for (int i = 0; i < m1; i++)
      for (int j = 0; j < n1; j++) {
        arr1[i][j] = tmp[n1 - 1 - j][i];
      }


  }

  private static boolean chk(int x, int y) {

    for (int i = 0; i < n1; i++) {
      for (int j = 0; j < m1; j++) {
        if (arr1[i][j] == '0') continue;

        int idx1 = i + x;
        int idx2 = j + y;

        if (0 <= idx1 && idx1 < n2 && 0 <= idx2 && idx2 < m2 && arr2[idx1][idx2] == '1') return false;

      }
    }

    return true;
  }

}

~~~

***

## [백준 21278번 - 호석이 두 마리 치킨](https://www.acmicpc.net/problem/21278)
---

__출제 의도__
+ 문제를 올바르게 이해했는가?
+ 모든 거리 관계를 파악할 줄 아는가? 전처리를 통해 계산하는 것을 떠올리는가?
+ BFS를 통해 최단 거리를 떠올리고 구현하는가?

__생각의 흐름 - 1. 최단 시간 키워드 발견__
+ 최단 거리 알고리즘
  + BFS -> 간선의 가중치 모두 동일, O(N)
  + Dijkstra -> 음이 아닌 가중치, O(E log V)
+ 둘의 장단점은? 시간 복잡도는? 이 문제에 적합한 것은? 

__생각의 흐름 - 2. 가능한 모든 조합으로 치킨집을 세워볼까?__
+ 치킨집을 지을 건물 조합
  + (1,1), (1,2), …, (N – 1, N)  O(N^2) 가지
+ 모든 조합을 모두 시도해보자.
+ i번 건물과 j번 건물에 치킨집을 세원다고 하자.
+ "모든 건물에서 가장 가까운 치킨집까지 왕복하는 최단 시간의 총합" 을 구하기 위해서는 모든 건물에 대해 i번 건물과 j번 건물까지의 최단 거리를 계산해야만 한다.

__생각의 흐름 - 3. 두 건물 x와 y 사이의 최단거리 dist(x, y)__
+ dist(x, y)는 x를 시작점으로 BFS를 수행하면 알 수 있다.
+ 시간 복잡도는 O( N + M ) 이다.
+ 총 O(N^3 * M)  100^3 * 5000 = 50억  시간초과!
+ 문제점: dist 함수가 너무 많이 호출된다.
+ 해결책: 미리 계산해 놓을 수 있다면 O(1)에 dist(x, y)를 가져온다!
+ D[i][j] := i에서 j로 가는 최단 거리

__시간, 공간 복잡도 계산하기__
+ 전처리를 통해 불필요한 시간 증가를 해소해야 한다.
+ 이를 통해 O(N^3) 으로 문제를 해결할 수 있다.

__구현__

~~~java

public class baekjoon21278 {

  static int N, M;
  static int[][] arr;

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    N = Integer.parseInt(st.nextToken());
    M = Integer.parseInt(st.nextToken());

    arr = new int[N + 1][N + 1];
    for (int i = 1; i <= M; i++) {
      st = new StringTokenizer(br.readLine(), " ");

      int x = Integer.parseInt(st.nextToken());
      int y = Integer.parseInt(st.nextToken());

      arr[x][y] = arr[y][x] = 1;
    }

    int result1 = -1, result2 = -1, min = Integer.MAX_VALUE;

    for (int i = 1; i <= N; i++) {
      for (int j = i + 1; j <= N; j++) {
        int[] dist = new int[N + 1];
        Arrays.fill(dist, -1);
        dist[i] = 0;
        dist[j] = 0;

        Queue<Integer> queue = new LinkedList<>();
        queue.add(i);
        queue.add(j);
        int tot = 0;
        while (!queue.isEmpty()) {
          int cur = queue.poll();
          for (int k = 1; k <= N; k++) {

            if (arr[k][cur] == 0) continue;
            if (dist[k] != -1) continue;

            dist[k] = dist[cur] + 1;
            queue.add(k);

            tot += dist[k];
          }
        }

        if (tot < min) {
          min = tot;
          result1 = i;
          result2 = j;
        }

      }

    }

    System.out.println(result1 + " " + result2 + " " + min * 2);

  }
}



~~~

***

## [백준 21278번 - 광부 호석](https://www.acmicpc.net/problem/21278)
---

__출제 의도__
+ "광산 뒤집기" 스킬을 쓰는 영역에 대한 관찰을 충분히 했는가?
+ H와 W의 관계를 이용해서 투 포인터 기법을 떠올렸는가?
+ 필요한 연산에 적합한 자료 구조를 스스로 떠올리 수 있는가?
+ 이 모든 과정을 성공적으로 구현할 줄 아는가?

__생각의 흐름 - 1. 기본 접근 시도__
+ 뒤집는 영역의 높이 H와 너비 W를 정하고 점수 계산해서 최대치 찾기

__생각의 흐름 - 2. 예제에 대한 관찰__
+ 주어진 입력을 직접 그려보면서 탐색 여부를 모두 확인해본다.
+ 가능한 "뒤집는 영역"은 가로가 길어질 수로 세로는 짧아진다.
+ 즉 K 개를 포함하는 (H, W)을 찾았다면, H가 증가하는 W는 무조건 같거나 작아야한다.
  + Two Pointer 적용가능
+ 매 순가 cnt 값을 보고 H 줄이기 or W 늘리기

__생각의 흐름 - 3. 영역 변경 시에 추가, 제거되는 광석 찾기__

__생각의 흐름 - 4. 자료구조 만들기__
+ 필요한 연산
  1. 특정 x 좌표의 광석들 정보 받아오기 -> X[x] = {x값인 광석들}
  2. 특정 y 좌표의 광석들 정보 받아오기 -> Y[y] = {y값인 광석들}

__시간, 공간 복잡도 계산하기__
1. X, Y 자료 구조 만들기  O(N)
2. W, H의 변화 총량 O(20만)
3. Del, Add 함수가 모든 W, H에 대해 호출 되어도 O(N)

+ 즉, 총 시간 복잡도는 O(max(N, 20만)) 이므로 시간 안에 충분히 나온다.

__구현__

~~~java

public class baekjoon21279 {

  public static void main(String[] args) throws IOException {

    BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

    StringTokenizer st = new StringTokenizer(br.readLine(), " ");

    int n = Integer.parseInt(st.nextToken());
    int c = Integer.parseInt(st.nextToken());

    ArrayList<long[]>[] xx = new ArrayList[100001];
    ArrayList<long[]>[] yy = new ArrayList[100001];

    for (int i = 0; i < 100001; i++) {
      xx[i] = new ArrayList<>();
      yy[i] = new ArrayList<>();
    }


    for (int i = 0; i < n; i++) {
      st = new StringTokenizer(br.readLine(), " ");

      long x = Integer.parseInt(st.nextToken());
      long y = Integer.parseInt(st.nextToken());
      long v = Long.parseLong(st.nextToken());

      xx[(int) x].add(new long[]{y, v});
      yy[(int) y].add(new long[]{x, v});
    }

    long mx = 0;
    long curval = 0;
    int curnum = 0;
    int xlim = 0;
    int ylim = 100000;


    while (xlim <= 100000) {
      for (int i = 0; i < xx[xlim].size(); i++) {
        if (xx[xlim].get(i)[0] > ylim) continue;
        curval += xx[xlim].get(i)[1];
        curnum++;
      }

      while (c < curnum) {
        for (int i = 0; i < yy[ylim].size(); i++) {
          if (yy[ylim].get(i)[0] > xlim) continue;
          curval -= yy[ylim].get(i)[1];
          curnum--;
        }
        ylim--;
      }

      xlim++;

      if (mx < curval) mx = curval;

    }

    System.out.println(mx);

  }
}

~~~

***