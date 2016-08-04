function clean(file)
close all
file1 = strcat(file,'.mat');
load(file1,'img_out');
imgs = strcat(file,'.jpg');
o_img = imread(imgs);
o_img = o_img(6:1015,6:1015);
mode = -1;
while mode ~=3
    figure(1);
    imshow(img_out);
    figure(2);
    imshow(o_img);
    
    mode = input ('Which of the modes do you want to start: 1. Square 2.point 3.Exit');
    if mode==1
        
        [y1,x1] = ginput(1)
        [y2,x2] = ginput(1);
        if x1>x2
            a=x1;
            x1=x2;
            x2=a;
        end
        if y1>y2;
            a=y1;
            x1=x2;
            x2=a;
        end
        img_out(x1:x2,y1:y2) = 0;
    end
    if mode == 2
        [y0,x0] = ginput(1);
        temp_img = img_out;
        b_img = bwlabel(temp_img);
        class = b_img(ceil(x0),ceil(y0));
        pic = double(b_img == class);
        img_out = img_out - pic;
    end    
end
VF = sum(img_out(:));
save(file,'img_out','VF');

end