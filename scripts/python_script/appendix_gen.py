# coding: utf-8

sentences = \
"""スカンク-倒れ-アザラシ-見かけ,Skunk-fell-seal-see,Sukanku,taorete,azarashi,mikake,Skunk,fallen down,seal,saw
イノシシ-怒っ-チーター-睨ま,Wild boar-angry-cheetah-look at,Inoshishi,okotte,chiitaa,niramana,Wild boar,be angry,cheetah,looked at
ビーバー-疲れ-オオカミ-呼びつけ,Beaver-tired-wolf-call,Biibaa,tsukare,ookami,yobituke,Beaver,tired,wolf,call
フクロウ-困っ-コウモリ-からかわ,Owl-troubled-bat-tease,Fukuroo,komat,koomori,karakawa,Owl,troubled,bat,tease
ミミズク-ダラけ-トナカイ-踏ま,Horned owl-lazy-reindeer-step on,Mimizuku,darake,tonakai,fuma,Horned,owl,lazy,reindeer,step on
モモンガ-焦っ-フェレット-急かさ,Momonga-impatient-ferret-hurry,Momonga,aset,feretto,sekasa,Momonga,impatient,ferret,hurry
チーター-呻い-アザラシ-励まさ,Cheetah-groaning-seal-encouraged,Chiitaa,umei,azarashi,hagemasa,Cheetah,groaning,seal,encouraged
ビーバー-喚い-イノシシ-はたか,Beaver-shouting-wild boar-beat up,Biibaa,umei,inoshishi,hataka,Beaver,shouting,wild boar,beat up
フクロウ-歩い-オオカミ-ひっかか,Owl-walk-wolf-scratch,Fukuroo,arui,ookami,hikkaka,Owl,walk,wolf,scratch
ミミズク-滑っ-コウモリ-しから,Horned owl-slipped-bat-scold,Mimizuku,subet,koomori,sikara,Horned owl,slipped,bats,scold
モモンガ-走っ-トナカイ-蹴ら,Momonga-running-reindeer-kick,Momonga,hasit,tonakai,kera,Momonga,running,reindeer,kick
スカンク-隠れ-フェレット-噛ま,Skunk-hiding-ferret-bite,Sukanku,kakure,feretto,kama,Skunk,hiding,ferret,bite
アザラシ-倒れ-スカンク-見かけ,Seal-fell-skunk-see,Azarashi,taorete,sukanku,mikake,Seal,fallen down,skunk,saw
チーター-怒っ-イノシシ-睨ま,Cheetah-angry-wild boar-look at,Chiitaa,okotte,inoshishi,niramana,Cheetah,be angry,Wild boar,looked at
オオカミ-疲れ-ビーバー-呼びつけ,Wolf-tired-beaver-call,Ookami,tsukare,biibaa,yobituke,Wolf,tired,beaver,call
コウモリ-困っ-フクロウ-からかわ,Bat-troubled-owl-tease,Koomori,komat,fukuroo,karakawa,Bat,troubled,owl,tease
トナカイ-ダラけ-ミミズク-踏ま,Reindeer-lazy-horned owl-step on,Tonakai,darake,mimizuku,fuma,Reindeer,lazy,horned owl,step on
フェレット-焦っ-モモンガ-急かさ,Ferret-impatient-momonga-hurry,Feretto,aset,momonga,sekasa,Ferret,impatient,momonga,hurry
アザラシ-呻い-チーター-励まさ,Seal-groaning-cheetah-encouraged,Azarashi,umei,chiitaa,hagemasa,Seal,groaning,cheetah,encouraged
イノシシ-喚い-ビーバー-はたか,Wild boar-shouting-Beaver-beat up,Inoshishi,umei,biibaa,hataka,Wild boar,shouting,beaver,beat up
オオカミ-歩い-フクロウ-ひっかか,Wolf-walk-owl-scratch,Ookami,arui,fukuroo,hikkaka,Wolf,walk,owl,scratch
コウモリ-滑っ-ミミズク-しから,Bat-slipped-horned owl-scold,Koomori,subet,mimizuku,sikara,Bat,slipped,horned owl,scold
トナカイ-走っ-モモンガ-蹴ら,Reindeer-running-momonga-kick,tonakai,hasit,momonga,kera,Reindeer,running,momonga,kick
フェレット-隠れ-スカンク-噛ま,Ferret-hiding-skunk-bite,Feretto,kakure,sukanku,kama,Ferret,hiding,skunk,bite"""


