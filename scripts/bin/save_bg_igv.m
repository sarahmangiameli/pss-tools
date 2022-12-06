function save_bg_igv(table,outname)
%columns 1-3 are expected to contain chromosom labels and bins
%column 4 contains the profile to be saved

%remove NaN and Inf and mask to zero
profile = table2array(table(:,4));
ind_mask = (isinf(profile)) | (isnan(profile));
profile(ind_mask) =0;

table_bg = table(:,1:3);
table_bg.profile = profile;

%Write the table
writetable(table_bg,outname,'Delimiter','\t','FileType','Text','WriteVariableNames',false)


end