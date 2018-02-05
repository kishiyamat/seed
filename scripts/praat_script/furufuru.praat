# infoウィンドウを初期化
clearinfo

# 音声等（src）があるディレクトリを変数に代入
dir_src$ = "D:\k\Desktop\Hawaii SSP\rec"
# 結果(rslt)が出力されるフォルダ名を変数に代入
dir_rslt$ = "D:\k\Desktop\Hawaii SSP\results"

# ファイル名を変数に代入
file_name$ = "171002_1100_subj02"

# 項目名を出力
; pitch_mean だとややこいからave(rage)で
column_name$ = "item,seg,seg_dur,pitch_ave,mitch_min,pitch_max'newline$'"
column_name$ > 'dir_rslt$'/'file_name$'.csv

# 音声ファイルの読み込み
Read from file: "'dir_src$'\'file_name$'.wav"
# テキストグリッドの読み込み
Read from file: "'dir_src$'\'file_name$'.TextGrid"

# オブジェクトの選択
selectObject: "TextGrid 'file_name$'"
# 第1層のインターバル数を変数に代入
int_num = Get number of intervals: 1

; ここでwavからピッチオブジェクトを作る。５秒のファイル程度で結構時間かかったたから、
; めっちゃ時間かかるかも？
selectObject: "Sound 'file_name$'"
To Pitch... 0.01 75 400
; http://user.keio.ac.jp/~kawahara/scripts/get_F0_Min_Max.praat

for i to int_num
    # オブジェクトの選択
    selectObject: "TextGrid 'file_name$'"
    # ラベルを取得し変数に代入
    seg_label$ = Get label of interval: 1, i

    if seg_label$ != ""

        # 開始時刻と終了時刻を取得し変数に代入
        seg_start = Get start time of interval: 1, i
        seg_end = Get end time of interval: 1, i

        # 分節音の継続長を計算し変数に代入
        seg_dur = seg_end - seg_start

        # Vと書かれた分節音の開始時刻を含む、第2層のインターバル番号を取得し変数に代入
        id_int = Get interval at time: 2, seg_start

        #　第2層でインターバル番号がid_intのインターバルのラベルを取得し変数に代入
        # (つまり単語のidを取得）
        id_label$ = Get label of interval: 2, id_int

        selectObject: "Pitch 'file_name$'"
        pitch_ave = Get mean: seg_start, seg_end, "Hertz"
        pitch_min = Get minimum: seg_start, seg_end, "Hertz", "Parabolic"
        pitch_max = Get maximum: seg_start, seg_end, "Hertz", "Parabolic"

        # 結果を変数に代入
        result$ = "'id_label$','seg_label$','seg_dur','pitch_ave','pitch_min','pitch_max','newline$'"
        # 変数に代入した結果をファイルに出力
        result$ >> 'dir_rslt$'/'file_name$'.csv
    endif
endfor
