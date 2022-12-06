function make_uncage_movie(frames_file,out_file,rl)

%Minimum and maximum pixel values for fixed-scale images
min_px = 60;
max_px = 1800;

contents = dir([frames_file,filesep,'*.tif']);

v = VideoWriter(out_file,'MPEG-4');
v.FrameRate = 4;
v.Quality = 100;
open(v);

count = 0;
for ii = 1:numel(contents)
    
    disp(['Processing image ',num2str(ii)])
    
    frame_ii = imread([frames_file,filesep,contents(ii).name]);
    comp_im_ii = cat(3,ag(frame_ii,min_px,max_px),0*ag(frame_ii,min_px,max_px),0*ag(frame_ii,min_px,max_px));

    text_str = [num2str(count*300/1000), ' s'];
    frame_ii = insertText(comp_im_ii,[10,10],text_str,'FontSize',20,'BoxOpacity',0.2,'BoxColor','black','TextColor','white');
    count = count+1;
    
    figure(1)
    imshow(frame_ii);
    hold on;
    draw_cell_outline(rl);
    
    drawnow;
    F = getframe(gcf);
    writeVideo(v,F)

end

close(v)



end
