function multi_xy_int = collect_radial_intensity(im_path,dna_filt,hist_filt,bins,thresh)

%Get image info
contents_c1 =  dir([im_path,filesep,dna_filt]); %DNA stain
contents_c2 = dir([im_path,filesep,hist_filt]); %IF

%Set up figure
figure(4)
clf;

multi_xy_int = []; %normaliized ratio of histone/dna intensity

%loop through xy positions
for ii = 1:numel(contents_c1)

    disp(['Processing image ',num2str(ii),' of ',num2str(numel(contents_c1))])

    %Read the images
    im1_ii = imread([im_path,filesep,contents_c1(ii).name]);
    im2_ii = imread([im_path,filesep,contents_c2(ii).name]);

    %%Register the images
    [optimizer,metric] = imregconfig('monomodal');
    im2_ii_reg = imregister(im2_ii,im1_ii,"translation",optimizer,metric);
    
    %Make the nuclear mask
    [rl, ~, mask_bg] = nuc_seg(im1_ii,thresh);

    %Background subtract images 
    im1_ii_br = median(im1_ii(mask_bg));
    im2_ii_br = median(im2_ii_reg(mask_bg));

    im1_ii_br = im1_ii - im1_ii_br;
    im2_ii_br = im2_ii_reg - im2_ii_br;

    im1_ii_br(im1_ii_br<0)=0;
    im2_ii_br(im2_ii_br<0)=0;

    %Show background subtracted images with masks
    figure(1)
    clf;
    tiledlayout(1,2,'TileSpacing','tight');

    nexttile;
    imshow(im1_ii_br,[]);
    draw_cell_outline(rl);
    title('DNA Stain');

    nexttile;
    imshow(im2_ii_br,[]);
    draw_cell_outline(rl);
    title('Histone Mark');

    %loop through cells and get intensity in concentric rings
    for jj = 1:max(rl(:))
      
        mask_jj = (rl == jj);
       
        [int_hist_bin_jj,int_dna_bin_jj,int_ratio_bin_jj] = get_radial_intensity(mask_jj,im2_ii_br,im1_ii_br,3,bins);

        keep = ~isnan(int_hist_bin_jj);
        figure(4)
        plot(bins(keep),int_hist_bin_jj(keep),'.-k');
        hold on;
        plot(bins(keep),int_dna_bin_jj(keep),'.-g');
        plot(bins(keep),int_ratio_bin_jj(keep),'.-r');
        xlabel('Radial position');
        ylabel('Normalized Intensity');


        multi_xy_int = [multi_xy_int;int_ratio_bin_jj];

    end

end
end
