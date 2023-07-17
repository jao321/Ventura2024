library("alakazam")
library("ggplot2")
library("dplyr")
library("RColorBrewer")
library("iNEXT")
library('tidyverse')
library('vegan')
library('rstatix')
library('ggprism')
library("tibble")
library("dplyr")


clonotyped <- list.files(path="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/", 
                recursive = TRUE,
                all.files = TRUE, 
                pattern="clonotyped_report.tsv")
diversities <- data.frame()

diversities <- diversities %>% 
  add_column( ID=NA ) %>%
  add_column( shannon=NA ) %>%
  add_column( simpson=NA )

  
meta <- read.csv("/Users/joaogervasio/Downloads/COVID_020223.csv")
meta$ID <- gsub(" ","", meta$ID)

for(i in clonotyped){
  print(strsplit(i,"/")[[1]][2])
  if(strsplit(i,"/")[[1]][2]=="GV92" 
     | strsplit(i,"/")[[1]][2]=="SP47" 
     | strsplit(i,"/")[[1]][2]=="ID310" 
     | strsplit(i,"/")[[1]][2]=="GV106" 
     | strsplit(i,"/")[[1]][2]=="SP114" 
     | strsplit(i,"/")[[1]][2]=="SP37"
     | strsplit(i,"/")[[1]][2]=="ID114"
     | strsplit(i,"/")[[1]][2]=="GV144"
     | strsplit(i,"/")[[1]][2]=="GV146"
     | strsplit(i,"/")[[1]][2]=="GV47"){
      next    
  }
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
  # df50 <- df[1:d50_clones,]
  df50 <- df[1:100,]
  tmp <- data.frame(strsplit(i,"/")[[1]][2],diversity(df50$seq_count, "shannon"),diversity(df50$seq_count, "simpson"))
  colnames(tmp) <- c("ID","shannon","simpson")
  diversities <- rbind(diversities, tmp)
}


diversities <- left_join(diversities,meta%>%select(ID,AGE,CLINICAL.CLASSIFICATION,AGE_GROUP,CITY), by = "ID")

diversities[diversities$CLINICAL.CLASSIFICATION=="Control",]$CITY="Control"
diversities[diversities$CLINICAL.CLASSIFICATION=="Control",]$AGE_GROUP="Control"

ggplot(diversities, aes(color=CLINICAL.CLASSIFICATION,x=AGE,y=shannon,)) +
  geom_count(size=5) +
  scale_color_manual(values = c("#1B79A5", "#FD7701","#FF4E00","#8ea604")) +
  geom_smooth(method="lm",se=FALSE)


df_p_val <- rstatix::wilcox_test(diversities, shannon ~ CITY) %>%
  rstatix::add_xy_position()


annotation <- data.frame(
  x = c(1,2,3,4),
  y = c(1,1,1,1),
  label = c(paste("n=",
                  nrow(diversities[diversities$CITY=="Control",])),
            paste("n=",
                  nrow(diversities[diversities$CITY=="BH",])),
            paste("n=",
                  nrow(diversities[diversities$CITY=="GV",])),
            paste("n=",
                  nrow(diversities[diversities$CITY=="SP",])))
)

df_p_val <- rstatix::wilcox_test(diversities, shannon ~ CITY) %>%
  rstatix::add_xy_position()

diversities$CITY <- factor(diversities$CITY, 
                           levels = c("Control","BH","GV","SP"))

ggplot(diversities, aes(x = CITY, y = shannon )) + 
  ylab("Shannon Diversity") +
  xlab("City") +
  labs(fill="City") +
  geom_boxplot(aes(fill=CITY)) +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"),
        legend.title=element_text(size=12)) +
  geom_label(data=annotation, aes( x=x, y=y, label=label),
             color="black", 
             size=7 , angle=45, fontface="bold" )
add_pvalue(df_p_val[df_p_val$p.adj.signif!="ns",], label = "p.adj.signif") +

df_p_val <- rstatix::wilcox_test(diversities, shannon ~ AGE_GROUP) %>%
  rstatix::add_xy_position() 

# diversities <- diversities %>% 
#   add_column( OUTCOME_AGE=paste(diversities$AGE_GROUP,diversities$CLINICAL.CLASSIFICATION)) 


diversities$AGE_GROUP <- factor(diversities$AGE_GROUP, 
                           levels = c("Control","Adult","Elderly"))



df_p_val <- rstatix::wilcox_test(diversities, shannon ~ AGE_GROUP) %>%
  rstatix::add_xy_position() 


annotation <- data.frame(
  x = c(1,2,3),
  y = c(1,1,1),
  label = c(paste("n=",
                  nrow(diversities[diversities$AGE_GROUP=="Control",])),
            paste("n=",
                  nrow(diversities[diversities$AGE_GROUP=="Adult",])),
            paste("n=",
                  nrow(diversities[diversities$AGE_GROUP=="Elderly",])))
)


ggplot(diversities, aes(x = AGE_GROUP, y = shannon )) + 
  ylab("Shannon Diversity") +
  xlab("Age Group") +
  labs(fill="Age Group") +
  geom_boxplot(aes(fill=AGE_GROUP)) +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"),
        legend.title=element_text(size=12)) +
  geom_label(data=annotation, aes( x=x, y=y, label=label),
             color="black", 
             size=7 , angle=45, fontface="bold" ) 


diversities[diversities$CLINICAL.CLASSIFICATION=="Moderate",]$CLINICAL.CLASSIFICATION="Hospitalized"
diversities[diversities$CLINICAL.CLASSIFICATION=="Severe",]$CLINICAL.CLASSIFICATION="Hospitalized"
diversities[is.na(diversities$CLINICAL.CLASSIFICATION),]$CLINICAL.CLASSIFICATION="Hospitalized"

df_p_val <- rstatix::wilcox_test(diversities, shannon ~ CLINICAL.CLASSIFICATION) %>%
  rstatix::add_xy_position()


diversities$CLINICAL.CLASSIFICATION <- factor(diversities$CLINICAL.CLASSIFICATION, 
                                levels = c("Control","Mild","Moderate","Severe"))

annotation <- data.frame(
  x = c(1,2,3,4),
  y = c(1,1,1,1),
  label = c(paste("n=",
                  nrow(diversities[diversities$CLINICAL.CLASSIFICATION=="Control",])),
            paste("n=",
                  nrow(diversities[diversities$CLINICAL.CLASSIFICATION=="Mild",])),
            paste("n=",
                  nrow(diversities[diversities$CLINICAL.CLASSIFICATION=="Moderate",])),
            paste("n=",
                  nrow(diversities[diversities$CLINICAL.CLASSIFICATION=="Severe",])))
)


ggplot(diversities, aes(x = CLINICAL.CLASSIFICATION, y = shannon )) + 
  ylab("Shannon Diversity") +
  xlab("Disease Outcome") +
  labs(fill="Disease Outcome") +
  geom_boxplot(aes(fill=CLINICAL.CLASSIFICATION)) +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=14,face="bold"),
        legend.title=element_text(size=12)) +
  geom_label(data=annotation, aes( x=x, y=y, label=label),
            color="black", 
            size=7 , angle=45, fontface="bold" )



########## TESTE DE NORMALIDADE #############3
library("ggpubr")
ggdensity(diversities$shannon)
shapiro.test(diversities$shannon) #se p > 0.05 => normal 
