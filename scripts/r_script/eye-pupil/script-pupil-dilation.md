# eye-tracking-lme

2017-01-19 TobiiRScripts  
written by Arai, Chen  
modified by Kishiyama

# 目的

**Tobii TX300** + **Tobii Extension** で計測した瞳孔データを分析する。
驚きを反映するのか、処理負荷を反映するのか。
処理負荷を反映する、という論文を参考にする。

# 概要

0. 環境の設定
1. data trimming
1. graph
1. LME
1. permutation analysis


# 0. 環境設定

データの読み込みの際に適切なディレクトリにいることを確認する。

```R
getwd()
# setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pupil")
setwd("C:/Users/岸山/Documents/GitHub/npi-thesis/result/main4pupil")
```

# 1. data trimming

ディレクトリの中身を確認する。  
![中身の確認](media/image1.png)


## 1.1. ファイルリスト

処理を一度に行うために、ファイルリストを作成する。  
![ファイルリスト](media/image2.png)  
眼球運動データは Tobii Studio から吐き出す際、
project名＋test名＋被験者名＋segment名で自動保存される。
パターンを指定してリスト data_list に読みこむ。

```R

file_pattern <- "npi_2017_New test"
data_list <- list.files(pattern = file_pattern)

if (length(data_list) == 0){
    print('you might want to make some changes')
    # もし一つも読み込めていなかったら file_pattern かパスがおかしい
}else{
    print('loaded')
}

# データの数を確認
# print(length(data_list))

# 個別のファイルを試に確認。
# print(data_list[1])
```


## 1.2. 瞳孔の情報が入ってないデータを取り除く


取り除くべきファイルを取り除かないと、エラーが吐かれる。
この点に例外処理を行いたい。可読性を下げない範囲で。
あるいは、main の前にもう一度チェックするとか。関数化して。
これは、ただファイル名を返すだけ。
問題がなければ、次に進んでよし。

```R
# data_list に対して以下の動作を繰り返し実行する。

# init the number of bad trials
bad_trials = 0
# file_name <- data_list[1]
# trial[(trial$GazeEventType == "Fixation") & (is.na(trial$PupilRight)),]
# trial[(trial$GazeEventType == "Saccade") & (!(is.na(trial$PupilRight))),]
# fixation だけでなく、saccadeのデータもある。

# TODO: Fixation以外も記録するのか記録しない

for(file_name in data_list){

file_name = data_list[1]
    trial <- read.table(file_name, head=T, sep="\t", na.string="NA", encoding="UTF-8")
    # PupilLeft と PupilRight にデータが入っているデータを取得する。
    dilation_in_trial <- trial[ (!(is.na(trial$PupilLeft))) & (!(is.na(trial$PupilRight))),]
    if (nrow(dilation_in_trial) == 0){
        print(paste("Bad trial!", file_name))
        bad_trials = bad_trials + 1

    }
}
if (bad_trials == 0){
    print("there's no bad trial!")
}
```


## 1.3. 全員分のデータを一つのファイルにまとめる


一つのファイルに対する作業

0. ファイル名を読み込んで data.frame を返す。
1. data.frame を入力に、Timestampを加えたり、カラムを削ったりの修正を行った data.frame を返す。
1. data.frame を入力に、同じFixationになっている時間帯を一つの行にまとめる。
1. E-prime情報を区切ってdata_with_gaze_flagの右側に(StudioEventDataの隣から)マッピングする。

以上の関数を順番にfor文で全てのファイルに適用します。


### 1.3.1. 必要な関数を定義


0. ファイル名を読み込んで data.frame を返す関数の定義


```R

# object: ファイル名を読み込んで data.frame を返す
# input ： string
    # name of the file
# return: data.frame
    #[1] "ParticipantName"        "SegmentName"            "SegmentStart"           "SegmentEnd"             "SegmentDuration"        "RecordingTimestamp"    
    #[7] "StudioEvent"            "StudioEventData"        "FixationIndex"          "SaccadeIndex"           "GazeEventType"          "GazeEventDuration"     
    #[13] "FixationPointX..MCSpx." "FixationPointY..MCSpx." "PupilLeft"              "PupilRight"             "X"
# error: "encoding="UTF-8"指定、 "na.string"で空欄にNAを挿入。    

getDataFrameFromFileName <- function(file_name){
    data_frame <- read.table(file_name, head=T, sep="\t", na.string="NA", encoding="UTF-8")
    return(data_frame)
}
```


