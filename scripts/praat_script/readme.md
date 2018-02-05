# rules
* indent は４半角スペース
* procedure 内の変数は"."をつけてローカルにする
* 基本的にGUIの操作の補助を想定する。そちらのほうが、使いやすいしイメージしやすいから。

# flow
まず４条件を録音する
TTTH（ライオン）は気持ち低め
TTTL（チーター）は気持ち高め

録音した中から、以下のタグでまともそうな音を保存していく。
テキストグリッドを作るときは、アノテート、サイレンス、で。
グリッドを振るときに以下のルールに従うと楽ぞ。
s_n1$ = "N1_"
s_npi$ = "NPI_"
s_break_1$ = "break_1"
s_v1$ = "V1_"
s_v1_aff$ = "AFF_"
s_break_2$ = "break_2"
s_n2$ = "N2_"
s_break_3$ = "break_3"
s_v2$ = "V2_"
s_md$ = "MD_"

adjust_length.praat を走らせて、adjustされた音のデータを取得する。
saveSelected.praat を走らせて、全て保存する
