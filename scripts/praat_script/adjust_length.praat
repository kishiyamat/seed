# -*- coding=utf-8 -*-

# input: ディレクトリ名
# output: null
# global: base_dir$
procedure declareDirectory: .target_dir$
    # 基礎ディレクトリ(original)の宣言
    #.
    #└── sound
    #    ├── f
    #    └── t
    #        ├── t01
    #        │   ├── adjusted
    #        │   └── original
    base_anim$ = "t/t20/"
    sound_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/"
    base_dir$ = "'sound_dir$''base_anim$''.target_dir$'/"
endproc

# 使用されるタグをイニシャライズします。
procedure tagInit:
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
    loop = 0
endproc

# 各文節の長さをイニシャライズします。
# ちょっと短すぎるらしいのでここ調整してメール
# 今日の文が before で、変更の文もメールする
# どういう音素が含まれているかも
procedure lenInit:
    l_n1 = 0.80
    l_npi = 0.50
    l_break_1 = 0.2
    l_v1 = 0.60
    l_aff = 0.60
    l_break_2 = 0.001
    l_n2 = 1.00
    l_break_3 = 0.2
    l_v2 = 0.85
    l_md = 0.001
endproc

# if x starts with y, return 1. else, 0
procedure xStartsWithY: .x$, .y$
    if left$(.x$,length(.y$)) = .y$
        result = 1
        #printline yes
    else
        result = 0
        #printline no
    endif
endproc

# 選択されているオブジェクトの長さを変更します。
# "選択されているオブジェクト_adjusted" を作成します。
procedure changeDurationTo: .after
    # ベースの名前を取得する
    .name$ = selected$ ("Sound", 1)
    # ターゲットの持続時間を取得する
    selectObject: "Sound '.name$'"
    .before = Get total duration
    # "adjust" という名前の duration tier を作って編集開始
    Create DurationTier: "adjust", 0, '.before'
    # 逆数を DurationTier に置く
    Add point: 0.000, '.after' / '.before'
    Add point: '.before', '.after' / '.before'
    # Manipulation object を作り、さっきの DurationTier とマージする。
    selectObject: "Sound '.name$'"
    To Manipulation: 0.01, 75, 600
    selectObject: "DurationTier adjust"
    plusObject: "Manipulation '.name$'"
    Replace duration tier
    selectObject: "Manipulation '.name$'"
    Get resynthesis (overlap-add)
    # adjustで調節したのを置き換える
    selectObject: "Sound '.name$'"
    Rename: "'.name$'_adjusted"
    # いらないファイルを消す
    selectObject: "Sound '.name$'"
    plusObject: "DurationTier adjust"
    plusObject: "Manipulation '.name$'"
    Remove
    # reference
    # http://www.fon.hum.uva.nl/praat/manual/Scripting_4_3__Querying_objects.html
endproc

# 変数名 z$ に代入する
procedure extractXfromYasZ: .x$, .y$, .return$
  .i = index(.y$, .x$)
  '.return$'$ = left$(.y$, .i-1)
endproc
#######################
#~program starts here~#
#######################

# main()
clearinfo
# タグの init
@tagInit
# 長さのinit
@lenInit
# 基礎ディレクトリ (base_dir$) の宣言 (original)
@declareDirectory: "original"
# 基礎ディレクトリ (base_dir$) から.wavの "Strings fileList" を作る
Create Strings as file list: "fileList", "'base_dir$'*.wav"
# リスト内 (.wav) で for を回します
selectObject: "Strings fileList"
filenum =  Get number of strings
# 各ファイルで操作する
for k to filenum
    # 対象のファイルを選択するまで
    ## ディレクトリにあるk番目のファイル名を取得する
    selectObject: "Strings fileList"
    soundname$ = Get string: k
    ## base_dir$ にある soundname$ を読み込む
    Read from file: "'base_dir$''soundname$'"
    ## 読み込んだファイルは .wav がついていない。
    ## 選択するためには、読み込んだファイル名から".wav"を引いた名前で選択する必要がある
    @extractXfromYasZ: ".wav", "'soundname$'", "target"
    # 選択したサウンドファイルの長さを変更する
    selectObject: "Sound 'target$'"
    dur = Get total duration
    # もし ターゲットの名前が任意のタグ (tagInit[x]) で始まっているなら、
    # 任意の長さ (lenInit) に直す
    @xStartsWithY: "'target$'", "'s_n1$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_n1'
    endif
    @xStartsWithY: "'target$'", "'s_npi$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_npi'
    endif
    @xStartsWithY: "'target$'", "'s_break_1$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_break_1'
    endif
    @xStartsWithY: "'target$'", "'s_v1$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_v1'
    endif
    @xStartsWithY: "'target$'", "'s_v1_aff$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_aff'
    endif
    @xStartsWithY: "'target$'", "'s_break_2$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_break_2'
    endif
    @xStartsWithY: "'target$'", "'s_n2$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_n2'
    endif
    @xStartsWithY: "'target$'", "'s_break_3$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_break_3'
    endif
    # v2 だけはそのままでいいよもう。
    @xStartsWithY: "'target$'", "'s_v2$'"
    if result = 1
        selectObject: "Sound 'target$'"
        dur = Get total duration
        @changeDurationTo:'dur' * 1.1
    endif
    @xStartsWithY: "'target$'", "'s_md$'"
    if result = 1
        selectObject: "Sound 'target$'"
        @changeDurationTo:'l_md'
    endif
endfor
