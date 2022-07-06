---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 03.이분 탐색 (Binary Search) 응용편
date: '2022-07-06 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 03.이분 탐색 (Binary Search) 응용편

# 매개 변수 탐색 (Parametric Search)
* toc
{:toc}

## 매개 변수 탐색 (Parametric Search)
---
+ 매개 변수 탐색(Parametric Search) <- 이분 탐색의 아이디어
> + 배열이 0과 1만 존재하며 오름차순 인건 보장되지만 전체 배열은 모른다
> + 특정 인덱스의 값을 O(T)에 계산 가능할 때, 여기서 0과 1의 경계를 찾아야 한다면?
> + EX) Up-Down 게임
>   + A가 1 ~ 1000 사이의 어떤 자연수를 선택
>   + B는 A한태 "생각한 숫자가 x 이상이야?" 라는 질문 가능
>   + A는 맞으면 1, 아니면 0이라고 대답
>   + 최소 횟수로 질문하려면?

+ 핵심
> 1. 정답을 __매개 변수(Parmaeter)__ 로 만들고 __Yes/No 문제(결정 문제)__ 로 바꿔 보기
> 2. 모든 값에 대해서 Yes/No를 채웠다고 생각했을 때, 정렬된 상태 인가?
> 3. Yes/No 결정하는 문제 풀기

        문제를 거꾸로 푸는 것이기 때문에 통찰력을 요구
        코딩테스트에서 빈도 높게 나옴, 훈련이 필요

+ 자주 하는 실수
> + 1위 매개 변수에 대한 결정이 Yes/No 꼴이 아닌데 이분 탐색 하는 경우
> + 2위 L, R, M, RESULT 변수 정의를 헷갈려서 부등호를 등을 잘못 쓰는 경우
> + 3위 L, R 범위를 잘못 설정하거나 Result 초기값을 잘못 설정하는 경우

+ 꿀팁 <키워드>
> + ~~의 최댓값을 구하시오
> + ~~의 최솟값을 구하시오

        Parametric Search 접근을 시도해볼 가치가 있다
  

***

## [백준 2805번 - 나무 자르기](https://www.acmicpc.net/problem/2805)
---

* __정답의 최대치__      
> + $$1 \leq N \leq 100만$$
> + $$1 \leq M \leq 20억$$
> + $$0 \leq 각 나무 높이 \leq 10억$$
> + 정답의 범위 : 0 ~ 10억
> + 잘린 나무의 길이의 합 ≤ 나무 높이의 총합 = 100만 X 10억 = $$10^{15}$$
> + 계산 과정 중의 변수 타입은 long로

* __키워드 체크하기__      
> + 적어도 M미터의 나무를 집에 가져가기 위해서 절단기에 __설정할 수 있는 높이의 최댓값__ 을 구하는 프로그램을 작성하시오

* __매개 변수 만들어 보기__  
> + 원래 문제 :  __원하는 길이 M 만큼을 얻을 수 있는__ 최대 __높이__ 는 얼마인가
> + 뒤집은 문제 : 어떤 __높이__ 로 잘랐을 때 __원하는 길이 M 만큼을 얻을 수 있는가__ 
>   + Yes/No

* __뒤집은 문제를 써먹기__
+ 핵심
> + 정답을 "매개 변수(Parameter)"로 만들고 Yes/No 문제(결정 문제)로 바꿔보기
> + 모든 값에 대해서 Yes/No 를 채웠다고 생각했을 때, 정렬된 상태인가?
> + Yes/No 결정 하는 문제 풀기

* __시간, 공간 복잡도 계산하기__
> + H를 정해서 결정 문제 한 번 풀기
>   + $$O\left(N \right)$$
> + 정답의 범위를 이분 탐색하면서 풀기
>   + $$O\left(\log X \right)$$
> + 총 시간 복잡도
>   + $$O\left(N \log X \right)$$

* __구현__

~~~java
public class baekjoon2805 {

    static int N, M;
    static int[] X;


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        M = Integer.parseInt(st.nextToken());

        X = new int[N + 1];

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            X[i] = Integer.parseInt(st.nextToken());
        }


        int L = 1, R = 2000000000;

        int result = 0;

        while (L <= R) {
            int mid = (L + R) / 2;
            if (checkLength(mid)) {
                L = mid + 1;
                result = mid;
            } else {
                R = mid - 1;
            }
        }

        System.out.println(result);

    }


    static boolean checkLength(int H) {
        long sum = 0;
        for (int i = 1; i <= N; i++) {
            if (X[i] > H) {
                sum += X[i] - H;
            }
        }
        return sum >= M;
    }

}
  ~~~
***

## [백준 1654번 - 랜선 자르기](https://www.acmicpc.net/problem/1654)
---

* __구현__

~~~java
public class baekjoon1654 {

    static int N, K;
    static int[] X;


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        K = Integer.parseInt(st.nextToken());
        N = Integer.parseInt(st.nextToken());

        X = new int[K + 1];

        for (int i = 1; i <= K; i++) {
            X[i] = Integer.parseInt(br.readLine());
        }


