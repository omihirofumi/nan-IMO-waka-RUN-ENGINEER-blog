---
date: '2025-02-27T00:28:13+09:00'
tags:
- にっぽー
title: 'にっぽー'
---
LeetCodeの[この問題](https://leetcode.com/problems/movie-rating/description/?envType=problem-list-v2&envId=rvchvayr)を↓で解いたけどどうなんだろうか。  
結合対象を減らすためにサブクエリでフィルタリングするようにしたけど、複雑になってしまった。  
<!--more-->
```sql
WITH RankedUsers AS (
    SELECT
        user_id,
        RANK() OVER (ORDER BY COUNT(user_id) DESC) AS rank
    FROM
        MovieRating
    GROUP BY user_id
),

RankedMovies AS (
    SELECT
        movie_id,
        RANK() OVER (ORDER BY AVG(rating) DESC) AS rank
    FROM
        MovieRating
    WHERE created_at BETWEEN '2020-02-01' AND '2020-02-29'   
    GROUP BY movie_id
),

temp AS (
    (
        SELECT
            U.name AS results
        FROM Users U
        INNER JOIN (
            SELECT user_id 
            FROM RankedUsers 
            WHERE rank = 1
        ) RU ON U.user_id = RU.user_id
        ORDER BY U.name
        LIMIT 1
    )
    UNION ALL
    (
        SELECT
            M.title AS results
        FROM Movies M
        INNER JOIN (
            SELECT movie_id 
            FROM RankedMovies 
            WHERE rank = 1
        ) RM ON M.movie_id = RM.movie_id
        ORDER BY M.title
        LIMIT 1
    )
)

SELECT results FROM temp
```
大量のデータ用意してテストしてみたい。  

ちなみに、人気のある回答は[これ](https://leetcode.com/problems/movie-rating/solutions/5788717/simple-solution-using-union-and-cte)みたい。  
自分で考えたのと、この回答の実行計画をClaude-3.7-sonnetに比較させてみた。
```markdown
### 実行速度の比較
- 1番目のクエリ: 実行時間 0.318ミリ秒 < 自分で考えたやつ
- 2番目のクエリ: 実行時間 1.486ミリ秒 < 人気のある回答

2番目のクエリは1番目のクエリの約4.7倍の時間がかかっていることがわかります。

### 主な違いと分析

1. **アプローチの違い**
   - 1番目のクエリはWITH句とRANK()ウィンドウ関数を使用
   - 2番目のクエリはサブクエリとGROUP BY + ソート + LIMITを使用

2. **実際のデータ処理**
   - どちらのクエリも2020年2月のデータがないため、映画部分は空の結果を返しています
   - 最終的な結果行数はどちらも1行（最も評価回数の多いユーザーのみ）

3. **メモリ使用**
   - 2番目のクエリはより多くのメモリを使用しています（例：HashAggregateで73kB）
   - しかし、データセットが小さいため、メモリ使用は問題になっていません

4. **行数の予測と実際**
   - 2番目のクエリは行数の予測が実際と大きく異なっています
   - 予測: users 1270行、実際: 5行
   - 統計情報の更新（ANALYZE）が必要かもしれません

### どちらが良いか？

**1番目のクエリ（WITH句とRANK()を使用したもの）の方が優れています**：

1. **実行速度**: 約5倍速い（0.318ms vs 1.486ms）
2. **SQLの明瞭さ**: ウィンドウ関数を使用することでランク付けの意図が明確
3. **効率性**: 少ないステップでより速く結果を生成
4. **スケーラビリティ**: データ量が増えた場合も効率的に動作する可能性が高い

実際の運用では、パフォーマンスの差は以下の要因によってさらに大きくなる可能性があります：
- データ量の増加
- 同時実行数の増加
- インデックスの活用（1番目のクエリはインデックスをより効率的に使用）

結論として、1番目のクエリ（WITH句とRANK()を使用した方）を採用することをお勧めします。より効率的で、意図も明確です。ただし、日付条件を実際のデータに合わせて調整する必要があります。
```
わーい。嬉しい。SQL苦手意識なくなってきた。


--- 

## いま読んでいる本
[ユーザーの問題解決とプロダクトの成功を導く　エンジニアのためのドキュメントライティング | ジャレッド・バーティ, ザッカリー・サラ・コ―ライセン, ジェン・ランボーン, デービッド・ヌーニェス, ハイディ・ウォーターハウス, 岩瀬 義昌 |本 | 通販 | Amazon](https://www.amazon.co.jp/%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E3%81%AE%E5%95%8F%E9%A1%8C%E8%A7%A3%E6%B1%BA%E3%81%A8%E3%83%97%E3%83%AD%E3%83%80%E3%82%AF%E3%83%88%E3%81%AE%E6%88%90%E5%8A%9F%E3%82%92%E5%B0%8E%E3%81%8F-%E3%82%A8%E3%83%B3%E3%82%B8%E3%83%8B%E3%82%A2%E3%81%AE%E3%81%9F%E3%82%81%E3%81%AE%E3%83%89%E3%82%AD%E3%83%A5%E3%83%A1%E3%83%B3%E3%83%88%E3%83%A9%E3%82%A4%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0-%E3%82%B8%E3%83%A3%E3%83%AC%E3%83%83%E3%83%89%E3%83%BB%E3%83%90%E3%83%BC%E3%83%86%E3%82%A3/dp/4800590833)

  
ユーザ（顧客だったりエンジニアだったり）が抱える問題を解決するためのドキュメントってことを強く意識しよう的な。  
「知識の呪い」についても理解しておくこと。
> 知識の呪い：自分が知っていることを他の人が知らないことを忘れてしまうこと
  
  
フリクションログはすぐにでも実践したい。  
→自分をユーザと見立てる。知識の呪いに注意する。
> フリクションログ：ユーザがアプリケーションを使う際にどのような問題に直面しているかを記録するログ


---
## Remix-Auth
Remix-Authと OAuth2で認証というか認可を実装したけどあんまりネットに情報が転がってなかったからZennに書くか。