counter = 1
for sentence in sentences.split("\n"):
    conds = ["a","b","c","d"]
    for cond in conds:
        items = sentence.split(",")
        sent= items[0].split("-")
        eng = items[1].split("-")
        n1j = items[2]
        v1j = items[3]
        n2j = items[4]
        v2j = items[5]
        n1e = items[6]
        v1e = items[7]
        n2e = items[8]
        v2e = items[9]
        npi = ""
        suffix_j = ""
        suffix_e = ""
        if cond == "a" or cond == "c":
            npi = "sika"
        else:
            npi = "dake"
        if cond == "a" or cond == "b":
            suffix_j = "iru"
            suffix_e = ""
        else:
            suffix_j = "nai"
            suffix_e = "-NEG"
        if cond == "a":
            print("""\eenumsentence{\n\scriptsize""")
        # ここに本体

        if cond =="a":
            full_j = "{0}しか{1}ている{2}を{3}なかった".format(sent[0],sent[1],sent[2],sent[3])
            full_e = "{0} was the only animal which {3} the {2} which is {1}.".format(eng[0],eng[1],eng[2],eng[3])
        elif cond =="b":
            full_j = "{0}だけ{1}ている{2}を{3}なかった".format(sent[0],sent[1],sent[2],sent[3])
            full_e = "{0} was the only animal which did not {3} the {2} which is {1}.".format(eng[0],eng[1],eng[2],eng[3])
        elif cond =="c":
            full_j = "{0}しか{1}てない{2}を{3}なかった".format(sent[0],sent[1],sent[2],sent[3])
            full_e = "{0} was the only animal which {3} the {2} which is not {1}.".format(eng[0],eng[1],eng[2],eng[3])
        elif cond =="d":
            full_j = "{0}だけ{1}てない{2}を{3}なかった".format(sent[0],sent[1],sent[2],sent[3])
            full_e = "{0} was the only animal which did not {3} the {2} which is not {1}.".format(eng[0],eng[1],eng[2],eng[3])
        gls = \
"""\item {0}\\\\
\gl{{{2}-{10}}}{{{3}-{11}}}
\gl{{{4}-{12}}}{{{5}{13}}}
\gl{{{6}-wo}}{{{7}-ACC}}
\gl{{{8}-inakatta}}{{{9}-NEG}}\\\\
‘{1}’""".format(
                full_j,
                full_e,
                n1j,
                n1e,
                v1j,
                v1e,
                n2j,
                n2e,
                v2j,
                v2e,
                npi,
                "only",
                suffix_j,
                suffix_e,
            )
        print(gls)
        if cond == "d":
            print("}\n")

test = "a	フェレット だけ 隠れ てない スカンク-噛ま,Cheetah was only animal staring at the dog which is angry.,Chiitaa,okotte,inoshishi,mite,Cheetah,angry,wild boar,stare"
hoge = test.split("\t")
# print(hoge)
cond = hoge[0]
sent = hoge[1]


sent= items[0]
eng = items[1]
n1j = items[2]
v1j = items[3]
n2j = items[4]
v2j = items[5]
n1e = items[6]
v1e = items[7]
n2e = items[8]
v2e = items[9]
npi = ""
suffix_j = ""
suffix_e = ""

if cond == "a" or cond == "c":
    npi = "sika"
else:
    npi = "dake"

if cond == "a" or cond == "b":
    suffix_j = "iru"
    suffix_e = ""
else:
    suffix_j = "nai"
    suffix_e = "NEG"

a = """
\item {0}\\\\
\gl{{{2}-{10}}}{{{3}-{11}}}
\gl{{{4}-{12}}}{{{5}{13}}}
\gl{{{6}-wo}}{{{7}-ACC}}
\gl{{{8}-inakatta}}{{{9}-NEG}}\\\\
‘{1}’
""".format(
    sent,
    eng,
    n1j,
    n1e,
    v1j,
    v1e,
    n2j,
    n2e,
    v2j,
    v2e,
    npi,
    "only",
    suffix_j,
    suffix_e,
    )

b = """
\item チーターだけ怒っているイノシシを見ていなかった\\\\
\gl{{Chiitaa-dake}}{{Cheetah-only}}
\gl{{okotte-iru}}{{angry}}
\gl{{inoshishi-wo}}{{dog-ACC}}
\gl{{mitei-nakatta}}{{stare-NEG}}\\\\
‘Cheetah was only animal not staring at the dog which is angry.’
"""

c = """
\item チーターしか怒ってないイノシシを見ていなかった\\\\
\gl{{Chiitaa-sika}}{{Cheetah-only}}
\gl{{okotte-nai}}{{angry}}
\gl{{inoshishi-wo}}{{dog-ACC}}
\gl{{mitei-nakatta}}{{stare-NEG}}\\\\
‘Cheetah was only animal staring at the dog which is not angry.’
"""

d = """
\item チーターだけ怒ってないイノシシを見ていなかった\\\\
\gl{{Chiitaa-dake}}{{Cheetah-only}}
\gl{{okotte-nai}}{{angry}}
\gl{{inoshishi-wo}}{{dog-ACC}}
\gl{{mitei-nakatta}}{{stare-NEG}}\\\\
‘Cheetah was only animal not staring at the dog which is not angry.’
"""

apple  = 50
orange = 100
total = apple + orange


template = "\eenumsentence{{{a}{b}{c}{d}}}".format(a=a,b=b,c=c,d=d)

#print(template)
