#' @title kwic
#' @description A function to extract keywords in context (KWIC) from an rStagger object from \code{\link{callStagger}} or \code{\link{readParsed}}
#' @param object A rStagger object
#' @param pattern A token/word/keyword to find
#' @param wdw_size Window Size, default = 3
#' @return Prints out the keyword with the context of size wdw_size
#' @export
kwic <- function(object, pattern, wdw_size = 3){
  checkmate::assertClass(object, "rStagger")
  require(dplyr)
  idx <- which(object$Form == pattern)
  
  lapply(idx, function(x, object, wdw){
    lower <- x - wdw + 1
    if(lower < 1){ lower <- 1}
    
    upper <- x + wdw - 1
    if(upper > nrow(object)){ upper <- nrow(object)}
    
    loc <- paste0("[", lower, ":", upper, "]")
    object$Form[lower:upper] %>% 
      paste(., collapse = " ") %>% paste(loc, ., collapse = "\t") %>% cat(., fill = TRUE)
    
  }, object, wdw = wdw_size) -> out
  
}