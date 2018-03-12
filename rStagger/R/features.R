
.TTR <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  out <- object %>% 
    mutate(Form = stringr::str_to_lower(Form)) %>%
    filter(!(POS.coarse %in% c("MID", "MAD", "PAD"))) %>% 
    group_by(Form) %>% 
    summarise(freq = n()) %>% 
    ungroup(Form) %>% 
    summarise(TTR = n()/sum(freq)) %>% as.numeric()
  
  return(out)
    
}

.DL <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  nWords <- object %>% 
    mutate(Form = stringr::str_to_lower(Form)) %>%
    filter(!(POS.coarse %in% c("MID", "MAD", "PAD"))) %>% 
    summarise(nWords = n()) %>% as.numeric()
  
  return(nWords)
  
}

.HAPAX <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  termFreq <- object %>% 
    mutate(Form = str_to_lower(Form)) %>%
    filter(!(POS.coarse %in% c("MID", "MAD", "PAD"))) %>% 
    group_by(Form) %>% 
    summarise(freq = n())
  
  nType <-  termFreq %>% ungroup(Form) %>% summarise(ntype = n()) %>% as.numeric()
  
  hapax <- termFreq %>% filter(freq == 1) %>% summarise(hapax = n()/nType) %>% as.numeric()
  
  return(hapax)
}

.MSL <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  msl <- object %>% 
    group_by(Sentence.ID) %>%
    summarise(SL = sum(stringr::str_detect(Form,pattern = "\\w"))) %>%
    ungroup(Sentence.ID) %>%
    summarise(MSL = mean(SL)) %>% as.numeric()
    
  
  return(msl)
}

.MWLC <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  mwlc <- object %>% 
    filter(stringr::str_detect(Form,pattern = "\\w")) %>%
    mutate(nchar = nchar(Form)) %>%
    summarise(mwlc = mean(nchar)) %>% as.numeric()
  
  
  return(mwlc)
}

.WLC <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  wlc <- object %>% 
    filter(stringr::str_detect(Form,pattern = "\\w")) %>%
    mutate(nchar = nchar(Form)) %>% select(nchar)
   
  
  return(wlc)
}


.LIX <- function(object){
  require(stringr)
  require(dplyr)
  checkmate::assertClass(object, "rStagger")
  
  # LIX = A/B + (C x 100)/A
  # A is the number of words
  # B is the number of periods (defined by period, colon or capital first letter)
  # C is the number of long words (more than 6 letters)
  
  A <- object %>% 
    filter(stringr::str_detect(Form,pattern = "\\w")) %>%
    summarise(nWords = n()) %>% as.numeric()
  
  B <- object %>%
    filter(POS.coarse == "MAD") %>%
    summarise(nPeriods = n()) %>% as.numeric()
  
  C <- object %>%
    filter(nchar(Form) > 6) %>%
    summarise(nLongWords = n()) %>% as.numeric()
  
  
  lix <- (A/B) + (C*100)/A
    
  return(lix)
  }


#' @title extract_features
#' @description A function to extract various measures from an rStagger object from \code{\link{callStagger}} or \code{\link{readParsed}}
#' @details The following features are implemented
#'  \itemize{
#'   \item Stylometry
#'   \itemize{
#'   \item{TTR: Type-Token Ratio}
#'   \item{DL: Document length as in number of words}
#'   \item{HAPAX: Hapax Legomenon}
#' }
#'   \item Readability
#'   \itemize{
#'   \item{LIX: Readability index (Swedish: Lasbarhetsindex)}
#'   \item{MSL: Mean sentence length calculated as the average number of words per sentence}
#'   \item{MWLC: Mean word length calculated as the average number of characters per word}
#' }
#' }
#' @param object A rStagger object
#' @param type Type of text feature to extract. Current choices c("Readability", "Stylometry")
#' @return A vector of features
extract_features <- function(object, type = c("Readability", "Stylometry")){
  checkmate::assertClass(object, "rStagger")
  checkmate::assertChoice(type, choices = c("Readability", "Stylometry"))
  
  if(identical(type,"Readability")){
    features <- c("LIX" = .LIX(object), 
                  "MSL" = .MSL(object),
                  "MWLC" = .MWLC(object))
  }
  
  if(identical(type,"Stylometry")){
    features <- c("TTR" = .TTR(object),
                  "DL" = .DL(object),
                  "HAPAX" = .HAPAX(object))
  }
  
  return(features)
}
  
  
