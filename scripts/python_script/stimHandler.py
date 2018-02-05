out = "stimuli2.csv"
inp = "stimuli.csv"

with open(inp,"r") as r:
  with open(out,"w") as w:
    for line in r:
      print(line)
      line  = line[:-2]
      line = line+",そうだ,。\n"
      w.write(line)

