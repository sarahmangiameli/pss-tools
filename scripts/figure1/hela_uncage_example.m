%% Set up
clear all;
close all;

addpath(genpath('scripts/bin'));

%% Pre-process images (crop, segment, background removal)
proc_im_path = 'data/images/figure1/hela_uncage_movie_frames';
proc_im = dir([proc_im_path, filesep,'*.tif']);

mask = preprocess_uncage_movie_frames('data/images/figure1/hela_uncage_raw');
rl = bwlabel(mask);

%% Make movie of uncaging process

out_file = 'figures/figure1/hela_uncage_movie';
make_uncage_movie(proc_im_path,out_file,rl);

%% Calculate the intensity decrease during uncaging

%Read the first and last image
contents = dir([proc_im_path,filesep,'*.tif']);
imi = imread([proc_im_path,filesep,contents(1).name]);
imf = imread([proc_im_path,filesep,contents(end).name]);

imi = double(imi);
imf = double(imf);

%% Display the images

out_file = 'figures/figure1';

%Set bounds for high image contrast
ub_hc = 1000;
lb_hc = 70;

%Set bounds for low contrast image (to show background)
ub_lc = 300;
lb_lc = 70;

%Make color images (high contrast)
imri_hc = cat(3,ag(imi,lb_hc,ub_hc),0*ag(imi),ag(imi,lb_hc,ub_hc));
imrf_hc = cat(3,ag(imf,lb_hc,ub_hc),0*ag(imf),ag(imf,lb_hc,ub_hc));

%Make color images (low contrast)
imri_lc = cat(3,ag(imi,lb_lc,ub_lc),0*ag(imi),ag(imi,lb_lc,ub_lc));
imrf_lc = cat(3,ag(imf,lb_lc,ub_lc),0*ag(imf),ag(imf,lb_lc,ub_lc));

%Set up scale bar
px_sz = 163; %nm
sb_10 = 10000/px_sz;

%Show the images
figure(1)
clf;
imshow(imri_hc)
draw_cell_outline(rl)
hold on;
plot([10,10],[1,sb_10],'linewidth',2)

set(gcf, 'InvertHardcopy', 'off')
format_page([4,4])
print('-dpdf',[out_file,filesep,'hela_uncage_im_pre.pdf'])

figure(2)
clf;
imshow(imrf_hc)
draw_cell_outline(rl)
set(gcf, 'InvertHardcopy', 'off')
format_page([4,4])
print('-dpdf',[out_file,filesep,'hela_uncage_im_post.pdf'])

%% Calculate background using cytoplasmic intensity

%Create background mask
blur_radius = 8;
cutoff = 130;
mask_br = make_cyto_br_mask(imi,blur_radius,cutoff);

mask_br = logical(mask_br-mask);
rl_br = bwlabel(mask_br);

%Show background mask on images
figure(3)
imshow(imri_lc);
hold on;
draw_cell_outline(rl);
draw_cell_outline(rl_br);
format_page([4,4])
print('-dpdf',[out_file,filesep,'hela_uncage_im_pre_br_mask.pdf'])

figure(4)
imshow(imrf_lc);
hold on
draw_cell_outline(rl);
draw_cell_outline(rl_br);
format_page([4,4])
print('-dpdf',[out_file,filesep,'hela_uncage_im_post_br_mask.pdf'])

%% Do the background subtraction

%Take background as median pixel value in background mask
br_init = median(imi(mask_br));
br_final = median(imf(mask_br));

%Subtract from images
imi_br = imi-br_init;
imf_br = imf-br_final;

%Set any negative pixel values to 0
imi_br(imi_br<0) = 0;
imf_br(imf_br<0) = 0;

%Make color images
imi_br_col = cat(3,ag(imi_br,lb_hc,ub_hc),0*ag(imi_br),ag(imi_br,lb_hc,ub_hc));
imf_br_col = cat(3,ag(imf_br,lb_hc,ub_hc),0*ag(imf_br),ag(imf_br,lb_hc,ub_hc));

%Display the images
figure(5)
clf;
imshow(imi_br_col)
draw_cell_outline(rl)
hold on;
plot([10,10],[1,sb_10],'linewidth',2)

set(gcf, 'InvertHardcopy', 'off')
format_page([4,4])
print('-dpdf',[out_file,filesep,'hela_uncage_im_pre_brsub.pdf'])

figure(6)
clf;
imshow(imf_br_col)
draw_cell_outline(rl)
set(gcf, 'InvertHardcopy', 'off')
format_page([4,4])
print('-dpdf',[out_file,filesep,'hela_uncage_im_post_brsub.pdf'])


%% Loop through nuclei and calculate intensity change
intensity_ratio = [];

for ii = 1:max(rl(:))
   
    mask_ii = (rl == ii);

    pxi = median(imi_br(mask_ii));
    pxf = median(imf_br(mask_ii));

    ratio_ii = pxf/pxi;

    intensity_ratio= [intensity_ratio,ratio_ii];

end

%% Plot the intensity decrease

%Separate intensity decrease for seleted and unselecdted cells
sel_ind = (intensity_ratio < 0.5); %verified manually by comparing the label matrix (rl) to raw image
unsel_ind = ~sel_ind;

sel_ratio = intensity_ratio(sel_ind);
unsel_ratio = intensity_ratio(unsel_ind);

%Set up bar graph
y = [mean(sel_ratio), mean(unsel_ratio)];
y(y>1) = 1;
x = [1,2];

%Calculate error bars
err_sel = std(sel_ratio);
err_unsel = std(unsel_ratio);

err = [err_sel,err_unsel];

%Display figure
figure(4)
clf
bar(x,y,0.8)
hold on;
errorbar(x,y,err,'.k')
ylabel('Intensity Ratio')

ax = gca;
ax.YGrid = 'on';
ax.YLim = ([0,1]);
ax.XTickLabel = {'Selected','Unselected'};

format_page([2,3])
print('-dpdf',[out_file,filesep,'hela_uncage_intensiity_bargraph.pdf'])
