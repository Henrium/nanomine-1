close all,clear all
% Pre-processing code to transform grayscale image to binary
% Compare Figure 2 and 3 for quality
% Updated Nov21, 2014 HZ. Added noise filter to filter out NP under 15nm
% Input: grayscale image. Vf to threshold
% Output: binary image

% ------------------------------------------------------------------------
I = imread('MS-25-96-10%-10K.jpg');
vf = 0.24; 
RemoveSideLength = 5; % Remove some area at each edge due to artificial shade
% Gaussian filter
GBbr = 15; % filter size
GBbs = 5; % standard deviation
% ------------------------------------------------------------------------


G = fspecial('gaussian',GBbr,GBbs);
Ig = imfilter(I,G,'same');

I_orig = I(:,:,1);
I_gray = Ig(:,:,1); % Take one column from RGB as in grayscale

% Convert rectangular image to square, taking short side length as square side
ImageSide = min(size(I_gray));

% Eliminate sides blacked by Gaussian filter
I_origsq = zeros(ImageSide-2*RemoveSideLength,ImageSide-2*RemoveSideLength);
I_origsq(1:end, 1:end) = I_orig((1+RemoveSideLength):(ImageSide-RemoveSideLength),...
    (1+RemoveSideLength):(ImageSide-RemoveSideLength));
I_origsq = uint8(I_origsq);

I_graysq = zeros(ImageSide-2*RemoveSideLength,ImageSide-2*RemoveSideLength);
disp(['Side length (in pixel):', num2str(ImageSide-2*RemoveSideLength)])

I_graysq(1:end, 1:end) = I_gray((1+RemoveSideLength):(ImageSide-RemoveSideLength),...
    (1+RemoveSideLength):(ImageSide-RemoveSideLength));
I_graysq = uint8(I_graysq);
NewImageSide = ImageSide-2*RemoveSideLength;


[it1, Ibin] = Transform(I_graysq, vf); 
[it2, Ibin_orig] = Transform(I_origsq, vf); 
figure(), imshow(I_graysq)
figure(), imshow(I_origsq)

Ibin = noise_filter(Ibin, 2000); % filter out under 15nm NP. change 'resolution' for each sample
figure(), imshow(Ibin)
figure(), imshow(Ibin_orig)

for i = 1:length(Ibin) 
    for j = 1:length(Ibin)
        if Ibin(i,j) > 0 
            Ibin(i,j) = 1; 
        end
    end
end
img_out=Ibin;
save('ML-05-96-10%-100-3.mat','img_out');

disp('# of clusters:')
max(max(bwlabel(img_out)))