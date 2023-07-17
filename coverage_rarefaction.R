library(iNEXT)
library(shazam)
library(dplyr)
library("Polychrome")

clonotyped <- list.files(path="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/", 
                          recursive = TRUE,
                          all.files = TRUE, 
                          pattern="clonotyped_report.tsv")
master <- data.frame()

for(i in clonotyped){
  print(strsplit(i,"/")[[1]][2])
  df <- read.csv(paste("/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/",i,sep=""),
                 sep="\t",
                 header = FALSE)
  colnames(df)=c("sequence_id","seq_count","most_common_cdr3","clone_id")
  df <- df %>%
    select("seq_count")
  colnames(df) <- strsplit(i,"/")[[1]][2]
  if (nrow(master)==0){
    master <- df
  }else{
    if(nrow(master)>nrow(df)){
      df[nrow(df):nrow(master),] <- 0
    }else{
      master[nrow(master):nrow(df),] <- 0
    }
    master<- cbind(master,df)
  }
  
  
  
  
}


# clones <- countClones(gv_50)
# yckon <- read.csv("/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/GV_50_L001-ds.600c4929fb654f969660ca232844a833/GV-50_db-pass_clone-pass_YClon_clonotyped.tsv",sep="\t")
# clonesy <- countClones(yckon, clone = "clone_id.1")
# 
# top_10 <- list()
# 
# for(x in 0:40){e
#   top_10 <- append(top_10,paste(gv_50[gv_50$clone_id==clones$clone_id[x],]$v_call[1],
#                        gv_50[gv_50$clone_id==clones$clone_id[x],]$j_call[1],
#                        nchar(gv_50[gv_50$clone_id==clones$clone_id[x],]$cdr3[1]),sep=","))
#   #top_10 <- append()
# }
# 
# top_yclon <- list()
# for(x in 0:40){
#   top_yclon <- append(top_yclon,paste(yckon[yckon$clone_id.1==clonesy$clone_id.1[x],]$v_call[1],
#                           yckon[yckon$clone_id.1==clonesy$clone_id.1[x],]$j_call[1],
#                           nchar(yckon[yckon$clone_id.1==clonesy$clone_id.1[x],]$cdr3[1]),sep=","))
#   #top_yclon <- append()
# }
# a <-intersect(top_10,top_yclon)




  



cumsum(clonesy$seq_freq[1:15])[15]
cumsum(clones$seq_freq[1:15])[15]



# db <- distToNearest(gv_50, model = "ham", normalize = "len", vCallColumn = "v_call", nproc = 4)

# out <- iNEXT(c(nrow(A04),A04$seq_count), q=c(0), datatype="incidence_freq")
# out <- iNEXT(A04$seq_count, q=0, datatype="abundance")
# 
# ggiNEXT(out, type=1, se=TRUE, facet.var="None", color.var="Assemblage", grey=FALSE)
# ggiNEXT(out, type=1, se=TRUE, facet.var="None", color.var="Order.q", grey=FALSE)
# P47 = createPalette(47,  c("#E8FF00", "#00FF00", "#FFFF00"))
# ggiNEXT(test,color.var="site") +
#   scale_color_manual(values=c(P47))

length(A24_count) <- length(A04_count)
abundance_matrix <- data.frame(A24 = c(A24_count),A04=c(A04_count))
abundance_matrix[is.na(abundance_matrix)] <- 0



test <- iNEXT(master, q=0, datatype="abundance")
write.table(test$DataInfo,
            file="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/rarefaction_richness_Datainfo.csv",
            quote = FALSE,
            row.names = FALSE)

write.table(test$iNextEst,
            file="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/rarefaction_richness_iNextEst.csv",
            quote = FALSE,
            row.names = FALSE)

write.table(test$AsyEst,
            file="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/rarefaction_richness_AsyEst.csv",
            quote = FALSE,
            row.names = FALSE)

test <- iNEXT(master, q=2, datatype="abundance")
write.table(test$DataInfo,
            file="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/rarefaction_simpson_Datainfo.csv",
            quote = FALSE,
            row.names = FALSE)

write.table(test$iNextEst,
            file="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/rarefaction_simpson_iNextEst.csv",
            quote = FALSE,
            row.names = FALSE)

write.table(test$AsyEst,
            file="/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/rarefaction_simpson_AsyEst.csv",
            quote = FALSE,
            row.names = FALSE)


