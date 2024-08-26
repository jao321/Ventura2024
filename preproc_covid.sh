#!/bin/sh
dir="path/to_directory_with_fastq_files"

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

	MaskPrimers.py score -s "$pasta"/"${sample[0]}"_quality-pass.fastq -p primers_seq.fasta --outdir "$pasta" --outname "${sample[0]}" --mode tag --fasta

	AssignGenes.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -b igblast --organism human --loci ig --format blast --exec igblastn --outdir "$pasta" --nproc 24

	MakeDB.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -i "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7 --format airr -r /imgt/human/vdj --outdir "$pasta" --outname "${sample[0]}" --extended

	rm "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7

	YClon "$pasta"/"${sample[0]}"_db-pass.tsv




done