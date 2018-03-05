
.unpackModelFile <- function(){
  file.bz2 <- system.file("bin","swedish.bin.bz2", package = "rStagger")
  message("Unpacking swedish.bin.bz2 ...")
  system(paste("bzip2 -d", file.bz2))
  message("Done")
}

.stringToDF <- function(input, internal = TRUE, ...){
  colnames <- c("Index", "Form", "Lemma","POS.coarse","POS.fine",
                "Morphological.features", "Head", "Dependency.type", "Chunk.tag", "Chunk.type", 
                "NE.tag", "NE.type","Token.ID")
  if(internal){
    input <- textConnection(input)
  }
  
  df <- read.delim(input,col.names = colnames, stringsAsFactors = FALSE, header = FALSE, ...)
  class(df) <- c(class(df), "rStagger")
  return(df)
}


#' @title dictonary
#' 
#' @description Get dictionary of various tags
#' 
#' @param type Type of dictionary. Currently only Part-of-speech dictionary
#' @return A lookup vector
#' @export
dictonary <- function(type = c("POS")){
  
  if(identical(type, "POS")){
    dict <- c(
      "HS" = "Possessive relative pronoun",
      "PS" = "Possessive pronoun",
      "VB" = "Verb",
      "IE" = "Infnitive marker",
      "PP" = "Preposition",
      "PN" = "Pronoun",
      "NN" = "Noun",
      "DT" = "Determiner",
      "KN" = "Conjunction",
      "RG" = "Cardinal number",
      "SN" = "Subordinating conjunction", 
      "HD" = "Relative determiner",
      "JJ" = "Adjective",
      "HP" = "Relative pronoun",
      "AB" = "Adverb",
      "PM" = "Proper noun",
      "RO" = "Ordinal number",
      "IN" = "Interjection",
      "HA" = "Relative adverb",
      "PC" = "Participle",
      "PL" = "Verb particle",
      "UO" = "Foreign word")
  }
  
  return(dict)
}