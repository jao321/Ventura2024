#!/bin/sh
#Author joaodgervasio
#PBS -N preproc_cov_samples
#PBS -e deu_ruim_pre_proc.err
#PBS -o o_que_rolou_pre_proc.log
#PBS -q fila64
#PBS -l select=1:ncpus=24
#PBS -M joaodgervasio@gmail.com

dir="/Users/joaogervasio/Documents/projeto_covid_doutorado/LuWerneck_24_01_2023-380046667/FASTQ_Generation_2023-01-26_22_37_54Z-649784140"

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

	python3 /Users/joaogervasio/Documents/YClon.py "$pasta"/"${sample[0]}"_db-pass_unique.tsv
	

	# gzip "$pasta"/R1.fastq

	# gzip "$pasta"/R2.fastq




done