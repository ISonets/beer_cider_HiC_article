#!/bin/bash
eval "$(/tools/bin/conda3.sh)"

DATADIR='/store/bioinf/data/own/run_2022_01/'

#Steps
WGS_PROCESS=yes
HI_C_PROC=yes
PROFILING=yes
ASSEMBLY=yes
HI_C_BINNING=yes


#tools
MetaPhlan=yes
MiCop=yes


N_THREADS=60
ENZYME=DpnII

ADAPTER_A=AGATCGGAAGAGCACACGTCTGAACTCCAGTCA
ADAPTER_B=AGATCGGAAGAGCGTCGTGTAGGGAAAGAGTGT


for name in B32 C30 C31 C33 C34
do
if [ $WGS_PROCESS = 'yes' ];
then
#-------------fastqc--------------
	mkdir $name
	mkdir ${name}/fastqc
	conda activate bioinf_v1
	fastqc -o ${name}/fastqc -f fastq -t $N_THREADS ${DATADIR}/${name}_WGS_R1.fastq.gz ${DATADIR}/${name}_WGS_R2.fastq.gz ${DATADIR}/${name}_HiC_R1.fastq.gz ${DATADIR}/${name}_HiC_R2.fastq.gz
	conda activate hicmag_py37
	mkdir ${name}/seqprep
	SeqPrep -f ${DATADIR}/${name}_WGS_R1.fastq.gz -r ${DATADIR}/${name}_WGS_R2.fastq.gz -1 ${name}/seqprep/unmerged1.fastq.gz -2 ${name}/seqprep/unmerged2.fastq.gz -s ${name}/seqprep/merged.fastq.gz -A $ADAPTER_A -B $ADAPTER_B
	conda activate hic_mag
	mkdir ${name}/trimmomatic
	trimmomatic PE -threads $N_THREADS  -phred33 ${name}/seqprep/unmerged1.fastq.gz ${name}/seqprep/unmerged2.fastq.gz ${name}/trimmomatic/output_forward_paired.fq.gz ${name}/trimmomatic/output_forward_unpaired.fq.gz ${name}/trimmomatic/output_reverse_paired.fq.gz ${name}/trimmomatic/output_reverse_unpaired.fq.gz SLIDINGWINDOW:4:15 MINLEN:115 LEADING:3
	trimmomatic SE -threads $N_THREADS  -phred33 ${name}/seqprep/merged.fastq.gz ${name}/trimmomatic/output_merged.fastq.gz SLIDINGWINDOW:4:15 MINLEN:80 LEADING:3
fi

if [ $ASSEMBLY = 'yes' ];
then
#-----------ASSEMBLING---------
	conda activate hicmag_py37
	spades.py --meta -1 ${name}/trimmomatic/output_forward_paired.fq.gz -2 ${name}/trimmomatic/output_reverse_paired.fq.gz --merged ${name}/trimmomatic/output_merged.fastq.gz -o ${name}/spades_out -t $N_THREADS -k 61,71,81,91,99,103,107,111,115,119,123,127 -m 140
	ASSEMBLY_READS=${name}/spades_out/contigs.fasta
#------bwa index-----------
	conda activate hic_mag
	bwa index $ASSEMBLY_READS

#--------alignment------
	bwa mem -t $N_THREADS -o ${name}/prepare_for_binning_p.sam $ASSEMBLY_READS ${name}/trimmomatic/output_forward_paired.fq.gz ${name}/trimmomatic/output_reverse_paired.fq.gz
	bwa mem -t $N_THREADS -o ${name}/prepare_for_binning_u.sam $ASSEMBLY_READS ${name}/trimmomatic/output_merged.fastq.gz

#-----sorting and merging in bam---------
	conda activate bioinf_v1
	samtools sort ${name}/prepare_for_binning_p.sam -@$N_THREADS -o ${name}/prepare_for_binning_p.bam
	samtools sort ${name}/prepare_for_binning_u.sam -@$N_THREADS -o ${name}/prepare_for_binning_u.bam
	samtools merge ${name}/prepare_for_binning.bam ${name}/prepare_for_binning_u.bam ${name}/prepare_for_binning_p.bam
	rm ${name}/prepare_for_binning_*
fi

