alias n := new
new name:
  @hugo new --kind post post/{{datetime("%Y-%m-%d")}}-{{name}}/index.md

run:
  @hugo serve
