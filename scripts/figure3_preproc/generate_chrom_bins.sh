#!/bin/bash

#This file creates a bedfile containing genomic bins of a specified size

#INPUTS:
#	chrom_size: Two column Tab delimited file containing chromosome name and length
#	bin_size: the desired output bin size in base pairs
#	filter:

#OUTPUTS:

#EXAMPLE USAGE:
#	generate_chrom_bins.sh reference/chrom_sizes/hg38.chrom.sizes 1000000 1

chrom_size=$1 #Chromosome size file
bin_size=$2 #Bin size in base pairs
filter=$3 #Logical - Keep only chrs 1-23

#note that the hg38.chrom_filt.sizes was generated using filterGenomeLengthFile.sh
if [ $filter -eq 1 ]
then
	genomeSizeFile='/broad/thechenlab/atac_pipeline_bc/genomes/chrom.sizes/hg38.chrom_filt.sizes'
	outname="hg38_filt_"$binS"bp.bed"
else
	genomeSizeFile='/broad/thechenlab/atac_pipeline_bc/genomes/chrom.sizes/hg38.chrom.sizes'
	outname="hg38_"$binS"bp.bed"
fi

while read line; do
	chrName=`echo $line| awk '{print $1}'`
	chrLen=`echo $line| awk '{print $2}'`

	lower=0
	upper=0

	while [ $upper -lt $chrLen ]; do

		((test=lower+binS+binS))

		if [ $test -le $chrLen ]
		then
		((upper=lower+binS))
		else
			upper=$chrLen
		fi

		echo -e "$chrName\t$lower\t$upper">>$outname
		((lower=$upper))

	done

done <$genomeSizeFile
