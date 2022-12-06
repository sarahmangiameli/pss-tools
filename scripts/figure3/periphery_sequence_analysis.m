%% To do list
%write the profiles file
%add resitual correlation
%save the residual track
%format track for igv
%writetable(model_track,'StepwiseLm_Model.bedgraph','Delimiter','\t','FileType','Text','WriteVariableNames',0)

%% Set up
close all;
clear all;

addpath(genpath('scripts/bin'));
addpath(genpath('scripts/bin/natsortrows'));

solar_extra = colorsJDB('color','solar_extra');
save_path ='figures/figure3';

%% Load the bedgraphs into a single table (includes stepwise regression to remove lamin signal from PSS periphery profile)
bedgraph_dir = ('data/processed/figure3_bedgraphs');

%set to 1 to update and overwrite table
make_table = 1;

if make_table
    profiles = bedgraphsToTable(bedgraph_dir);
    writetable(profiles,[bedgraph_dir,filesep,'summary_table.txt']);
else
    profiles = readtable([bedgraph_dir,filesep,'summary_table.txt']);
end


%% Make the residual track

%get the profiiles
pss = profiles.PSS;
lam = profiles.lamin;

%exclude zero bins from regression
pss(pss == 0) = NaN;
lam(lam == 0)= NaN;

%do the regression
mdl = stepwiselm(lam,pss,'penter',.01); 
pss_res = mdl.Residuals.Raw;

res = profiles(:,1:3);
res.pss_res = pss_res;


%% Figure 3B - chromosome level enrichment plot

log_path = 'data/processed/figure3_log_files';

% Read in the idx stats files
wg1s=readtable([log_path,filesep,'WG_Lam1_Sel_S1_001.st.rmdup.flt.stats.log']);
wg2s=readtable([log_path,filesep,'WG_Lam2_Sel_S2_001.st.rmdup.flt.stats.log']);
wg3s=readtable([log_path,filesep,'WG_Lam3_Sel_S3_001.st.rmdup.flt.stats.log']);

wg1i=readtable([log_path,filesep,'WG_Lam1_Tot_S4_001.st.rmdup.flt.stats.log']);
wg2i=readtable([log_path,filesep,'WG_Lam2_Tot_S5_001.st.rmdup.flt.stats.log']);
wg3i=readtable([log_path,filesep,'WG_Lam3_Tot_S6_001.st.rmdup.flt.stats.log']);

chip1s=readtable([log_path,filesep,'CHIP_Lam1.rmdup.flt.stats.log']);
chip2s=readtable([log_path,filesep,'CHIP_Lam2.rmdup.flt.stats.log']);

chip1i=readtable([log_path,filesep,'CHIP_Lam1_Input.rmdup.flt.stats.log']);
chip2i=readtable([log_path,filesep,'CHIP_Lam2_Input.rmdup.flt.stats.log']);

% Get the enrichment value
ew1=get_enr(wg1s.Var3,wg1i.Var3,0);
ew2=get_enr(wg2s.Var3,wg2i.Var3,0);
ew3=get_enr(wg3s.Var3,wg3i.Var3,0);

ew = [ew1,ew2,ew3];

ec1=get_enr(chip1s.Var3,chip1i.Var3,0);
ec2=get_enr(chip2s.Var3,chip2i.Var3,0);

ec = [ec1,ec2];

%Read chromosome names and lengths
lengths = wg1s.Var2;
names = wg1s.Var1;

%Get mean and standard deviation from replicates
wmean=mean(ew,2);
wstd=std(ew,0,2);

cmean = mean(ec,2);
cstd = std(ec,0,2);

%Sort data by chromosome length
[~,ord]=sort(lengths,'descend');

c1 = [0, 0.4470, 0.7410];
c2 = [0.8500, 0.3250, 0.0980];

figure(1)
clf;
plot(wmean(ord),'.-','MarkerSize',12,'Color',c1);
hold on
plot(cmean(ord),'.-','MarkerSize',12,'Color',c2);
errorbar(wmean(ord),wstd(ord),'.','Color',c1)
errorbar(cmean(ord),cstd(ord),'.','Color',c2)

legend('PSS','LamB1 ChIP','Location','southwest')

xlabel('Chromosomes ordered by length')
ylabel('Enrichment')

ax=gca;
ax.XTick=1:1:23;
ax.XTickLabel=names(ord);
ax.XGrid='on';
xlim([0.5,23.5])

format_page([5,3])
print('-dpdf',[save_path,filesep,'enr_by_chrom.pdf'])
%% Fig 3C - Visualize traces

%This flashes the plot and saves the file (top: ChIP, bottom: PSS)
save_path_bg = 'figures/figure3/enrichment_bargraphs';
disp_enr_bar(profiles,save_path_bg);

%% Figure 3D - Correlations

[~,r_sig,~,rowname,colname] = cor_by_chr(profiles,1);

figure(1)
plot_heatmap(r_sig,rowname,colname)
title('Correlations by Chromosome')
set(gcf, 'InvertHardcopy', 'off')
colormap(solar_extra);
format_page([8,5])

print('-dpdf',[save_path,filesep,'cor_by_chr.pdf'])

%% Sup Fig 4C - Residual Correlations

%Swap the PSS profile for the residual
profiles_res = [res,profiles(:,6:end)];
[~,r_sig,~,rowname,colname] = cor_by_chr(profiles_res,1);

figure(2)
plot_heatmap(r_sig,rowname,colname)
title('Residual Correlations by Chromosome')
set(gcf, 'InvertHardcopy', 'off')
colormap(solar_extra);
format_page([8,5])

print('-dpdf',[save_path,filesep,'res_cor_by_chr.pdf'])
