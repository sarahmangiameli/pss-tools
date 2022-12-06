function mask_br = make_cyto_br_mask(im,blur_radius,cutoff)

%Smooth and threshold
im_lowpass = double(imgaussfilt(im,blur_radius));
mask_br = (im_lowpass > cutoff);

%Remove small stray regions
rl_br = bwlabel(mask_br);
props = regionprops( rl_br, 'Area' );
keepers = find( [props.Area]>900 );
mask_br = ismember( rl_br, keepers );

end