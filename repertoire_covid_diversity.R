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
a <- list.dirs(path = "/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140",
               full.names = TRUE,
               recursive = TRUE)

meta <- read.csv("/Users/joaogervasio/Downloads/COVID_020223.csv")

meta$ID <- gsub(" ","", meta$ID)
covid <- read.table("/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/A20/A20_db-pass_unique_YClon_clonotyped.tsv",
                    head = TRUE,
                    nrows = 1,
                    sep = "\t")[- 1, ]

covid <- covid %>% 
  add_column( age=NA ) %>%
  add_column( covid=NA ) %>%
  add_column( repretoire_ID=NA ) %>%
  add_column( city=NA )%>%
  #add_column( met = NA) %>%
  add_column ( plasm = NA )

covid <- covid %>%
  select(sequence_id,v_call,j_call,clone_id,repretoire_ID,city,covid,age,plasm)

#### go through each folder ####
for(i in a){
  sample <- strsplit(i, split = "/")[[1]][8]
  file_in_path <- paste(a[1],"/",sample,"/",sample,"_db-pass_unique_YClon_clonotyped.tsv",
                        sep="")
  # fname <- paste(strsplit(strsplit(i, split = "/")[[1]][8], split = "-")[[1]][1],"_db-pass_unique_YClon_clonotyped.tsv",
  #                sep="")
  sample_ID <- sample
  
  if(is.na(sample) != TRUE){
    # file_path <- paste(i,fname,sep="/")
    print(sample)
    tmp <- read.csv(file_in_path, sep="\t")
    tmp <- tmp %>%
      select(sequence_id,v_call,j_call,clone_id)
    tmp['age'] <- meta[meta$ID == sample_ID,]$AGE_GROUP
    #tmp['met'] <- meta[meta$ID == sample_ID,]$METILATION
    tmp['plasm'] <- meta[meta$ID == sample_ID,]$PLASMABLAST
    tmp['covid'] <- meta[meta$ID == sample_ID,]$CLINICAL.CLASSIFICATION
    tmp['repretoire_ID'] <- sample_ID
    if(grepl("ID",sample_ID)){
      tmp['city'] <- "BH"
    }else if(grepl("SP",sample_ID)){
      tmp['city'] <- "SP"
    }else if(grepl("V",sample_ID)){
      tmp['city'] <- "GV"
    }else if(grepl("A",sample_ID)){
      tmp['city'] <- "Control"
    }
    
    covid <- rbind(covid, tmp)
    
  }
  
  # print(file_path)
  
  
}
print(colnames(covid))






### organize data for each possible groups ####

# uso de gene v e j #

usage_v <- countGenes(covid, gene = "v_call", groups = "city", clone = "clone_id")
top_10_v <- usage_v %>% 
  group_by(city) %>%
  top_n(n = 7)
v_usage_graph <- ggplot(top_10_v, aes(fill=city, y=clone_freq, x=gene))
v_usage_graph + geom_bar(position="dodge", stat="identity") +
  scale_fill_brewer(palette="Set2") +
  theme(text = element_text(size=20)) 
## age ##
usage_v <- countGenes(covid, gene = "v_call", groups = "age", clone = "clone_id")
top_10_v <- usage_v %>% 
  group_by(age) %>%
  top_n(n = 7)
v_usage_graph <- ggplot(top_10_v, aes(fill=age, y=clone_freq, x=gene))
v_usage_graph + geom_bar(position="dodge", stat="identity") +
  scale_fill_brewer(palette="Set2") +
  theme(text = element_text(size=20)) 

## plasm ##
usage_v <- countGenes(covid, gene = "v_call", groups = "plasm", clone = "clone_id")
top_10_v <- usage_v %>% 
  group_by(plasm) %>%
  top_n(n = 7)
v_usage_graph <- ggplot(top_10_v, aes(fill=plasm, y=clone_freq, x=gene))
v_usage_graph + geom_bar(position="dodge", stat="identity") +
  scale_fill_brewer(palette="Set2") +
  theme(text = element_text(size=20)) 

## covid severity ##
usage_v <- countGenes(covid, gene = "v_call", groups = "covid", clone = "clone_id")
top_10_v <- usage_v %>% 
  group_by(covid) %>%
  top_n(n = 7)
v_usage_graph <- ggplot(top_10_v, aes(fill=covid, y=clone_freq, x=gene))
v_usage_graph + geom_bar(position="dodge", stat="identity") +
  scale_fill_brewer(palette="Set2") +
  theme(text = element_text(size=20)) 

rm(usage_v,v_usage_graph,top_10_v)

# diversidade de simpson #
simpson <- data.frame()

simpson <- simpson %>% 
  add_column("Repertoire") %>%
  add_column("Diversity") %>% 
  add_column("City") %>% 
  add_column("Covid") %>%
  add_column("Age") %>%
  #add_column("Metilation") %>%
  add_column("Plasmoblast")

