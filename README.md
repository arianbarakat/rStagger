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


| Index|Form   |Lemma  |POS.coarse |POS.fine |Morphological.features         |Head |Dependency.type |Chunk.tag |Chunk.type |NE.tag |NE.type |Token.ID                     |Sentence.ID |
|-----:|:------|:------|:----------|:--------|:------------------------------|:----|:---------------|:---------|:----------|:------|:-------|:----------------------------|:-----------|
|     1|Hej    |hej    |IN         |IN       |_                              |_    |_               |_         |_          |O      |_       |staggerInput91d1052362a:0:0  |0           |
|     2|.      |.      |MAD        |MAD      |_                              |_    |_               |_         |_          |O      |_       |staggerInput91d1052362a:0:3  |0           |
|     1|mitt   |min    |PS         |PS       |NEU&#124;SIN&#124;DEF          |_    |_               |_         |_          |O      |_       |staggerInput91d1052362a:1:5  |1           |
|     2|namn   |namn   |NN         |NN       |NEU&#124;SIN&#124;IND&#124;NOM |_    |_               |_         |_          |O      |_       |staggerInput91d1052362a:1:10 |1           |
|     3|är     |vara   |VB         |VB       |PRS&#124;AKT                   |_    |_               |_         |_          |O      |_       |staggerInput91d1052362a:1:15 |1           |
|     4|Kung   |Kung   |PM         |PM       |NOM                            |_    |_               |_         |_          |B      |person  |staggerInput91d1052362a:1:18 |1           |
|     5|Julian |Julian |PM         |PM       |NOM                            |_    |_               |_         |_          |I      |person  |staggerInput91d1052362a:1:23 |1           |


```r

# Or in parallel.. 

nrCores <- parallel::detectCores()
parsed_corpus <- parallel::mclapply(c("~/Desktop/test1.txt", "~/Desktop/test2.txt"), 
                                    FUN = callStagger,
                                    mc.cores = nrCores)


# To read an already parsed object

readParsed(file = "~/Desktop/rStagger_KungJulian.conll")

```

#### Extracting Entities

```r
extract_enitity(parsed, type = "person")


```

|          1 |
|:-----------|
|Kung Julian |

#### Extracting Features

```r
extract_features(test, "Readability")

```

|     |         |
|:----|--------:|
|LIX  | 6.000000|
|MSL  | 3.000000|
|MWLC | 3.833333|

```r
extract_features(test, "Stylometry")

```

|      |   |
|:-----|--:|
|TTR   |  1.0|
|DL    |  6|
|HAPAX |  1.0|

## Details

See more at [https://www.ling.su.se/english/nlp/tools/stagger](https://www.ling.su.se/english/nlp/tools/stagger)
