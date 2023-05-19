#!/bin/sh
dir="/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140/anotar"

for entry in "$dir"/*
do
   pasta="$entry"

	for arquivo in "$pasta"/*
	do
	   gzip -d "$arquivo"
	done

	for arquivo in "$pasta"/*
	do
		stri="$(basename -- "$arquivo")"

		if [[ "$stri" =~ "R1" ]]; then
			mv "$pasta"/"$stri" "$pasta"/R1.fastq
		elif [[ "$arquivo" =~ "R2" ]]; then
			mv "$pasta"/"$stri" "$pasta"/R2.fastq
		fi
	done

	foldername=${pasta##*/}
	IFS='-'
	read -a sample <<< "$foldername"


	AssemblePairs.py align -1 "$pasta"/R1.fastq -2 "$pasta"/R2.fastq --nproc 8 --rc tail --coord illumina --outdir "$pasta" --outname "${sample[0]}"

	#gzip "$pasta"/R1.fastq

	#gzip "$pasta"/R2.fastq

	FilterSeq.py quality -s "$pasta"/"${sample[0]}"_assemble-pass.fastq -q 30 --outdir "$pasta" --outname "${sample[0]}"

	MaskPrimers.py score -s "$pasta"/"${sample[0]}"_quality-pass.fastq -p /Users/joaogervasio/Documents/projeto_covid_doutorado/primers_seq.fasta --outdir "$pasta" --outname "${sample[0]}" --mode tag --fasta

	AssignGenes.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -b /Users/joaogervasio/Downloads/igblast --organism human --loci ig --format blast --exec /Users/joaogervasio/Downloads/local_usr/igblastn --outdir "$pasta" --nproc 24

	MakeDB.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -i "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7 --format airr -r /Users/joaogervasio/Downloads/imgt/human/vdj --outdir "$pasta" --outname "${sample[0]}" --extended

	rm "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7




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
