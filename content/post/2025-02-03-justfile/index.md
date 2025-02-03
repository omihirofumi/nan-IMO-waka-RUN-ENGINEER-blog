---
date: '2025-02-03T23:29:52+09:00'
tags:
- tool
title: 'justっていうmakeみたいなやつ'
---
[just](https://github.com/casey/just)は`make`コマンドをいろいろ改善したRust制のツール。  

使い方は`make`とほぼ一緒  
`justfile`を用意して、`just <RECIPE>`


例えば
```just:justfile
alias n := new
new name:
  @hugo new --kind post post/{{datetime("%Y-%m-%d")}}-{{name}}/index.md
```
↑このブログの投稿を作成する時のコマンドを`just new`で実行できるように設定してみた。  
`hugo new "test"` or `hugo n "test`を実行すると、`hugo new --kind post post/2025-02-03-test/index.md`が実行される。

`env`をロードしたりもできるみたい。  
バリバリ使うことはないと思うけど、`make`じゃなくて`just`をしばらく使ってこ。




