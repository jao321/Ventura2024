library(dplyr)
library(tidyverse)
library(stringr)
library(plyr)

df <- read.csv("/Users/joaogervasio/Documents/YClon_input_test_airr_only_essential_info_YClon_clonotyped.tsv",sep="\t")
df$v_call <- str_split_i(df$v_call, "\\*",1)
df$v_call <- str_split_i(df$v_call, "\\,",1)
df$j_call <- str_split_i(df$j_call, "\\*",1)
df$j_call <- str_split_i(df$j_call, "\\,",1)
df <- df %>% 
  add_column( len=NA )
df$len <- str_length(df$cdr3)
df <- df %>%
  select(v_call,j_call,cdr3,len)
max <- ddply(df,.(v_call,j_call,len),nrow)
# unique(df)
# 
# df[df$v_call=="IGLV8S2" & df$j_call=="IGLJ4S1P" & df$len ==33,]
# larger <- df[df$v_call=="IGLV8S2" & df$j_call=="IGLJ4S1P" & df$len ==33,]
