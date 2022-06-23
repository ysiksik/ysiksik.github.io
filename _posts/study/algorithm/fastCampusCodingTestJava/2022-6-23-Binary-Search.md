---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 03.이분 탐색 (Binary Search)
date: '2022-06-23 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     - 
---

# [Part3 Ch02 알고리즘] 03.이분 탐색 (Binary Search)

# 이분 탐색 (Binary Search)
* toc
{:toc}

## 이분 탐색
---
+ 이분 탐색
> + 정렬이 보장되는 배열에서 기준 X를 가지고 범위를 이분 하면서 탐색하는 방법
> + $$시간 복잡도 :  \quad O\left(\log N \right)$$
> + 정렬이 아니라면 불가능  

+ 자주 하는 실수
> + 1위 입력된 배열에 바로 이분 탐색을 하는 경우, 정렬을 하지 않은 경우
> + 2위 L, R, M, RESULT 변수 정의를 헷갈려서 부등호를 등을 잘못 쓰는 경우
> + 3위 L, R 범위를 잘못 설정하거나 Result 초기값을 잘못 설정하는 경우

***

## [백준 7795번 - 먹을 것인가 먹힐 것인가](https://www.acmicpc.net/problem/7795)
---

* __정답의 최대치__      
> + $$N\leq20,000$$
> + $$M\leq20,000$$
> + $$모든 \, 쌍이 \, 정답인 \, 경우 \Rightarrow N \times M \Rightarrow Integer$$

* __시간, 공간 복잡도 계산하기__
> + B 배열 정려 한번
>   + $$O\left(M \log M \right)$$
> + 모든 A의 원소마다, B 배열에 대해 이분 탐색 필요
>   + $$O\left(N \log M \right)$$
> + 총 시간 복잡도
>   + $$O\left(\left( N + M \right) \log M \right)$$

* __구현__

~~~java
public class baekjoon7795 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        int T = Integer.parseInt(br.readLine());
        int[] A;
        int[] B;

        for (int i = 0; i < T; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            int N = Integer.parseInt(st.nextToken());
            int M = Integer.parseInt(st.nextToken());

            A = new int[N + 1];
            B = new int[M + 1];

            st = new StringTokenizer(br.readLine(), " ");
            for (int a = 1; a <= N; a++) {
                A[a] = Integer.parseInt(st.nextToken());
            }

            st = new StringTokenizer(br.readLine(), " ");
            for (int b = 1; b <= M; b++) {
                B[b] = Integer.parseInt(st.nextToken());
            }

            // B 배열에 대해 이분탐색을 할 예정이니까, 정렬을 해주자!
            Arrays.sort(B, 1, M + 1);


            int result = 0;

            for (int j = 1; j <= N; j++) {

                int X = A[j];
                int res = 0; // 만약 A[L...R] 중 X 이하의 수가 없다면 0 을 return 한다.
                int L = 1;
                int R = M;

                while (L <= R) {
                    int mid = (L + R) / 2;
                    if (B[mid] < X) {
                        res = mid;
                        L = mid + 1;
                    } else {
                        R = mid - 1;
                    }

                }
                result += res;
            }

            System.out.println(result);

        }

    }

}
  ~~~
***

## [백준 1920번 - 수 찾기](https://www.acmicpc.net/problem/1920)
---

* __정답의 최대치__      
> + $$N\leq100,000$$
> + $$M\leq100,000$$
> + $$Integer$$

* __시간, 공간 복잡도 계산하기__
> + A 배열 정려 한번
>   + $$O\left(M \log M \right)$$
> + 모든 B의 원소마다, A 배열에 대해 이분 탐색 필요
>   + $$O\left(N \log M \right)$$
> + 총 시간 복잡도
>   + $$O\left(\left( N + M \right) \log M \right)$$

* __구현__

