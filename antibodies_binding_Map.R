library(dbplyr)
library(tidyverse)
library(R.utils)
library(ggplot2)
library(rstatix)
library(ggprism)
library(ggpubr)
#Neutralizes = binds not weakly to the antigen
dir <- list.dirs(path = "/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140",
               full.names = TRUE,
               recursive = TRUE)
meta <- read.csv("/Users/joaogervasio/Downloads/COVID_020223.csv")
meta$ID <- gsub(" ","", meta$ID)

covid <- data.frame()
covid <- covid %>% 
  add_column( age=NA ) %>%
  add_column( covid=NA ) %>%
  add_column( repretoire_ID=NA ) %>%
  add_column( city=NA ) %>%
  #add_column( met = NA) %>%
  add_column ( plasm = NA ) %>%
  add_column( binds_to_SARS_CoV2=NA ) %>%
  add_column( doesnt_bind_to_SARS_CoV2=NA ) %>%
  add_column( neutralize_aginst_SARS_CoV2=NA ) %>%
  add_column( doesnt_neutralize_aginst_SARS_CoV2=NA ) %>%
  add_column( unique_binds_to_SARS_CoV2=NA ) %>%
  add_column( unique_neutralize_aginst_SARS_CoV2=NA ) %>%
  add_column( binds_and_neutralize=NA ) %>%
  add_column( unique_binds_and_neutralize=NA ) %>%
  add_column(binds_to_unique=NA) %>%
  add_column(not_bind_to_unique=NA) %>%
  add_column(neutralize_unique=NA) %>%
  add_column(not_neutralize_unique=NA)


for(i in dir){
  sample <- strsplit(i, split = "/")[[1]][8]
  
  file_in_path <- paste(dir[1],"/",sample,"/",sample,"report.csv",
                        sep="")
  print(file_in_path)  
  
  if(file.exists(file_in_path)){
    df<- read.csv(file_in_path)
    
    unique_seq <- countLines(paste(dir[1],"/",sample,"/",sample,"_db-pass_unique_YClon_clonotyped.tsv",
                     sep=""))
    sample_ID <- sample
    
    tmp <- data.frame(repretoire_ID=sample_ID)
    tmp <- tmp %>%
      add_column( age=NA ) %>%
      add_column( covid=NA ) %>%
      # add_column( repretoire_ID=sample_ID ) %>%
      add_column( city=NA ) %>%
      #add_column( met = NA) %>%
      add_column ( plasm = NA ) %>%
      add_column( binds_to_SARS_CoV2=NA ) %>%
      add_column( doesnt_bind_to_SARS_CoV2=NA ) %>%
      add_column( neutralize_aginst_SARS_CoV2=NA ) %>%
      add_column( doesnt_neutralize_aginst_SARS_CoV2=NA ) %>%
      add_column( unique_binds_to_SARS_CoV2=NA ) %>%
      add_column( unique_neutralize_aginst_SARS_CoV2=NA ) %>%
      add_column( binds_and_neutralize=NA ) %>%
      add_column( unique_binds_and_neutralize=NA ) %>%
      add_column(binds_to_unique=NA) %>%
      add_column(not_bind_to_unique=NA) %>%
      add_column(neutralize_unique=NA) %>%
      add_column(not_neutralize_unique=NA)
    
    if(is.na(sample) != TRUE){
      # file_path <- paste(i,fname,sep="/")
      tmp['age'] <- unique(meta[meta$ID == sample_ID,]$AGE_GROUP)
      #tmp['met'] <- meta[meta$ID == sample_ID,]$METILATION
      tmp['plasm'] <- unique(meta[meta$ID == sample_ID,]$PLASMABLAST)
      tmp['covid'] <- unique(meta[meta$ID == sample_ID,]$CLINICAL.CLASSIFICATION)
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
      
      
    }
    df = df[!(is.na(df$Expanyion) | df$Expanyion==""),]
    
    # binds_to_unique <- nrow(grepl("Merc",df$Binds.to))
    # not_bind_to_unique <- unique(df$Doesn.t.Bind.to)
    neutralize_unique <- unique(df$Neutralising.Vs)
    # not_neutralize_unique <- unique(df$Not.Neutralising.Vs)
    
    binds_and_neutralize <- sum(grepl("SARS-CoV2",df$Binds.to) &
          grepl("SARS-CoV2",df$Neutralising.Vs) &
          grepl("YES",df$Expanyion))
    
    tmp['binds_to_SARS_CoV2'] <- sum(grepl("SARS-CoV2",df$Binds.to))/unique_seq
    tmp['doesnt_bind_to_SARS_CoV2'] <- sum(grepl("SARS-CoV2",df$Doesn.t.Bind.to))/unique_seq
    tmp['neutralize_aginst_SARS_CoV2'] <- sum(grepl("SARS-CoV2|SARS-COV2|SARS_CoV2",df$Neutralising.Vs))/unique_seq
    tmp['doesnt_neutralize_aginst_SARS_CoV2'] <- sum(grepl("SARS-CoV2",df$Not.Neutralising.Vs))/unique_seq
    
    
    tmp['binds_to_unique'] <- nrow(df %>%
           group_by(Binds.to)%>%
           summarise(across(everything(), ~paste0(unique(.), collapse = "|"))))
    tmp['not_bind_to_unique'] <-nrow(df %>%
                                group_by(Doesn.t.Bind.to)%>%
                                summarise(across(everything(), ~paste0(unique(.), collapse = "|"))))
    tmp['neutralize_unique'] <-nrow(df %>%
                                group_by(Neutralising.Vs)%>%
                                summarise(across(everything(), ~paste0(unique(.), collapse = "|"))))
    tmp['not_neutralize_unique'] <-nrow(df %>%
                                group_by(Not.Neutralising.Vs)%>%
                                summarise(across(everything(), ~paste0(unique(.), collapse = "|"))))

    
    covid <- rbind(covid, tmp)
  }
}  

