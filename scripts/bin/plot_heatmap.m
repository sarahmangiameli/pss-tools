function f = plot_heatmap(mat_in,rownames,colnames)

%Sort the data by column mean
mean_cor = nanmean(mat_in);
[~,st_order] = sort(mean_cor,'descend');
data_viz = mat_in(:,st_order);

%Raw Correlation matrix
clf;
h=imagesc(data_viz);

colorbar;
colormap(jet)

xtickangle(90)

ax = gca;
ax.TickLabelInterpreter = 'none';
ax.XTick = 1:1:size(data_viz,2)+0.5;
ax.YTick = 1:1:size(data_viz,1)+0.5;
ax.XTickLabel = colnames(st_order);
ax.YTickLabel = rownames;

%Choose symmetrical bounds
upperb = max(abs(data_viz(:)));
lowerb = -upperb;
caxis([lowerb,upperb])

end