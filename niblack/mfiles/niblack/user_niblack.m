function user_niblack(filename, win0)
path = './';
img_path = strcat(path,filename,'.tif');
flag = 0;
win = win0;
pixel_size = 590;
cut_side = 5; 
filter_r = 10;

img = imread(img_path);
img = img (1:pixel_size, 1:pixel_size);
GBbr = 5; % filter size
GBbs = 1; % standard deviation
G = fspecial('gaussian',GBbr,GBbs);
img_blurred = imfilter(img,G,'same');
% img_blurred = medfilt2(img, [filter_r filter_r]);
img_blurred = img_blurred((1+cut_side):(pixel_size-cut_side), (1+cut_side):(pixel_size-cut_side));
while flag==0
    img_th = niblack(img_blurred, [win, win], -.2,10);
    img_out = noise_filter(-img_th+1, 2000);
    figure(1);
    imshow(img_blurred);
    figure(2);
    imshow(img_out);
    figure(3)
    imshow(img);
    disp('If the binary image matches with the original image, enter 0;');
    disp('If the binary image does not match the original one, enter the adjustment value:');
    disp('Current Win_size:');
    win
    disp('VF =');
    sum(img_out(:))/(pixel_size-2*cut_side)^2
    adjust = input('adjustment value is:');
    if adjust == 0
        flag = 1;
    else
        win = win +adjust;
    end
end
img1 = img_out;
% [img_out, VF] = black_dot(img_out);
save_path = strcat(path,filename,'.mat');
save(save_path,'img_out');

end