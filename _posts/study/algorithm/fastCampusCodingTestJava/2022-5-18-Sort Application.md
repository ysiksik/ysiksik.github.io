---
layout: post
bigtitle: '알고리즘 유형별 문제풀이'
subtitle: 02.다양한 정렬 응용법 (Sort Application)
date: '2022-5-18 11:45:51 +0900'
categories:
    - study
    - algorithm
    - fastcampus-codingtest-java
comments: true
tags: fastcampusAlgorithm
# related_posts:
#     - 
---

# [Part3 Ch02 알고리즘] 02.다양한 정렬 응용 (Sort Application)

# 다양한 정렬 응용 (Sort Application)
* toc
{:toc}

## 핵심
---
+ 조건
  + 정렬 조건이 필요.
    > + Comparable
    >   + Return 음수 : 내 가 먼저
    >   + Return 양수 : 쟤(other) 가 먼저
    >   + Return 0 : 같음
  + 시간 복잡도는 약 O(N log N)
    > + JAVA 의 정렬
    >   + Object 원소 정렬이 항상 좋은거 아니냐?
    >     +  In-place Sort 가 아니라서 오래 걸릴 수 있음

    > | Primitive 원소 정렬 | Object 원소 정렬 |
    > | --- | ---|
    > | Dual-Pivot Quick Sort | Tim Sort (selection sort 와 merge sort 가 석여서 사용)|
    > | 최선 $$O\left(N\right)$$ | 최선 $$O\left(N\right)$$  |
    > | 최악 $$O\left(N^M\right)$$ | 최악 $$O\left(N \log N \right)$$ |
    > | 평균 $$O\left(N \log N \right)$$ | 평균 $$O\left(N \log N \right)$$ |

  + In-place / Stable 여부를 알아야 한다.
    > + 정렬 알고리즘이 In-place(제자리) 한가?
    >   + 정렬 하는 과정에서 N 에 비해 충분히 무시할 만한 개수의 메모리만큼만 추가적으로 사용하는지.
    > + 정렬 알고리즘이 Stable(안정) 한가?
    >   + 동등한 위상의 원소들의 순서 관계가 보존되는지.

    > | Primitive 원소 정렬 | Object 원소 정렬 |
    > | --- | ---|
    > | Dual-Pivot Quick Sort | Tim Sort (selection sort 와 merge sort 가 석여서 사용)|
    > | 평균 $$O\left(N \log N \right)$$ | 평균 $$O\left(N \log N \right)$$ |
    > | In-place Sort | Stable Sort |

+ 특성
  + 같은 정보들은 인접해 있다.
  + 각 원소 마다, 가장 비슷한 순서의 다른 원소는 자신의 양 옆이다.
  + 정렬만 해도 쉽게 풀리는 문제가 많다.

***

## [백준 10825번 - 국영수](https://www.acmicpc.net/problem/10825)
---

> + $$N\leq100,000$$
> + $$1 \leq 모든 점수 \leq 100 \quad Integer로 충분$$
> +  $$정렬만 하니깐 \quad O\left(N \log N \right)$$
>   + $$N \log N \leq 100,000 \log 100,000 = 1,600,000 \quad 1초가능$$

~~~java
public class baekjoon10825 {

    static class SubjectScore implements Comparable<SubjectScore> {
        String name;
        int language;
        int english;
        int mathematics;

        public SubjectScore(String name, int language, int english, int mathematics) {
            this.name = name;
            this.language = language;
            this.english = english;
            this.mathematics = mathematics;
        }

        @Override
        public int compareTo(SubjectScore o) {

            if (language != o.language) return o.language - language;
            if (english != o.english) return english - o.english;
            if (mathematics != o.mathematics) return o.mathematics - mathematics;
            return name.compareTo(o.name);
        }
    }


    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));

        int N = Integer.parseInt(br.readLine());
        SubjectScore[] subjectScoresList = new SubjectScore[N];

        for (int i = 0; i < N; i++) {
            StringTokenizer st = new StringTokenizer(br.readLine(), " ");
            subjectScoresList[i] = new SubjectScore(st.nextToken(), Integer.parseInt(st.nextToken()), Integer.parseInt(st.nextToken()), Integer.parseInt(st.nextToken()));
        }

        Arrays.sort(subjectScoresList);

        for (SubjectScore subjectScore : subjectScoresList) {
            System.out.println(subjectScore.name);
        }

    }
}
  ~~~
***
