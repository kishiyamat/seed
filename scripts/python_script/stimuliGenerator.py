# -*- coding=utf-8 -*- #
# by kishiyama

items_in_sentences ="""
アザラシ しか 倒れ ている スカンク を 見かけなかった
チーター しか 怒っ ている イノシシ を 睨まなかった
オオカミ しか 疲れ ている ビーバー を 呼びつけなかった
コウモリ しか 困っ ている フクロウ を からかわなかった
トナカイ しか ダラけ ている ミミズク を 踏まなかった
フェレット しか 焦っ ている モモンガ を 急かさなかった

アザラシ しか 呻い ている チーター を 励まさなかった
イノシシ しか 喚い ている ビーバー を はたかなかった
オオカミ しか 歩い ている フクロウ を ひっかかなかった
コウモリ しか 滑っ ている ミミズク を しからなかった
トナカイ しか 走っ ている モモンガ を 蹴らなかった
フェレット しか 隠れ ている スカンク を 噛まなかった"""

# データをアイテム行ごとにリストに
items_as_sentence = list(items_in_sentences.strip().split("\n"))
# 文のデータをアイテムごとにリストに
items_per_sentence = [i_s.split() for i_s in items_as_sentence]

# 全てのパターンの元
# なぜかうまく機能しなかった。
switched_items = list()
for items in items_per_sentence:
    base = list(items)
    tmp = base[0]
    base[0] = base[4]
    base[4] = tmp
    print(base)
    switched_items.append(base)

switched_items.extend(items_per_sentence)

# 組み換えパターンを記述していく。
stimuli = list()
#a: NPI_t, AFF_t
#items = ['スカンク', 'しか', '倒れ', 'ている', 'アザラシ', 'を', '見かけなかった']
for items in switched_items:
    sufix =  [''      , ''  , ''   , ''     , ''      , '' , ''           ]
    x = list()
    for b, s in zip(items, sufix):
        new_s = str(b+s)
        x.append(new_s)
    stimuli.append(x)
#print(x)
#print(' '.join(sample))
#b: NPI_f, AFF_t
#items = ['スカンク', 'しか', '倒れ', 'ている', 'アザラシ', 'を', '見かけなかった']
    sufix =  [''      , 'だけ', ''   , ''     , ''      , '' , ''           ]
    x = list()
    for b, s in zip(items, sufix):
        if b == "しか":
            new_s = s
        else:
            new_s = str(b+s)
        x.append(new_s)
    stimuli.append(x)
#c: NPI_t, AFF_f
#items = ['スカンク', 'しか', '倒れ', 'ている', 'アザラシ', 'を', '見かけなかった']
    sufix =  [''      , ''  , ''    , 'てない', ''      , '' , ''           ]
    x = list()
    for b, s in zip(items, sufix):
        if b == "ている":
            new_s = s
        else:
            new_s = str(b+s)
        x.append(new_s)
    stimuli.append(x)
#d: NPI_f, AFF_f
#items = ['スカンク', 'しか', '倒れ', 'ている', 'アザラシ', 'を', '見かけなかった']
    sufix =  [''      , 'だけ', ''   , 'てない', ''      , '' , ''           ]
    x = list()
    for b, s in zip(items, sufix):
        if b == "しか":
            new_s = s
        elif b == "ている":
            new_s = s
        else:
            new_s = str(b+s)
        x.append(new_s)
    stimuli.append(x)

for stimulus in stimuli:
    print(" ".join(stimulus))