1. data.frame を入力に、Timestamp を加えたり、StudioEventData を削ったりの修正を行った data.frame を返す関数の定義


```R

# object: data.frameの 一次整形
# input : data.frame
    # ParticipantName, SegmentName,
        # SegmentStart, SegmentEnd, SegmentDuration, RecordingTimestamp, StudioEvent, StudioEventData,
    # FixationIndex,
        # SaccadeIndex,
    # GazeEventType, GazeEventDuration
    # FixationPointX..MCSpx., FixationPointY..MCSpx.,
        # PupilLeft, PupilRight, X
# return : data.frame
    # ParticipantName, SegmentName,
    # FixationIndex,
    # GazeEventType, GazeEventDuration,
    # FixationPointX FixationPointY
    # Timestamp
    # TODO 結局 Timestamp ってなに？
# error
    # TODO　この関数に例外処理をあてます
    # undefined columns selected が順当かと。

refineRawDataFrame <- function(raw){

    selected_column <- raw[,c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX..MCSpx.", "FixationPointY..MCSpx.", "PupilLeft", "PupilRight")]

    renamed_column <- NULL
    colnames(selected_column) <- c("ParticipantName", "SegmentName", "SegmentStart", "SegmentEnd", "SegmentDuration",
        "RecordingTimestamp", "FixationIndex", "SaccadeIndex", "GazeEventType", "GazeEventDuration",
        "FixationPointX", "FixationPointY", "PupilLeft", "PupilRight")
    renamed_column <- selected_column

    # 反応時間の間隔を算出。
    # SegmentStart: trialの開始点
    # RecordingTimestamp: recording point の時間点
    column_with_timestamp <- NULL
    renamed_column$Timestamp <- renamed_column$RecordingTimestamp - renamed_column$SegmentStart
    column_with_timestamp <- renamed_column

    # いらないカラムを削除(2回目)
    # TODO ~~SegmantStart, SegmentEnd, SegmentDuration, RecordingTimestamp, PupilLeft, PupilRight~~
    selected_column <- column_with_timestamp[,c("ParticipantName", "SegmentName",
        "PupilLeft", "PupilRight", "Timestamp")]

    # NA でない列のみ抽出する。
    selected_column <- selected_column[ (!(is.na(selected_column$PupilLeft))) &
        (!(is.na(selected_column$PupilRight))),]

    refined_column <- selected_column
    return(refined_column)
}
```

2. E-prime情報を区切ってdata_with_gaze_flagの右側に(StudioEventDataの隣から)マッピングします。


```R

# input1： string
    # name of the file
# input2:data.frame(with StudioEventData)
    #[1] "ParticipantName"        "SegmentName"            "SegmentStart"           "SegmentEnd"             "SegmentDuration"        "RecordingTimestamp"    
    #[7] "StudioEvent"            "StudioEventData"        "FixationIndex"          "SaccadeIndex"           "GazeEventType"          "GazeEventDuration"     
    #[13] "FixationPointX..MCSpx." "FixationPointY..MCSpx." "PupilLeft"              "PupilRight"             "X"
# input3: integer
    # number of columns
# return: data.frame (with E-prime情報)
    #[1] "ParticipantName"   "SegmentName"       "FixationIndex"     "GazeEventType"     "GazeEventDuration" "FixationPointX"    "FixationPointY"    "GazeStart"           
    #[9] "GazeEnd"              "StudioEventData"   "ListNo"            "Condition"         "ItemNoA"           "ItmeNoB"           "C1Type1"           "C1Type2"          
    #[17] "C2Type1"           "C2Type2"           "SoundType"         "TrialOrFiller"     "Picture"           "Sound"             "CorrectAnswer"     "AOI1"             
    #[25] "AOI2"              "AOI3"              "AOI4"              "AOI5"              "AOI6"              "AOI7"              "AOI8"              "TypeTag1"         
    #[33] "TypeTag2"          "TypeTag3"          "TypeTag4"          "TypeTag5"          "TypeTag6"          "TypeTag7"          "TypeTag8"          "LocationTag1"     
    #[41] "LocationTag2"      "LocationTag3"      "LocationTag4"      "LocationTag5"      "LocationTag6"      "LocationTag7"      "LocationTag8"

addStudioEventData <- function(file_name, data_with_gaze_flag, numcol) {
    # E-prime から Tobii に送る信号は StudioEventData に記録される
    # それを取り出して別の object にしておいて後で区切ｒｙ
    # str と　int　の　2 levels となる。
    # excel などだと2行目だが、head=T で読んでいるので1行目は head 扱い。
    raw_data_frame <- getDataFrameFromFileName(file_name)
    eventdata <- raw_data_frame[1,]$StudioEventData

    #文字形式（Factorでも数値でもない）に変換して data_with_gaze_flag に加える
    data_with_gaze_flag$StudioEventData <- as.character(eventdata)
    # ここでaddしたStudioEventDataはnullしないの？ ←次のステップでします。

    # E-prime情報を空白で区切ってlistにまとめる。
    # うまくデータが読み込めているかを確認するための unlist
    list_of_eventdata <- unlist(strsplit(data_with_gaze_flag$StudioEventData, " "))

    # list　の行数が numcol の倍数でければエラー。
    # numcol = 8
    if (length(list_of_eventdata)/numcol != nrow(data_with_gaze_flag)) {
        print(paste("Bad trial!", file_name))
    }

    # matrix()関数を使って、一列しかなかった list を8ずつ切って横にして、表にします。
    mat <- matrix(list_of_eventdata , nrow = nrow(data_with_gaze_flag), ncol = numcol, byrow=T)
    mat <- as.data.frame(mat)

    #matにコラム名を付け加えます。
    colnames(mat) <- c("hoge", "piyo", "ItemNo", "Condition",
        "AOI1", "AOI2", "AOI3", "AOI4")  

    #temp2(Tobii)とmat(E-prime)を合併します。
    data_with_eventdata <- cbind(data_with_gaze_flag, mat)

    return(data_with_eventdata)
}
```

