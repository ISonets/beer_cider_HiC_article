#!/bin/bash

for name in B32 C30 C31 C33 C34;
do
	mkdir ${name}
	mob_recon --infile "/home/sonets/beverages/${name}/spades_out/contigs.fasta" --outdir "${name}/mob_out/" -t -c -f -n 40

done