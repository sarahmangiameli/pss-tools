# About pss-tools
This repository contains nalysis scripts to reproduce main figures in Photoselective sequencing: microscopically-guided genomic measurements with subcellular resolution

# Contents
[scripts:](https://github.com/sarahmangiameli/pss-tools/tree/main/scripts) This directory contains the analysis scripts. Scripts that are meant to be run directly to can be found in the figure directory that corresponds to the main text figure where the analysis was presented.

[reference:](https://github.com/sarahmangiameli/pss-tools/tree/main/reference) This directory contains reference information such as chromosome lengths and the genomic bins for the enrichment plots in Fig. 3.

[figures:](https://github.com/sarahmangiameli/pss-tools/tree/main/figures) This directory contains example output files from the analysis scripts.

[data:](https://github.com/sarahmangiameli/pss-tools/tree/main/data) This directory contains raw data required to run the scripts such as aligned reads, tables, and images.

# System Requirments

## Hardware
A typical laptop will have sufficient resources to run most of the analysis scripts (except cell_type_deconvolution.R). We tested these scripts on a laptop with 16 GB of RAM and 4 cores @ 2.7 GHz CPU. With these specifications, the scripts should run in under 5 minutes, except for radial_intensity_profile.m, which will take about 2 hours. 

To efficienntly run cell_type_deconvolution.R we reccomennd using a system with at least 80 GB of RAM. With these specifications the script will run in roughly 6 hours. 

## Software

### Operating system 
We tested the Matlab scripts using Mac OS Monterey, however we expect that the code would be supported by any operating system where suitable versions of R and Matlab are availible. 

### Other software dependancies
Matlab scripts were tested in version R2022a, and require at least R2019b. 

R scripts were tested in R 4.1 and require R 4.1 or later.

Additionally, the following R packages are required:
[ChromVAR:](https://github.com/GreenleafLab/chromVAR) https://github.com/GreenleafLab/chromVAR