        long L = 1;
        long R = Integer.MAX_VALUE;
        long result = 0;

        while (L <= R) {
            long mid = (L + R) / 2;
            if (crop(mid)) {
                L = mid + 1;
                result = mid;
            } else {
                R = mid - 1;
            }
        }

        System.out.println(result);

    }

    static boolean crop(long H) {
        int count = 0;
        for (int i = 1; i <= K; i++) {
            count += X[i] / H;
        }
        return count >= N;
    }

}

  ~~~
***


## [백준 2512번 - 예산](https://www.acmicpc.net/problem/2512)
---

* __구현__

~~~java
public class baekjoon2512 {

    static int N, M;
    static int[] X;


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        X = new int[N + 1];
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            X[i] = Integer.parseInt(st.nextToken());
        }
        M = Integer.parseInt(br.readLine());

        int L = 1, R = Arrays.stream(X).max().getAsInt();

        int result = 0;

        while (L <= R) {
            int mid = (L + R) / 2;
            if (checkTheValueDistribution(mid)) {
                result = mid;
                L = mid + 1;
            } else {
                R = mid - 1;
            }
        }

        System.out.println(result);

    }

    private static boolean checkTheValueDistribution(int mid) {

        int sum = 0;
        for (int i = 1; i <= N; i++) {
            if (X[i] <= mid) {
                sum += X[i];
            } else {
                sum += mid;
            }
        }

        return sum <= M;
    }

}

  ~~~
***

## [백준 2110번 - 공유기 설치](https://www.acmicpc.net/problem/2110)
---

* __정답의 최대치__      
> + $$2 \leq N \leq 200,000$$
> + $$2 \leq C \leq N$$
> + $$1 \leq 좌표 \leq 10억$$
> + 제일 멀리 설치 해보면 정답은 10억 이하 -> Integer

* __키워드 체크하기__      
> + 가장 인접한 __두 공유기 사이의 거리를 최대__ 로 하는 프로그램을 작성하시오

* __매개 변수 만들어 보기__  
> + 원래 문제 :  __C개의 공유기를 설치했을 때__ 최대 __인접 거리__ 는 얼마인가
> + 뒤집은 문제 : 어떤 __거리__ 만킁은 거리를 둘 때 __공유기 C개를 설치할 수 있는가
>   + Yes/No

* __뒤집은 문제를 써먹기__
> + 어떤 __거리__ 만큼은 거리를 둘 때 외쪽 집부터 되는 대로 전부 설치해보기

* __시간, 공간 복잡도 계산하기__
> + 주어진 집들을 정렬하기
>   + $$O\left(N \log N \right)$$
> + D를 정해서 결정 문제 한 번 풀기 
>   + $$O\left(N \right)$$
> + 정답의 범위를 이분 탐색하면서 풀기
>   + $$O\left(\log X \right)$$
> + 총 시간 복잡도 
>   + $$O\left( N \log N + N \log X \right)$$

* __구현__

~~~java
public class baekjoon2110 {

    static int N, C;
    static int[] X;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());

        X = new int[N + 1];

        C = Integer.parseInt(st.nextToken());

        for (int i = 1; i <= N; i++) {
            X[i] = Integer.parseInt(br.readLine());
        }

        Arrays.sort(X, 1, N + 1);

        int L = 1, R = 1000000000;
        int result = 0;

        while (L <= R) {
            int mid = (L + R) / 2;
            if (distanceMeasurement(mid)) {
                L = mid + 1;
                result = mid;
            } else {
                R = mid - 1;
            }
        }

        System.out.println(result);

    }

    private static boolean distanceMeasurement(int mid) {

        int last = X[1];
        int cnt = 1;

        for (int i = 2; i <= N; i++) {
            if (X[i] - last < mid) continue;
            last = X[i];
            cnt++;
        }
        return cnt >= C;
    }


}

  ~~~
***

## [백준 2343번 - 기타 레슨](https://www.acmicpc.net/problem/2343)
---

* __구현__

~~~java
public class baekjoon2343 {

    static int N, M;
    static int[] X;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());

        X = new int[N + 1];

        M = Integer.parseInt(st.nextToken());

        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            X[i] = Integer.parseInt(st.nextToken());
        }

        int L = Arrays.stream(X).max().getAsInt(), R = 1000000000;
        int result = 0;

        while (L <= R) {
            int mid = (L + R) / 2;

            if (lectureLength(mid)) {
                R = mid - 1;
                result = mid;
            } else {
                L = mid + 1;
            }
        }

        System.out.println(result);

    }

    private static boolean lectureLength(int mid) {

        int cnt = 1, sum = 0;

        for (int i = 1; i <= N; i++) {
            if (X[i] + sum > mid) {
                cnt++;
                sum = X[i];
            } else {
                sum += X[i];
            }
        }

        return cnt <= M;

    }


}

  ~~~
***

## [백준 6236번 - 용돈관리](https://www.acmicpc.net/problem/6236)
---

* __구현__

~~~java
public class baekjoon6236 {