covid$covid[covid$covid == "Moderate"] <- "Hospitalized"
covid$covid[covid$covid == "Severe"] <- "Hospitalized"

df_p_val <- rstatix::t_test(covid, binds_to_SARS_CoV2 ~ city) %>%
  rstatix::add_xy_position()

ggplot(covid, aes(x = covid, y = neutralize_aginst_SARS_CoV2 )) + 
  geom_violin() +
  ylab("% of the repertoire that neutralizes SARS_CoV2") +
  xlab("Disease outcome") +
  scale_y_continuous(breaks=seq(0,1,0.1), limits = c(min(0), max(0.2))) +
  geom_count(aes(color=city), size=7, alpha=0.5,
             position=position_dodge(width =0.5,
                                     preserve = "single")) +
  scale_color_manual(values=c("#FF4E00","#8ea604","#f5bb00","#540D6E"))+
  geom_count(aes(shape=age), size=7, alpha=0.5,
             position=position_dodge(width =-0.5,
                                     preserve = "single")) +
  scale_shape_manual(values=c(15, 17))+
  theme(text = element_text(size=20)) 


  add_pvalue(df_p_val, label = "p.adj.signif", y.position= 0.1)
p

df_p_val <- rstatix::t_test(covid[covid$city!="GV",], binds_to_SARS_CoV2 ~ covid) %>%
  rstatix::add_xy_position()

ggplot(covid[covid$city!="GV",], aes(x = covid, y = neutralize_aginst_SARS_CoV2*1 )) + 
  geom_violin() +
  geom_count(aes(color=city), size=3, alpha=0.5) +
  scale_y_continuous(breaks=seq(0,1,0.02), limits = c(min(0), max(0.12))) +
  theme(axis.title = element_text(size = 20),
        axis.text=element_text(size = 15),
        legend.text=element_text(size = 15))+
  ylab("Proportion of the repertoire that neutralizes to SARS_CoV2") +
  xlab("Disease outcome") 
  add_pvalue(df_p_val, label = "p.adj.signif")

