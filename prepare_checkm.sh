#!/bin/bash

# format CheckM output file for easy reading in R:
# replace whitespaces with tab . 

FILE_IN=$1
HOME_DIR=$2

cat $FILE_IN | tr -s " " | head -n -1 | tail -n +4 > "${HOME_DIR}/CheckM_MOD"
sed 's/^[ \t]*//'  "${HOME_DIR}/CheckM_MOD" | sed  's/ /\t/g' > "${HOME_DIR}/CheckM_m"
cut -f 1,2,13,14,15 "${HOME_DIR}/CheckM_m" | sort > "${HOME_DIR}/CheckM_final" 
rm "${HOME_DIR}/CheckM_MOD"
rm "${HOME_DIR}/CheckM_m"
