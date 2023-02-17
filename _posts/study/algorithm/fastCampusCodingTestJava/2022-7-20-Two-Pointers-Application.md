---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 04.두 포인터 (Two Pointer) - 응용편
date: '2022-07-20 00:00:00 +0900'
categories:
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 04.두 포인터 (Two Pointer) - 응용편

# 두 포인터 (Two Pointer) - 응용편
* toc
{:toc}

## 두 포인터 (Two Pointer) - 응용편


## [백준 13144번 - List of Unique Numbers](https://www.acmicpc.net/problem/13144)
---

* __정답의 최대치__      
> + $$ N = 100,000 $$
> + 모든 연속 구간이 모두 정답에 카운트
> + 개수 = N + (N - 1) + ... + 2 + 1 = 50억 -> Long

* __키워드 체크하기__      
> + 이 수열에서 __연속한 1개 이상의 수를 뽑았을 때__ 같은 수가 여러 번 등장하지 않는 경우의 수 

* __시간 복잡도 계산하기__
> + 왼쪽 시작 L 결정 O(N)
> + 오른쪽 끝을 R을 이전의 R부터 시작해서 이동
> + R을 이동해서 추가된 원소가[L, R-1]안에 있는지 확인 -> O(1)
> + 총 -> O(N)


* __구현__

~~~java
public class baekjoon13144 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());
        int[] a = new int[N + 1];
        int[] cnt = new int[100001];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }
        long result = 0;
        for (int L = 1, R = 0; L <= N; L++) {

            while (R + 1 <= N && cnt[a[R + 1]] == 0) {
                R++;
                cnt[a[R]]++;
            }

            result += R - L + 1;
            cnt[a[L]]--;

        }

        System.out.println(result);

    }
}
~~~
***

## [백준 1253번 - 좋다](https://www.acmicpc.net/problem/1253)
---

* __정답의 최대치__
> + 정답이 N 이하이므로 Integer 범위
> + 원소 두 개의 합도 최대 $$ 10^9 $$ 이므로 Integer 범위

* __시간 복잡도 계산하기__
> + 정렬 하기 $$ O\left(N \log N \right) $$
> + 타겟 수 결정 $$ O\left( N \right) $$
> + 다른 수 2개 결정해서 만들어지나 확인 $$ O\left( N \right) $$
> + 총 -> O(N^2)

* __구현__

~~~java
public class baekjoon1253 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());
        int[] a = new int[N + 1];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }


        Arrays.sort(a, 1, N + 1);

        int result = 0;

        for (int T = 1; T <= N; T++) {
            int target = a[T];

            int L = 1, R = N;

            while (L < R) {
                int sum = a[R] + a[L];

                if (L == T) L++;
                else if (R == T) R--;
                else {
                    if (sum > target) {
                        R--;
                    } else if (sum == target) {
                        result++;
                        break;
                    } else {
                        L++;
                    }
                }


            }
        }
        System.out.println(result);
    }
}

~~~
***


## [백준 2473번 - 세 용액](https://www.acmicpc.net/problem/2473)
---

* __구현__

~~~java
ppublic class baekjoon2473 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());

        int[] a = new int[N + 1];

        st = new StringTokenizer(br.readLine(), " ");

        for (int i = 1; i <= N; i++) {
            a[i] = Integer.parseInt(st.nextToken());
        }


        Arrays.sort(a, 1, N + 1);

        long bestSum = Long.MAX_VALUE;
        int v1 = 0, v2 = 0, v3 = 0;
        for (int i = 1; i <= N - 2; i++) {
            int L = i + 1;
            int R = N;
            int target = -a[i];

            while (L < R) {
                if (bestSum > Math.abs(-(long) target + a[L] + a[R])) {
                    bestSum = Math.abs(-(long) target + a[L] + a[R]);
                    v1 = a[i];
                    v2 = a[L];
                    v3 = a[R];
                }
                if (target < a[L] + a[R]) {
                    R--;
                } else {
                    L++;
                }

            }

        }

        System.out.println(v1 + " " + v2 + " " + v3);

    }
}
~~~
***

## [백준 16472번 - 고냥이](https://www.acmicpc.net/problem/16472)
---

* __정답의 최대치__
> + N = 26 이라면 문자열 전체를 인식하므로, 최대 길이인 10만이 정답이다.

* __키워드 체크하기__
> + 최대 N개의 종류의 알파벳을 가진 __연속된 문자열__ 밖에 인식하지 못한다.

* __시간 복잡도 계산하기__
> + R을 하나씩 이동시키면서 L을 조절하기 O(N)
> + kind를 O(26)에 계산하거나 O(1)에 계산 가능
> + 총 -> O(N)

* __구현__

~~~java
public class baekjoon16472 {

    static int kind;
    static int[] cnt;

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        StringTokenizer st = new StringTokenizer(br.readLine(), " ");

        int N = Integer.parseInt(st.nextToken());

        String text = br.readLine();
        cnt = new int[26];

        int len = text.length();

        int result = 0;

        for (int R = 0, L = 0; R < len; R++) {
            addText(text.charAt(R));

            while (kind > N) {
                deleteText(text.charAt(L++));
            }

            result = Math.max(result, R - L + 1);
        }
        System.out.println(result);

    }

    private static void deleteText(char charAt) {
        cnt[charAt - 'a']--;
        if (cnt[charAt - 'a'] == 0) {
            kind--;
        }
    }

    private static void addText(char charAt) {
        cnt[charAt - 'a']++;
        if (cnt[charAt - 'a'] == 1) {
            kind++;
        }

    }


}

  ~~~
***


