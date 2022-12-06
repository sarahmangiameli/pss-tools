#!/usr/bin/env Rscript

# This script calculates the enrichment in a set of genomic bins.

#INPUTS:
# selected -
#
#OUTPUTS:

peakFile='/Volumes/broad_thechenlab/Sarah/code/pss-tools/reference/chrom_bins/hg38.100000bp_bins.filt.bed'
sel='/Volumes/broad_thechenlab/Sarah/PhotoselectiveSequencing/20221027_AndrewCandT/mergedBam/H3K9me2_CT.bam'
outFile='/Volumes/broad_thechenlab/Sarah/code/pss-tools/data/processed/figure3_bedgraphs/H3K9me2_CT_Bedgraphs_1000000bp'
paired=1

print("loading libraries")
library(chromVAR)
library(tidyverse)
library(SummarizedExperiment)
library(BiocParallel)
library(reshape2)
library(Matrix)
library(grid)
library(MASS)
library(ggplot2)

print("reading peaks file")
#Read in the peaks file
peaks <- getPeaks(peakFile,sort_peaks = TRUE)

#Read in the counts
bamfiles <- c(sel)

#Raw counts
if (paired == 1) {
  print("reading counts into bins - paired end")
  fragment_counts <- getCounts(bamfiles, peaks,
                                paired =  TRUE,
                                by_rg = FALSE,
                                format = "bam")

} else {
  print("reading counts into bins - single end")
  fragment_counts <- getCounts(bamfiles, peaks,
                                paired =  FALSE,
                                by_rg = FALSE,
                                format = "bam")

}

print("generating tracks")
#Get the row data
gr <- rowRanges(fragment_counts)

#Extract raw counts matrix and sequencing depths
counts <-assays(fragment_counts)$counts
depths <-colSums(counts)

#Normalize counts by read depths
countsNormGlobal <- t(t(counts)/depths)

#Normalize counts on per chromosome basis

countsNormByChr <- counts
chr_list <- seqnames(seqinfo(peaks))

for (i in 1:length(chr_list)) {

  #used to read chr name
  chr_i <- chr_list[i]
  ridx_i <- as(seqnames(gr), "vector") == chr_i

  countsNormByChr[ridx_i,1]=countsNormByChr[ridx_i,1]/sum(countsNormByChr[ridx_i,1])
}

c1 <-as(seqnames(gr), "vector")
c2 <-as.integer(start(ranges(gr))-1)
c3 <-end(ranges(gr))

c4_rawCounts <- counts[,1]
c4_normCountsGlobal <- countsNormGlobal
c4_normCountsChrom <-countsNormByChr


dataOut_rawCounts <- data.frame(c1,c2,c3,c4_rawCounts)
dataOut_normCountsGlobal <- data.frame(c1,c2,c3,as.matrix(c4_normCountsGlobal))
dataOut_normCountsChrom <- data.frame(c1,c2,c3,as.matrix(c4_normCountsChrom))

print("saving tracks")
write.table(dataOut_rawCounts,
            file = paste(outFile,'/rawCounts.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")
write.table(dataOut_normCountsGlobal,
            file = paste(outFile,'/normCounts.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")
write.table(dataOut_normCountsChrom,
            file = paste(outFile,'/normCountsChr.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")
