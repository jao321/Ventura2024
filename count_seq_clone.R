library(stringr)
args <- commandArgs(trailingOnly = TRUE)
print("Reading file...")
df <- read.csv(args[1], sep="\t")

print("Counting sequences...It will take some time, I'm sorry")
df <- df %>%
  add_column(clone_seq_count=NA)
for(x in unique(df$clone_id)){
  df[df$clone_id==x,]$clone_seq_count=nrow(df[df$clone_id==x,])
}
  
print("Writing file...")

write.table(paste(strsplit(args[1],split="[.]"),".seq_count.tsv"), sep="\t",quote=F, row.names = FALSE)