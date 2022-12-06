function [r,r_sig,p,rownames,colnames] = cor_by_chr(table,removeZero)

%The first 3 columns of table should contain positional information
%Column 4 is the independant variable
%Remaining columns will be correlated to column 4

%% Set up
chrs = table.chr;
chrs = natsort(unique(chrs));

table_noPos = table(:,4:end);

%Set zeros to NaN to avoid consideration during correlation
if removeZero
    table_noPos{:,:}(table_noPos{:,:} == 0) = NaN;
end

%Output matrix for r and p values
r = [];
p = [];

%% Loop through the chromosomems

for ii = 1: numel(chrs)
    
    chr_ii = chrs{ii};
    ind_ii = strcmp(table.chr,chr_ii);
    
    table_ii = table_noPos(ind_ii,:);
    [c_ii,p_ii] = corrcoef(table2array(table_ii),'Rows','pairwise');
    
    row_ii = c_ii(1,:);
    p_row_ii = p_ii(1,:);
    
    r = [r;row_ii];
    p = [p;p_row_ii];
     
end

%% Remove auto correlation
r = r(:,2:end);
p = p(:,2:end);

%% Set insignificant entries to NaN
r_sig = r;
insig = (p > 0.05);
r_sig(insig) = NaN;

%% Output names
rownames = chrs;
colnames = table_noPos.Properties.VariableNames(2:end);

end