ggplot(covid, aes(x = covid, y = neutralize_aginst_SARS_CoV2 )) + 
  geom_violin() +
  geom_count(aes(color=city), size=3, alpha=0.5) +
  scale_y_continuous(breaks=seq(0,1,0.02), limits = c(min(0), max(0.12))) +
  theme(axis.title = element_text(size = 20),
        axis.text=element_text(size = 15),
        legend.text=element_text(size = 15))+
  ylab("Proportion of the repertoire that neutralizes to SARS_CoV2") +
  xlab("Disease outcome")
  
  
  
  
ggplot(covid, aes(x = age, y = binds_to_SARS_CoV2 )) + 
  geom_violin(aes(fill=age)) +
  scale_y_continuous(breaks=seq(0,1,0.1), limits = c(min(0), max(0.2))) +
  ylab("% of the repertoire that binds to SARS_CoV2") +
  xlab("Age group")

teste <- data.frame()



#### binding ####
binding_map <- data.frame()

for(i in dir){
  sample <- strsplit(i, split = "/")[[1]][8]
  
  file_in_path <- paste(dir[1],"/",sample,"/",sample,"report.csv",
                        sep="")
  
  if(file.exists(file_in_path)){
    print(file_in_path)
    df<- read.csv(file_in_path)
    
    df = df[!(is.na(df$Expanyion) | df$Expanyion=="" | df$Expanyion=="NO" | df$Neutralising.Vs==""),]
    
    bind_unique <- unique(df$Binds.to)
    
    a <- list()
    for(x in bind_unique){
      temp <- strsplit(x,";")
      for(i in 1:length(temp[[1]])){
        a <- append(a,temp[[1]][i])
      }
      
    }
    
    a <- unique(a)
    if(length(a)==0){
      binding_map[sample,] <- 0
      binding_map[sample,"Repertoire"] <- sample
      next
    }
    
    temp_df <- data.frame(Repertoire=sample)
    names <- ""
    names <- colnames(temp_df)
    
    
    for(x in 1:length(a)){
      temp <- data.frame("a"=nrow(df[grep(a[x],df$Binds.to), ]))
      temp_df <- cbind(temp_df,temp)
      colnames(temp_df) <- append(names,a[x])
      names <- colnames(temp_df)
    }
    
    if(ncol(neutralizing_map)==0){
      neutralizing_map<- temp_df
      next
    }
    
    if(ncol(neutralizing_map) < ncol(temp_df)){
      
      
      falta <- setdiff(colnames(binding_map),colnames(temp_df))
      colunas <- colnames(temp_df)
      if(length(falta) != 0){
        for(x in 1:length(falta)){
          temp_df <- temp_df %>%
            add_column(new_column=0)
          
        }
      }
      colnames(temp_df) <- append(colunas, falta)
      
      falta <- setdiff(colnames(temp_df),colnames(binding_map))
      colunas <- colnames(binding_map)
      if(length(falta) != 0){
        for(x in 1:length(falta)){
          binding_map <- binding_map %>%
            add_column(new_column=0)
          
        }
      }
      colnames(binding_map) <- append(colunas, falta)
      binding_map <- rbind(binding_map,temp_df)
    }else if(ncol(binding_map) > ncol(temp_df)){
      
      
      falta <- setdiff(colnames(temp_df),colnames(binding_map))
      colunas <- colnames(binding_map)
      if(length(falta) != 0){
        for(x in 1:length(falta)){
          binding_map <- binding_map %>%
            add_column(new_column=0)
          
        }}
      colnames(binding_map) <- append(colunas, falta)
      
      falta <- setdiff(colnames(binding_map),colnames(temp_df))
      colunas <- colnames(temp_df)
      if(length(falta) != 0){
        for(x in 1:length(falta)){
          temp_df <- temp_df %>%
            add_column(new_column=0)
          
        }}
      colnames(temp_df) <- append(colunas, falta)
      binding_map <- rbind(binding_map,temp_df)
    }else{
      binding_map <- rbind(binding_map,temp_df)
    }
  }
  
}

