#!/bin/sh
#Author joaodgervasio
#PBS -N preproc_cov_samples
#PBS -e deu_ruim.err
#PBS -o o_que_rolou.log
#PBS -q fila64
#PBS -l select=1:ncpus=24
#PBS -M joaodgervasio@gmail.com

echo "vai rodar"

# Rscript /home/joaodgervasio/2sagarana/drop_duplicates_from_tsv.R
LC_ALL=en_US.UTF-8 Rscript /home/joaodgervasio/2sagarana/analysis_sagarana.R

echo "rodou? será?"