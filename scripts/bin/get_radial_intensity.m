function [int_hist_bin,int_dna_bin,int_ratio_bin] = get_radial_intensity(mask_start,im_hist,im_dna,step,bins)

se = strel('disk',step);
int_hist = [];
int_dna = [];
ar = 1;

mask_in = mask_start;

while (ar > 0)

    %Make the ring mask
    mask_out = mask_in;
    mask_in = imerode(mask_out,se);
    ring_mask = logical(mask_out-mask_in);
    
    %Get the median intensity inside the ring mask
    int_while_hist = sum(im_hist(ring_mask));
    int_while_dna = sum(im_dna(ring_mask));

    int_hist = [int_hist,int_while_hist];
    int_dna = [int_dna,int_while_dna];
    
    %Check the remaining cell area
    props = regionprops(mask_in, 'Area' );

    if isempty(props)
        ar = 0;
    else
        ar = props.Area;
    end

end

% Normalize the max intensity to 1
int_hist = double(int_hist);
int_dna = double(int_dna);

int_ratio = int_hist./int_dna;

int_hist = int_hist/max(int_hist);
int_dna = int_dna/max(int_dna);
int_ratio = int_ratio/max(int_ratio);

% Make radial position vector
r = 0:1:numel(int_hist)-1;
r_norm = r/max(r);

%Bin data into radial position common to all cells
int_hist_bin = NaN(size(bins));
int_dna_bin = NaN(size(bins));
int_ratio_bin = NaN(size(bins));

%Loop through the radial positns
for ii = 1:numel(r_norm)
    
    %Get radial position of ring mask
    r_ii = r_norm(ii);

    %Find nearest bin
    dif_ii = abs(bins-r_ii);
    [~,ind] = min(dif_ii);
    
    %Fill the vector
    int_hist_bin(ind) = int_hist(ii);
    int_dna_bin(ind) = int_dna(ii);
    int_ratio_bin(ind) = int_ratio(ii);

end
end