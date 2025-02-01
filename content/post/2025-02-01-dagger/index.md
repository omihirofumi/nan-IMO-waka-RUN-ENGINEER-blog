---
title: Daggerっていうリリースパイプラインを作って実行するツール触った
date: 2025-02-01
tags: ["cicd", "tool", "messing garound "]
---
[Dagger](https://dagger.io/)っていうリリースパイプラインをYamlとかじゃなくてコードで記述するツールを知ったので試してみる。
公式の[Quickstart](https://docs.dagger.io/quickstart/daggerize)をやってみた。

Go, Python, TypeScriptで記述できて今回は久しぶりだしGoで書いた。

```go
package main

import (
	"context"
	"fmt"
	"math"
	"math/rand"

	"dagger/hello-dagger/internal/dagger"
)

type HelloDagger struct{}

// Publish the application container after building and testing it on-the-fly
func (m *HelloDagger) Publish(ctx context.Context, source *dagger.Directory) (string, error) {
	_, err := m.Test(ctx, source)
	if err != nil {
		return "", err
	}
	return m.Build(source).
		Publish(ctx, fmt.Sprintf("ttl.sh/hello-dagger-%.0f", math.Floor(rand.Float64()*10000000))) //#nosec
}

// Build the application container
func (m *HelloDagger) Build(source *dagger.Directory) *dagger.Container {
	build := m.BuildEnv(source).
		WithExec([]string{"npm", "run", "build"}).
		Directory("./dist")
	return dag.Container().From("nginx:1.25-alpine").
		WithDirectory("/usr/share/nginx/html", build).
		WithExposedPort(80)
}

// Return the result of running unit tests
func (m *HelloDagger) Test(ctx context.Context, source *dagger.Directory) (string, error) {
	return m.BuildEnv(source).
		WithExec([]string{"npm", "run", "test:unit", "run"}).
		Stdout(ctx)
}

// Build a ready-to-use development environment
func (m *HelloDagger) BuildEnv(source *dagger.Directory) *dagger.Container {
	nodeCache := dag.CacheVolume("node")
	return dag.Container().
		From("node:21-slim").
		WithDirectory("/src", source).
		WithMountedCache("/root/.npm", nodeCache).
		WithWorkdir("/src").
		WithExec([]string{"npm", "install"})
}
```
こういう感じで記述してくみたい。

`Publish`を実行するには、`dagger call publish --source=.`とすればいい。  
メソッド名をスネークケースにしたものを`dagger call`の引数にしたら、そのメソッドが実行できる。  
なので、`BuildEnv`メソッドを呼びたい時は`dagger call build-env --source=.`  
今回はローカルで試しているけど、CI上でも実行できる。


UIも用意されていて、[Dagger Cloud](https://dagger.cloud/)で実行結果のトレースが見れる。

{{< figure src="dagger-cloud.png" alt="Dagger CloudのUI" >}}


[Daggerverse](https://daggerverse.dev/)に他の人が開発した`Dagger関数`があるのでそれを利用することもできる。

## 感想
Cloud Buildのプログラミング版ってイメージかな？  
たしかに、開発者としてプログラミングしていってパイプライン作れるのは便利かも。DevOpsっぽいね。  
あと他の人の車輪を利用できるのも嬉しい。  
ローカルでCIが確認できるのも嬉しい。  

ただ、慣れてないだけかもしれないけど、こういうパイプラインは`YAML`のが宣言的で見やすい気がする。  


そういえば、
[ttl.sh](https://ttl.sh/)って初めて知ったな。
```go
	return m.Build(source).
		Publish(ctx, fmt.Sprintf("ttl.sh/hello-dagger-%.0f", math.Floor(rand.Float64()*10000000))) //#nosec

```
