#' @title callStagger
#' 
#' @description A function to call Stagger (NLP) from R.  Works currently only on a UNIX system with Java installed.
#' @import magrittr
#' 
#' @param textFile String or path to .txt file. If string, the string will be written to a temporary file that is deleted once the algorithm finishes
#' @param outFile Path to outfile. Default NULL
#' @param jarFile Path to .jar (Stagger) file. Default NULL (uses included .jar file)
#' @param modelFile Path to .bin modelfile (i.e. the Swedish file). Default NULL (uses included modelfile)
#' @return Returns a dataframe with class c("data.frame", "rStagger")
#' 
#' @examples \donttest{callStagger(textFile = "Hej, mitt namn är Kung Julian)}
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
  }
  
  return(.stringToDF(callResult))
}

#' @title callStagger.parallel
#' 
#' @description A function to call Stagger (NLP) from R in parallel.  Works currently only on a UNIX system with Java installed.
#' 
#' @param files A vector of textfiles (file names)
#' @param file.dir Path to directory of textfiles
#' @param out.dir Path to directory for output files
#' @param jarFile Path to .jar (Stagger) file. Default NULL (uses included .jar file)
#' @param modelFile Path to .bin modelfile (i.e. the Swedish file). Default NULL (uses included modelfile)
#' @return Returns a .txt file containing the parsed text
#' 
#' @details Uses GNU Parallel. See more at \href{https://www.gnu.org/software/parallel/}{https://www.gnu.org/software/parallel/}
#' 
#' @examples \donttest{callStagger.parallel(files = c("test1.txt", "test2.txt"), file.dir = "~/Desktop/", "~/Desktop/")}
#'
#' @export
callStagger.parallel <- function(files, file.dir, out.dir, jarFile = NULL, modelFile = NULL){
  
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
  
  dirs <- c(file.dir, out.dir)
  
  if(!all(dir.exists(dirs))){
    stop(paste("Following directories does not exist(s): ", dirs[!dir.exists(dirs)]))  
  }
  
  if(!all(file.exists(paste0(file.dir,files)))){
    stop(paste("Following file(s) does not exist(s): ", files[!file.exists(paste0(file.dir,files))]))  
  }
  
  callString <- paste0("parallel 'java -jar ", jarFile,
                       " -modelfile ", modelFile,
                       " -tag ", file.dir,
                       "{} > ", out.dir , "staggerOut_{}' ::: ", paste(files, collapse = " "))
  message("Running ...")
  system(callString)
  message("Done!")
  
}

#' @title readParsed
#' 
#' @description A function to read Stagger output into data.frame
#' 
#' @param file Path to file
#' @param ... Other argument to pass to internal calls (read.delim())
#' @return  Returns a dataframe with class c("data.frame", "rStagger")
#' 
#'
#' @export
readParsed <- function(file, ...){
  colnames <- c("Index", "Token", "Lemma","POS.coarse","POS.fine",
                "Morphological.features", "Head", "Dependency", "Chunk.tag", "Chunk.type", 
                "NE.tag", "NE.type","TokenID")
  df <- read.delim(file,col.names = colnames, header = FALSE, ...)
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


.unpackModelFile <- function(){
  file.bz2 <- system.file("bin","swedish.bin.bz2", package = "rStagger")
  message("Unpacking swedish.bin.bz2 ...")
  system(paste("bzip2 -d", file.bz2))
  message("Done")
}

.stringToDF <- function(string, ...){
  colnames <- c("Index", "Token", "Lemma","POS.coarse","POS.fine",
                "Morphological.features", "Head", "Dependency", "Chunk.tag", "Chunk.type", 
                "NE.tag", "NE.type","TokenID")
  df <- read.delim(textConnection(string),col.names = colnames, header = FALSE, ...)
  class(df) <- c(class(df), "rStagger")
  return(df)
}
