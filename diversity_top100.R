library("dplyr")
library('tidyverse')
library("tibble")
library("dplyr")


clonotyped <- list.files(path="path/to/tsv_MiAIRR", 
                         recursive = TRUE,
                         all.files = TRUE, 
                         pattern="clonotyped_report.tsv")

diversities <- data.frame()

diversities <- diversities %>% 
  add_column( ID=NA ) %>%
  add_column( shannon=NA ) %>%
  add_column( simpson=NA )


for(i in clonotyped){
  df <- read.csv(paste("path/to/tsv_MiAIRR/",i,sep=""),
                 sep="\t",
                 header = FALSE)
  colnames(df)=c("sequence_id","seq_count","most_common_cdr3","clone_id")
  df <- df[order(df$seq_count, decreasing = TRUE),]
  row.names(df) <- NULL
  df <- df %>%
    add_column(cumsum=cumsum(df$seq_count))
  full_rep = sum(df$seq_count)
  top_100 <- df[1:100,]
  tmp <- data.frame(strsplit(i,"/")[[1]][2],diversity(top_100$seq_count, "shannon"),simpson.unb(top_100$seq_count))
  colnames(tmp) <- c("ID","shannon","simpson")
  diversities <- rbind(diversities, tmp)
}