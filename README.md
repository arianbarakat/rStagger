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

extract_enitity(parsed, type = "person")

# Or in parallel.. 

nrCores <- parallel::detectCores()
parsed_corpus <- parallel::mclapply(c("~/Desktop/test1.txt", "~/Desktop/test2.txt"), mc.cores = nrCores)


# To read an already parsed object

readParsed(file = "~/Desktop/rStagger_KungJulian.conll")

```

## Details

See more at [https://www.ling.su.se/english/nlp/tools/stagger](https://www.ling.su.se/english/nlp/tools/stagger)
