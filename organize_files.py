#!/usr/bin/env python3
#change file names for covid samples
import os
# path = "/home/ufmg/joaodgervasio/2sagarana/temp/"
# high_dir = os.listdir(path)
# high_dir.sort() 

# for i in high_dir:
# 	if i.find(".") == -1:
# 		print(i)
# 		os.system("wc -l "+path+""+i+"/"+i+"_db-pass_unique_YClon_clone_report.tsv >> "+path+"count.txt")
	# try:
	# 	ini = open(path+"/"+i+"/"+i+"_db-pass_unique_YClon_clonotyped.tsv","r")
	# except:
	# 	continue

	# clone_id ={}
	# seq_in = 0
	# clone_in = 0

	# for x in ini:
	# 	if x.find("sequence")!= -1:
	# 		tmp = x.strip().split("\t")
	# 		seq_in = tmp.index("sequence")
	# 		clone_in = tmp.index("clone_id")
	# 	else:
	# 		tmp = x.strip().split("\t")
	# 		try:
	# 			clone_id[tmp[seq_in]] = tmp[clone_in]
	# 		except:
	# 			continue
	# ini.close()

	# out = open(path+"/"+i+"/"+i+"_db-pass_YClon_clonotyped.tsv", "w")
	# try:
	# 	ref = open(path+"/"+i+"/"+i+"_db-pass.tsv", "r")
	# except:
	# 	continue

	# for x in ref:
	# 	if x.find("sequence")!= -1:
	# 		out.write(x.strip()+"\tclone_id\n")
	# 		tmp = x.strip().split("\t")
	# 		seq_in = tmp.index("sequence")
	# 	else:
	# 		tmp = x.strip().split("\t")
	# 		try:
	# 			out.write(x.strip()+"\t"+clone_id[tmp[seq_in]]+"\n")
	# 		except:
	# 			continue

# import os
# path = "/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/"
s = "A20 GV144 GV92 ID144 ID268 SP27 SP47 A24 GV106 GV146 ID124 ID226 ID310 SP39 A65 GV143 GV47 ID143 ID248 SP138 SP40"
high_dir = s.split(" ")
# high_dir = os.listdir(path)

for i in high_dir:
# 	if i.find(".") == -1:
# 		print(i)
# 		os.system("wc -l /Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/"+i+"/*_db-pass.tsv  >> /Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/count.txt")
		os.system("HWE3Ns%Da$ | scp joaodgervasio@sarapalha.icb.ufmg.br:/home/ufmg/joaodgervasio/2sagarana/temp/"+i+"/"+i+"_db-pass_unique_YClon_clone_report.tsv "+"/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/"+i)
	# 	files = os.listdir(os.path.join(path,i))
	# 	direct = os.path.join(path,i)
	# 	for x in files:
	# 		if x.find("_L001") != -1:
	# 			tmp = x.split("_")
	# 			# print(tmp)
	# 			os.rename(os.path.join(direct,x),os.path.join(direct,tmp[0]+tmp[1]+x.split("_L001")[1]))
	# # print(i)
