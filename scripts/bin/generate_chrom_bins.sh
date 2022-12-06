#!/bin/bash

#This file creates a bedfile containing genomic bins of a specified size. Note that the chrY, chrM
#and any unplaced contigs are removed.

#INPUTS:
#	chrom_size: Two column Tab delimited file containing chromosome name and length.
#	The expected format is [genome ID].chrom.sizes
#	bin_size: the desired output bin size in base pairs

#OUTPUTS:
# Bed format file with chromosomes dividied into regions of the specified size

#EXAMPLE USAGE:
#	generate_chrom_bins.sh reference/chrom_sizes/hg38.chrom.sizes 1000000

chrom_size=$1 #Chromosome size file
bin_size=$2 #Bin size in base pairs

#Generate the output file path
genome_id=`basename $chrom_size | cut -d. -f1`
output_name='reference/chrom_bins/'$genome_id'.'$bin_size'bp_bins.filt.bed'

#If old file exists, remove it
if [ -f "$output_name" ]
then
	rm $output_name
fi

#Removes ChrY, chrM, and unplaced contigs
filt_chrom_size=$chrom_size".filtered"
cat $chrom_size | grep chr| grep -v chrM | grep -v Y | awk '{if(length($1)<6)print}'| sort -V -k1,1 > $filt_chrom_size

#Start the bin generation
echo "Generating "$bin_size" bp bins for "$genome_id

while read line; do
	chrName=`echo $line| awk '{print $1}'`
	chrLen=`echo $line| awk '{print $2}'`

	lower=0
	upper=0

	while [ $upper -lt $chrLen ]; do

		((test=lower+bin_size))

		if [ $test -le $chrLen ]
		then
			((upper=lower+bin_size))
		else
			upper=$chrLen
		fi

		if [ $lower -eq 0 ]
		then
			((lower=1))
		fi

		echo -e "$chrName\t$lower\t$upper">>$output_name
		((lower=$upper))

	done

done <$filt_chrom_size