~~~java
public class baekjoon1920 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        int N = Integer.parseInt(br.readLine());
        int[] A = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= N; i++) {
            A[i] = Integer.parseInt(st.nextToken());
        }

        int M = Integer.parseInt(br.readLine());
        int[] B = new int[M + 1];

        st = new StringTokenizer(br.readLine(), " ");
        for (int i = 1; i <= M; i++) {
            B[i] = Integer.parseInt(st.nextToken());
        }

        Arrays.sort(A, 1, N + 1);

        for (int i = 1; i <= M; i++) {
            int X = B[i];
            int L = 1;
            int R = N;
            int result = 0;

            while (L <= R) {
                int mid = (L + R) / 2;

                if (A[mid] == X) {
                    result = 1;
                    break;
                }

                if (A[mid] < X) {
                    L = mid + 1;
                } else {
                    R = mid - 1;
                }
            }
            System.out.println(result);


        }

    }

}
  ~~~
***


## [백준 1764번 - 듣보잡](https://www.acmicpc.net/problem/1764)
---

* __정답의 최대치__      
> + $$N\leq500,000$$
> + $$M\leq500,000$$
> + $$Integer$$

* __시간, 공간 복잡도 계산하기__
> + B 배열 정려 한번
>   + $$O\left(M \log M \right)$$
> + 모든 A의 원소마다, B 배열에 대해 이분 탐색 필요
>   + $$O\left(N \log M \right)$$
> + 총 시간 복잡도
>   + $$O\left(\left( N + M \right) \log M \right)$$

* __구현__

~~~java
public class baekjoon1764 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());
        int M = Integer.parseInt(st.nextToken());

        String[] A = new String[N + 1];
        String[] B = new String[M + 1];

        for (int a = 1; a <= N; a++) {
            A[a] = br.readLine();
        }

        for (int b = 1; b <= M; b++) {
            B[b] = br.readLine();
        }

        Arrays.sort(B, 1, M + 1);

        List<String> list = new ArrayList<>();

        for (int i = 1; i <= N; i++) {
            int L = 1;
            int R = M;
            String X = A[i];

            while (L <= R) {
                int mid = (L + R) / 2;
                if (X.compareTo(B[mid]) == 0) {
                    list.add(X);
                    break;
                }
                if (X.compareTo(B[mid]) > 0) {
                    L = mid + 1;
                } else {
                    R = mid - 1;
                }

            }


        }

        StringBuilder sb = new StringBuilder();

        sb.append(list.size()).append("\n");

        Collections.sort(list);

        for (String s : list) {
            sb.append(s).append("\n");
        }

        System.out.println(sb);

    }

}

  ~~~
***

## [백준 3273번 - 두 수의 합](https://www.acmicpc.net/problem/3273)
---

* __정답의 최대치__      
> + $$N\leq100,000$$
> + $$X\leq2,000,000$$
> + $$Integer$$

* __시간, 공간 복잡도 계산하기__
> + A 배열 정려 한번
>   + $$O\left(M \log M \right)$$
> + 모든 A의 원소마다, A 배열에 대해 이분 탐색 필요
>   + $$O\left(N \log M \right)$$
> + 총 시간 복잡도
>   + $$O\left(\left( N + M \right) \log M \right)$$

* __구현__

~~~java
public class baekjoon3273 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));


        int n = Integer.parseInt(br.readLine());

        int[] a = new int[n + 1];


        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= n; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }

        int x = Integer.parseInt(br.readLine());

        Arrays.sort(a);

        int result = 0;

        for (int i = 1; i <= n; i++) {
            int L = i+1;
            int R = n;
            while (L <= R) {
                int mid = (L + R) / 2;

                if (a[i] + a[mid] == x) {
                    result++;
                    break;
                }
                if (a[i] + a[mid] < x) {
                    L = mid + 1;
                }else{
                    R = mid - 1;
                }
            }
        }

        System.out.println(result);

    }

}

  ~~~
***

## [백준 10816번 - 숫자 카드 2](https://www.acmicpc.net/problem/10816)
---

