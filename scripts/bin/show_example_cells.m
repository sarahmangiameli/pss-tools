function show_example_cells(dna_im,hist_im,corner,len,thresh)

%Set pixel size for 40x
px_sz = 163; %nm/px

%Read the example images
c1 = imread(dna_im);
c2 = imread(hist_im);

%Define the image bounds
x1 = corner(1);
y1 = corner(2);
x2 = x1+len;
y2 = y1+len;

%Crop the image
c1c = c1(y1:y2,x1:x2);
c2c = c2(y1:y2,x1:x2);

[optimizer,metric] = imregconfig('monomodal');
c2c = imregister(c2c,c1c,"translation",optimizer,metric);

%Seg the image
[rl, ~, ~] = nuc_seg(c1c,thresh);

%Make color images
r = cat(3,ag(c1c),0*ag(c2c),ag(c1c));
g = cat(3,0*ag(c1c),ag(c2c),0*ag(c1c));
m = cat(3,ag(c1c),ag(c2c),ag(c1c));

%Show the images
figure(8)
clf
imshow(r)
hold on;
draw_cell_outline(rl);
plot([1,10^4/px_sz],[10,10],'-w')
set(gcf, 'InvertHardcopy', 'off')

figure(9)
clf
imshow(g)
hold on;
draw_cell_outline(rl);
plot([1,10^4/px_sz],[10,10],'-w')
set(gcf, 'InvertHardcopy', 'off')


figure(10)
clf
imshow(m)
hold on;
plot([1,10^4/px_sz],[10,10],'-w')
draw_cell_outline(rl);
set(gcf, 'InvertHardcopy', 'off')