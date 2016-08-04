img = imread('101.TIF');
img = img( 251:2250, 251:4008-250 );
img = medfilt2(img,[10,10]);
[~,bw] = Transform(img, 0.007);
bw = bw(:,1:2000);
figure(1);
imshow(img(:,1:2000));
figure(2);
imshow(bw);
l=bwlabel(bw);
max(max(l))