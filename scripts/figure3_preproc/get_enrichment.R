#!/usr/bin/env Rscript

# This script calculates the enrichment in a set of genomic bins.

#INPUTS:
# selected -
# 
#OUTPUTS:


#Accept input from CL
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least three arguments must be supplied - bam files for selected and total, and peaks bed file", call.=FALSE)
}

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

print("Warning - is your setting for single/paired reads correct in getCounts?")
print("reading peaks file")
#Read in the peaks file
peaks <- getPeaks(args[3],sort_peaks = TRUE)

#Read in the counts
bamfiles <- c(args[1],args[2])

print("checking for stats files")
#get expected log file names
sel_log <- gsub(".bam", ".stats.log", args[1])
tot_log <- gsub(".bam", ".stats.log", args[2])

if (!file.exists(sel_log) | !file.exists(tot_log)) {
  print(sel_log)
  print(tot_log)
  stop("one or more bam does not have an associated idx stats file - expected names above", call.=FALSE)
}

print("reading idxstats file")
#Get stats file (for read depth)
stats_sel <-read.table(sel_log, header = FALSE, sep = "", dec = ".")
stats_tot <-read.table(tot_log, header = FALSE, sep = "", dec = ".")

print("reading counts into bins")
#Raw counts
fragment_counts <- getCounts(bamfiles, peaks,
                             paired =  TRUE,
                             by_rg = FALSE,
                             format = "bam")

print("generating tracks")
#Get the row data
gr <- rowRanges(fragment_counts)

#Extract raw counts matrix and sequencing depths
counts <-assays(fragment_counts)$counts
depths <-colData(fragment_counts)$depth

#Normalize counts by read depths
countsNormGlobal <- t(t(counts)/depths)



#Normalize counts on per chromosome basis
countsNormByChr <- counts
for (i in 1:dim(stats_sel)[1]) {

  chr_sel_i <- stats_sel[i,1]
  chr_tot_i <- stats_tot[i,1]
  depth_sel_i <-stats_sel[i,3]
  depth_tot_i <-stats_tot[i,3]

  if (chr_sel_i != chr_tot_i) {
    stop("mismatched chromosome order in stats files", call.=FALSE)
  }

  ridx_i <- as(seqnames(gr), "vector") == chr_sel_i

  countsNormByChr[ridx_i,1]=countsNormByChr[ridx_i,1]/depth_sel_i
  countsNormByChr[ridx_i,2]=countsNormByChr[ridx_i,2]/depth_tot_i
}

#get fold enrichment with global norm
enrFold <- countsNormGlobal[,1]/countsNormGlobal[,2]
#Get log fold enrichment and mask inf to zero
enrGlobal <- log2(countsNormGlobal[,1]/countsNormGlobal[,2])
enrGlobal[!is.finite(enrGlobal)] <- 0


#Get log fold enrichment and mask inf to zero
enrByChr <- log2(countsNormByChr[,1]/countsNormByChr[,2])
enrByChr[!is.finite(enrByChr)] <- 0


c1 <-as(seqnames(gr), "vector")
c2 <-as.integer(start(ranges(gr))-1)
c3 <-end(ranges(gr))

c4_rawSel <- counts[,1]
c4_rawTot <-counts[,2]
c4_global <-enrGlobal
c4_byChr <-enrByChr
c4_fold <-enrFold

dataOut_rawSel <- data.frame(c1,c2,c3,c4_rawSel)
dataOut_rawTot <- data.frame(c1,c2,c3,c4_rawTot)
dataOut_global <- data.frame(c1,c2,c3,c4_global)
dataOut_byChr <- data.frame(c1,c2,c3,c4_byChr)
dataOut_fold <- data.frame(c1,c2,c3,c4_fold)

print("saving tracks")
write.table(dataOut_rawSel,
            file = paste(args[4],'/rawSelCounts.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")
write.table(dataOut_rawTot,
            file = paste(args[4],'/rawTotCounts.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")
write.table(dataOut_global,
            file = paste(args[4],'/logFoldEnrGlobal.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")

write.table(dataOut_byChr,
            file = paste(args[4],'/logFoldEnrByChr.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")

write.table(dataOut_fold,
            file = paste(args[4],'/foldEnrGlobal.bedgraph',sep = ""),
            row.names = F,
            col.names = F,
            quote = F,
            sep = "\t")
