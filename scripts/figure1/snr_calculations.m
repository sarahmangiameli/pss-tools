%% Set up 
close all;
clear all;

addpath(genpath('scripts/bin'))
addpath(genpath('scripts/bin/Violinplot-Matlab'))

table_path = 'data/tables/pss_data_summary.xlsx';

%% Read in the library sizes for paired caged and uncaged libraries

data = readtable(table_path,'Sheet','BlockingEfficiency');

%% Set up figure

%Separate by sample type
ind_cell = [find(strcmp([data.SampleType], 'HeLa'));find(strcmp([data.SampleType], 'IMR90'))];
ind_tis = find(strcmp([data.SampleType], 'MouseBrain'));

data_cell = data(ind_cell,:);
data_tis = data(ind_tis,:);

x_caged = ones(size(data_cell.BlockEff));
x_uncaged = ones(size(data_tis.BlockEff))*1.2;

y_caged = data_cell.BlockEff;
y_uncaged = data_tis.BlockEff;

mean_caged = mean(y_caged);
mean_uncaged = mean(y_uncaged);

%% Display the blocking efficiency (Figure 1D)

figure(1)
clf;
plot(x_caged,y_caged,'.')
hold on;
plot([0.9,1.1],[mean_caged,mean_caged],'Color',[0.5,0.5,0.5])

plot(x_uncaged,y_uncaged,'.')
plot([1.1,1.3],[mean_uncaged,mean_uncaged],'Color',[0.5,0.5,0.5])

xlim([0.8,1.4])
ylim([99.9,100])

ylabel('Blocking Efficiency (%)')

ax = gca;
ax.YGrid = 1;
ax.YMinorGrid = 1;
ax.XTick = [1,1.2];
ax.XTickLabel = ["Cells","Tissue"];

format_page([2,3])
print('-dpdf','figures/figure1/blocking_efficiency.pdf')

%% Read the summary data for signal to noise plots
unbiased_data = readtable(table_path,'Sheet','Cells');

%Filter the table by experiment
min_cell_rows = strcmp(unbiased_data.ExpFilter,'mincell') & strcmp(unbiased_data.SampleFilter,'sel');
min_cell_data = unbiased_data(min_cell_rows,:);

%% SNR as for IMR90 Cells (Fig. 2E)

frac_sel = min_cell_data.FracSel;

figure(2)
clf;
scatter(frac_sel,min_cell_data.SNR,12,"filled")
hold on;
box on;
ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';

%fit a line
ft = fittype({'x'});
p1 = fit(frac_sel,min_cell_data.SNR,ft);
x_fit = linspace(0,max(ax.XTick));
y_fit = feval(p1, x_fit);
slope = p1.a;

plot(x_fit,y_fit);

legend('Data',['Fit (m = ',num2str(slope),')'],'Location','southeast')


xlabel('Fraction of cells selected')
ylabel('SNR')

% Do the insert
axes('Position',[.2 .56 .2 .3])
box on
scatter(frac_sel,min_cell_data.SNR,12,"filled")
hold on;
plot(x_fit,y_fit);
box on;
ax = gca;
xlim([0,0.05]);
ylim([0,500]);

%Save figure
format_page([7.5,4.5])
print('-dpdf','figures/figure1/imr90_snr.pdf')

%% Get summary data for brain tissues
atac_data = readtable(table_path,'Sheet','Tissues');

ind_sel = strcmp(atac_data.SampleFilter,'sel');
atac_sel_data = atac_data(ind_sel,:);

%% Make the figure

figure(6)
clf;
scatter(atac_sel_data.FracSel,atac_sel_data.SNR,12,"filled")
hold on;
box on;
xlabel('Fraction Cells Selected')
ylabel('SNR')

ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';

xlim([0,0.05])

%fit a line
ft = fittype({'x'});
p1 = fit(atac_sel_data.FracSel,atac_sel_data.SNR,ft);
x_fit = linspace(0,max(ax.XTick));
y_fit = feval(p1, x_fit);
slope = p1.a;

plot(x_fit,y_fit);

legend('Data',['Fit (m = ',num2str(slope),')'],'Location','southeast')

% Do the insert
axes('Position',[.2 .56 .2 .3])
box on
scatter(atac_sel_data.FracSel,atac_sel_data.SNR,12,"filled")
hold on;
plot(x_fit,y_fit);
box on;
ax = gca;
xlim([0,0.01]);
ylim([0,100]);

