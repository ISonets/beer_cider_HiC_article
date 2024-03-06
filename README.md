# README
Essential scripts and notebooks for the publication
Sonets, I. et al. Hi-C metagenomics facilitate comparative genome analysis of bacteria and yeast from spontaneous beer and cider. Food Microbiology, 2024

## General and bacterial-related analyses:

-analysis_beverages.sh - main script including the steps from raw reads processing to WGS and Hi-C binning, along with the taxonomy analysis;

-plots_article - a folder with R ipynb notebooks visualizing bacterial MAGs' abundance and quality metrics, along with the input data;

-prepare_checkm.sh - script for CheckM (MAG quality evaluation);

-prepare_gtdbtk.sh - script for GTDBTk (MAG taxonomic classifier);

-binned_MAGs_stats.py - script for evaluating the number of MAGs and their quality across the binning tools;

-kraken2_search.sh - bash script for Kraken2 processing of the raw reads;

-median_coverage_bin3c.R, median_coverage_metabat.R - R scripts for calculating median coverage for bin3c and MetaBat2 binners, respectively;

-metabat_binning.sh -  WGS assembly with Megahit and MetaBat2 binning script;

-prep_tsv_for_dastool.py - script for preparing .tsv files for DAS-Tool aggregating binner;

-plas_mag.py - script for constructing plasmid-bacterial network (B25 sample);

-prep_hiczin.py - script for preparing data for the HiCzin tool;

-run_mob_suite.sh - script for MobTyper (plasmid contigs detection);

-count_reads.sh - basic script for reads counting.

## Yeast-related analyses

-CL01_run_juicer.sh - bash script for generating a Hi-C contact map for the CL01 MAG from B2 sample (Brettanomyces bruxellensis yeast);

-CL01_stats.sh - bash script for calculating statistics of the Juicer run for the CL01 MAG of B2 sample;

-anvio_v1.sh - bash script for comparative genomic analysis of yeast genomes using anvi'o.
