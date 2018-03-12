#' @title callStagger
#' 
#' @description A function to call Stagger (NLP) from R.  Works currently only on a UNIX system with Java installed. Use parallel:mclapply to run in parallel
#' @import magrittr
#' 
#' @param textFile String or path to .txt file. If string, the string will be written to a temporary file that is deleted once the algorithm finishes
#' @param outFile Path to outfile. Default NULL
#' @param jarFile Path to .jar (Stagger) file. Default NULL (uses included .jar file)
#' @param modelFile Path to .bin modelfile (i.e. the Swedish file). Default NULL (uses included modelfile)
#' @param suppress.output A logical. Suppress output to the R environment, useful when writing to file in Batches
#' @return Returns a dataframe with class c("data.frame", "rStagger")
#' 
#' @examples \donttest{callStagger(textFile = "Hej, mitt namn är Kung Julian)}
#'
#' @export
callStagger <- function(textFile, outFile = NULL, jarFile = NULL, modelFile = NULL, suppress.output = FALSE){
  require(magrittr)
  checkmate::assertOS(c("mac", "linux"))

  if(is.null(jarFile)){
    jarFile <- system.file("java", "stagger.jar", package = "rStagger")
  }
  
  if(is.null(modelFile)){
    modelFile <- system.file("bin", "swedish.bin", package = "rStagger")
    
    if(identical(modelFile, "")){
      .unpackModelFile()
      modelFile <- system.file("bin", "swedish.bin", package = "rStagger")
    }
  }
  
  if(inherits(textFile, "character") && !file.exists(textFile)){
    tempFilePath <-  tempfile(pattern = "staggerInput", fileext = ".txt")
    write(textFile, file = tempFilePath)
    on.exit(unlink(tempFilePath))
    textFile <- tempFilePath
  }
  
  files <- c(jarFile, modelFile, textFile)
  
  if(!all(file.exists(files))){
    stop(paste("Following file(s) does not exist(s): ", files[!file.exists(files)]))  
  }
  
  callString <- paste("java -jar", jarFile,"-modelfile", modelFile,"-tag",textFile)
  callResult <- system(callString, intern = TRUE) %>% paste0(collapse = "\n")
  
  if(!is.null(outFile)){
    write(callResult, file = outFile)
    message(paste(Sys.time(),"| Result written to:", outFile))
  }
  
  if(!suppress.output){
    return(.stringToDF(callResult))
  }
  
}


#' @title extract_entity
#'
#' @description A function to extract entities from a rStagger object.
#' Entities: 
#' - person
#' - animal
#' - myth
#' - place 
#' - inst 
#' - product
#' - work 
#' - event
#' - other
#' 
#' @import dplyr
#'
#' @param object An object of class rStagger
#' @param type Entity type to extract: c("all","person","place","inst","product","myth","work","animal","other")
#' @return Returns a string of entities (the chosen entity type)
#'
#' @export
extract_entity <- function(object, type = c("all","person","place","inst","product","myth","work","animal","other","event")){
  require(dplyr)
  
  if(!("rStagger" %in% class(object))){
    stop("Supply a parsed Stagger object")
  }
  
  if(type == "all"){
    type <-  c("person","place","inst","product","myth","work","animal","other, event")
  }
  
  object.filtered <- object %>% dplyr::filter(., NE.type %in% type) %>% 
                        mutate(.,newEntity = ifelse(NE.tag == "B", TRUE, FALSE)) %>%
                        mutate(., entityGroup = cumsum(newEntity))
  
  entities <- split(object.filtered, f = object.filtered$entityGroup) %>%
                vapply(FUN = function(x){paste(x$Lemma, collapse = " ")}, FUN.VALUE = character(1))
  
  return(entities)
}


#' @title countPosTags
#' 
#' @description A function to count the frequencies of POS tags
#' @import dplyr
#' 
#' @param object A rStagger object
#' @return Returns a dataframe with POS frequencies c("data.frame", "rStagger", "rStaggerCount")
#'
#' @export
countPosTags <- function(object){
  require(dplyr)
  
  if(!("rStagger" %in% class(object))){
    stop("Supply a parsed Stagger object")
  }
  
  count <- object %>% group_by(POS.coarse) %>% summarise(count = n())
  class(count) <- c(class(count), "rStaggerCount")
  return(count)
}

#' @title countTerm
#' 
#' @description A function to count the frequencies of Tokens or Lemmas
#' @import dplyr lazyeval
#' 
#' @param object A rStagger object
#' @param type Term type, Tokens or Lemmas
#' @return Returns a dataframe with Token or Lemma frequencies c("data.frame", "rStagger", "rStaggerCount")
#'
#' @export
countTerm <- function(object, type = c("Token", "Lemma")){
  require(dplyr)
  require(lazyeval)
  
  if(!("rStagger" %in% class(object))){
    stop("Supply a parsed Stagger object")
  }
  
  if(length(type) > 1){
    stop("Supply only one value as type")
  }
  
  type <- switch (tolower(type) ,
                  "token" = "Form",
                  "lemma" = "Lemma")
  
  if(!(type %in% c("Form", "Lemma"))){
    stop("Supply term type: Token or Lemma")
  }
  
  count <- object %>% 
    group_by_(lazyeval::interp(type)) %>% 
    summarise(count = n())
  
  class(count) <- c(class(count), "rStaggerCount")
  return(count)
}


