function profiles = bedgraphsToTable(bed_dir)
%% Read the PSS and ChIP-Seq Bedgraphs

%Load the PSS track (use this to get chromosomal bis as well)
disp('Loading Track: PSS')
pss_track_loc = 'data/processed/figure3_bedgraphs/PSS_Periphery_Bedgraphs_100000bp/logFoldEnrChrNorm.bedgraph';
profiles = readtable(pss_track_loc,'FileType','text');

profiles.Properties.VariableNames{1}='chr';
profiles.Properties.VariableNames{2}='bin_start';
profiles.Properties.VariableNames{3}='bin_end';
profiles.Properties.VariableNames{4}='PSS';

%Load the lamin track
disp('Loading Track: Lamin ChIP')
lamin_track_loc = 'data/processed/figure3_bedgraphs/Lamin_Bedgraphs_100000bp/logFoldEnrChrNorm.bedgraph';
profiles = append_track(profiles,lamin_track_loc,'lamin');

%load the p-q arm track
disp('Loading Track: p-q arm position')
pq_track_loc = 'data/processed/figure3_bedgraphs/pq-pos_Bedgraphs_100000bp/pq-pos.bedgraph';
profiles = append_track(profiles,pq_track_loc,'p-q_pos');

%load histones tracks
contents = dir([bed_dir,filesep,'H*_B*']);
for ii = 1:numel(contents);

    folder_ii = contents(ii).name;
    trackname_ii = extractBefore(folder_ii,"_");
    

    if contains(folder_ii,'_CT_')
        filename='rawCounts.bedgraph';
        trackname_ii = [trackname_ii,'_CT'];
    else
        filename='logFoldEnrChrNorm.bedgraph';
    end
    disp(['Loading Track: ',trackname_ii]);
    profiles = append_track(profiles,[bed_dir,filesep,folder_ii,filesep,filename],trackname_ii);

end


    function updated_table = append_track(starting_table,track_path,track_name)

    new_track = readtable(track_path,'FileType','text');
    new_track.Properties.VariableNames{1}='chr';
    new_track.Properties.VariableNames{2}='bin_start';
    new_track.Properties.VariableNames{3}='bin_end';
    new_track.Properties.VariableNames{4}=track_name;


    %check that the new track used the same bins as the current table
    same_chr = min(strcmp(starting_table.chr,new_track.chr));
    same_start = min(starting_table.bin_start == new_track.bin_start);
    same_end = min(starting_table.bin_end == new_track.bin_end);

    if (same_chr && same_start && same_end)
        updated_table = [starting_table,new_track(:,4)];
    else
        disp('Bins do not match - could not add track')
    end

    end




end