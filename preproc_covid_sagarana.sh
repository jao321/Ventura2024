#!/bin/sh
#Author joaodgervasio
#PBS -N preproc_cov_samples
#PBS -e SP_pre_err.err
#PBS -o SP_pre_log.log
#PBS -q fila64
#PBS -l select=1:ncpus=12
#PBS -M joaodgervasio@gmail.com

dir="/home/ufmg/joaodgervasio/2sagarana/covid_sample/SP"

#comandos

# chmod +x /home/joaodgervasio/2sagarana/yclon/bin/activate

# source /home/joaodgervasio/2sagarana/yclon/bin/activate

# pip3 list

echo "Some console message"

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
	#IFS='-'
	read -a sample <<< "$foldername"

	echo "Some console message 2"

	/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/local_usr/AssemblePairs.py align -1 "$pasta"/R1.fastq -2 "$pasta"/R2.fastq --nproc 24 --rc tail --coord illumina --outdir "$pasta" --outname "${sample[0]}" --minlen 50 --log "${sample[0]}".log --failed

	/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/local_usr/FilterSeq.py quality -s "$pasta"/"${sample[0]}"_assemble-pass.fastq -q 30 --outdir "$pasta" --outname "${sample[0]}" --log "${sample[0]}".log --failed

	/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/local_usr/MaskPrimers.py score -s "$pasta"/"${sample[0]}"_quality-pass.fastq -p /home/joaodgervasio/2sagarana/primers_seq.fasta --outdir "$pasta" --outname "${sample[0]}" --mode tag --fasta --log "${sample[0]}".log --failed

	/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/local_usr/AssignGenes.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -b /home/joaodgervasio/2sagarana/local_usr/igblast --organism human --loci ig --format blast --exec /home/joaodgervasio/2sagarana/local_usr/igblastn --outdir "$pasta" --nproc 12 --log "${sample[0]}".log --failed

	/home/joaodgervasio/2sagarana/miniconda3/bin/python /home/joaodgervasio/2sagarana/local_usr/MakeDB.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -i "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7 --format airr -r /home/joaodgervasio/2sagarana/imgt/human/vdj --outdir "$pasta" --outname "${sample[0]}" --extended --log "${sample[0]}".log --failed

	#/home/joaodgervasio/2sagarana/miniconda/bin/python /home/joaodgervasio/2sagarana/YClon.py "$pasta"/"${sample[0]}"_db-pass.tsv
	
	rm "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7

	# gzip "$pasta"/R1.fastq

	# gzip "$pasta"/R2.fastq




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
