function br_mask = mask_bright_spots(im,nuc_mask)

br_cut = 300;

se1 = strel('disk', 8, 0);
mask_di = imdilate(nuc_mask,se1);

br_mask = zeros(size(im)); 
br_mask(im > br_cut) = 1;

se2 = strel('disk', 5, 0);
br_mask = imdilate(br_mask,se2) & ~mask_di;

end