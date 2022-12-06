function [rl,mask_mod,mask_bg] = nuc_seg(im,thresh)

%Normalize the image
im_norm = double(im);

mult_max = 3;
mult_min = 0.3;
mean_im = mean(im(:));

im_norm(im_norm > (mult_max*mean_im)) = mult_max*mean_im;
im_norm(im_norm < (mult_min*mean_im)) = mult_min*mean_im;

im_lowpass = imgaussfilt(im_norm,3);
im_mean = mean(im_lowpass(im_lowpass>0));

mask = im_lowpass>thresh*im_mean;
mask = imfill(mask,'holes');

%Make the mask for background subtraction
mask_bg = mask;
se = strel('disk',5);
mask_bg = ~imdilate(mask_bg,se);

%Remove small regions, concave regions, and objects touching border
rl = bwlabel(imclearborder(mask));
props = regionprops( rl, 'Area' ,'Solidity');
keepers = find([props.Area]>2300 & [props.Solidity]>0.95);
mask_mod = ismember( rl, keepers );
rl = bwlabel(mask_mod);

end