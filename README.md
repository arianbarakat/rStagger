# rStagger

A wrapper around the java implementation of the NLP tool Stagger. 


To download and install the package, use:

```r
devtools::install_github("arianbarakat/rStagger", subdir = "rStagger")
```

### Requirements

* R
* Java


## Usage

```r
library(rStagger)

parsed <- callStagger(textFile = "Hej, mitt namn är Kung Julian",
                      outFile = "~/Desktop/rStagger_KungJulian.conll")
  
print(parsed) 

```


| Index|Form  |Lemma  |POS.coarse |POS.fine |Morphological.features         |Head |Dependency |Chunk.tag |Chunk.type |NE.tag |NE.type |Token.ID                      |
|-----:|:------|:------|:----------|:--------|:------------------------------|:----|:----------|:---------|:----------|:------|:-------|:----------------------------|
|     1|Hej    |hej    |IN         |IN       |_                              |_    |_          |_         |_          |O      |_       |staggerInputdb83fbe71e0:0:0  |
|     2|,      |,      |MID        |MID      |_                              |_    |_          |_         |_          |O      |_       |staggerInputdb83fbe71e0:0:3  |
|     3|mitt   |min    |PS         |PS       |NEU&#124;SIN&#124;DEF          |_    |_          |_         |_          |O      |_       |staggerInputdb83fbe71e0:0:5  |
|     4|namn   |namn   |NN         |NN       |NEU&#124;SIN&#124;IND&#124;NOM |_    |_          |_         |_          |O      |_       |staggerInputdb83fbe71e0:0:10 |
|     5|är     |vara   |VB         |VB       |PRS&#124;AKT                   |_    |_          |_         |_          |O      |_       |staggerInputdb83fbe71e0:0:15 |
|     6|Kung   |Kung   |PM         |PM       |NOM                            |_    |_          |_         |_          |B      |person  |staggerInputdb83fbe71e0:0:18 |
|     7|Julian |Julian |PM         |PM       |NOM                            |_    |_          |_         |_          |I      |person  |staggerInputdb83fbe71e0:0:23 |


```r
extract_enitity(parsed, type = "person")


```

|          1 |
|:-----------|
|Kung Julian |


```r

# Or in parallel.. 

nrCores <- parallel::detectCores()
parsed_corpus <- parallel::mclapply(c("~/Desktop/test1.txt", "~/Desktop/test2.txt"), 
                                    FUN = callStagger,
                                    mc.cores = nrCores)


# To read an already parsed object

readParsed(file = "~/Desktop/rStagger_KungJulian.conll")

```

## Details

See more at [https://www.ling.su.se/english/nlp/tools/stagger](https://www.ling.su.se/english/nlp/tools/stagger)
