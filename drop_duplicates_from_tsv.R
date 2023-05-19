a <- list.dirs(path = "/home/joaodgervasio/2sagarana/temp",
               full.names = TRUE,
               recursive = TRUE)
# print(a)

for(i in a){
  # fname <- paste(strsplit(strsplit(i, split = "/")[[1]][8], split = "-")[[1]][1],"_db-pass.tsv",
  #       sep="")
  # fname <- paste(paste(a[1],strsplit(i, split = "/")[[1]][6], sep="/"),"_db-pass.tsv",
  #       sep="")
  sample <- strsplit(i, split = "/")[[1]][6]
  file_in_path <- paste(a[1],"/",sample,"/",sample,"_db-pass.tsv",
                    sep="")
  # print(sample)
  
  if(is.na(sample) != TRUE){
    # #file_path <- paste(i,fname,sep="/")
    teste <- read.csv(file_in_path, sep="\t")
    # # #fname <- paste(strsplit(strsplit(i, split = "/")[[1]][8], split = "-")[[1]][1],"_db-pass_unique.tsv",
    # # #               sep="")
    file_out_path <- paste(a[1],"/",sample,"/",sample,"_db-pass_unique.tsv",
                           sep="")
    # print(file_out_path)
    # # #file_path <- paste(i,fname,sep="/")
    df2 <- teste[!duplicated(teste$sequence), ]
    write.table(df2, file = file_out_path,
                row.names=FALSE, sep="\t",quote = FALSE)
  }
  
  # print(file_path)
  

}

