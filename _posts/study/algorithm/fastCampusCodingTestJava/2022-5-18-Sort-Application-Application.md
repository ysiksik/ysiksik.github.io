---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 02.다양한 정렬 응용법 (Sort Application) 응용편
date: '2022-06-15 00:00:00 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     -
---

# [Part3 Ch02 알고리즘] 02.다양한 정렬 응용 (Sort Application) 응용편

# 다양한 정렬 응용 (Sort Application) 응용편
* toc
{:toc}

## [백준 1015번 - 수열 정리](https://www.acmicpc.net/problem/1015)
---

* __정답의 최대치__      
> + 출력: 0 ~ N - 1
> + $$N\leq50$$
> + int 범위면 충분

* __시간, 공간 복잡도 계산하기__
> + 배열정렬
>   + $$정렬은 \quad O\left(N \log N \right)$$
> + P배열 구하기
>   + $$순서대로 \; 채우면 \quad O\left(N\right)$$  
> + 복잡도
>   + $$시간: \quad O\left(N \log N \right)$$
>   + $$공간: \quad O\left(N\right)$$  

* __구현__
~~~java
public class baekjoon1015 {


    static class NumberIdx implements Comparable<NumberIdx> {
        int num;
        int idx;


        public NumberIdx(int num, int idx) {
            this.num = num;
            this.idx = idx;
        }

        @Override
        public int compareTo(NumberIdx o) {
            return this.num - o.num;

            //자바는 Object 원소 정렬이 Tim Sort이고 Tim Sort는 Stable 하기 때문에 NUM이 같으면 IDX 오름차순이 보장이 됨
        }
    }


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());

        int[] P = new int[N];
        NumberIdx[] B = new NumberIdx[N];

        StringTokenizer st = new StringTokenizer(br.readLine(), " ");
        for (int i = 0; i < N; i++) {

            B[i] = new NumberIdx(Integer.parseInt(st.nextToken()), i);
        }

        Arrays.sort(B);

        for (int i = 0; i < N; i++) {
            P[B[i].idx] = i;
        }


        for (int i = 0; i < N; i++) {
            System.out.print(P[i] + " ");
        }

    }
}
  ~~~

        자바는 Object 원소 정렬이 Tim Sort이고 Tim Sort는 Stable 하기 때문에 NUM이 같으면 IDX 오름차순이 보장이 된다는 것을 기억하자.
        
***

## [백준 1181번 - 단어 정렬](https://www.acmicpc.net/problem/1181)
---
* __정답의 최대치__      
> + $$1\leq N \leq20,000$$
> + int 범위면 충분

* __시간, 공간 복잡도 계산하기__
> + 배열정렬
>   + $$정렬은 \quad O\left(N \log N \right)$$
> + 배열 구하기
>   + $$순서대로 \; 읽으면 \quad O\left(N\right)$$  
> + 복잡도
>   + $$시간: \quad O\left(N \log N \right)$$
>   + $$공간: \quad O\left(N\right)$$  

* __구현__
~~~java
public class baekjoon1181 {


    static class Word implements Comparable<Word> {
        String name;

        public Word(String name) {
            this.name = name;
        }

        @Override
        public int compareTo(Word o) {

            if (this.name.length() != o.name.length()) {
                return this.name.length() - o.name.length();
            }

            return name.compareTo(o.name);
        }
    }


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());

        Word[] words = new Word[N];

        for (int i = 0; i < N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            words[i] = new Word(st.nextToken());
        }

        Arrays.sort(words);

        for (int i = 0; i < N; i++) {
            if (i == 0 || !words[i - 1].name.equals(words[i].name)) {
                System.out.println(words[i].name);
            }
        }
    }
}
~~~
***

## [백준 11652번 - 카드](https://www.acmicpc.net/problem/11652)
---
* __정답의 최대치__      
> + $$입출력 \; -2^{62} \sim 2^{62}$$
> + int 범위로는 감당이 안됨 long 사용해야함

* __시간, 공간 복잡도 계산하기__
> + 배열정렬
>   + $$정렬은 \quad O\left(N \log N \right)$$
> + Counting
>   + $$순서대로 \; 읽으면 \quad O\left(N\right)$$  
> + 복잡도
>   + $$시간: \quad O\left(N \log N \right)$$
>   + $$공간: \quad O\left(N\right)$$  


+ __구현__
  + HashMap을 이용하면 더 쉽게 풀 수 있지만 정렬의 특성을 이용해서 풀이해 봄
  + 같은 정보는 인접해 있다는 특성을 이용해서 풀이
  
