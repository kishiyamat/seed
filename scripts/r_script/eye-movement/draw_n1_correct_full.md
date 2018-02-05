# graph

## Analysis of gaze to N2

N2の分析。ターゲットへのゲイズを見る。

```R
#グラフの作成
#ディレクトリの確認から
getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main")

#ライブラリーとデータの読み込み
library(ggplot2)
library(reshape)
data_all <- read.csv("./csv/output.csv", header =T)

#digital化
#そのままではグラフ化ができない
#グラフの全体（土台）の時間軸の幅をここで決める。
#（複合名詞全体は約6000ms,一文字は約3000ms）
#comp_nounでまず20~6000msを20ms単位でbinのリストを作っておいて、
#それをカラム数にしてdataAllと同じ行数で行列bindataを作って後でdataAllの右側につっくけます。
# TODO: comp_noun は意味不明

# 最初の呈示   : 2000 ms

# n1         : 800 ms
# NPI        : 500 ms
# break      : 200 ms

# v1         : 600 ms

span_begin <- 2000
span_end <- 8000
# span_begin <- 4700
# span_end <- 6100

comp_noun <- seq(span_begin,span_end,20)

#comp_noun <- seq(4100,6100,20)
#comp_noun <- seq(4100,4900,20)
#comp_noun <- seq(2420,3540,20)
binary_data <- matrix(span_begin, nrow = nrow(data_all), ncol = length(comp_noun))
colnames(binary_data) <- comp_noun

# グラフの開始時点を揃える基準となる音声ファイルのonsetはここで決めます。
# 時間窓 20ms で見ていき、その区間を見続けていれば 1, 0 見ていなければ 0
# （MF01ではonset3がcritical regionです）
for (i in 1:length(comp_noun)){
    binary_data[,i] <- ifelse((data_all$GazeStart < (span_begin + i*20) & data_all$GazeEnd > (span_begin +i*20)),
        1,
        0)}

# Fixation1: 41~185ms
# Fixation2: 188~225ms

# ＜調整例＞
# 開始始時点が [0]
#   bindata[,i] <- ifelse((dataAll$GazeStart < (0 + i*20) & dataAll$GazeEnd > (0 +i*20)), 1, 0)
# 開始始時点が [onset2]
#   bindata[,i] <- ifelse((dataAll$GazeStart < (dataAll$onset2 + i*20) & dataAll$GazeEnd > (dataAll$onset2 +i*20)), 1, 0)

# 意味： この行のGazeStart~GazeEndの範囲の中でそのbinの数値（例：40ms）が入ってれば、1と表示する。
# [onset2 + i*20]にすれば、onset2が開始時点になって、それ以前の時間帯は見ないことになる。
# 例：i=0であれば、一行目からはonset2のその数値をGazeStart~GazeEndに当てはめることになる

gr <- cbind(data_all, as.data.frame(binary_data))　
#dataall(trial情報)とbindata（bin注視情報）と合併

# 数値であったAOIを文字に転換する
# AOI == 0 means looks to marginal area.
# TODO: BackGround は存在しうる。画面外にFixationすると、そうなる。
# ここ。ここでそれぞれのターゲットを変える。
# ただ、それは今ではない。
# 前にすすめる
gr$Target <- ifelse(gr$AOI == 1, as.character(gr$AOI1), "BackGround")
gr$Target <- ifelse(gr$AOI == 2, as.character(gr$AOI2), gr$Target)
gr$Target <- ifelse(gr$AOI == 3, as.character(gr$AOI3), gr$Target)
gr$Target <- ifelse(gr$AOI == 4, as.character(gr$AOI4), gr$Target)

#必要なコラムだけを取り出す
#participant,item, cond, AOI,Target,bin1500~3520
gr<- gr[,c(1, 9, 10, 15, ncol(gr), 16:(ncol(gr)-1))]

# melt time binaries into one column.
# grを立てにする。t20の時にAOI2に入っているのか。
gr2 <- melt(gr,id=c("ParticipantName", "ItemNo", "Condition", "AOI", "Target"))

gr2$variable <- as.numeric(as.character(gr2$variable))
#melt()かけたら、binaries が variable,入っているか(1/0)がvalueになる。
#ERRORは一度出たが、今回はでなかった。

#わかりやすいため並べ替えます
gr2 <- gr2[order(gr2$ParticipantName, gr2$ItemNo),]
#ERROR
#gr2$itemBがNullになってる。$ItmeNoBに変更。

#aggregate for each trial (participants x items)
gr3 <-aggregate(
    gr2$value,
    by = list(gr2$ParticipantName, gr2$ItemNo, gr2$Condition,  gr2$AOI, gr2$Target, gr2$variable),
    FUN = sum,
    na.rm = TRUE)
#Tobiiの記録の中で、一定の期間であるAOIが視野に入ったら一カウントされます。
#逆にその期間に視野に入ってないbinの部分には０と表記され、AOIが多く重複されています
#この式は一つのbinの中に重複のないように、AOIをaggregate()で消します。
#違う言い方だとすると、違う区間で111が入ったら、同じ行にまとめられます。

colnames(gr3) = c("subj","item","cond", "AOI", "variable", "bin","value")
gr3$AOI <- NULL
#必要がないコラムを削除

#そうすると、もう一回cast()でデータを開いて、TargetがNAのところを0に入れ替える

#ただし、最初から最後まで一回も見られたのないAOIはどうしてもカウントされません
#それがカウントされないと、比率の母数が正しく求められません
#（例：「6回提示の中にTargetが何回見られた」の中、「6回」が0だとしても正しく求められません）
gr.temp <- cast(gr3)
#cast()を実行すると、gr3の"variable"と"value"にしたがって自動的に分解してもらえます。ちょっと時間かかります
#(例：variableの"CompetitorCompound"などが横になって、"value"がその下に)

# 一回も出たことない Target　がNAになっているはずです。それを0に書き換えます。
# backgroud はそのまま
# 全てのターゲットは一回は出現するため、ここはスキップ
# gr.temp$BackGround <- ifelse(is.na(gr.temp$BackGround),0,gr.temp$BackGround)

# やっぱり名前にオペレーターは入れてはならない
# N1_V1_t :
# N1_V1_f :
# N2_V1_t :
# N2_V1_f :

gr.temp$A <- ifelse(is.na(gr.temp$A),0,gr.temp$A)
gr.temp$B <- ifelse(is.na(gr.temp$B),0,gr.temp$B)
gr.temp$C <- ifelse(is.na(gr.temp$C),0,gr.temp$C)
gr.temp$D <- ifelse(is.na(gr.temp$D),0,gr.temp$D)

#　他に見たい組み合わせも簡単にできるようにしておきます
#　gr.temp$Combined <- gr.temp$TargetCompound + gr.temp$CompetitorCompound
# gr.temp$IrrelevantCompound <- gr.temp$IrrelevantCompoundA + gr.temp$IrrelevantCompoundB

#　(t1) N1_V1_t (t2) N1_V1_f (t3) N2_V1_t (t4) N2_V1_f
# 画像の方
gr.temp$t1 <- gr.temp$A
gr.temp$t2 <- gr.temp$B
gr.temp$t3 <- gr.temp$C
gr.temp$t4 <- gr.temp$D
# gr.temp$correct <-

# これは「ちーたー」と「怒っている」が同じ節に入る解釈。
# [IP チーターしかおこっている] → A
# [IP チーターだけおこっている] → A
# [IP チーターしかおこってない] → A
# [IP チーターだけおこっている] → B
# でも、これだと予想が使いないよね。全部Aに対して、で良いんじゃない？
# 最初にガッとあがる予定。

# gr.temp$c <- ifelse((gr.temp$cond == "a" | gr.temp$cond == "b" | gr.temp$cond == "c"), gr.temp$A, gr.temp$B)

#aggregate for graph (Use t1~t4)
#グラフ作成ためのデータフレーム
gra <- aggregate(
    gr.temp$t1,
    by=list(gr.temp$bin, gr.temp$cond),
    mean)
colnames(gra) <- c("bin", "cond", "mean")

# TODO: 最適なグラフ
# 適切な形式で保存

#グラフ作成の本番
d = data.frame(t = c(2000 , 2800 , 3300 , 3500 , 4100, 4700 , 5500),
          region = c(""   , "N1" , "NPI", ""   , "V1", "POL", "N2"))
g.Combined.Region6000 <-
  ggplot(data=gra, aes(x=bin, y=mean, colour = cond))+
  # dで定義したtとregionで縦線を引きます。
  geom_vline(data=d, mapping=aes(xintercept=t), linetype=3, color="black") +
  geom_text(data=d, mapping=aes(x=t, y=0.6, label=region),
      size=5, angle=90, vjust=-0.4, hjust=0 , color="#222222", family="mono") +
      # size=7, angle=90, vjust=-0.4, hjust=0 , color="#444444", family="serif") +
  geom_line(aes(group=cond, color=cond)) +
  # geom_point(aes(group=cond, color=cond)) +
  scale_x_continuous("Time") +
  scale_y_continuous(limits=c(0,0.65), name="Proportion of looks to target N1") +
  scale_color_discrete("Condition") +
  theme(axis.title.y = element_text(size = 16)) +
  theme(axis.title.x = element_text(size = 20)) +
  theme(legend.title = element_text(size = 16)) +
  theme(legend.text = element_text(size = 20))+
  # theme_bw() +
  theme_classic()+
  ggtitle("Proportion of gaze to N1 doing V1"
)  
# 最初の呈示   : 2000 ms

# n1         : 800 ms
# NPI        : 500 ms
# break      : 200 ms


# v1         : 600 ms
#必要に応じて変えます　
#グラフ保存
ppi <- 600
g.Combined.Region6000
#画質をscreen上きれいに映すようにpixel=300ppiに設定
# png("../png/n2_target_full.png", width=12*ppi, height=6*ppi, res=ppi)
dev.copy(pdf, "../pdf/n1_v1_full.pdf")

# この一回表示するプロセスが必要らしい。
dev.off()
#もう一度グラフのオブジェクトを読み込みます#dev.off()で閉じないとファイルが保存されません　　
```