    static int N, M;
    static int[] X;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        X = new int[N + 1];
        M = Integer.parseInt(st.nextToken());

        for (int i = 1; i <= N; i++) {
            X[i] = Integer.parseInt(br.readLine());
        }

        int L = Arrays.stream(X).max().getAsInt(), R = 1000000000;

        int result = 0;

        while (L <= R) {
            int mid = (L + R) / 2;
            if (pocketMoneyCalculation(mid)) {
                R = mid - 1;
                result = mid;
            } else {
                L = mid + 1;
            }
        }

        System.out.println(result);

    }

    private static boolean pocketMoneyCalculation(int mid) {

        int count = 1, sum = 0;

        for (int i = 1; i <= N; i++) {
            if (sum + X[i] > mid) {
                count++;
                sum = X[i];
            } else {
                sum += X[i];
            }
        }

        return count <= M;
    }


}

  ~~~
***

## [백준 13702번 - 이상한 술집](https://www.acmicpc.net/problem/13702)
---

* __구현__

~~~java
public class baekjoon13702 {

    static int N, K;
    static int[] X;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        N = Integer.parseInt(st.nextToken());
        X = new int[N + 1];
        K = Integer.parseInt(st.nextToken());

        for (int i = 1; i <= N; i++) {
            X[i] = Integer.parseInt(br.readLine());
        }

        long L = 0, R = Integer.MAX_VALUE;
        long result = 0;

        while (L <= R) {
            long mid = (L + R) / 2;

            if (alcoholDistribution(mid)) {
                L = mid + 1;
                result = mid;
            } else {
                R = mid - 1;
            }

        }
        System.out.println(result);
    }

    private static boolean alcoholDistribution(long mid) {

        if (mid == 0) {
            return false;
        }

        int sum = 0;
        for (int i = 1; i <= N; i++) {
            sum += X[i] / mid;
        }
        return sum >= K;
    }


}

  ~~~
***

## [백준 17266번 - 어두운 굴다리](https://www.acmicpc.net/problem/17266)
---

* __구현__

~~~java
public class baekjoon17266 {

    static int N, M;
    static int[] X;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        N = Integer.parseInt(br.readLine());
        M = Integer.parseInt(br.readLine());
        X = new int[M + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= M; i++) {
            X[i] = Integer.parseInt(st.nextToken());
        }

        int L = 0, R = N;
        int result = N;

        while (L <= R) {
            int mid = (L + R) / 2;

            if (lengthCheck(mid)) {
                R = mid - 1;
                result = mid;
            } else {
                L = mid + 1;
            }

        }

        System.out.println(result);

    }

    private static boolean lengthCheck(int mid) {

        int last = 0;

        for (int i = 1; i <= M; i++) {
            if (X[i] - last <= mid) {
                last = X[i] + mid;
            } else {
                return false;
            }

        }


        return last >= N;
    }


}

  ~~~
***

## [백준 1300번 - K 번째 수](https://www.acmicpc.net/problem/1300)
---

* __구현__

~~~java
public class baekjoon1300 {

    static int N, K;


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());
        K = Integer.parseInt(br.readLine());


        long L = 1, R = (long) N * N, result = 0;

        while (L <= R) {
            long mid = (L + R) / 2;

            if (obtainingAValue(mid)) {
                result = mid;
                R = mid - 1;
            } else {
                L = mid + 1;
            }

        }

        System.out.println(result);
    }

    private static boolean obtainingAValue(long mid) {

        long sum = 0;

        for (int i = 1; i <= N; i++) {
            sum += Math.min(N, mid / i);
        }

        return sum >= K;
    }


}

  ~~~
***


## [백준 1637번 - 날카로운 눈](https://www.acmicpc.net/problem/1637)
---

* __구현__

~~~java
public class baekjoon1637 {

    static int N;
    static int[][] A;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        A = new int[N + 1][3];

        for (int i = 1; i <= N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            for (int j = 0; j < 3; j++) {
                A[i][j] = Integer.parseInt(st.nextToken());
            }
        }

        long L = 1, R = Integer.MAX_VALUE, result = 0, count = 0;

        while (L <= R) {
            long mid = (L + R) / 2;

            if (numCheck((int) mid)) {
                R = mid - 1;
                result = mid;
            } else {
                L = mid + 1;
            }
        }


        if (result == 0) {
            System.out.println("NOTHING");
        } else {
            for (int i = 1; i <= N; i++) {
                if (result >= A[i][0] && result <= A[i][1] && (result - A[i][0]) % A[i][2] == 0) {
                    count++;
                }
            }
            System.out.println(result + " " + count);
        }


    }

    private static boolean numCheck(int mid) {

        long sum = 0;

        for (int i = 1; i <= N; i++) {
            sum += countNum(A[i][0], A[i][1], A[i][2], mid);
        }

        return sum % 2 == 1;
    }

    private static int countNum(int A, int C, int B, int X) {
        if (X < A) return 0;
        if (C < X) return (C - A) / B + 1;
        return (X - A) / B + 1;
    }

}