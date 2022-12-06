%% Set up

close all;
clear all;

addpath(genpath('scripts/bin'))

h3k9me3_path = 'data/images/figure3/H3K9me3';
h4k8ac_path = 'data/images/figure3/H4K8ac';
h4k20me_path = 'data/images/figure3/H4K20me';

dna_filt = '*c1*';
hist_filt = '*c2*';
bins = 0:0.04:1; %bins for radial intensity
thresh = 2.7; %Segmentation threshold (times the mean)
%% Image processing for radial intensity distributions

% H3K9me3

%Do the radial intensity calculation for all xy in image directory
multi_xy_int = collect_radial_intensity(h3k9me3_path,dna_filt,hist_filt,bins,thresh);

output.rad_int = multi_xy_int;
output.bins = bins;

%save result
save('data/processed/figure3_radial_int/H3K9me3_radial_int.mat','output');


% H4K8ac

%Do the radial intensity calculation for all xy in image directory
multi_xy_int = collect_radial_intensity(h4k8ac_path,dna_filt,hist_filt,bins,thresh);

output.rad_int = multi_xy_int;
output.bins = bins;

%save result
save('data/processed/figure3_radial_int/H4K8ac_radial_int.mat','output');

% H4K20me

%Do the radial intensity calculation for all xy in image directory
multi_xy_int = collect_radial_intensity(h4k20me_path,dna_filt,hist_filt,bins,thresh);

output.rad_int = multi_xy_int;
output.bins = bins;

%save result
save('data/processed/figure3_radial_int/H4K20me_radial_int.mat','output');

%% Final plottiing

%Read the intensity
H3K9me3_data = 'data/processed/figure3_radial_int/H3K9me3_radial_int.mat';

figure(5)
clf
[mean_int_h3k9me3,dev_h3k9me3,bins_h3k9me3,n_h3k9me3] = disp_radial_plot(H3K9me3_data,'k');
format_page([5,3])
print('-dpdf','figures/figure3/H3K9me3_radial_int.pdf')

%Read the intensity
H4k8ac_data = 'data/processed/figure3_radial_int/H4K8ac_radial_int.mat';

figure(6)
clf;
[mean_int_h4k8ac,dev_h4k8ac,bins_h4k8ac,n_h4k8ac] = disp_radial_plot(H4k8ac_data,'k');
format_page([5,3])
print('-dpdf','figures/figure3/H4K8ac_radial_int.pdf')

%Read the intensity
h4k20me_data = 'data/processed/figure3_radial_int/H4K20me_radial_int.mat';

figure(7)
clf
[mean_int_h4k20me,dev_h4k20me,bins_h4k20me,n_h4k20me] = disp_radial_plot(h4k20me_data,'k');
format_page([5,3])
print('-dpdf','figures/figure3/H4K20me_radial_int.pdf')

%% Display H3K9me3 and H4K8ac on same axes

%Set up colors
c1 = [0, 0.4470, 0.7410];
c2 = [0.8500, 0.3250, 0.0980];

figure(4)
clf;
plot(bins_h3k9me3,mean_int_h3k9me3,'.-','Color',c1)
hold on;
plot(bins_h4k8ac,mean_int_h4k8ac,'.-','Color',c2)

plot(bins_h3k9me3,mean_int_h3k9me3+dev_h3k9me3,'--','Color',c1)
plot(bins_h3k9me3,mean_int_h3k9me3-dev_h3k9me3,'--','Color',c1)

plot(bins_h4k8ac,mean_int_h4k8ac+dev_h4k8ac,'--','Color',c2)
plot(bins_h4k8ac,mean_int_h4k8ac-dev_h4k8ac,'--','Color',c2)


legend(['H3K9me3 (N=',num2str(n_h3k9me3),' cells)'],['H4K8ac (N=',num2str(n_h4k8ac),' cells)'],'Location','southwest')
xlim([-0.01,1.01])
ylim([0.3,1.1])
xlabel('Radial position')
ylabel('Normalized fluoresence intensity')

box on;
ax = gca;
ax.XTick = 0:0.1:1;
ax.XTickLabel = flip(0:0.1:1);

format_page([5,3])
print('-dpdf','figures/figure3/radial_int_multi.pdf')

%% Show example images H3K9me3
dna_im = [h3k9me3_path,filesep,'single_plane_1-2000_2xy32c1.tif'];
hist_im = [h3k9me3_path,filesep,'single_plane_1-2000_2xy32c2.tif'];

h3k9me3_corner = [1264,600];
h3k9me3_len = 380;

show_example_cells(dna_im,hist_im,h3k9me3_corner,h3k9me3_len,2.0)

figure(8)
format_page([4,4])
print('-dpdf','figures/figure3/H3K9me3_example_cells_dna.pdf')

figure(9)
format_page([4,4])
print('-dpdf','figures/figure3/H3K9me3_example_cells_hist.pdf')

figure(10)
format_page([4,4])
print('-dpdf','figures/figure3/H3K9me3_example_cells_merge.pdf')

%% Show example images H4K8ac

dna_im = [h4k8ac_path,filesep,'h4k8acxy16c1.tif'];
hist_im = [h4k8ac_path,filesep,'h4k8acxy16c2.tif'];

h4k8ac_corner = [1140,770];
h4k8ac_len = 380;

show_example_cells(dna_im,hist_im,h4k8ac_corner,h4k8ac_len,2.2)

figure(8)
format_page([4,4])
print('-dpdf','figures/figure3/H4K8ac_example_cells_dna.pdf')

figure(9)
format_page([4,4])
print('-dpdf','figures/figure3/H4K8ac_example_cells_hist.pdf')

figure(10)
format_page([4,4])
print('-dpdf','figures/figure3/H4K8ac_example_cells_merge.pdf')

%% Show example images H4K20me

dna_im = [h4k20me_path,filesep,'h4k20me002xy02c1.tif'];
hist_im = [h4k20me_path,filesep,'h4k20me002xy02c2.tif'];

h4k20me_corner = [1015,440];
h4k20me_len = 380;

show_example_cells(dna_im,hist_im,h4k20me_corner,h4k20me_len,2.4)

figure(8)
format_page([4,4])
print('-dpdf','figures/figure3/H4K20me_example_cells_dna.pdf')

figure(9)
format_page([4,4])
print('-dpdf','figures/figure3/H4K20me_example_cells_hist.pdf')

figure(10)
format_page([4,4])
print('-dpdf','figures/figure3/H4K20me_example_cells_merge.pdf')