### 1.3.2. 実行部分

tempを使わないように書き換える。

```R

#initialize

#必要なpackage #cast(), melt()などデータの分解、横/縦立て直し
library(reshape)

#処理した全員分のデータをループ式で足していく
data_all <- NULL

# E-prime から Tobii に送る信号の項目数を先に指定しておく。
# 実験デザイン時に必要な項目を指定する
numcol = 8
    #実際には36項目だけど、36項目がまとまった StudioEventData というカラムも足して37
    #Tobiiから吐き出したtextファイルの中StudioEvent欄を回収する。
    #実験内容に応じてコラム数を変更する必要がある。
    #("list", "trial", "itemA", "itemB", "cond",
    #"AOI1", "AOI2", "AOI3", "AOI4", "AOI5", "AOI6", "AOI7", "AOI8"…..))

# すでにデータがないファイルは削除済みであることを想定している。
file_pattern <- "npi_2017_New test"
data_list <- list.files(pattern = file_pattern)

# n = 1
for(n in 1:length(data_list)){
    #何ファイル目を処理しているかをプリントする。
    print(paste("now access to", n))
    # バグが出たらどこで止まっているのかたどり着くことができる。
    # 関数を呼び出すごとに例外処理したい。したくない？

    # 0
    # ファイル名を読み込んで data.frame を返す
    raw_data_frame = getDataFrameFromFileName(data_list[n])

    # 1
    # data.frameの 一次整形
    refined_data_frame = refineRawDataFrame(raw_data_frame)
    #print(head(refined_data_frame, 10))

    # 3
    # E-prime情報を区切って data_with_gaze_flag の右側にマッピングします。
    data_with_eventdata = addStudioEventData(data_list[n],refined_data_frame, numcol=8)

    # できたデータを一人分ずつdata_allの下から付け加える。
    # 一つにつき２０００近いデータがある。
    data_all <- rbind(data_all, data_with_eventdata)
}
```

## 1.4. 注視点のXY座標をAOIにマッピングする

AOIにマッピングして保存

