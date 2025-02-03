---
date: '2025-02-03T19:36:53+09:00'
tags:
- prisma
- database
- tool
title: '`prisma migrate`の備忘録'
---
ORMの[Prisma](https://www.prisma.io/)でmigrateするときに毎度調べてる気がするので、メモしとく。

開発用DBの場合は、`prisma migrate dev`  
本番用DBの場合は、`prisma migrate deploy`  

### migrate devとmigrate deployの差分
`migrate dev`(開発用コマンド)だと↓が実行されちゃう
- スキーマ変更がある場合に新しいマイグレーションを作成
- リセットされるケースがある
    - マイグレーション履歴に不整合がある
    - 実際のデータベースのスキーマとマイグレーション履歴の最終状態が不一致

### まとめ
本番用DBに`migrate dev`しない！  
もしやっちゃうと、、  
- DBにマイグレーションしていないスキーマが実行されてしまう（スキーマファイルがマイグレーション履歴より進んでる場合）。
- イレギュラーな状態だとリセットされてデータが吹っ飛ぶ可能性がある。

