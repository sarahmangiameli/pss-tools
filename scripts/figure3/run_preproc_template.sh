# This script shows how to generate a set of chromosomal bins, then calculates
# the enrichment from sample and input bed files. Output bedgraphs includ the raw
# fragment counts and enrichment normalized globally and by chromosome.

#Requires R4.1 or later
#Requies samtools

#Set script path
script_path='scripts/bin'

#Run IDX stats on bam files (for chromosome level enrichment plot)
bam_path='data/aligned/figure3/individual'
out_path='data/processed/figure3_log_files'
bash $script_path'/batch_index.sh' $bam_path
bash $script_path'/batch_idx_stats.sh' $bam_path $out_path

#Merge repliciates to single bam files
merge_bam_path='data/aligned/figure3/merged'
samtools merge $merge_bam_path/PSS_Periphery_Sel.bam $bam_path/*WG*Sel*.bam
samtools merge $merge_bam_path/PSS_Periphery_Input.bam $bam_path/*WG*Tot*.bam

#Generate the chromosomal bins
chrom_sizes='reference/chrom_sizes/hg38.chrom.sizes'
bin_size=100000

bash $script_path'/generate_chrom_bins.sh' $chrom_sizes $bin_size

# Specify paths to sample and input bam files
sample='data/aligned/figure3/PSS_Periphery_Sel.bam'
input='data/aligned/figure3/PSS_Periphery_Input.bam'
out_file='data/processed/figure3_bedgraphs/PSS_Periphery_'$bin_size'bp'
chrom_bins='reference/chrom_bins/hg38.100000bp_bins.filt.bed'
paired=1

#Make the enrichment traces
mkdir $out_file
Rscript $script_path/get_enrichment.R $sample $input $chrom_bins $out_file $paired
