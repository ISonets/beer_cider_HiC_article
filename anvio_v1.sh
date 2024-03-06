# !/bin/bash

# -------------anvio pangenome analysis-----------

# py36
# use only python 3.6 for anvio!

for i in *.fasta
do
	anvi-script-reformat-fasta ${i} -o ${i%.*}_fixed.fasta -l 1000 --simplify-names --seq-type NT # to remove other all charactes except ATGCatgcNn
done

# create AUGUSTUS .gff file before use, see https://github.com/Gaius-Augustus/Augustus
for i in *.fasta
do 
    augustus --species=pichia_stipitis --gff3=on $i > ${i%.*}_ann.gff
done

# after creating .gff file, check it. If 1st line of file is ##gff-version3,remove it, because script used below is suddenly breaks.
# or fix it with 
for i in *.gff
do 
    sed '/^#/d' ${i} 
done

for i in *.gff
do
	anvi-script-augustus-output-to-external-gene-calls -i ${i} -o ${i%.*}.txt
done

for i in *_fixed.fasta
do 
	anvi-gen-contigs-database -f ${i} -o ${i%.*}.db --external-gene-calls ${i%.*}_ann.txt
   	anvi-run-hmms -c ${i%.*}.db
done

# setup KOfam DB for func annotation
anvi-setup-kegg-kofams

# annotating
for i in *.db
do
 anvi-run-kegg-kofams --num-threads 8 -c ${i%} 
done

# create external-genomes.txt before use, see https://merenlab.org/software/anvio/help/7/artifacts/external-genomes/ for examples
# create genome storage
anvi-gen-genomes-storage -e external-genomes.txt -o Dekkera-bruxellensis-GENOMES.db --gene-caller AUGUSTUS

# analysis
anvi-pan-genome -g Dekkera-bruxellensis-GENOMES.db -n Dekkera_bruxellensis --output-dir Dekkera_bruxellensis --num-threads 32 --use-ncbi-blast --mcl-inflation 10
# be sure to use muscle v.3.8, not 5.1, it will ruin the whole installation

anvi-display-pan -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db -g Dekkera-bruxellensis-GENOMES.db

anvi-import-misc-data additional-data-layers.txt -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db --target-data-table layers

# selecting bin manually, then making a summary
anvi-summarize -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db -g Dekkera-bruxellensis-GENOMES.db -o bin-SUMMARY -C bin_genes

# metabolism estimation
anvi-estimate-metabolism -e external-genomes.txt --module-completion-threshold 0.5

# func enrichment analysis (1st variant, for estimation as a pangenome,might be useful)
# See https://merenlab.org/software/anvio/help/7/programs/anvi-compute-functional-enrichment/ for other variants
anvi-compute-functional-enrichment-in-pan -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db -g Dekkera-bruxellensis-GENOMES.db       
                                            --category-variable niche \
                                            --annotation-source KOfam --include-gc-identity-as-function \
                                            -o DBRU_func_enr.txt \
                                            --functional-occurrence-table-output DBRU_func_occur.txt

# ANI to help with phylogenomics interpretation
anvi-compute-genome-similarity -e external-genomes.txt -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db -o ANI/ --program pyANI

# phylogenomics
anvi-get-sequences-for-gene-clusters -g Dekkera-bruxellensis-GENOMES.db \
                                     -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db \
                                     -C all_genes \
                                     -b SCGs \
                                     --concatenate-gene-clusters \
                                     -o concatenated-proteins.fa
                                     
# bug encountered: different name length breaks ETE3 wrapper in anvio(
anvi-gen-phylogenomic-tree -f concatenated-proteins.fa \
                           -o phylogenomic-tree.txt
                      
anvi-display-pan -p Dekkera_bruxellensis/Dekkera-bruxellensis-PAN.db -g Dekkera-bruxellensis-GENOMES.db
# don't forget to reroot D.anomalus
# end for now