for(i in unique(covid$repretoire_ID)){
  print(i)
  report <- paste(a[1],"/",i,"/",i,"_db-pass_unique_YClon_clone_report.tsv",
                  sep="")
  div_rep <- read.csv(report, sep="\t")
  tmp <- data.frame("Repertoire" = i, 
                    "Diversity"= diversity(div_rep$seq_count, "simpson"),
                    "City" = covid[covid$repretoire_ID == i,]$city[1],
                    "Covid" = covid[covid$repretoire_ID == i,]$covid[1],
                    "Age" = covid[covid$repretoire_ID == i,]$age[1],
                    "Plasmablast" = covid[covid$repretoire_ID == i,]$plasm[1])#,
  #"Metilation"= covid[covid$repretoire_ID == i,]$met[1])
  simpson <- rbind(simpson,tmp)
  rm(tmp)
  
}

#### choose groups if needed ####
groups <- simpson[(simpson$Age == "Adult" & simpson$Covid == "Severe") | (simpson$Age == "Elderly"),]
groups <- simpson[simpson$Age == "Adult",]
groups["Plasmablast"] <- NULL

df_p_val <- rstatix::wilcox_test(groups, Diversity ~ Covid) %>%
  rstatix::add_xy_position()

ggplot(groups, aes(x = Age, y = Diversity )) + geom_boxplot(aes(fill=Age))

ggplot(groups, aes(x = Covid, y = Diversity )) + geom_boxplot(aes(fill=Covid))



  ylab("Simpson Diversity") +
  geom_boxplot(aes(fill=Age)) +
  scale_y_continuous(breaks=seq(0,1,0.000002), limits = c(min(0.99999), max(1))) +
  geom_count() +
  theme(text = element_text(size=40),
                     legend.key.size = unit(2, 'cm'))+
    

groups <- simpson[(simpson$Age == "Adult"),]


#### back ####





df_p_val <- rstatix::t_test(simpson, Diversity ~ City) %>%
  rstatix::add_xy_position()

ggplot(simpson, aes(x = City, y = Diversity )) + 
  ylab("Simpson Diversity") +
  add_pvalue(df_p_val, label = "p.adj.signif") +
  geom_boxplot(aes(fill=City)) +
  scale_y_continuous(breaks=seq(0,1,0.000002), limits = c(min(0.99999), max(1))) +
  geom_count() 
  add_pvalue(df_p_val, label = "p.adj.signif")


simpson[simpson$Covid == "Moderate",]$Covid <- "Hospitalized" 
simpson[simpson$Covid == "Severe",]$Covid = "Hospitalized"
ggplot(simpson[!simpson$City=="GV",], aes(x = Covid, y = Diversity )) + 
  ylab("Simpson Diversity") +
  xlab("Disease outcome") +
  ggtitle("Diversity vs Disease outcome")+
  geom_violin() +
  geom_count(aes(color=City), size=7, alpha=0.5,
             position=position_dodge(width =0.5,
                                     preserve = "single")) +
  scale_color_manual(values=c("#FF4E00","#8ea604","#f5bb00","#540D6E"))+
  geom_count(aes(shape=Age), size=7, alpha=0.5,
             position=position_dodge(width =-0.5,
                                     preserve = "single")) +
  scale_shape_manual(values=c(15, 17))+
  theme(text = element_text(size=20)) 


df_p_val <- rstatix::pairwise_t_test(simpson, Diversity ~ Age) %>%
  rstatix::add_xy_position()

ggplot(simpson, aes(x = Age, y = Diversity )) + 
  ylab("Simpson Diversity") +
  #scale_y_continuous(breaks=seq(0,1,0.000002), limits = c(min(0.99999), max(1))) +
  geom_boxplot(aes(fill=Age)) +
  geom_count() +
  add_pvalue(df_p_val, label = "p.adj.signif")

  
df_p_val <- rstatix::t_test(simpson, Diversity ~ Plasmablast) %>%
  rstatix::add_xy_position()

ggplot(simpson, aes(x = Plasmablast, y = Diversity )) + 
  ylab("Simpson Diversity") +
  geom_boxplot(aes(fill=Plasmablast)) +
  #scale_y_continuous(breaks=seq(0,1,0.000002), limits = c(min(0.99999), max(1))) +
  geom_count() + 
  add_pvalue(df_p_val, label = "p.adj.signif")

shannon <- data.frame()

shannon <- shannon %>% 
  add_column("Repertoire") %>%
  add_column("Diversity") %>% 
  add_column("City") %>% 
  add_column("Covid") %>% 
  add_column("Age") %>%
  #add_column("Metilation") %>%
  add_column("Plasmoblast")

for(i in unique(covid$repretoire_ID)){
  tmp <- data.frame("Repertoire" = i, 
                    "Diversity"= as.numeric(diversity(covid[covid$repretoire_ID == i,]$clone_id
                                                      , "shannon")),
                    "City" = covid[covid$repretoire_ID == i,]$city[1],
                    "Covid" = covid[covid$repretoire_ID == i,]$covid[1],
                    "Age" = covid[covid$repretoire_ID == i,]$age[1],
                    "Plasmablast" = covid[covid$repretoire_ID == i,]$plasm[1])
  shannon <- rbind(shannon,tmp)
  rm(tmp)
}