```R

# グローバル変数に data_all がある状態。

# 1080*1920の画面を８分割にする。
#  1  2
#  3  4
# TODO ここでなぜか 0 が起きている
# -1 と振られた奴が。
data_all$AOI <- ifelse(data_all$FixationPointX >= 0 & data_all$FixationPointX < 960
    & data_all$FixationPointY >= 0 & data_all$FixationPointY < 540,
    1,
    0)
data_all$AOI <- ifelse(data_all$FixationPointX >= 960 & data_all$FixationPointX < 1920
    & data_all$FixationPointY >= 0 & data_all$FixationPointY < 540,
    2,
    data_all$AOI)
data_all$AOI <- ifelse(data_all$FixationPointX >= 0 & data_all$FixationPointX < 960
    & data_all$FixationPointY >= 540 & data_all$FixationPointY < 1080,
    3,
    data_all$AOI)
data_all$AOI <- ifelse(data_all$FixationPointX >= 960 & data_all$FixationPointX < 1920
    & data_all$FixationPointY >= 540 & data_all$FixationPointY < 1080,
    4,
    data_all$AOI)

#Fixationだけを残す。Saccadeのデータも削除（XY軸の情報がない）。
# この段階ですでに GazeEventType が落ちているようにみえるけど。
data_with_fixation <-data_all[data_all$GazeEventType == "Fixation",]

# 必要のない情報を削除する。
data_with_fixation$GazeEventDuration <- NULL
data_with_fixation$StudioEventData <- NULL
data_with_fixation$FixationIndex <- NULL
data_with_fixation$GazeEventType <- NULL

# 確認
#head(data_with_fixation)

# データ全体のバランスを確認します。
table(data_with_fixation$ParticipantName, data_with_fixation$SegmentName)

# csvで保存
write.csv(data_with_fixation, "./csv/output.csv", row.names=F)
```

補足：音声ファイルのmapping
```R
#補足：音声ファイルのmapping
#今回はいらない
#list <- read.csv("list.csv", head=T, sep=",", na.string="NA", encoding="UTF-8")
#list
#list$OnsetId<-paste(list$ItemNoA,"_",list$Condition,sep="")
#head(list)

#praatで作ったonsetファイル（音声ファイルとonset時間）
#onset <- read.csv("onset.csv", head=T, sep=",", na.string="NA", encoding="UTF-8")
#onset
#head(onset)

#OnsetとE-primeリストとmergeします
#combine<-merge(list,onset,by.x="Sound",by.y="Word",all.x=TRUE)
#head(combine)
#combine<-combine[order(combine$ListNo,combine$TrailNo),]
#head(combine,50)

#PartIでtrimmedされたOutput2.csvを読み込みます
#data_with_fixation <- read.csv("Output2.csv", header =T)
#head(data_with_fixation)
#data_with_fixation$OnsetId<-paste(data_with_fixation$itemA,"_",data_with_fixation$cond,sep="")
#head(data_with_fixation)

#combineとOuputとmergeします
#data_with_fixation<-merge(data_with_fixation,combine,by.x="OnsetId",by.y="OnsetId",all.x=TRUE)
#head(data_with_fixation)
#data_with_fixation<-data_with_fixation[order(data_with_fixation$ParticipantName,data_with_fixation$SegmentName,data_with_fixation$GazeStart),]
#head(data_with_fixation)
```

# 2. graph

