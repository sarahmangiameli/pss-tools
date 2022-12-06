#!/bin/bash

bam_path=$1
out_path=$2

filenames=`ls $bam_path/*.bam`

for eachfile in $filenames
do
  saveName=`basename $eachfile | sed 's/.bam/.stats.log/g'`
  samtools idxstats $eachfile > temp.log

  cat temp.log | grep chr |grep -v chrM | grep -v Y | awk '{if(length($1)<6)print}' > temp2.log

  sort -k2 -tr -n temp2.log > $out_path/$saveName

  rm temp.log
  rm temp2.log

done
