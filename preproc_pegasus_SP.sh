#!/bin/bash
#SBATCH -J rep_pipe_SP
#SBATCH --time=3-27:00:00
#SBATCH --mem=32000
#SBATCH --ntasks=1
#S BATCH --gres=gpu:1 
#S BATCH --gpus-per-task=1
#SBATCH --cpus-per-task=12
#SBATCH --nodes=1
#S BATCH --chdir=/homes/gervasio/
#SBATCH --mail-user=stat0429@ox.ac.uk
#SBATCH --mail-type=ALL
#SBATCH --mail-type=begin
#SBATCH --mail-type=end
#SBATCH --partition=high-opig-cpu
#SBATCH --clusters=swan
#SBATCH -w naga04.cpu.stats.ox.ac.uk
#SBATCH --output=/vols/opig/users/gervasio/rep_pipe_SP_log.out
#SBATCH --error=/vols/opig/users/gervasio/rep_pipe_SP_oops_did_not_work.out

source /vols/opig/users/gervasio/local/bin/activate

dir="/vols/opig/users/gervasio/covidao/samples/SP"


for entry in "$dir"/*
do

   pasta="$entry"


	foldername=${pasta##*/}
	#IFS='-'
	read -a sample <<< "$foldername"

	# python3 /vols/opig/users/gervasio/covidao/local_usr/AssemblePairs.py align -1 "$pasta"/R1.fastq -2 "$pasta"/R2.fastq --nproc 24 --rc tail --coord illumina --outdir "$pasta" --outname "${sample[0]}" --minlen 50 --log "${sample[0]}".log --failed

	# python3 /vols/opig/users/gervasio/covidao/local_usr/FilterSeq.py quality -s "$pasta"/"${sample[0]}"_assemble-pass.fastq -q 30 --outdir "$pasta" --outname "${sample[0]}" --log "${sample[0]}"_quality.log --failed

	# python3 /vols/opig/users/gervasio/covidao/local_usr/MaskPrimers.py score -s "$pasta"/"${sample[0]}"_quality-pass.fastq -p /vols/opig/users/gervasio/covidao/primers_seq.fasta --outdir "$pasta" --outname "${sample[0]}" --mode tag --fasta --log "${sample[0]}"_primer.log --failed

	python3 /vols/opig/users/gervasio/covidao/local_usr/AssignGenes.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -b /vols/opig/users/gervasio/covidao/local_usr/igblast --organism human --loci ig --format blast --exec /vols/opig/users/gervasio/covidao/local_usr/igblastn --outdir "$pasta" --nproc 24

	python3 /vols/opig/users/gervasio/covidao/local_usr/MakeDb.py igblast -s "$pasta"/"${sample[0]}"_primers-pass.fasta -i "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7 --format airr -r /vols/opig/users/gervasio/covidao/imgt/human/vdj --outdir "$pasta" --outname "${sample[0]}" --extended 
	
	rm "$pasta"/"${sample[0]}"_primers-pass_igblast.fmt7





done