meta <- read.csv("/Users/joaogervasio/Downloads/COVID_020223.csv")
meta$ID <- gsub(" ","", meta$ID)
# meta <- meta %>%
#   select("Assemblage","CITY","")
names(meta)[names(meta) =="ID"]<-"Assemblage"

coverage <- data.frame(Assemblage=c(test$DataInfo$Assemblage), 
                                    coverage=c(test$DataInfo$SC))
coverage <- left_join(coverage,meta, by="Assemblage")
coverage[coverage$CLINICAL.CLASSIFICATION=="Control",]$CITY <- "Control" 


# plot coverage #
ggplot(coverage, aes(x=Assemblage, y=coverage, color=CITY)) +
  geom_count(stat="identity", size=10) +
  xlab("Patients") +
  ylab("Coverage") +
  ylim(0,1)

  
rarefaction <-test$iNextEst$size_based
rarefaction <- left_join(rarefaction,meta, by="Assemblage")
rarefaction[rarefaction$CLINICAL.CLASSIFICATION=="Control",]$CITY <- "Control"

# plot rarefaction Coverage vs No of Sequences #
ggplot(rarefaction, aes(x=m,y=SC, group=Assemblage, color=CITY))+
  geom_line(data=filter(rarefaction, Method=="Rarefaction"), linetype="solid") +
  geom_line(data=filter(rarefaction, Method=="Extrapolation"), linetype="dashed") +
  geom_count(data=filter(rarefaction,Method=="Observed")) +
  geom_ribbon(aes(ymin=SC.LCL, ymax=SC.UCL),linetype=0, alpha=0.1) +
  xlab("Number of sequences") +
  ylab("Sample coverage") +
  scale_y_continuous(breaks = seq(0, 1, 0.25))

  
# plot rarefaction Diversity vs No of Sequences #
ggplot(rarefaction, aes(x=m,y=qD, group=Assemblage, color=CITY))+
  geom_line(data=filter(rarefaction, Method=="Rarefaction"), linetype="solid") +
  geom_line(data=filter(rarefaction, Method=="Extrapolation"), linetype="dashed") +
  geom_count(data=filter(rarefaction,Method=="Observed")) +
  geom_ribbon(aes(ymin=qD.LCL, ymax=qD.UCL),linetype=0, alpha=0.1) +
  xlab("Number of sequences") +
  ylab("Clone Diversity") 


  
diversity <- test$AsyEst
diversity <- diversity[diversity$Diversity=="Shannon diversity",]
rarefaction <- left_join(rarefaction,diversity, by="Assemblage")
# plot rarefaction Diversity vs Coverage #
ggplot(rarefaction, aes(x=qD,y=SC, group=Assemblage, color=CITY))+
  geom_line(data=filter(rarefaction, Method=="Rarefaction"), linetype="solid") +
  geom_line(data=filter(rarefaction, Method=="Extrapolation"), linetype="dashed") +
  geom_count(data=filter(rarefaction,Method=="Observed")) +
  geom_ribbon(aes(xmin=qD.LCL, xmax=qD.UCL),linetype=0, alpha=0.1) +
  xlab("Simpson diversity") +
  ylab("Sample Coverage") 







# threshold <- findThreshold(db$dist_nearest, method = "density")
# thr <- round(threshold@threshold, 2)
# thr
# 
# 
# 
# a = 0
# 
# for(i in 1:length(ref$sequence)){
#   a = a+1
#   if(a%%1000==0){
#     print(a)
#   }
#   ref$clone_id[i] <- ini[ini$sequence == ref$sequence[1],]$clone_id
# }

estimateD(abundance_matrix,q=0,base="coverage")


}

for(i in clonotyped){
  
  df <- read.csv(paste("/Users/joaogervasio/Documents/projeto_covid_doutorado/covidao/",i,sep=""),
                 sep="\t",
                 header = FALSE)
  # print((,strsplit(i,"/")[[1]][2]))
  print(nrow(df))
  }
  # colnames(df)=c("sequence_id","seq_count","most_common_cdr3","clone_id")
  # df <- df %>%
  #   select("seq_count")
  # colnames(df) <- strsplit(i,"/")[[1]][2]
  # if (nrow(master)==0){
  #   master <- df
  # }else{
  #   if(nrow(master)>nrow(df)){
  #     df[nrow(df):nrow(master),] <- 0
  #   }else{
  #     master[nrow(master):nrow(df),] <- 0
  #   }
  #   master<- cbind(master,df)
  # }
  # 
  # 
  
  
}
