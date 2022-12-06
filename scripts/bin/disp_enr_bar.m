function disp_enr_bar(table,save_path)
% The first 3 rows of the table should contain bins (begraph format). 
% The following two columns will be displayed

%% Get the chromosome list

chrs = unique(table.chr);
chrs = natsort(unique(chrs));

bins = table(:,1:3);

%% Loop throrough chromosomes
bar_width = 0.8;


for ii = 1 : numel(chrs)

    figure(1)
    clf
    t=tiledlayout(2,1);
    t.TileSpacing = 'none';

    chr_ii = chrs{ii};
    [xp_wg,xn_wg,yp_wg,yn_wg] = generate_bars(bins,table.PSS,chr_ii);
    [xp_ch,xn_ch,yp_ch,yn_ch] = generate_bars(bins,table.lamin,chr_ii);

    wgmin = min(yn_wg);
    wgmax = max(yp_wg);

    chmin = min(yn_ch);
    chmax = max(yp_ch);

    nexttile
    bar(xp_ch,yp_ch,bar_width,'FaceColor',[65, 100, 175]/255)
    hold on
    bar(xn_ch,yn_ch,bar_width,'FaceColor',[10, 23,49]/255)
    %xlim([0,xmax])
    ylim([chmin,chmax])
    ax = gca;
    ax.XTick = {};
    ax.YTick = {};
    axis off

    nexttile
    bar(xp_wg,yp_wg,bar_width,'FaceColor',[65, 100, 175]/255)
    hold on
    bar(xn_wg,yn_wg,bar_width,'FaceColor',[10, 23,49]/255)
    %xlim([0,xmax])
    ylim([wgmin,wgmax])
    ax = gca;
    ax.XTick = {};
    ax.YTick = {};
    axis off
    
    format_page([10,1.5])
    print('-dpdf',[save_path,filesep,chr_ii,'.pdf'])  


end







