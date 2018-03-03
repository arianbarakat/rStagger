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
  colnames <- c("Index", "Form", "Lemma","POS.coarse","POS.fine",
                "Morphological.features", "Head", "Dependency.type", "Chunk.tag", "Chunk.type", 
                "NE.tag", "NE.type","Token.ID")
  df <- read.delim(file,col.names = colnames, header = FALSE, ...)
  class(df) <- c(class(df), "rStagger")
  return(df)
}
