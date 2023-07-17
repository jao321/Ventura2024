library("alakazam")
library("ggplot2")
library("dplyr")
library("RColorBrewer")
library("iNEXT")
library('tidyverse')
library('vegan')
library('rstatix')
library('ggprism')

a <- list.dirs(path = "/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140",
               full.names = TRUE,
               recursive = TRUE)

meta <- read.csv("/Users/joaogervasio/Downloads/COVID_020223.csv")

library("dbplyr")
library("tidyverse")

meta$ID <- gsub(" ","", meta$ID)
covid <- read.table("/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/A20/A20_db-pass_unique_YClon_clonotyped.tsv",
                    head = TRUE,
                    nrows = 1,
                    sep = "\t")[- 1, ]
df <- read.table("/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/A20/A20_db-pass_unique_YClon_clonotyped.tsv",
                    sep = "\t",
                    head = TRUE)

covid <- read.table("/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/A04/A04_db-pass_unique_YClon_clonotyped.tsv",
                    sep = "\t",
                    head = TRUE)

covid <- covid %>%
  select(clone_id)

covid <- covid %>% 
  add_column( clone_seq_count=NA )


df <- df %>%
  select(clone_id)

df <- df %>% 
  add_column( clone_seq_count=NA )


dup <- table(covid$clone_id)
dup <- lapply(dup, dplyr::nth,-1)
dup <- append(length(dup),dup)
up <- table(df$clone_id)
up <- lapply(up, dplyr::nth,-1)
up <- append(length(up),up)
a <- list(dup,up)
# covid <- covid[!duplicated(covid[ , c("clone_id")]),]
# for(x in 1:nrow(covid)){
#   covid[covid$clone_id==x,]$clone_seq_count = dup[[x]][1]
# }

  






df <- covid[!duplicated(covid[ , c("clone_id")]),]
print("Calculating rarefaction... This will take some minutes")
x <- iNEXT(df$clone_seq_count)
y <- iNEXT(covid$clone_seq_count)
z <- iNEXT(a,q=0, datatype="abundance")
coverage <- DataInfo(df$clone_seq_count)[4]


p <-ggiNEXT(x,color.var="Order.q") +
  xlab("Number of sequences") +
  ylab("Clone diversity") +
  annotate("text", x = 3000, y =-3000, label = paste("Coverage: ",coverage), size=8) +
  coord_cartesian(ylim=c(-0,30000),clip="off")


print("Saving the plot!")
png(str_replace(args[1],".tsv","_RAREFACTION.png"),width = 1200, height = 1200,)
print(p)
dev.off()