```R

#グラフの作成
#ディレクトリの確認から

getwd()

#ライブラリーとデータの読み込み
library(ggplot2)
library(reshape)
data_all <- read.csv("./csv/output.csv", header =T)
#head(dataAll,100)

#digital化
#そのままではグラフ化ができない
#グラフの全体（土台）の時間軸の幅をここで決める。
#（複合名詞全体は約6000ms,一文字は約3000ms）
#comp_nounでまず20~6000msを20ms単位でbinのリストを作っておいて、
#それをカラム数にしてdataAllと同じ行数で行列bindataを作って後でdataAllの右側につっくけます。
# TODO: comp_noun は意味不明
# ている + n1
comp_noun <- seq(2900,5500,20)
#comp_noun <- seq(2420,3540,20)
binary_data <- matrix(0,nrow = nrow(data_all), ncol = length(comp_noun))
colnames(binary_data) <- comp_noun

# グラフの開始時点を揃える基準となる音声ファイルのonsetはここで決めます。
# 時間窓 20ms で見ていき、その区間を見続けていれば 1, 0 見ていなければ 0
# （MF01ではonset3がcritical regionです）
for (i in 1:length(comp_noun)){
    binary_data[,i] <- ifelse((data_all$GazeStart < (0 + i*20) & data_all$GazeEnd > (0 +i*20)),
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

gr.temp$A <- ifelse(is.na(gr.temp$A),0,gr.temp$C)
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

#aggregate for graph (Use t1~t4)
#グラフ作成ためのデータフレーム
gra <- aggregate(
    gr.temp$t3,
    by=list(gr.temp$bin, gr.temp$cond),
    mean)
colnames(gra) <- c("bin", "cond", "mean")

# a: NPI+AFFG

# gra$cond <- ifelse((gra$cond == 1), "NPI_t_AFF_t", gra$cond)
# gra$cond <- ifelse((gra$cond == 2), "NPI_f_AFF_t", gra$cond)
# gra$cond <- ifelse((gra$cond == 3), "NPI_t_AFF_f", gra$cond)
# gra$cond <- ifelse((gra$cond == 4), "NPI_f_AFF_f", gra$cond)

#グラフ作成の本番
g.Combined.Region6000 <- ggplot(data=gra, aes(x=bin, y=mean, colour = cond))+
  geom_line(aes(group=cond, color=cond)) +
  geom_point(aes(group=cond, color=cond)) +
  scale_x_continuous("Time") +
  scale_y_continuous(limits=c(0,0.5), name="Proportion of looks to target") +
  scale_color_discrete("Condition") +
  theme(axis.title.y = element_text(size = 16)) +
  theme(axis.title.x = element_text(size = 20)) +
  theme(legend.title = element_text(size = 16)) +
  theme(legend.text = element_text(size = 20))+
  ggtitle("Proportion of gaze to N2 doing V1")  

#必要に応じて変えます　
#グラフ保存
ppi <- 300
#画質をscreen上きれいに映すようにpixel=300ppiに設定
png("../png/g.Combined.RegionN2_aff.png", width=12*ppi, height=6*ppi, res=ppi)
#png()でpng拡張子のグラフで外部保存します。ppiに応じて長さと幅の設定は　12*6*ppi

# エラー: Continuous value supplied to discrete scale
# 多分 cond　に数字を入れているから。
g.Combined.Region6000
dev.off()
#もう一度グラフのオブジェクトを読み込みます#dev.off()で閉じないとファイルが保存されません　　


#補足：複数の図の一覧表を保存

#ALL24
library(gridExtra)　　#パッケージのggplot2ではなく、別にgridExtraが必要です。
ppi<-300
png("AllGraphList.png",width=24*ppi, height=12*ppi,res=ppi)
                    #幅は一つのグラフの2倍の24*ppiになります
graph<-grid.arrange(g1,g2,g3,g4,ncol=2)
                    #grid.arrange()でR内でできたグラフのオブジェクトをまとめます。（外部のpngファイルではなく）
dev.off()

```

