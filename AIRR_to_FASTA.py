#usr/bin/env python3
import sys
from Bio.Seq import Seq

filename = sys.argv[1]
f = open(filename,"r")

header = f.readline().split("\t")
name_indx = header.index("sequence_id")
seq_indx = header.index("sequence")

fasta = open(filename.replace(".tsv",".fasta"),"w")
for x in f:
	tmp = x.split("\t")
	fasta.write(">"+tmp[name_indx]+"\n"+str(Seq(tmp[seq_indx]).translate())+"\n")