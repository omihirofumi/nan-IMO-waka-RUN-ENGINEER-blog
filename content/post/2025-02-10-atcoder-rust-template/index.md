---
date: '2025-02-10T22:00:28+09:00'
tags:
  - Rust
  - AtCoder
  - tool
  - 競プロ
title: 'AtCoderの問題をRustで解くための雛形リポジトリを作った'
---

AtCoderの問題をRustで解くときに、毎回環境を整えるのが面倒だったので、雛形リポジトリを作った。
[just](https://github.com/casey/just) を使って、新しい問題のディレクトリや `main.rs` をサクッと作れるようにしてる。

## リポジトリ
GitHub に置いてる。
➡ [atcoder-rust-base](https://github.com/omihirofumi/atcoder-rust-base)

## セットアップ
まず `just` をインストール。

```bash
cargo install just
```

## `justfile` の中身
`just new <問題番号>` でディレクトリとファイルを作って、`Cargo.toml` も更新してくれる。

```just
main_fn := """
fn main() {

}
"""

@new num:
  mkdir -p src/{{num}}
  touch src/{{num}}/main.rs
  echo "{{main_fn}}" > src/{{num}}/main.rs
  echo "[[bin]]" >> Cargo.toml
  echo 'name = "{{num}}"' >> Cargo.toml
  echo 'path = "src/{{num}}/main.rs"' >> Cargo.toml
```

## 使い方
新しい問題の雛形を作るには、

```bash
just new <問題番号>
```

例えば、`just new no001` を実行すると、こんな感じのディレクトリ構成になる。

```
src/
└── no001/
    └── main.rs
```

`main.rs` の中身はこんな感じ。

```rust
fn main() {

}
```

`Cargo.toml` にはこんなのが追記される。

```toml
[[bin]]
name = "no001"
path = "src/no001/main.rs"
```

## 実行方法
作成した `main.rs` を実行するには、

```bash
cargo run --bin <問題番号>
```

例えば、`no001` を実行するなら、

```bash
cargo run --bin no001
```

こんな感じで使える。


