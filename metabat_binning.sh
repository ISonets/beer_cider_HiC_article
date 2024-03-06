#!/bin/bash
eval "$(/tools/bin/conda3.sh)"
conda activate hic_mag

DATADIR='/store/bioinf/data/own/run_2022_01/'
N_THREADS=60
# Enter working directory
cd beverages/

for name in C34 # C30 C31 C33
do
	#---------Megahit--------
	megahit -t $N_THREADS -1 $name/trimmomatic/output_forward_paired.fq.gz -2 $name/trimmomatic/output_reverse_paired.fq.gz -r $name/trimmomatic/output_merged.fastq.gz -o $name/megahit
	bwa index $name/megahit/final.contigs.fa

	#-----------WGS binning by Metabat------------
	bwa mem -t $N_THREADS -o $name/megahit_prepare_for_binning.sam $name/megahit/final.contigs.fa ${DATADIR}/${name}_WGS_R1.fastq.gz ${DATADIR}/${name}_WGS_R2.fastq.gz
	samtools sort $name/megahit_prepare_for_binning.sam -@$N_THREADS -o $name/megahit_prepare_for_binning.bam
	rm $name/megahit_prepare_for_binning.sam
	metabat2 -i $name/megahit/final.contigs.fa $name/megahit_prepare_for_binning.bam -o $name/metabat_out/bin -v -t $N_THREADS
	jgi_summarize_bam_contig_depths --outputDepth $name/depth_metabat.tsv $name/megahit_prepare_for_binning.bam
done