binding_map <- binding_map[-c(39),]

# a <- !grepl("weak",colnames(binding_map))
# ct = 0
# for(x in 1:length(a)){
#   if(a[x]==FALSE){
#     binding_map<- binding_map[,-(x-ct)]
#     ct = ct+1
#   }
# }



a <- as.list(grep("SARS-CoV2|SARS_CoV2|SARS-COV2",colnames(binding_map)))
anti_sars_cov2 <- binding_map %>% select(1)

for(i in a){
  anti_sars_cov2 <- cbind(anti_sars_cov2,binding_map %>% select(i))
}
percentage_binding <- list()

for(i in 1:nrow(anti_sars_cov2)){
  sample <- anti_sars_cov2[i,1]
  print(sample)
  
  percentage_binding <- append(percentage_binding,sum(anti_sars_cov2[i,2:ncol(anti_sars_cov2)]))
}

anti_sars_cov2$binds_sars_cov2 <- percentage_binding

a <- grep("SARS-CoV2|SARS_CoV2|SARS-COV2",colnames(binding_map))

#### variantes ####
variant <- data.frame()
for(x in 1:nrow(anti_sars_cov2)){
  teste <- t(anti_sars_cov2[x,2:31])
  teste <- cbind(newColName = rownames(teste), teste)
  rownames(teste) <- 1:nrow(teste)
  teste <- data.frame(teste)
  colnames(teste) <- c("variable","value")
  teste <- teste %>%
    add_column(ID =anti_sars_cov2[x,1])
  variant <- rbind(variant,teste)
}

unique_var_name <- c("WT","Omicron","Gamma","Beta","Alpha","Delta","Epsilon","Eta","Kappa","Iota","Lambda","Mu")

ggplot(teste,aes(fill=variable,x=ID,y=as.numeric(value))) +
  geom_bar(position="fill",stat="identity") +
  scale_fill_manual("legend", 
                    values = c("WT"= "#ea5545", "Omicron"="#f46a9b","Gamma"="#ef9b20",
                               "Beta"="#edbf33", "Alpha"="#7c1158","Delta"="#ede15b",
                               "Epsilon"="#bdcf32", "Eta"="#bdcf32","Kappa"="#87bc45",
                               "Iota"="#27aeef","Lambda"= "#b33dc6","Mu"="#4421af")) +
  xlab("Repertoire") +
  ylab("Ratio of the neutralizing antibodies that bind to each variant")




teste <- variant
for(x in unique_var_name){
  teste$variable[grepl(x,teste$variable)] <- x
}









#### not binding ####
not_binding_map <- data.frame()

for(i in dir){
  sample <- strsplit(i, split = "/")[[1]][8]
  
  file_in_path <- paste(dir[1],"/",sample,"/",sample,"report.csv",
                        sep="")
  print(file_in_path)
  if(file.exists(file_in_path)){
    df<- read.csv(file_in_path)
    
    df = df[!(is.na(df$Expanyion) | df$Expanyion==""),]
    
    binds_to_unique <- unique(df$Binds.to)
    not_bind_to_unique <- unique(df$Doesn.t.Bind.to)
    neutralize_unique <- unique(df$Neutralising.Vs)
    not_neutralize_unique <- unique(df$Not.Neutralising.Vs)
    
    for(x in binds_to_unique){
      temp <- strsplit(x,";")
      for(i in 1:length(temp[[1]])){
        a <- append(a,temp[[1]][i])
      }
      
    }
    
    a <- unique(a)
    
    temp_df <- data.frame(Repertoire=sample)
    names <- ""
    names <- colnames(temp_df)
    
    
    for(x in 1:length(a)){
      temp <- data.frame("a"=nrow(df[grep(a[x],df$Binds.to), ]))
      temp_df <- cbind(temp_df,temp)
      colnames(temp_df) <- append(names,a[x])
      names <- colnames(temp_df)
    }
    
    if(ncol(not_binding_map)==0){
      not_binding_map<- temp_df
      next
    }
    
    
    if(ncol(not_binding_map)==ncol(temp_df)){
      not_binding_map <- rbind(not_binding_map,temp_df)
    }else if(ncol(not_binding_map)>ncol(temp_df)){
      print(ncol(not_binding_map))
      print(ncol(temp_df))
      falta <- setdiff(not_binding_map, temp_df)
      for(x in 1:length(falta)){
        temp_df <- temp_df %>%
          add_column(falta[x])
      }
      not_binding_map <- rbind(not_binding_map,temp_df)
      
    }else if(ncol(not_binding_map)<ncol(temp_df)){

      falta <- setdiff(not_binding_map, temp_df)
      for(x in 1:length(falta)){
        not_binding_map <- not_binding_map %>%
          add_column(falta[x])    
      }
      not_binding_map <- rbind(not_binding_map,temp_df)
    }
  }
  
}
  