* __정답의 최대치__      
> + $$-10,000,000 \leq N \leq 10,000,000$$
> + $$-10,000,000 \leq M \leq 10,000,000$$
> + $$Integer$$

* __시간, 공간 복잡도 계산하기__
> + A 배열 정려 한번
>   + $$O\left(M \log M \right)$$
> + 모든 B의 원소마다, A 배열에 대해 이분 탐색 필요
>   + $$O\left(N \log M \right)$$
> + 총 시간 복잡도
>   + $$O\left(\left( N + M \right) \log M \right)$$

* __구현__

~~~java
public class baekjoon10816 {


    static int lower_bound(int[] A, int L, int R, int X) {
        int ans = R + 1;
        while (L <= R) {
            int mid = (L + R) / 2;
            if (A[mid] >= X) {
                ans = mid;
                R = mid - 1;
            } else {
                L = mid + 1;
            }
        }
        return ans;
    }

    static int upper_bound(int[] A, int L, int R, int X) {
        int ans = R + 1;
        while (L <= R) {
            int mid = (L + R) / 2;
            if (A[mid] > X) {
                ans = mid;
                R = mid - 1;
            } else {
                L = mid + 1;
            }
        }
        return ans;
    }


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());

        int[] cards = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            cards[i] = Integer.parseInt(st.nextToken());
        }

        int M = Integer.parseInt(br.readLine());

        int[] numbers = new int[M + 1];
        int[] result = new int[M + 1];

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= M; i++) {
            numbers[i] = Integer.parseInt(st.nextToken());
        }

        Arrays.sort(cards, 1, N + 1);

        for (int i = 1; i <= M; i++) {
            int x = numbers[i];
            int upper = upper_bound(cards, 1, N, x);
            int lower = lower_bound(cards, 1, N, x);

            result[i] = upper - lower;
        }

        StringBuilder sb = new StringBuilder();

        for (int i = 1; i <= M; i++) {
            sb.append(result[i]).append(" ");
        }
        System.out.println(sb);

    }

}

  ~~~
***

## [백준 2470번 - 두 용액](https://www.acmicpc.net/problem/2470)
---

* __정답의 최대치__      
> + 두 수의 합으로 가능한 범위 : -20억 ~ 20억
> + Integer 범위 : -21억 4748만 3648 ~ -21억 4748만 3647

* __시간, 공간 복잡도 계산하기__
> + 배열 정렬 한번
>   + $$O\left(N \log N \right)$$
> + 모든 원소마다 Left로 정하고, -A[Left]를 이분 탐색하기
>   + $$O\left(N \log N \right)$$
> + 총 시간 복잡도
>   + $$O\left(N \log N \right)$$

* __구현__

~~~java
public class baekjoon2470 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());
        int[] solution = new int[N + 1];


        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            solution[i] = Integer.parseInt(st.nextToken());
        }


        Arrays.sort(solution, 1, N + 1);
        int best_sum = Integer.MAX_VALUE;
        int v1 = 0, v2 = 0;

        for (int i = 1; i <= N; i++) {
            int L = i + 1;
            int R = N;
            int X = -solution[i];

            int candidate = R + 1;

            while (L <= R) {
                int mid = (L + R) / 2;

                if (solution[mid] >= X) {
                    R = mid - 1;
                    candidate = mid;
                } else {
                    L = mid + 1;
                }

            }

            if (i < candidate - 1 && Math.abs(solution[i] + solution[candidate - 1]) < best_sum) {
                best_sum = Math.abs(solution[i] + solution[candidate - 1]);
                v1 = solution[i];
                v2 = solution[candidate - 1];
            }

            if (candidate <= N && Math.abs(solution[i] + solution[candidate]) < best_sum){
                best_sum = Math.abs(solution[i] + solution[candidate]);
                v1 = solution[i];
                v2 = solution[candidate];
            }


        }

        StringBuilder sb = new StringBuilder();
        sb.append(v1).append(' ').append(v2);
        System.out.println(sb);

    }

}

  ~~~
***