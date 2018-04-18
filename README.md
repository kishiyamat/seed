# README

言語学の研究を出力するベースです。
実験系を想定しています。
thesis.tex と compile.sh をみれば察してもらえるかもしれません。

シンボリックリンクの張り方
1. 張る先のディレクトリに移動する
1. ln -s 張る先からみたディレクトリのパス/* .

これで bib, tex, style にある全てのファイルを main 下に張る。
新しいファイルが作られた場合は、もう一度同じコマンドでいい。
既にあるものは上書きされず、新しいファイルのみのリンクが生成される。


```shell
# pwd
# seed/paper/main

ln -sf ../latex/bib/* .
ln -sf ../latex/style/* .
ln -sf ../latex/tex/* .
```

という感じです。