#### Neutralizing #####
neutralizing_map <- data.frame()

for(i in dir){
  sample <- strsplit(i, split = "/")[[1]][8]
  
  file_in_path <- paste(dir[1],"/",sample,"/",sample,"report.csv",
                        sep="")
  
  if(file.exists(file_in_path)){
    print(file_in_path)
    df<- read.csv(file_in_path)
    
    df = df[!(is.na(df$Expanyion) | df$Expanyion==""),]
    
    # binds_to_unique <- unique(df$Binds.to)
    # not_bind_to_unique <- unique(df$Doesn.t.Bind.to)
    neutralize_unique <- unique(df$Neutralising.Vs)
    print(neutralize_unique)
    # not_neutralize_unique <- unique(df$Not.Neutralising.Vs)
    
    for(x in neutralize_unique){
      temp <- strsplit(x,";")
      for(i in 1:length(temp[[1]])){
        a <- append(a,temp[[1]][i])
      }
      
    }
    
    a <- unique(a)
    
    temp_df <- data.frame(Repertoire=sample)
    names <- ""
    names <- colnames(temp_df)
    
    
    for(x in 1:length(a)){
      temp <- data.frame("a"=nrow(df[grep(a[x],df$Neutralising.Vs), ]))
      temp_df <- cbind(temp_df,temp)
      colnames(temp_df) <- append(names,a[x])
      names <- colnames(temp_df)
    }
    
    if(ncol(neutralizing_map)==0){
      neutralizing_map<- temp_df
      next
    }
    
    
    if(ncol(neutralizing_map)==ncol(temp_df)){
      neutralizing_map <- rbind(neutralizing_map,temp_df)
    }else if(ncol(neutralizing_map)>ncol(temp_df)){
      print(ncol(neutralizing_map))
      print(ncol(temp_df))
      falta <- setdiff(neutralizing_map, temp_df)
      for(x in 1:length(falta)){
        temp_df <- temp_df %>%
          add_column(falta[x])
      }
      neutralizing_map <- rbind(neutralizing_map,temp_df)
      
    }else if(ncol(neutralizing_map)<ncol(temp_df)){
      print(ncol(neutralizing_map))
      print(ncol(temp_df))
      falta <- setdiff(neutralizing_map, temp_df)
      for(x in 1:length(falta)){
        neutralizing_map <- neutralizing_map %>%
          add_column(falta[x])    
      }
      neutralizing_map <- rbind(neutralizing_map,temp_df)
    }
  }
  
}

#### Not neutralizing agains ####
not_neutralizing_map <- data.frame()

