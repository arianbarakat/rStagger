# @title callStagger.parallel
# 
# @description A function to call Stagger (NLP) from R in parallel.  Works currently only on a UNIX system with Java installed.
# 
# @param files A vector of textfiles (file names)
# @param file.dir Path to directory of textfiles
# @param out.dir Path to directory for output files
# @param jarFile Path to .jar (Stagger) file. Default NULL (uses included .jar file)
# @param modelFile Path to .bin modelfile (i.e. the Swedish file). Default NULL (uses included modelfile)
# @return Returns a .txt file containing the parsed text
# 
# @details Uses GNU Parallel. See more at \href{https://www.gnu.org/software/parallel/}{https://www.gnu.org/software/parallel/}
# 
# @examples \donttest{callStagger.parallel(files = c("test1.txt", "test2.txt"), file.dir = "~/Desktop/", "~/Desktop/")}
#
# @export
.callStagger.parallel <- function(files, file.dir, out.dir, progress = TRUE, jarFile = NULL, modelFile = NULL){
  
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
  
  if(progress){
    eta <- "--eta "
  } else {
    eta <- ""
  }
  
  callString <- paste0("parallel ", eta,
                       "'java -jar ", jarFile,
                       " -modelfile ", modelFile,
                       " -tag ", file.dir,
                       "{} > ", out.dir , "staggerOut_{}' ::: ", paste(files, collapse = " "))
  message("Running ...")
  system(callString)
  message("Done!")
  
}