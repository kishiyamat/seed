# eye-tracking-lme

markdown-preview-plus を Atom に導入。
https://qiita.com/kouichi-c-nakamura/items/5b04fb1a127aac8ba3b0

eye-tracking の実験で得たデータを解析するためのスクリプト。

# Rules
* やっぱり名前にオペレーターは入れてはならない
* 相変わらず aggregate がわからない。
  * Splits the data into subsets, computes summary statistics for each, and returns the result in a convenient form.
  * aggregate:	(…を)集合する、集める、集団とする
  * filter みたいな機能を持っているらしい。
  * help("aggregate") でどうぞ

* 命名責任を放棄してはならない
* 関数化して例外処理を組み込みましょう
* 三項演算子は可読性を下げるため使わない
  * と思いきや、三項演算子を使わないと置き換えができない仕様
* インデントは4スペース
* 読めば分かる点はコメントをかかない。
* 変数はスネークケースで、関数とクラスはキャメルで、カラム名はアッパーキャメルケース
* code は syntax が似ている python 指定。
* データと、そのデータを使うロジックは、一つのクラスにまとめる
* 一つ一つのオブジェクトの役割は単純にする
* 複雑な処理は、オブジェクトを組み合わせて実現する
* [R の S4 クラス、メソッド入門](http://www.okadajp.org/RWiki/?S4%20クラスとメソッド入門)
* 最初に目的、最後に補足。
* x<-"chen_practice_New test_B_P001_Segment 1.tsv"
* 変数名はcamelCaseかsnake_caseで。

```bash
pandoc -V documentclass=ltjarticle -V geometry:margin=1in --number-sections --latex-engine=lualatex --filter pandoc-citeproc data-trimming.md -o data-trimming.pdf
```
ディレクトリじゃできないから、ちゃんと移ってから実行する

```bash
pandoc -V documentclass=ltjarticle -V geometry:margin=1in --number-sections --latex-engine=lualatex --filter pandoc-citeproc head-entity-ratio.md -o head-entity-ratio.pdf
```