for(i in dir){
  sample <- strsplit(i, split = "/")[[1]][8]
  
  file_in_path <- paste(dir[1],"/",sample,"/",sample,"report.csv",
                        sep="")
  print(file_in_path)
  if(file.exists(file_in_path)){
    df<- read.csv(file_in_path)
    
    df = df[!(is.na(df$Expanyion) | df$Expanyion==""),]
    
    binds_to_unique <- unique(df$Binds.to)
    not_bind_to_unique <- unique(df$Doesn.t.Bind.to)
    neutralize_unique <- unique(df$Neutralising.Vs)
    not_neutralize_unique <- unique(df$Not.Neutralising.Vs)
    
    for(x in binds_to_unique){
      temp <- strsplit(x,";")
      for(i in 1:length(temp[[1]])){
        a <- append(a,temp[[1]][i])
      }
      
    }
    
    a <- unique(a)
    
    temp_df <- data.frame(Repertoire=sample)
    names <- ""
    names <- colnames(temp_df)
    
    
    for(x in 1:length(a)){
      temp <- data.frame("a"=nrow(df[grep(a[x],df$Not.Neutralising.Vs), ]))
      temp_df <- cbind(temp_df,temp)
      colnames(temp_df) <- append(names,a[x])
      names <- colnames(temp_df)
    }
    
    if(ncol(not_neutralizing_map)==0){
      not_neutralizing_map<- temp_df
      next
    }
    
    
    if(ncol(not_neutralizing_map)==ncol(temp_df)){
      not_neutralizing_map <- rbind(not_neutralizing_map,temp_df)
    }else if(ncol(not_neutralizing_map)>ncol(temp_df)){
      print(ncol(not_neutralizing_map))
      print(ncol(temp_df))
      falta <- setdiff(not_neutralizing_map, temp_df)
      for(x in 1:length(falta)){
        temp_df <- temp_df %>%
          add_column(falta[x])
      }
      not_neutralizing_map <- rbind(not_neutralizing_map,temp_df)
      
    }else if(ncol(not_neutralizing_map)<ncol(temp_df)){
      print(ncol(not_neutralizing_map))
      print(ncol(temp_df))
      falta <- setdiff(not_neutralizing_map, temp_df)
      for(x in 1:length(falta)){
        not_neutralizing_map <- not_neutralizing_map %>%
          add_column(falta[x])    
      }
      not_neutralizing_map <- rbind(not_neutralizing_map,temp_df)
    }
  }
  
}





#### Neutralizing ####
neutralizing_map <- data.frame()

for(i in dir){
  sample <- strsplit(i, split = "/")[[1]][8]
  
  file_in_path <- paste(dir[1],"/",sample,"/",sample,"report.csv",
                        sep="")
  
  if(file.exists(file_in_path)){
    print(file_in_path)
    df<- read.csv(file_in_path)
    
    df = df[!(is.na(df$Expanyion) | df$Expanyion=="" | df$Expanyion=="NO" | df$Neutralising.Vs==""),]
    
    neutralize_unique <- unique(df$Neutralising.Vs)

    a <- list()
    for(x in neutralize_unique){
      temp <- strsplit(x,";")
      for(i in 1:length(temp[[1]])){
        a <- append(a,temp[[1]][i])
      }
      
    }
    
    a <- unique(a)
    if(length(a)==0){
      neutralizing_map[sample,] <- 0
      neutralizing_map[sample,"Repertoire"] <- sample
      next
    }
    
    temp_df <- data.frame(Repertoire=sample)
    names <- ""
    names <- colnames(temp_df)
    
    
    for(x in 1:length(a)){
      temp <- data.frame("a"=nrow(df[grep(a[x],df$Neutralising.Vs), ]))
      temp_df <- cbind(temp_df,temp)
      colnames(temp_df) <- append(names,a[x])
      names <- colnames(temp_df)
    }
    
    if(ncol(neutralizing_map)==0){
      neutralizing_map<- temp_df
      next
    }
    
    if(ncol(neutralizing_map) < ncol(temp_df)){

      
      falta <- setdiff(colnames(neutralizing_map),colnames(temp_df))
      colunas <- colnames(temp_df)
      for(x in 1:length(falta)){
        temp_df <- temp_df %>%
          add_column(new_column=0)

      }
      colnames(temp_df) <- append(colunas, falta)
      
      falta <- setdiff(colnames(temp_df),colnames(neutralizing_map))
      colunas <- colnames(neutralizing_map)
      for(x in 1:length(falta)){
        neutralizing_map <- neutralizing_map %>%
          add_column(new_column=0)

      }
      colnames(neutralizing_map) <- append(colunas, falta)
      
      neutralizing_map <- rbind(neutralizing_map,temp_df)
    }else if(ncol(neutralizing_map) > ncol(temp_df)){
      
      
      falta <- setdiff(colnames(temp_df),colnames(neutralizing_map))
      colunas <- colnames(neutralizing_map)
      if(length(falta) != 0){
      for(x in 1:length(falta)){
        neutralizing_map <- neutralizing_map %>%
          add_column(new_column=0)
        
      }}
      colnames(neutralizing_map) <- append(colunas, falta)

      falta <- setdiff(colnames(neutralizing_map),colnames(temp_df))

      colunas <- colnames(temp_df)
      if(length(falta) != 0){
      for(x in 1:length(falta)){
        temp_df <- temp_df %>%
          add_column(new_column=0)
        
      }}
      colnames(temp_df) <- append(colunas, falta)
      neutralizing_map <- rbind(neutralizing_map,temp_df)
    }else{
      neutralizing_map <- rbind(neutralizing_map,temp_df)
    }
  }
  
}
neutralizing_map <- neutralizing_map[-c(39),]

