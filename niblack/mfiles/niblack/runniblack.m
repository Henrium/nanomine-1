function runniblack(filename, win0, adjust)

filepath = './niblack/imgs/';
img_path = strcat(filepath,filename,'.tif');
flag = 0;
win = win0;
pixel_size = 400;
cut_side = 5; 
filter_r = 10;

img = imread(img_path);
img_size = length(img);
img = img (1:pixel_size, 1:pixel_size);
GBbr = 5; % filter size
GBbs = 1; % standard deviation
%G = fspecial('gaussian',GBbr,GBbs);
%img_blurred = imfilter(img,G,'same');
img_blurred = medfilt2(img, [filter_r filter_r]);
img_blurred = img_blurred((1+cut_side):(pixel_size-cut_side), (1+cut_side):(pixel_size-cut_side));
win = win +adjust;
img_th = niblack(img_blurred, [win, win], -.2,10);
img_out = noise_filter(-img_th+1, 2000);
VF = sum(img_out(:))/(pixel_size-2*cut_side)^2;

%img1 = img_out;
% [img_out, VF] = black_dot(img_out);
save_path = strcat(filepath,filename,'.mat');
save(save_path,'img_out');

fname = [filename,'.tif'];
win_size = win;

% Save summary result into MAT file for views to read
save([filepath,'NiblackSummary.mat'], 'fname', 'win_size','img_size','adjust');
end