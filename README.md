# rStagger

A wrapper around the java implementation of the NLP tool Stagger. 


To download and install the package, use:

```r
devtools::install_github("arianbarakat/rStagger", subdir = "rStagger")
```

### Requirements

* R
* Java
* GNU Parallel (Optional, used in the parallel version)


## Usage

```r
library(rStagger)

parsed <- callStagger(textFile = "Hej, mitt namn är Kung Julian)

extract_enitity(parsed, type = "person")

# Or in parallel.. 

callStagger.parallel(files = c("test1.txt", "test2.txt"), file.dir = "~/Desktop/", out.dir =  "~/Desktop/")

readParsed(file = "~/Desktop/staggerOut_test1.txt")

```

## Details

See more at [https://www.ling.su.se/english/nlp/tools/stagger](https://www.ling.su.se/english/nlp/tools/stagger)
