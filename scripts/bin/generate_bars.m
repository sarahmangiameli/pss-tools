function [xp,xn,yp,yn] = generate_bars(bins,profile,chr)

%keeps the total number of bins constant across all chromosomes
%mostly for convenience plotting
chr1_ind = (string(bins.chr) == 'chr1');
chr1_bins = bins(chr1_ind,2:3);

%Get the indicated chromosome
ind_chr = (string(bins.chr) == chr);
profile_chr = profile(ind_chr,:);

%Get bin cebters
x = (chr1_bins.bin_start+chr1_bins.bin_end)/2;
y = zeros(size(x));

%Fill the biins
y_temp = profile_chr;
realbins = numel(y_temp);
y(1:realbins)=y_temp;


%Separate positive and negative values
ind_pos = (y > 0);

xp = x;
xn = x;

yp = y;
yp(~ind_pos)= 0;

yn = y;
yn(ind_pos) = 0;

end