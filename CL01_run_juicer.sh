#!/bin/bash

RESTRICTASE=HpaII
REF_GENOME=/home/sonets/CL01/CL01.fasta
JUICER_PATH=/home/sonets/juicer-1.6
NUM_THREADS=16
GENOME_NAME=CL01_v2

# must do before once !
#conda activate py37

# prepare reads
mkdir fastq
ln -s /hdd20tb/bioinf/analysis/hicmicrobiome/run_2020_08/B2/CL01/fastq/IN_Hi_C_R1.fastq.gz fastq/Hi_C_R1.fastq.gz
ln -s /hdd20tb/bioinf/analysis/hicmicrobiome/run_2020_08/B2/CL01/fastq/IN_Hi_C_R2.fastq.gz fastq/Hi_C_R2.fastq.gz

# prepare reads
bwa index $REF_GENOME

# prepare restrict. sites file
python $JUICER_PATH/misc/generate_site_positions.py $RESTRICTASE $GENOME_NAME $REF_GENOME

# map reads - just get merged_nodups
$JUICER_PATH/CPU/juicer.sh -S early -z $REF_GENOME -g $GENOME_NAME -s $RESTRICTASE -y ./${GENOME_NAME}_HpaII.txt -D $JUICER_PATH/CPU -p $GENOME_NAME -t $NUM_THREADS

# reorder contigs
rm -fr 3d-dna; mkdir 3d-dna; cd 3d-dna
$JUICER_PATH/3d-dna/run-asm-pipeline.sh -i 5000 --polisher-input-size 5000 $REF_GENOME ../aligned/merged_nodups.txt

# stats
perl $JUICER_PATH/CPU/scripts/common/statistics.pl -s ${GENOME_NAME}_HpaII.txt ../aligned/merged_nodups.txt
