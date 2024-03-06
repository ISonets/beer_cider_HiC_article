#!/bin/bash

eval "$(/tools/bin/conda3.sh)"
conda activate hic_mag
DATADIR='/store/bioinf/data/own/run_2022_01/'

for name in B32 #C30 C31 C33 C34
do
  kraken2 --db tools/kraken2/standard/ --threads 32 --output ${name}_output.out \
  --classified-out ${name}_classified.out --report ${name}_report.out \
  --paired ${DATADIR}/${name}_WGS_R1.fq.gz ${DATADIR}/${name}_WGS_R2.fq.gz 
done