~~~java
public class baekjoon11652 {


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());

        long[] numbers = new long[N];

        for (int i = 0; i < N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            numbers[i] = Long.parseLong(st.nextToken());
        }

        Arrays.sort(numbers);

        long mode = numbers[0];
        int modeCount = 1;
        int currentCount = 1; // mode: 최빈값, modeCount: 최빈값의 등장 횟수, currentCount: 현재 값(a[1])의 등장 횟수

        for (int i = 1; i < N; i++) {
            if (numbers[i - 1] == numbers[i]) {
                currentCount++;
            } else {
                currentCount = 1;
            }

            if (currentCount > modeCount) {
                mode = numbers[i];
                modeCount = currentCount;
            }
        }

        System.out.println(mode);

    }
}
~~~

        
***

## [백준 20291번 - 파일정리](https://www.acmicpc.net/problem/20291)
---
* __정답의 최대치__      
> + $$1\leq N \leq50,000$$
> + int 범위면 충분

* __시간, 공간 복잡도 계산하기__
> + 배열정렬
>   + $$정렬은 \quad O\left(N \log N \right)$$
> + 배열 구하기
>   + $$순서대로 \; 읽으면 \quad O\left(N\right)$$  
> + 복잡도
>   + $$시간: \quad O\left(N \log N \right)$$
>   + $$공간: \quad O\left(N\right)$$  

* __구현__
  
~~~java

public class baekjoon20291 {

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());

        String[] list = new String[N];

        for (int i = 0; i < N; i++) {
            String s = br.readLine();
            list[i] = s.split("\\.")[1];
        }


        Arrays.sort(list);

        StringBuilder sb = new StringBuilder();

        for (int i = 0; i < N; ) {
            
            int cnt = 1, j = i + 1;

            for (; j < N; j++) {
                if (list[j].compareTo(list[i]) == 0) {
                    cnt++;
                } else break;
            }

            sb.append(list[i]).append(" ").append(cnt).append("\n");

            i = j;
        }

        System.out.println(sb);

    }
}

~~~
***

## [백준 15970번 - 화살표 그리기](https://www.acmicpc.net/problem/15970)
---
* __정답의 최대치__      
> + $$점의\,개수\; N\leq50,000$$
> + $$0\leq점의 위치\leq10^5=100,000$$
> + $$0\leq점의\,색깔 \leq N$$
> + $$점두개\,\Rightarrow 2 \times 10^5 \,만큼의\,화살표\,길이\,색깔마다\,이런\,점들이\,있다면$$
>   + 총 5,000/2 쌍 만큼 만들 수 있음
>   + 즉 모든 점마다 10만 만큼의 길이를 갖는 화살표를 그리는 경우
>   + $$정답의\,최대치:\, 5,000 \times 100,000 = 5 \times 10^8  \, \Rightarrow \, Integer로\,계산해도\,충분$$

* __시간, 공간 복잡도 계산하기__
> + 색깔별로 모으기
>   + $$공간:\,ArrayList로 \quad O\left(N\right)$$  
> + 배열 정렬
>   + $$정렬은 \quad O\left(N \log N \right)$$
> + 정답 계산
>   + $$점마다\,좌우만\,보니깐 \quad O\left(N\right)$$  
> + 복잡도
>   + $$시간: \quad O\left(N \log N \right)$$
>   + $$공간: \quad O\left(N\right)$$  



+ __구현__
    + 각 원소마다, 가장 가까운 원소는 자신의 양옆 중에 있다는 특성을 이용해서 풀이

~~~java

public class baekjoon15970 {

    static int N;
    static ArrayList<Integer>[] lists;

    static int leftAdd(int color, int idx) {
        if (idx == 0) return Integer.MAX_VALUE;

        return lists[color].get(idx) - lists[color].get(idx - 1);

    }

    static int rightAdd(int color, int idx) {
        if (idx + 1 == lists[color].size()) return Integer.MAX_VALUE;
        return lists[color].get(idx + 1) - lists[color].get(idx);
    }

    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        N = Integer.parseInt(br.readLine());

        lists = new ArrayList[N + 1];

        for (int i = 1; i <= N; i++) {
            lists[i] = new ArrayList<Integer>();
        }

        for (int i = 1; i <= N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            int location = Integer.parseInt(st.nextToken());
            int color = Integer.parseInt(st.nextToken());

            lists[color].add(location);


        }

        int result = 0;

        for (int i = 1; i <= N; i++) {
            Collections.sort(lists[i]);
        }

        for (int i = 1; i <= N; i++) {
            for (int j = 0; j < lists[i].size(); j++) {
                int left = leftAdd(i, j);
                int right = rightAdd(i, j);

                result += Math.min(left, right);

            }

        }

        System.out.println(result);
    }
}
~~~
***
