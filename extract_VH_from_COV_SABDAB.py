#!/usr/bin/env python3
f = open("/Users/joaogervasio/Documents/projeto_covid_doutorado/CoV-AbDab_201222.csv",'r')

header = f.readline().split(",")
name_indx = header.index("Name")
seq_indx = header.index("VHorVHH")

fasta = open("/Users/joaogervasio/Documents/projeto_covid_doutorado/cov-abdab_201222.fasta","w")
for x in f:
	tmp = x.split(",")
	fasta.write(">"+tmp[name_indx]+"\n"+tmp[seq_indx]+"\n")
