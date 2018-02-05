# 実験に使う4条件を合成
# リストを作ります。
# 順番を並び替えます。

clearinfo

# タグの init
s_n1$ = "N1_"
#s_npi$ = "NPI_"
s_npi_t$ = "NPI_t"
s_npi_f$ = "NPI_f"
s_break_1$ = "break_1"
s_v1$ = "V1_"
#s_v1_aff$ = "AFF_"
s_v1_aff_t$ = "AFF_t"
s_v1_aff_f$ = "AFF_f"
s_break_2$ = "break_2"
s_n2$ = "N2_"
s_break_3$ = "break_3"
s_v2$ = "V2_"
s_md$ = "MD_"

# 作業ディレクトリの設定
base_anim$ = "t/t08"
base_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/'base_anim$'/adjusted/"
list_name$ = "fileList"
Create Strings as file list: "'list_name$'", "'base_dir$'*.wav"

procedure getXfromYasZ: .i, .list_name$, .after$
  selectObject: "Strings '.list_name$'"
  Extract part: '.i', '.i'
  selectObject: "Strings '.list_name$'_part"
  Rename: "'.after$'"
endproc

# NPI + AFF +
@getXfromYasZ: 4, list_name$, "'s_n1$'"
#npi
@getXfromYasZ: 7, list_name$, "'s_npi_t$'"
@getXfromYasZ: 6, list_name$, "'s_npi_f$'"

@getXfromYasZ: 10, list_name$, "'s_break_1$'"
@getXfromYasZ: 8, list_name$, "'s_v1$'"
#aff_t
@getXfromYasZ: 2, list_name$, "'s_v1_aff_t$'"
@getXfromYasZ: 1, list_name$, "'s_v1_aff_f$'"

@getXfromYasZ: 11, list_name$, "'s_break_2$'"
@getXfromYasZ: 5, list_name$, "'s_n2$'"
@getXfromYasZ: 12, list_name$, "'s_break_3$'"
@getXfromYasZ: 9, list_name$, "'s_v2$'"
@getXfromYasZ: 3, list_name$, "'s_md$'"

selectObject: "Strings 's_n1$'"
plusObject: "Strings 's_npi_t$'"
plusObject: "Strings 's_npi_f$'"
plusObject: "Strings 's_break_1$'"
plusObject: "Strings 's_v1$'"
plusObject: "Strings 's_v1_aff_t$'"
plusObject: "Strings 's_v1_aff_f$'"
plusObject: "Strings 's_break_2$'"
plusObject: "Strings 's_n2$'"
plusObject: "Strings 's_break_3$'"
plusObject: "Strings 's_v2$'"
plusObject: "Strings 's_md$'"
Append

selectObject: "Strings appended"


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

# frag を出して自動で frag を持つオブジェクトを任意の名前で保存したほうがいい
# 死んで謝るべきコードの汚さ。

# データのインポート
clearinfo
base_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/'base_anim$'/adjusted/"
selectObject: "Strings appended"
filenum =  Get number of strings
printline 'filenum'
# NPI t, AFF t
for k to filenum
  if k != 3
    if k != 7
      printline 'k'
      selectObject: "Strings appended"
      soundname$ = Get string: k
      printline 'base_dir$''soundname$'
      Read from file: "'base_dir$''soundname$'"
    endif
  endif
endfor

# データのインポート
clearinfo
base_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/'base_anim$'/adjusted/"
selectObject: "Strings appended"
filenum =  Get number of strings
printline 'filenum'
# NPI f, AFF t
for k to filenum
  if k != 2
    if k != 7
      printline 'k'
      selectObject: "Strings appended"
      soundname$ = Get string: k
      printline 'base_dir$''soundname$'
      Read from file: "'base_dir$''soundname$'"
    endif
  endif
endfor

# データのインポート
clearinfo
base_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/'base_anim$'/adjusted/"
selectObject: "Strings appended"
filenum =  Get number of strings
printline 'filenum'
# NPI t, AFF f
for k to filenum
  if k != 3
    if k != 6
      printline 'k'
      selectObject: "Strings appended"
      soundname$ = Get string: k
      printline 'base_dir$''soundname$'
      Read from file: "'base_dir$''soundname$'"
    endif
  endif
endfor

# データのインポート
clearinfo
base_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/'base_anim$'/adjusted/"
selectObject: "Strings appended"
filenum =  Get number of strings
printline 'filenum'
# NPI f, AFF f
for k to filenum
  if k != 2
    if k != 6
      printline 'k'
      selectObject: "Strings appended"
      soundname$ = Get string: k
      printline 'base_dir$''soundname$'
      Read from file: "'base_dir$''soundname$'"
    endif
  endif
endfor



clearinfo
base_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/'base_anim$'/adjusted/"
Create Strings as file list: "fileList", "'base_dir$'*.wav"
selectObject: "Strings appended"
filenum =  Get number of strings
printline 'filenum'

for k to filenum
  printline 'k'
  selectObject: "Strings appended"
  soundname$ = Get string: 'k'
  ext$ = ".wav"
  i = index(soundname$, ext$)
  target$ = left$(soundname$,i-1)
  printline sound is 'soundname$'
  printline target is 'target$'
  selectObject: "Sound 'target$'"
  Copy: "'k'"
  printline 'k' is 'target$'
endfor

#AFF_f_tenai_adjusted.wav
#AFF_t_teiru_adjusted.wav
#MD_souda_adjusted.wav
#N1_cheetah_adjusted.wav
#N2_penguin_adjusted.wav
#NPI_f_dake_adjusted.wav
#NPI_t_sika_adjusted.wav
#V1_okot_adjusted.wav
#V2_nadamenakatta_adjusted.wav
#break_1_adjusted.wav
#break_2_adjusted.wav
#break_3_adjusted.wav
