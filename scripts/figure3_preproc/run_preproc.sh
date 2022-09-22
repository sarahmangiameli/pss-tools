# This script shows how to generate a set of chromosomal bins, then calculates
# the enrichment from sample and input bed files. Output bedgraphs includ the raw
# fragment counts and enrichment normalized globally and by chromosome.


# Generate the chromosomal bins
script_path='scripts/figure3_preproc'
chrom_sizes='reference/chrom_sizes/hg38.chrom.sizes'
bin_size=100000

bash $script_path'/generate_chrom_bins.sh' $chrom_sizes $bin_size

# Specify pathhs to sample and input files
sample='/broad/thechenlab/Sarah/PhotoselectiveSequencing/20220103_LaminNovaseqHG38/Test/'
input='/broad/thechenlab/Sarah/PhotoselectiveSequencing/20220103_LaminNovaseqHG38/Test/'

#Run idx stats (used for normalizing reads on per-chromosome basis)
