# README

# automaton用のブランチです

automatonの設定をするときはここを編集します。
正直、もっといい方法があるとは思ってます。

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


# 各ディレクトリの説明

## bib

こちらは gist で管理しています。
[kisiyama/ref.bib](https://gist.github.com/kisiyama/0f615ecb4ec47c9cfdec60c62c22b5f1)
