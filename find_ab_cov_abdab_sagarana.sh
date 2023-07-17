#!/bin/sh
#Author joaodgervasio
#PBS -N preproc_cov_samples
#PBS -e deu_ruim_pre_proc.err
#PBS -o o_que_rolou_pre_proc.log
#PBS -q fila64
#PBS -l select=1:ncpus=24
#PBS -M joaodgervasio@gmail.com

#chmod 777 /home/joaodgervasio/2sagarana/mmseqs/bin/mmseqs

# /home/joaodgervasio/2sagarana/mmseqs/bin/mmseqs createdb /home/joaodgervasio/2sagarana/cov-abdab_201222.fasta cov-abdabDB
	
# /home/joaodgervasio/2sagarana/mmseqs/bin/mmseqs createindex cov-abdabDB tempor

dir="/home/joaodgervasio/2sagarana/temp"

for entry in "$dir"/*
do
   pasta="$entry"

	# for arquivo in "$pasta"/*
	# do
	#    gzip -d "$arquivo"
	# done

	# for arquivo in "$pasta"/*
	# do
	# 	stri="$(basename -- "$arquivo")"

	# 	if [[ "$stri" =~ "R1" ]]; then
	# 		mv "$pasta"/"$stri" "$pasta"/R1.fastq
	# 	elif [[ "$arquivo" =~ "R2" ]]; then
	# 		mv "$pasta"/"$stri" "$pasta"/R2.fastq
	# 	fi
	# done

	foldername=${pasta##*/}
	IFS='-'
	read -a sample <<< "$foldername"

	#/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/AIRR_to_FASTA.py "$pasta"/"${sample[0]}"_db-pass_unique_YClon_clonotyped.tsv

	#/home/joaodgervasio/2sagarana/mmseqs/bin/mmseqs easy-search "$pasta"/"${sample[0]}"_db-pass_unique_YClon_clonotyped.fasta cov-abdabDB "$pasta"/"${sample[0]}"_cov_abdab.m8 tempor

	/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/top_ab_from_cov_abdab.py "$pasta"/"${sample[0]}"_cov_abdab.m8




done




# for entry in "$dir"/*
# do
#    gzip -d "$entry"
# done

# for entry in "$dir"/*
# do
# 	stri="$(basename -- "$entry")"

# 	if [[ "$stri" =~ "R1" ]]; then
# 		mv "$stri" R1.fastq
# 	elif [[ "$entry" =~ "R2" ]]; then
# 		mv "$stri" R2.fastq
# 	fi
# done

# foldername=${PWD##*/}
# IFS='-'
# read -a sample <<< "$foldername"


# AssemblePairs.py align -1 R1.fastq -2 R2.fastq --nproc 8 --rc tail --coord illumina --outname "${sample[0]}"

# FilterSeq.py quality -s "${sample[0]}"_assemble-pass.fastq -q 30 --outname "${sample[0]}"

# MaskPrimers.py score -s "${sample[0]}"_quality-pass.fastq -p /Users/joaogervasio/Documents/projeto_covid_doutorado/primers_seq.fasta --outname "${sample[0]}" --mode tag --fasta

# AssignGenes.py igblast -s "${sample[0]}"_primers-pass.fasta -b /Users/joaogervasio/Downloads/igblast --organism human --loci ig --format blast --exec /Users/joaogervasio/Downloads/local_usr/igblastn

# MakeDB.py igblast -s "${sample[0]}"_primers-pass.fasta -i "${sample[0]}"_primers-pass_igblast.fmt7 --format airr -r /Users/joaogervasio/Downloads/imgt/human/vdj --outname "${sample[0]}" --extended