%Save figure
format_page([7.5,4.5])
print('-dpdf','figures/figure1/brain_snr.pdf')

%% Plot a single line for both atac and genome-wide

figure(9)
clf;
scatter(min_cell_data.FracSel,min_cell_data.SNR,12,"filled")
hold on;
scatter(atac_sel_data.FracSel,atac_sel_data.SNR,12,"filled")
box on;

xlabel('Fraction Cells Selected')
ylabel('SNR')

ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';

%fit a line
ft = fittype({'x'});
p1 = fit([atac_sel_data.FracSel;min_cell_data.FracSel],[atac_sel_data.SNR;min_cell_data.SNR],ft);
x_fit = linspace(0,max(ax.XTick));
y_fit = feval(p1, x_fit);
slope = p1.a;

plot(x_fit,y_fit);

legend('Cells','Tissue',['Fit (m = ',num2str(slope),')'],'Location','southeast')


% Do the insert
axes('Position',[.2 .56 .2 .3])
box on
scatter(min_cell_data.FracSel,min_cell_data.SNR,12,"filled")
hold on;
scatter(atac_sel_data.FracSel,atac_sel_data.SNR,12,"filled")
plot(x_fit,y_fit);
box on;
ax = gca;
xlim([0,0.05]);
ylim([0,500]);

ax = gca;
ax.XGrid = 'on';
ax.YGrid = 'on';

%Save figure
format_page([7.5,4.5])
print('-dpdf','figures/figure1/cell_brain_snr.pdf')

%% Violin plots of unique fragments per area

ind_sel = strcmp(unbiased_data.SampleFilter,'sel');
unbiased_sel_data = unbiased_data(ind_sel,:);

%Exclude periphery exp to calculate avg cell area 
ind_whole_cell = strcmp(unbiased_data.SampleFilter,'sel') & strcmp(unbiased_data.ExpFilter,'mincell');
unbiased_whole_cell = unbiased_data(ind_whole_cell,:);

%Use 10 uM x 10 uM area for comparison to other methods
area_size = 100;

%Set up the violin plot
atac_tag = atac_sel_data.LibType;

atac_frags_per_area = atac_sel_data.BrCorLibSizePerArea*area_size;

unbiased_tag = unbiased_sel_data.LibType;
unbiased_frags_per_area = unbiased_sel_data.BrCorLibSizePerArea*area_size;

tags = [atac_tag;unbiased_tag];
points = [atac_frags_per_area;unbiased_frags_per_area];

atac_mean = mean(atac_frags_per_area);
atac_sd = std(atac_frags_per_area);

unbiased_mean = mean(atac_frags_per_area);
unbiased_sd = std(atac_frags_per_area);

%Get average cell area (convert reads per 100 um^2 to reads per cell)
atac_cell_area = mean(atac_sel_data.SelArea./atac_sel_data.SelCells);
unbiased_cell_area = mean(unbiased_whole_cell .SelArea./unbiased_whole_cell .SelCells);

%% Display the figures
figure(7)

clf;
vs = violinplot(atac_frags_per_area , atac_tag,'ShowMean',true);
xlim([0.5, 1.5]);
ylim([1000,8200])
ylabel('Unique Fragments per 100 \mum^2')

yyaxis right
ylabel('Unique Fragments per Cell')
ylim([1000,8200])
ax=gca;
ax.YColor = [0.1500 0.1500 0.1500];
cell_ticks = 400:300:2800;
ax.YTick = cell_ticks*100/atac_cell_area;
ax.YTickLabel=cell_ticks;

format_page([3,3])
print('-dpdf','figures/figure1/unique_frags_atac.pdf')

figure(8)
clf;
vs = violinplot(unbiased_frags_per_area, unbiased_tag,'ShowMean',true);
xlim([0.5, 1.5]);
ylim([4,14]*10^4)
ylabel('Unique Fragments per 100 \mum^2')


yyaxis right
ylabel('Unique Fragments per Cell')
ylim([4,14]*10^4)
ax=gca;
ax.YColor = [0.1500 0.1500 0.1500];
cell_ticks = 100000:30000:350000;
ax.YTick = cell_ticks*100/unbiased_cell_area;
ax.YTickLabel=cell_ticks;

format_page([3,3])
print('-dpdf','figures/figure1/unique_frags_unbiased.pdf')