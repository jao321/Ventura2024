library("ggplot2")
library('dplyr')
library('tidyverse')
library("RColorBrewer")
library("viridis")
library("ggnewscale")
install.packages("ggnewscale")

clonotyped <- list.files(path="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/", 
                         recursive = TRUE,
                         all.files = TRUE, 
                         pattern="clonotyped_report.tsv")

meta <- read.csv("/Users/joaogervasio/Downloads/COVID_020223.csv")
meta$ID <- gsub(" ","", meta$ID)


clones_representative <- data.frame()
clones_representative <-  clones_representative %>%
  add_column("ID") %>%
  add_column("sequence_id") %>%
  add_column("seq_count") %>%
  add_column("most_common_cdr3") %>%
  add_column("clone_id") %>%
  add_column("cumsum") 

for(i in clonotyped){
  print(strsplit(i,"/")[[1]][2])
  df <- read.csv(paste("/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/",i,sep=""),
                 sep="\t",
                 header = FALSE)
  colnames(df)=c("sequence_id","seq_count","most_common_cdr3","clone_id")
  df <- df[order(df$seq_count, decreasing = TRUE),]
  row.names(df) <- NULL
  df <- df %>% 
    add_column(cumsum=cumsum(df$seq_count))
  full_rep = sum(df$seq_count)
  d50_clones <- as.numeric(rownames(df[which.min(abs((full_rep/2)-df$cumsum)),]))
  df50 <- df[1:d50_clones,]
  df50 <- df50 %>%
    add_column(ID=strsplit(i,"/")[[1]][2]) %>%
    add_column(seq_freq=df50$seq_count/full_rep) 
  # tmp <- data.frame(strsplit(i,"/")[[1]][2],diversity(df50$seq_count, "shannon"),diversity(df50$seq_count, "simpson"))
  # colnames(tmp) <- c("ID","shannon","simpson")
  # diversities <- rbind(diversities, tmp)
  clones_representative <- rbind(clones_representative,df50)
}
clones_representative <- left_join(clones_representative,meta%>%select(ID,CLINICAL.CLASSIFICATION,AGE_GROUP,CITY), by = "ID")



clone_usage_graph <- ggplot(clones_representative[clones_representative$CLINICAL.CLASSIFICATION=="Severe" | clones_representative$CLINICAL.CLASSIFICATION=="Moderate",], 
                            aes(fill=seq_freq*100, y=seq_freq*100, x=ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Hospitalized") +
  scale_fill_gradientn(limits = c(0,28),colours = c("#FFFFFA",brewer.pal(n = 9, name = "YlOrRd"))) +
  ylab("Clonal frequency (%)") + 
  labs(fill='Clonal frequency\n range %') +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"),
        legend.title=element_text(size=10))



clone_usage_graph <- ggplot(clones_representative[clones_representative$CLINICAL.CLASSIFICATION=="Mild",], 
                            aes(fill=seq_freq*100, y=seq_freq*100, x=ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Mild") +
  scale_fill_gradientn(limits = c(0,28),colours = c("#FFFFFA",brewer.pal(n = 9, name = "YlOrRd"))) +
  ylab("Clonal frequency (%)") + 
  labs(fill='Clonal frequency\n range %') +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"),
        legend.title=element_text(size=10))

clone_usage_graph <- ggplot(clones_representative[clones_representative$CITY=="SP",], aes(fill=seq_freq, y=seq_freq, x=ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Clonal frequency SP") +
  scale_fill_viridis(limits = c(0,0.05)) +
  ggnewscale::new_scale_fill()+
  geom_bar(position="stack", stat="identity") +
  scale_fill_gradientn(limits = c(0.05,0.28),colours = brewer.pal(n = 9, name = "YlOrRd")) 
