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

callStagger(textFile = "Hej, mitt namn är Kung Julian)

# Or in parallel.. 

callStagger.parallel(files = c("test1.txt", "test2.txt"), file.dir = "~/Desktop/", "~/Desktop/")
```

## Details

See more at [https://www.ling.su.se/english/nlp/tools/stagger](https://www.ling.su.se/english/nlp/tools/stagger)
