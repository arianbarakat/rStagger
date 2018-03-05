#' @title readParsed
#' 
#' @description A function to read Stagger output into data.frame
#' @details Based the CoNLL-X annotated data format. 
#' See more at \href{https://ilk.uvt.nl/~emarsi/download/pubs/14964.pdf}{https://ilk.uvt.nl/~emarsi/download/pubs/14964.pdf}
#' 
#' @importFrom utils read.delim
#' @param file Path to file
#' @param ... Other argument to pass to internal calls (read.delim())
#' @return  Returns a dataframe with class c("data.frame", "rStagger")
#' 
#' @export
readParsed <- function(file, ...){
  df <- .stringToDF(input = file, internal = FALSE, ...)
  return(df)
}