a <- !grepl("weak",colnames(neutralizing_map))
ct = 0
for(x in 1:length(a)){
  if(a[x]==FALSE){
    neutralizing_map<- neutralizing_map[,-(x-ct)]
    ct = ct+1
  }
}



a <- as.list(grep("SARS-CoV2|SARS_CoV2|SARS-COV2",colnames(neutralizing_map)))
anti_sars_cov2 <- neutralizing_map %>% select(1)

for(i in a){
  anti_sars_cov2 <- cbind(anti_sars_cov2,neutralizing_map %>% select(i))
}
percentage_neutralize <- list()

for(i in 1:nrow(anti_sars_cov2)){
  sample <- anti_sars_cov2[i,1]
  print(sample)
  
  percentage_neutralize <- append(percentage_neutralize,sum(anti_sars_cov2[i,2:ncol(anti_sars_cov2)]))
}

anti_sars_cov2$neutralize_sars_cov2 <- percentage_neutralize

# a <- grep("SARS-CoV2|SARS_CoV2|SARS-COV2",colnames(neutralizing_map))

#### variantes ####
variant <- data.frame()
for(x in 1:nrow(anti_sars_cov2)){
  teste <- t(anti_sars_cov2[x,2:31])
  teste <- cbind(newColName = rownames(teste), teste)
  rownames(teste) <- 1:nrow(teste)
  teste <- data.frame(teste)
  colnames(teste) <- c("variable","value")
  teste <- teste %>%
    add_column(ID =anti_sars_cov2[x,1])
  variant <- rbind(variant,teste)
}

unique_var_name <- c("Mu","WT","Omicron","Gamma","Beta","Alpha","Delta","Epsilon","Eta","Kappa","Iota","Lambda")

for(x in unique_var_name){
  variant[grep(x,variant$variable),]$variable <- x
}


ggplot(variant,aes(fill=variable,x=ID,y=as.numeric(value))) +
  geom_bar(position="fill",stat="identity") +
  scale_fill_manual("legend", 
                    values = c("WT"= "#ea5545", "Omicron"="#f46a9b","Gamma"="#ef9b20",
                               "Beta"="#edbf33", "Alpha"="#7c1158","Delta"="#ede15b",
                               "Epsilon"="#bdcf32", "Eta"="#bdcf32","Kappa"="#87bc45",
                               "Iota"="#27aeef","Lambda"= "#b33dc6","Mu"="#4421af")) +
  xlab("Repertoire") +
  ylab("Ratio of the binding antibodies that neutralizes to each variant")




teste <- variant
for(x in unique_var_name){
  teste$variable[grepl(x,teste$variable)] <- x
}