ggplot(shannon, aes(x = City, y = Diversity )) + 
  ylab("Shannon Diversity") +
  geom_boxplot(aes(fill=City)) +
  geom_count() 
  add_pvalue(df_p_val, label = "p.adj.signif")

df_p_val <- rstatix::t_test(shannon, Diversity ~ City) %>%
  rstatix::add_xy_position()
  
ggplot(shannon, aes(x = Covid, y = Diversity )) + 
  ylab("Shannon Diversity") +
  geom_boxplot(aes(fill=Covid)) +
  geom_count() 
add_pvalue(df_p_val, label = "p.adj.signif")

ggplot(shannon, aes(x = Age, y = Diversity )) + 
  ylab("Shannon Diversity") +
  geom_boxplot(aes(fill=Age)) +
  geom_count() 
add_pvalue(df_p_val, label = "p.adj.signif")

ggplot(shannon, aes(x = Plasmablast, y = Diversity )) + 
  ylab("Shannon Diversity") +
  geom_boxplot(aes(fill=Plasmablast)) +
  geom_count() +
  scale_y_continuous(breaks=seq(0,13,1), limits = c(min(9), max(13)))
add_pvalue(df_p_val, label = "p.adj.signif")


#### frequencia clonal ####
freq <- countClones(covid, groups = "repretoire_ID")
  
freq["city"] <- ""
freq["Plasmablast"] <- ""
freq["Age"] <- ""
freq["Covid"] <- ""
a <-unique(freq["repretoire_ID"])

for(i in (1:nrow(a))){
  print(a[[1]][i])
  
  freq[freq["repretoire_ID"]==a[[1]][i],]["Plasmablast"] <- meta[meta["ID"]==a[[1]][i],]$PLASMABLAST
  freq[freq["repretoire_ID"]==a[[1]][i],]["Age"] <- meta[meta["ID"]==a[[1]][i],]$AGE_GROUP
  freq[freq["repretoire_ID"]==a[[1]][i],]["Covid"] <- meta[meta["ID"]==a[[1]][i],]$CLINICAL.CLASSIFICATION

  if(grepl("ID",a[[1]][i])){
    freq[freq["repretoire_ID"]==a[[1]][i],]["city"] <- "BH"
  }else if(grepl("SP",a[[1]][i])){
    # print(a)
    freq[freq["repretoire_ID"]==a[[1]][i],]["city"] <- "SP"
  }else if(grepl("V",a[[1]][i])){
    # print(a)
    freq[freq["repretoire_ID"]==a[[1]][i],]["city"] <- "GV"
  }else if(grepl("A",a[[1]][i])){
    # print(a)
    freq[freq["repretoire_ID"]==a[[1]][i],]["city"] <- "Control"
  }
}


top_10_clones <- freq %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 5)
clone_usage_graph <- ggplot(top_10_clones, aes(fill=clone_id, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  scale_fill_viridis_c(option = "magma") +
  theme(text = element_text(size=20)) 


# city #


BH <- freq %>% filter(city == "BH")
BH["city"] <- NULL
top_10_clones_BH <- BH %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_BH, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency BH") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))


SP <- freq %>% filter(city == "SP")
SP["city"] <- NULL
top_10_clones_SP <- SP %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_SP, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency SP") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))

GV <- freq %>% filter(city == "GV")
GV["city"] <- NULL
top_10_clones_GV <- GV %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_GV, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency GV") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))

Control <- freq %>% filter(city == "Control")
Control["city"] <- NULL
top_10_clones_Control <- Control %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_Control, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency Controle") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))
  
# plasmab #

lower <- freq %>% filter(Plasmablast == "lower")
lower["Plasmablast"] <- NULL
top_10_clones_lower <- lower %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_lower, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency low on secreting cells") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))


medium <- freq %>% filter(Plasmablast == "medium")
medium["Plasmablast"] <- NULL
top_10_clones_medium <- medium %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_medium, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency medium on secreting cells") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))

high <- freq %>% filter(Plasmablast == "high")
high["Plasmablast"] <- NULL
top_10_clones_high <- high %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_high, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency high on secreting cells") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))


# age #

adult <- freq %>% filter(Age == "Adult")
adult["Age"] <- NULL
top_10_clones_adult <- adult %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_adult, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency Adults") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))

Elder <- freq %>% filter(Age == "Elderly")
Elder["Age"] <- NULL
top_10_clones_Elder <- Elder %>% 
  group_by(repretoire_ID) %>%
  top_n(n = 1000)

clone_usage_graph <- ggplot(top_10_clones_Elder, aes(fill=seq_freq, y=seq_freq, x=repretoire_ID))
clone_usage_graph + geom_bar(position="stack", stat="identity") +
  theme(text = element_text(size=40), 
        axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        legend.key.size = unit(2, 'cm')) +
  ggtitle("Top 1000 clonal frequency Elderly") +
  scale_fill_gradientn(limits = c(0,0.23),colours = brewer.pal(n = 9, name = "YlOrRd"))

### Expansion ###