if [ $HI_C_PROC = 'yes' ];
then
	conda activate hic_mag
	bbduk.sh in1=${DATADIR}/${name}_HiC_R1.fastq.gz in2=${DATADIR}/${name}_HiC_R2.fastq.gz k=23 hdist=1 mink=11 ktrim=r tpe tbo ftm=5 qtrim=r trimq=10 out=${name}/hic_paired.fastq.gz
	bwa mem -5SP $ASSEMBLY_READS ${name}/hic_paired.fastq.gz | samtools view -F 0x904 -bS -o ${name}/hic2ctg_unsorted.bam -
	conda activate bioinf_v1 #samtools from another env
	samtools sort -o ${name}/hic2ctg.bam -n ${name}/hic2ctg_unsorted.bam
	rm ${name}/hic2ctg_unsorted.bam
fi

if [ $PROFILING = 'yes' ];
then
if [ $MetaPhlan = 'yes' ];
then
#----------MetaPhlan profiling-------------

	mkdir ${name}/metaphlan
	conda activate hic_mag
#-------profiling WGS data---------------
	metaphlan ${name}/trimmomatic/output_merged.fastq.gz --bowtie2out ${name}/metaphlan/metaplan_prof.bowtie2.bz2 --nproc $N_THREADS --input_type fastq -o  ${name}/metaphlan/Profiled_metagenome_metaphlan_${name}.txt 

	metaphlan ${name}/metaphlan/metaplan_prof.bowtie2.bz2 --nproc $N_THREADS --input_type bowtie2out -o  ${name}/metaphlan/Profiled_metagenome_metaphlan_${name}_s.txt --tax_lev 's'  

#-------profiling Hi-C data------------
	metaphlan ${name}/hic_paired.fastq.gz --bowtie2out ${name}/metaphlan/metaplan_prof_HiC.bowtie2.bz2 --nproc $N_THREADS --input_type fastq -o  ${name}/metaphlan/Profiled_metagenome_metaphlan_HiC_${name}.txt

	metaphlan ${name}/metaphlan/metaplan_prof_HiC.bowtie2.bz2 --nproc $N_THREADS --input_type bowtie2out -o  ${name}/metaphlan/Profiled_metagenome_metaphlan_HiC_${name}_s.txt --tax_lev 's' 

fi

if [ $MiCop = 'yes' ];
then
#-----------MiCoP profiling--------------
	conda activate bioinf_v1
	mkdir ${name}/micop
#-------fungi---------
	python ~/tools/MiCoP/run-bwa.py ${name}/trimmomatic/output_merged.fastq.gz --fungi --output ${name}/micop/alignments_micop_fungi.sam
	python ~/tools/MiCoP/compute-abundances.py ${name}/micop/alignments_micop_fungi.sam --fungi  --output ${name}/micop/micop_fungi.txt
#--------virus-----------
	python ~/tools/MiCoP/run-bwa.py ${name}/trimmomatic/output_merged.fastq.gz --virus --output ${name}/micop/alignments_micop_virus.sam
	python ~/tools/MiCoP/compute-abundances.py ${name}/micop/alignments_micop_virus.sam --virus  --output ${name}/micop/micop_virus.txt
fi
fi

if [ $HI_C_BINNING = 'yes' ];
then
#----------Hi-C binning by bin3C------------
	conda activate bin3c
	~/tools/bin3C/bin3C.py mkmap -e $ENZYME -v $ASSEMBLY_READS ${name}/hic2ctg.bam ${name}/bin3c_out
	~/tools/bin3C/bin3C.py cluster --only-large -v ${name}/bin3c_out/contact_map.p.gz ${name}/bin3c_clust
#-----------checkm bin3c-------------
	conda activate hicmag_py37
	checkm lineage_wf -f ${name}/bin3c_clust/CheckM.txt -t $N_THREADS  ${name}/bin3c_clust/fasta/  ${name}/bin3c_clust/fasta/SCG
	gtdbtk classify_wf --cpus $N_THREADS --genome_dir ${name}/bin3c_clust/fasta/ --extension fna --out_dir ${name}/gtdbtk_out_bin3c
fi

done


#----------Unite metaphlan results----------
conda activate hic_mag
merge_metaphlan_tables.py C3*/metaphlan/*_HiC_C3*[0-9].txt B32/metaphlan/*_HiC_B32.txt > all_metaphlan_HiC_beverages.txt
merge_metaphlan_tables.py C3*/metaphlan/*_C3*[0-9].txt B32/metaphlan/*_B32.txt > all_metaphlan_WGS_beverages.txt
merge_metaphlan_tables.py C3*/metaphlan/*_HiC_C3*[0-9]_s.txt  B32/metaphlan/*_HiC_B32_s.txt > all_metaphlan_HiC_beverages_s.txt
merge_metaphlan_tables.py C3*/metaphlan/*_C3*[0-9]_s.txt  B32/metaphlan/*_B32_s.txt > all_metaphlan_WGS_beverages_s.txt

