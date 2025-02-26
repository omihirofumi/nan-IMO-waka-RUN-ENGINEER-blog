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


--- 

## いま読んでいる本
[ユーザーの問題解決とプロダクトの成功を導く　エンジニアのためのドキュメントライティング | ジャレッド・バーティ, ザッカリー・サラ・コ―ライセン, ジェン・ランボーン, デービッド・ヌーニェス, ハイディ・ウォーターハウス, 岩瀬 義昌 |本 | 通販 | Amazon](https://www.amazon.co.jp/%E3%83%A6%E3%83%BC%E3%82%B6%E3%83%BC%E3%81%AE%E5%95%8F%E9%A1%8C%E8%A7%A3%E6%B1%BA%E3%81%A8%E3%83%97%E3%83%AD%E3%83%80%E3%82%AF%E3%83%88%E3%81%AE%E6%88%90%E5%8A%9F%E3%82%92%E5%B0%8E%E3%81%8F-%E3%82%A8%E3%83%B3%E3%82%B8%E3%83%8B%E3%82%A2%E3%81%AE%E3%81%9F%E3%82%81%E3%81%AE%E3%83%89%E3%82%AD%E3%83%A5%E3%83%A1%E3%83%B3%E3%83%88%E3%83%A9%E3%82%A4%E3%83%86%E3%82%A3%E3%83%B3%E3%82%B0-%E3%82%B8%E3%83%A3%E3%83%AC%E3%83%83%E3%83%89%E3%83%BB%E3%83%90%E3%83%BC%E3%83%86%E3%82%A3/dp/4800590833)

  
ユーザ（顧客だったりエンジニアだったり）が抱える問題を解決するためのドキュメントってことを強く意識しよう的な。  
「知識の呪い」についても理解しておくこと。
> 知識の呪い：自分が知っていることを他の人が知らないことを忘れてしまうこと
  
  
フリクションログはすぐにでも実践したい。  
→自分をユーザと見立てる。知識の呪いに注意する。
> フリクションログ：ユーザがアプリケーションを使う際にどのような問題に直面しているかを記録するログ
