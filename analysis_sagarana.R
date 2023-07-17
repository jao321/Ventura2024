library("alakazam")
library("ggplot2")
library("dplyr")
library("RColorBrewer")
library("iNEXT")
library('tidyverse')
library('vegan')
library('rstatix')
library('ggprism')


#### list folders that are in a specific directory ####
a <- list.dirs(path = "/home/joaodgervasio/2sagarana/temp",
               full.names = TRUE,
               recursive = TRUE)

meta <- read.csv("/home/joaodgervasio/2sagarana/COVID_020223.csv")

meta$ID <- gsub(" ","_", meta$ID)
covid <- read.table("/home/joaodgervasio/2sagarana/temp/A20/A20_db-pass_unique_YClon_clonotyped.tsv",
                    head = TRUE,
                    nrows = 1,
                    sep = "\t")[- 1, ]

covid <- covid %>% 
  add_column( age=NA ) %>%
  add_column( covid=NA ) %>%
  add_column( reprtoire_ID=NA ) %>%
  add_column( cidade=NA )%>%
  add_column( met = NA) %>%
  add_column ( plasm = NA )

covid <- covid %>%
  select(sequence_id,v_call,j_call,clone_id,reprtoire_ID,cidade,covid,age,met,plasm)

#### go through each folder ####
for(i in a){
  sample <- strsplit(i, split = "/")[[1]][6]
  file_in_path <- paste(a[1],"/",sample,"/",sample,"_db-pass_unique_YClon_clonotyped.tsv",
                        sep="")
  # fname <- paste(strsplit(strsplit(i, split = "/")[[1]][8], split = "-")[[1]][1],"_db-pass_unique_YClon_clonotyped.tsv",
  #                sep="")
  sample_ID <- sample
  
  if((is.na(sample) != TRUE) && (sample != "A20")){
    # file_path <- paste(i,fname,sep="/")
    print(fname)
    tmp <- read.csv(file_in_path, sep="\t")
    tmp <- tmp %>%
      select(sequence_id,v_call,j_call,clone_id)
    tmp['age'] <- meta[meta$ID == sample_ID,]$AGE_GROUP
    tmp['met'] <- meta[meta$ID == sample_ID,]$METILATION
    tmp['plasm'] <- meta[meta$ID == sample_ID,]$PLASMABLAST
    tmp['covid'] <- meta[meta$ID == sample_ID,]$CLINICAL.CLASSIFICATION
    tmp['reprtoire_ID'] <- sample_ID
    if(grepl("ID",sample_ID)){
      tmp['cidade'] <- "BH"
    }else if(grepl("SP",sample_ID)){
      tmp['cidade'] <- "SP"
    }else if(grepl("V",sample_ID)){
      tmp['cidade'] <- "GV"
    }else if(grepl("A",sample_ID)){
      tmp['cidade'] <- "Control"
    }
    
    covid <- rbind(covid, tmp)
    
  }
  
  # print(file_path)
  
  
}
print(colnames(covid))