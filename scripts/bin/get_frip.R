#!/usr/bin/env Rscript

#Accept input from CL
args = commandArgs(trailingOnly=TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)==0) {
  stop("At least two arguments must be supplied - bam file, and peaks bed file", call.=FALSE)
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

print("reading peaks file")
#Read in the peaks file
peaks <- getPeaks(args[2],sort_peaks = TRUE)

#Read in the counts
bamfiles <- c(args[1])

print("reading counts into bins - paired end")
fragment_counts <- getCounts(bamfiles, peaks,
                               paired =  TRUE,
                               by_rg = FALSE,
                               format = "bam")

counts <-assays(fragment_counts)$counts
rip <-colSums(counts)
depth <- colData(fragment_counts)$depth

frip <- rip/depth
frip