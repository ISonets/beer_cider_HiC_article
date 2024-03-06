#!/bin/bash
REF_GENOME=/home/sonets/CL01/CL01.fasta
mkdir fastq/
ln -s /hdd20tb/bioinf/analysis/hicmicrobiome/run_2020_08/B2/CL01/fastq/IN_Hi_C_R1.fastq.gz fastq/Hi_C_R1.fastq.gz
ln -s /hdd20tb/bioinf/analysis/hicmicrobiome/run_2020_08/B2/CL01/fastq/IN_Hi_C_R2.fastq.gz fastq/Hi_C_R2.fastq.gz

# prepare reads
bwa index $REF_GENOME

#alignment
bwa mem -t 16 $REF_GENOME fastq/Hi_C_R1.fastq.gz fastq/Hi_C_R2.fastq.gz > CL01_aln.sam

#samtools
samtools view -S -b CL01_aln.sam -o CL01_aln.bam
samtools sort -@ 16 CL01_aln.bam > CL01_aln_sorted.bam
samtools index CL01_aln_sorted.bam

#stats
samtools flagstat CL01_aln_sorted.bam
