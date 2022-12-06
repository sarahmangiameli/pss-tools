function mask_mod = quick_seg_movie(first_im)

im_norm = first_im;

%Segment by thresholding
mult_max = 5;
mult_min = 0.3;
mean_im = mean(first_im(:));

im_norm(im_norm > (mult_max*mean_im)) = mult_max*mean_im;
im_norm(im_norm < (mult_min*mean_im)) = mult_min*mean_im;

im_lowpass = imgaussfilt(im_norm,3);

im_mean = mean(im_lowpass(im_lowpass>0));
mask = (im_lowpass>1.7*im_mean);

%Manually smooth boundary on middle cell (cosmetic)
mask_man = ones(size(first_im));
coords_man_x = [229,230,230,231,231,231,232,232,233,234,235,235,236,236,237,238,239,240,240,241,242,243,243,244,245,245];
coords_man_y = [375,375,374,374,373,372,372,371,371,371,371,370,370,369,369,369,369,369,368,368,368,368,367,367,367,366];

for ii = 1:numel(coords_man_x)
   mask_man(coords_man_y(ii),coords_man_x(ii)) = 0;
end

mask = mask & mask_man;

%Remove small regions
rl = bwlabel(mask);
props = regionprops( rl, 'Area' );
keepers = find( [props.Area]>800 );
mask_mod = ismember( rl, keepers );


%Close holes
se = strel('disk', 2, 0);
mask_mod = imclose(mask_mod, se);
mask_mod = imfill(mask_mod, 'holes');
mask_mod = imdilate(mask_mod,se);

end
