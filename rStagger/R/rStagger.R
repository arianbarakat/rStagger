#' @title callStagger
#' 
#' @description A function to call Stagger (NLP) from R
#' @import magrittr
#' 
#' @param textFile String or path to .txt file. If string, the string will be written to a temporary file that is deleted once the algorithm finishes
#' @param outFile Path to outfile. Default NULL
#' @param jarFile Path to .jar (Stagger) file. Default NULL (uses included .jar file)
#' @param modelFile Path to .bin modelfile (i.e. the Swedish file). Default NULL (uses included modelfile)
#' @return Returns a dataframe with class c("data.frame", "rStagger")
#' 
#' @example \dontrun{callStagger(textFile = "Hej, mitt namn är Kung Julian)}
#'
#' @export
callStagger <- function(textFile, outFile = NULL, jarFile = NULL, modelFile = NULL){
  require(magrittr)
  
  if(is.null(jarFile)){
    jarFile <- system.file("java", "stagger.jar", package = "rStagger")
  }
  
  if(is.null(modelFile)){
    modelFile <- system.file("bin", "swedish.bin", package = "rStagger")
    
    if(identical(modelFile, "")){
      unpackModelFile()
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
  }
  
  return(stringToDF(callResult))
}


#' @title unpackModelFile
#'
#' @description Utility function to unpack modelfile (Swedish model)
#' 
#' @return Unpacked swedish.bin modelfile
unpackModelFile <- function(){
  file.bz2 <- system.file("bin","swedish.bin.bz2", package = "rStagger")
  message("Unpacking swedish.bin.bz2 ...")
  system(paste("bzip2 -d", file.bz2))
  message("Done")
}

#' @title stringToDF
#' @description Utility function
#' 
#' @param string A string file
#' @param ... Other argument to pass to internal calls (read.delim())
#' @export
stringToDF <- function(string, ...){
  colnames <- c("Index", "Token", "Lemma","POS.coarse","POS.fine",
                "Morphological.features", "Head", "Dependency", "Chunk.tag", "Chunk.type", 
                "NE.tag", "NE.type","TokenID")
  df <- read.delim(textConnection(string),col.names = colnames, header = FALSE, ...)
  class(df) <- c(class(df), "rStagger")
  return(df)
}

#' @title extract_entity
#'
#' @description A function to extract entities from a rStagger object
#' 
#' @import dplyr
#'
#' @param object An object of class rStagger
#' @param type Entity type to extract: c("all","person","place","inst","product","myth","work","animal","other")
#' @return Returns a string of entities (the chosen entity type)
#'
#' @export
extract_entity <- function(object, type = c("all","person","place","inst","product","myth","work","animal","other")){
  require(dplyr)
  
  if(!("rStagger" %in% class(object))){
    stop("Supply a parsed Stagger object")
  }
  
  if(type == "all"){
    type <-  c("person","place","inst","product","myth","work","animal","other")
  }
  
  object.filtered <- object %>% dplyr::filter(., NE.type %in% type) %>% 
                        mutate(.,newEntity = ifelse(NE.tag == "B", TRUE, FALSE)) %>%
                        mutate(., entityGroup = cumsum(newEntity))
  
  entities <- split(object.filtered, f = object.filtered$entityGroup) %>%
                vapply(FUN = function(x){paste(x$Lemma, collapse = " ")}, FUN.VALUE = character(1))
  
  return(entities)
}



