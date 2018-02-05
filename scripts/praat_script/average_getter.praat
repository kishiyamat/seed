# -*-coding utf-8-*-
# the grammars seem different from those on windows

clearinfo
# declare the src directry
src_dir$ = "/home/kishiyama/home/thesis/npi-thesis/src/sound/"

# read the sound

src_file$ = "cheetah.wav"
target_sound$ = "'src_dir$''src_file$'"
Read from file: "'target_sound$'"
# read the text
src_tg_file$ = "cheetah_penguin.TextGrid"
target_tg$ = "'src_dir$''src_tg_file$'"
Read from file: "'target_tg$'"

selectObject: "TextGrid cheetah_penguin"
n = Get number of intervals: 1

# 平均値を得るための init
n1 = 0
npi_t = 0
break_1 = 0
v1 = 0
v1_aff = 0
break_2 = 0
n2 = 0
break_3 = 0
v2 = 0
md = 0

# タグの init
s_n1$ = "N1_"
s_npi_t$ = "NPI_"
s_break_1$ = "break_1"
s_v1$ = "V1_"
s_v1_aff$ = "AFF_"
s_break_2$ = "break_2"
s_n2$ = "N2_"
s_break_3$ = "break_3"
s_v2$ = "V2_"
s_md$ = "MD_"
loop = 0

for i to n
  selectObject: "TextGrid cheetah_penguin"
  label$ = Get label of interval: 1, i
  start = Get starting point: 1, i
  end = Get end point: 1,i
  dur = end - start
  if "'label$'" != ""
    printline 'i','label$','dur'
    @xStartsWithY: "'label$'", "'s_n1$'"
      if result = 1
        n1 = n1 + 'dur'
        loop = loop + 1
      endif
    @xStartsWithY: "'label$'", "'s_npi_t$'"
      if result = 1
        npi_t = npi_t + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_break_1$'"
      if result = 1
        break_1 = break_1 + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_v1$'"
      if result = 1
        printline 'can you see me? v1'
        v1 = v1 + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_v1_aff$'"
      if result = 1
        printline 'can you see me?'
        v1_aff = v1_aff + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_break_2$'"
      if result = 1
        break_2 = break_2 + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_n2$'"
      if result = 1
        n2 = n2 + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_break_3$'"
      if result = 1
        break_3  = break_3  + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_v2$'"
      if result = 1
        v2 = v2 + 'dur'
      endif
    @xStartsWithY: "'label$'", "'s_md$'"
      if result = 1
        md = md + 'dur'
      endif
  else
    # 何もタグが無い場合
    printline
  endif
endfor

# 計算
n1 = n1/loop
npi_t = npi_t/loop
break_1 = break_1/loop
v1 = v1/loop
v1_aff = v1_aff/loop
break_2 = break_2/loop
n2 = n2/loop
break_3 = break_3/loop
v2 = v2/loop
md = md/loop

printline 'n1'  'tab$'n1
printline 'npi_t''tab$'npi_t
printline 'break_1''tab$'break_1
printline 'v1'  'tab$'v1
printline 'v1_aff''tab$'aff
printline 'break_2''tab$'break_2
printline 'n2'  'tab$'n2
printline 'break_3''tab$'break_3
printline 'v2'  'tab$'v2
printline 'md'  'tab$'md

procedure xStartsWithY: .x$, .y$
 if left$(.x$,length(.y$)) = .y$
  result = 1
  #printline yes
 else
  result = 0
  #printline no
 endif
endproc

#0.50  	n1
#0.40	  npi_
#0.15	  break_1
#0.45  	v1
#0.40	  aff_
#0.15	  break_2
#0.75  	n2
#0.15	  break_3
#1.00  	v2
#0.50	  md

# http://www.fon.hum.uva.nl/praat/manual/Formulas_5__String_functions.html
# 指定するために名前付けが必要

0.5956525800694354 seconds
