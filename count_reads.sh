#!/bin/bash

DATADIR='/store/bioinf/data/own/run_2022_01'
cd $DATADIR
ls $DATADIR | find *R1* >> ~/read_counts.txt
for SAMPLE in $(ls $DATADIR/*R1*)
do
    zcat $SAMPLE | echo $((`wc -l`/4)) >> ~/read_counts.txt
done
