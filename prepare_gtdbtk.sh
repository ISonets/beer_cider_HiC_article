#!/bin/bash

DIRECTORY=$1
HOME_DIR=$2

for file in ${DIRECTORY}/*summary.tsv;
do
	 out_file=${file#${DIRECTORY}/gtdbtk.}
	 name=${out_file%120.summary.tsv}
	 tail -n +2 "$file" | cut -f 1,2 >> "${HOME_DIR}/gtdbtk_all.txt"
done
sort "${HOME_DIR}/gtdbtk_all.txt" > "${HOME_DIR}/gtdbtk_sorted.txt"
rm "${HOME_DIR}/gtdbtk_all.txt" 