function [mean_int,dev,bins,n_cells] = disp_radial_plot(int_mat,col)


%Read the intensity
data = load(int_mat);

radial_int = data.output.rad_int;
bins = data.output.bins;
n_cells = size(radial_int,1);

mean_int = nanmean(radial_int);
dev = nanstd(radial_int);

keep = ~isnan(mean_int);

bins = bins(keep);
mean_int = mean_int(keep);
dev = dev(keep);

%Do the plotting
plot(bins,mean_int,'.-','Color',col);
hold on;
plot(bins,mean_int+dev,'--','Color',col)
plot(bins,mean_int-dev,'--','Color',col)
xlim([-0.01,1.01])
ylim([0.3,1.1])
xlabel('Fractional radial position')
ylabel('Normalized fluoresence intensity')

%Display number of cells
xL=xlim;
yL=ylim;
text(0.99*xL(2),0.99*yL(2),['n = ',num2str(n_cells),' cells'],'HorizontalAlignment','right','VerticalAlignment','top')

box on;
ax = gca;
ax.XTick = 0:0.1:1;
ax.XTickLabel = flip(0:0.1:1);

end