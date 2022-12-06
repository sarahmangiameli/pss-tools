function mask = preprocess_uncage_movie_frames(im_dir)
%% read in the first image
contents = dir([im_dir,filesep,'*.tif']);
first_im = imread([im_dir,filesep,contents(1).name]);

%manually define the crop region
x1 = 640;
x2 = x1+700;
y1 = 640;
y2 = y1+700;

%crop first image
first_im = first_im(y1:y2,x1:x2);

%% Seg first image
mask = quick_seg_movie(first_im);

%% Mask bright spots (stray tagmentation oligos) in background
br_mask = mask_bright_spots(first_im,mask);

%% Loop through all the images, crop, remove bright spots, save movie frames

contents = dir(['data/images/figure1/hela_uncage_raw',filesep,'*.tif']);

for ii = 1:numel(contents)

    disp(['Processing image ',num2str(ii)])
    im_ii = imread(['data/images/figure1/hela_uncage_raw',filesep,contents(ii).name]);
    im_ii = im_ii(y1:y2,x1:x2);
    im_ii = regionfill(im_ii,br_mask);
    
    
    imc = cat(3,ag(im_ii,100,1200),0*ag(im_ii,100,1200),0*ag(im_ii,100,1200));
    
    figure(1)
    clf
    imshow(imc)
    
    imwrite(im_ii,['data/images/figure1/hela_uncage_movie_frames',filesep,contents(ii).name])
    
end


