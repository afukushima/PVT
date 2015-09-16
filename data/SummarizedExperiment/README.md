# SummarizedExperiment
 for AtMetExpress

An example
------------
```R
load("AtMeKO.ALL.RData")
head(assays(AtMeKO.ALL)$accumulation)
mcols(AtMeKO.ALL)
colData(AtMeKO.ALL)
abstract(metadata(AtMeKO.ALL)[[1]])
AtMeKO.ALL[, AtMeKO.ALL$leafcolor == "palegreen"]
```
