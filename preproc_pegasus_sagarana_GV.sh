#!/bin/bash
#SBATCH -J rep_pipe_GV
#SBATCH --time=3-27:00:00
#SBATCH --mem=20000
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
#SBATCH -w naga03.cpu.stats.ox.ac.uk
#SBATCH --output=/vols/opig/users/gervasio/rep_pipe_GV_log.out
#SBATCH --error=/vols/opig/users/gervasio/rep_pipe_GV_oops_did_not_work.out

source /vols/opig/users/gervasio/local/bin/activate

dir="/vols/opig/users/gervasio/covidao/sagarana/GV/GV47"


for entry in "$dir"/*
do

   pasta="$entry"

sample="GV47"
# 	foldername=${pasta##*/}
# 	#IFS='-'
# 	read -a sample <<< "$foldername"

python3 /vols/opig/users/gervasio/covidao/local_usr/AssemblePairs.py align -1 "$dir"/R1.fastq -2 "$dir"/R2.fastq --nproc 24 --rc tail --coord illumina --outdir "$dir" --outname "$sample" --minlen 50 --log "$sample".log --failed

python3 /vols/opig/users/gervasio/covidao/local_usr/FilterSeq.py quality -s "$dir"/"$sample"_assemble-pass.fastq -q 30 --outdir "$dir" --outname "$sample" --log "$sample"_quality.log --failed

python3 /vols/opig/users/gervasio/covidao/local_usr/MaskPrimers.py score -s "$dir"/"$sample"_quality-pass.fastq -p /vols/opig/users/gervasio/covidao/primers_seq.fasta --outdir "$dir" --outname "$sample" --mode tag --fasta --log "$sample"_primer.log --failed

python3 /vols/opig/users/gervasio/covidao/local_usr/AssignGenes.py igblast -s "$dir"/"$sample"_primers-pass.fasta -b /vols/opig/users/gervasio/covidao/local_usr/igblast --organism human --loci ig --format blast --exec /vols/opig/users/gervasio/covidao/local_usr/igblastn --outdir "$dir" --nproc 24

python3 /vols/opig/users/gervasio/covidao/local_usr/MakeDb.py igblast -s "$dir"/"$sample"_primers-pass.fasta -i "$dir"/"$sample"_primers-pass_igblast.fmt7 --format airr -r /vols/opig/users/gervasio/covidao/imgt/human/vdj --outdir "$dir" --outname "$sample" --extended 

rm "$dir"/"$sample"_primers-pass_igblast.fmt7




# source /vols/opig/users/gervasio/local/bin/activate

dir="/vols/opig/users/gervasio/covidao/sagarana/GV/GV51"


# for entry in "$dir"/*
# do

#    pasta="$entry"

sample="GV51"
# 	foldername=${pasta##*/}
# 	#IFS='-'
# 	read -a sample <<< "$foldername"

python3 /vols/opig/users/gervasio/covidao/local_usr/AssemblePairs.py align -1 "$dir"/R1.fastq -2 "$dir"/R2.fastq --nproc 24 --rc tail --coord illumina --outdir "$dir" --outname "$sample" --minlen 50 --log "$sample".log --failed

python3 /vols/opig/users/gervasio/covidao/local_usr/FilterSeq.py quality -s "$dir"/"$sample"_assemble-pass.fastq -q 30 --outdir "$dir" --outname "$sample" --log "$sample"_quality.log --failed

python3 /vols/opig/users/gervasio/covidao/local_usr/MaskPrimers.py score -s "$dir"/"$sample"_quality-pass.fastq -p /vols/opig/users/gervasio/covidao/primers_seq.fasta --outdir "$dir" --outname "$sample" --mode tag --fasta --log "$sample"_primer.log --failed

python3 /vols/opig/users/gervasio/covidao/local_usr/AssignGenes.py igblast -s "$dir"/"$sample"_primers-pass.fasta -b /vols/opig/users/gervasio/covidao/local_usr/igblast --organism human --loci ig --format blast --exec /vols/opig/users/gervasio/covidao/local_usr/igblastn --outdir "$dir" --nproc 24

python3 /vols/opig/users/gervasio/covidao/local_usr/MakeDb.py igblast -s "$dir"/"$sample"_primers-pass.fasta -i "$dir"/"$sample"_primers-pass_igblast.fmt7 --format airr -r /vols/opig/users/gervasio/covidao/imgt/human/vdj --outdir "$dir" --outname "$sample" --extended 

rm "$dir"/"$sample"_primers-pass_igblast.fmt7
# done