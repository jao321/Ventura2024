#!/usr/bin/env python
import pandas as pd
import sys
import time

ini =time.time()
#get metadata covabdab
covabdab = pd.read_table("/home/joaodgervasio/2sagarana/CoV-AbDab_201222.csv", sep=",")
covabdab = covabdab.reset_index()

print("read_cov_abdab")
print(time.time()-ini)

clones = pd.read_table(sys.argv[1].split("temp")[0]+"temp/"+sys.argv[1].split("/")[-1].split("_")[0]+"/"+sys.argv[1].split("/")[-1].split("_")[0]+"_db-pass_unique_YClon_clonotyped.tsv",sep="\t")
count = pd.read_table(sys.argv[1].split("temp")[0]+"temp/"+sys.argv[1].split("/")[-1].split("_")[0]+"/"+sys.argv[1].split("/")[-1].split("_")[0]+"_db-pass_unique_YClon_clone_report.tsv",sep="\t")
count = count[["seq_count","clone_id"]]
clones = clones.merge(count,how='left')
del count
clones = clones.reset_index()

print("organized clones")
print(time.time()-ini)

#read the m8 file with alignment of our data against cov-abdab
if sys.argv[1].find(".gz") != -1:
	al = pd.read_table(sys.argv[1], header = None, names=["qseqid","sseqid", \
		"pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore"], compression='gzip')
else:
	al = pd.read_table(sys.argv[1], header = None, names=["qseqid","sseqid", \
		"pident","length","mismatch","gapopen","qstart","qend","sstart","send","evalue","bitscore"])

al = al[["qseqid","sseqid","pident","length"]]
#filter for alignment with more than 60% of identity and coverage of 112 aminoacids
al = al.loc[(al["pident"] >= 0.9)&(al["length"]>110)]
#sort and remove duplicates
al = al.sort_values(al.columns[2], ascending=False)
al = al[["qseqid","sseqid"]]
al = al.drop_duplicates(subset=[al.columns[0]],keep='first')
#al = al.drop_duplicates(subset=[al.columns[1]],keep='first')
al = al.reset_index()
# al.to_csv(argv[1].replace("cov_abdab.m8","_ab.tsv"),sep="\t")
# exit()
al["Binds to"] = ""
al["Doesn't Bind to"] = ""
al["Neutralising Vs"] = ""
al["Not Neutralising Vs"] = ""
al["Expanyion"] = ""

print("organized alignment")
print(time.time()-ini)

# for index, row in al.iterrows():
for index in range(0,len(al)):
	cl_row = clones.loc[clones["sequence_id"]==al.at[index,"qseqid"]]
	if cl_row["seq_count"][int(cl_row["index"])] >= 5:
		al.at[index,"Expanyion"] = "YES"
	else:
		al.at[index,"Expanyion"] = "NO"
	row = covabdab.loc[covabdab['Name']==al.at[index,"sseqid"]] #gets the row from covabdab that is correspondent to the antibody hit
	al.at[index,"Binds to"] = row["Binds to"][int(row["index"])]
	al.at[index,"Doesn't Bind to"] = row["Doesn't Bind to"][int(row["index"])]
	al.at[index,"Not Neutralising Vs"] = row["Not Neutralising Vs"][int(row["index"])]
	al.at[index,"Neutralising Vs"] = row["Neutralising Vs"][int(row["index"])]

print("done")
print(time.time()-ini)

al.to_csv(sys.argv[1].replace(sys.argv[1].split("/")[-1],sys.argv[1].split("/")[-1].split("_")[0]+"report.csv"))