# 3. LME
```R
getwd()
setwd("/home/kishiyama/home/thesis/npi-thesis/result/main4pulil")

library(lme4)
library(reshape)

data <- read.csv("./csv/output.csv", header =T)
head(data)
#バランスを確認
table(data$ParticipantName, data$Condition)
table(data$Condition)

　　　　　　　　　　　　　　　　　　　　　　　#実際のAOIの名前をマッピングします　
data$target <- ifelse(data$AOI == 1, as.character(data$AOI1), "BackGround")
data$target <- ifelse(data$AOI == 2, as.character(data$AOI2), data$target)
data$target <- ifelse(data$AOI == 3, as.character(data$AOI3), data$target)
data$target <- ifelse(data$AOI == 4, as.character(data$AOI4), data$target)

data <-data[order(data$ParticipantName,data$ItemNo,data$GazeStart),]


#onset時間点：どのonsetから切り揃えるでしょうか

data$slapse <- data$GazeStart - 2900
data$elapse <- data$GazeEnd - 2900

# 例： onset1からでしたら0,
# data$slapse <- data$GazeStart - 0
# data$elapse <- data$GazeEnd - 0

#onset2からでしたらdata$onset2
#data$slapse <- data$GazeStart - data$onset2
#data$elapse <- data$GazeEnd - data$onset2

#そうしたら、onset以外の部分は負数になって、
#後で時間区間の長さを調整する部分と合わせて0以下は0と入れ替えられて処理しないことになる

  #  slapse elapse
  #1   -824   -670
  #2   -603   -397
  #3      3    173
  #4    177    680
  #5    926   1523
  #6   1220   1603


#onset内の時間区間の長さを調整
data$slapse <- ifelse(data$slapse < 0, 0, data$slapse)
data$elapse <- ifelse(data$elapse >= 4500, 4500, data$elapse)
　
# 例：開始点は0,終了点は1000
# -> 0以下は0で入れ替え、1000以上は1000で入れ替えます
# 相殺してしまうと、概念上slapseとelapse以外の点が外されてしまします。（すごい技！）
# data$slapse <- ifelse(data$slapse < 0, 0, data$slapse)
# data$elapse <- ifelse(data$elapse >= 1000, 1000, data$elapse)

　　　　　　　　　　　　　　　　　　　　　　　　#  slapse elapse
　　　　　　　　　　　　　　　　　　　　　　　　#1      0   -199
　　　　　　　　　　　　　　　　　　　　　　　　#2      0    -10
　　　　　　　　　　　　　　　　　　　　　　　　#3      3      3
　　　　　　　　　　　　　　　　　　　　　　　　#4    177    177
　　　　　　　　　　　　　　　　　　　　　　　　#5    926   1000
　　　　　　　　　　　　　　　　　　　　　　　　#6   1220   1000

# 時間内の比率を見るから、durだけを見ていい（開始点と終了点はもう無視していい）
# わかりづらいけど、途中まで進まえると分かりやすいかもしれない。
data$dur <- data$elapse - data$slapse
# 万が一0以下（オーバーした区間）を除外
data$dur <- ifelse(data$dur < 0, 0, data$dur)

#必要なコラムだけを残ります
data <- data[,c("ParticipantName", "ItemNo", "target", "Condition", "slapse","elapse","dur")]
data <-data[order(data$ParticipantName,data$ItemNo,data$slapse),]

#CALUCULATING SUM (aggregation for each trial)
#同じ区間の中もし別に他の注視時間があれば全部合算する。
data <-aggregate(
    data$dur,
    by=list(data$ParticipantName, data$ItemNo, data$target, data$Condition),
    FUN=sum,
    na.rm=TRUE)
colnames(data) = c("subj","item","AOI","cond","sum")

                        #sort
data <- data[order(data$subj, data$item),]
                        #"variable","value"に書き換えないと、cast()が実行できません
colnames(data) = c("subj","item","variable","cond","value")

# cast creates separate columns for each object fixated
# 各絵に分けたら、それぞれの絵にどれくらい見ているのか、
# 後で分けて計算しやすい。（いちいち取り出すではなく、コラム単位で計算できる）

# cast 関数が無い。
data2 <- cast(data)

# replace NULL
# ここはどのような列を作っているかにもよります。
data2$BackGround <- ifelse(is.na(data2$BackGround), 0, data2$BackGround)
data2$A<- ifelse(is.na(data2$A), 0, data2$A)
data2$B<- ifelse(is.na(data2$B), 0, data2$B)
data2$C<- ifelse(is.na(data2$C), 0, data2$C)
data2$D<- ifelse(is.na(data2$D), 0, data2$D)

# calculate ALL column
data2$all <-  (data2$BackGround
              + data2$A
              + data2$B
              + data2$C
              + data2$D)

# 検証したい絵の条件はここで変更
# 条件が一つの絵のみの場合
# data2$logit <- log((data2$C + 0.5) / (data2$all - data2$C + 0.5))
# 条件がC(N2がV1をしている絵)の場合

# 条件が２つ以上の絵の場合
#data2$Competitor_TargetCompound <- data2$CompetitorCompound + data2$TargetCompound
#data2$logit <- log((data2$Competitor_TargetCompound + 0.5) / (data2$all - data2$Competitor_TargetCompound + 0.5))

# たぶん、該当する文節でのgazeの割合を見ている。
# 基本四つのパタン.odds率を計算。0.5は微調整（分母が0でしたら計算できなくなります。）
data2$logit_c <- log((data2$C + 0.5) / (data2$all - data2$C + 0.5))
data2$logit_a <- log((data2$A + 0.5) / (data2$all - data2$A + 0.5))
data2$logit_b <- log((data2$B + 0.5) / (data2$all - data2$B + 0.5))
data2$logit_d <- log((data2$D + 0.5) / (data2$all - data2$D + 0.5))

# 下位条件を付けます
# wo-ni の奴やで。
data2$npi <- ifelse(data2$cond == "a" | data2$cond == "c", 1, 0)
data2$aff <- ifelse(data2$cond == "a" | data2$cond == "b", 1, 0)

#中心化
data2$npi <- scale(data2$npi, scale=F)
data2$aff <- scale(data2$aff, scale=F)

#転換しやすいため
#logit1:Competitor_TargetCompound
#logit2:TargetCompound
#logit3:CompetitorCompound
#logit4:TargetSimplex

data2$logit<-data2$logit_c
tapply(data2$logit, list(data2$npi, data2$aff), mean)

#汎用性LMEモデル
m10 <- lmer(logit ~ tone3*comp + (1+tone3*comp|subj) + (1+tone3*comp|item), data = data2)
m0  <-  lmer(logit ~ npi*aff + (1|subj) + (1|item), data = data2)

anova(m10,m0)
summary(m10)
summary(m0)
```
