#!/bin/bash

#Index all bam files in directory
bam_path=$1

filenames=`ls $bam_path/*.bam`

for eachfile in $filenames
do
  checkname=$eachfile".bai"
  if [ -f "$checkname" ]; then
    echo "$checkname exists."
  else
  echo "indexing: "$eachfile
  samtools index $eachfile
  fi
done
