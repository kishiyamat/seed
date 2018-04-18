# cd ./paper/
cd chapters

# 各ファイルに行うしょりの図の大きさの修正
ls | grep '.md' | cat | while read md
do
  # base に名前を与えた状態からスタート
  base=$(echo $md | sed 's/\.[^\.]*$//' | cat)
  # pandoc で変換
  pandoc ${base}.md -o ${base}.tex
  # includegraphics の設定を編集
  sed -i 's/includegraphics/includegraphics[width=8.0cm]/g' ${base}.tex
  # sed -i 's/includegraphics/includegraphics[width=1.0\\columnwidth]/g' ${base}.tex
  # sed -i 's/includegraphics/includegraphics[scale=0.8]/g' ${base}.tex
  # tightlist や itemize、enumerateは言語学では使わない。
  # * で例文を作成。言語学者なら許される。
  # new line の潰し方
  # https://stackoverflow.com/questions/1251999/how-can-i-replace-a-newline-n-using-sed
  sed -i ':a;N;$!ba;s/\\tightlist//g' ${base}.tex
  sed -i 's/\\begin{itemize}/\\eenumsentence{/g' ${base}.tex
  sed -i 's/\\end{itemize}/}/g' ${base}.tex
done
cd ../
cd main
platex thesis.tex
platex thesis.tex
pbibtex thesis
platex thesis.tex
platex thesis.tex
dvipdfmx thesis.dvi
cd ../
