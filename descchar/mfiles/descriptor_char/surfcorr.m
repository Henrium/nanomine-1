function corrsf = surfcorr(image)
% -------------------------------------------------------------------------
% Written by Hongyi Xu, Northwestern U
% 5/2/2013
% Surface-surface correlation function
% 
% INPUT:
% image:   binary image, '1' for filler, '0' for matrix. Square image.
% 
% OUTPUT:
% corrsf:  surface-surface correlation function
%
% SUBFUNCTION USED:
% C = find_edge_1.m
% -------------------------------------------------------------------------
L = length(image);
imax = L;  jmax = L;

% ------------------ Get the "surface image", '1' surface -----------------
[x,y]=size(image);

image_ext = zeros([x+2 y+2]); % expanded image
image_ext(2:x+1,2:y+1) = image;

image_tmp = 4*image - image_ext(1:x,2:y+1) - image_ext(3:x+2,2:y+1)...
                    - image_ext(2:x+1,1:y) - image_ext(2:x+1,3:y+2);
% in 'image_tmp': + '1' edge; - '0' edge; 0 interior

clear x y

img = (image_tmp > 0);
img = double(img);
% -------------------------------------------------------------------------

R = min(round(imax/2),round(jmax/2));  % for a square image, R is half of the edge length
count = zeros(R+1,1);
Bn = zeros(R+1,1); % Initialization of Bn: set the value as 0

A = img - mean(mean(img));
F = fft2(A);
c = fftshift(ifft2(F.*conj(F))); % 2-points correlation. fftshift is to move the peak in the center of the image
% This 2-points correlation function refers to DT Fullwood, SR Kalidindi,
% SR Niezgoda, A Fast, N Hampson: "Gradient-based microstructure 
% reconstructions from distribution useing fast Fourier transforms",
% Material Science and Engineering, Volume 494, Issues 1-2, 2008, P68-72

[y,jc] = max(max(c));   % This two lines is to find the max value of the matrix, and 
[y,ic] = max(max(c'));  % also find the coordinates (location) of the max value in the matrix

for i = 1:imax
    for j = 1 : jmax
        r = round(sqrt((i-ic)^2 + (j-jc)^2)); % r is the distances between a given point and the max value point(peak).
        if r<=R   % this constraints is to confine the counting range into a circle which has the radius of R, and centered at the peak
            Bn(r+1) = Bn(r+1) + c(i,j);  % add all the value of the pixels together, which are located on the same circle centered at the peak
            count(r+1) = count(r+1) +1;  % also count the number of the pixels located on the same circle. It should be monotone increasing.
        end
    end
end

Bn = Bn./count; % calculate the average value of each Bn(average value of the pixels located on the same circle)
corrf = Bn./y;  % y is the max value of the matrix "c" 

% Transform the corr to original scale
VF = sum(sum(img))/L/L;
LL = length(corrf);
corrsf = VF^2 + (VF - VF^2) ./ ( corrf(1) - corrf(LL) ) .* ( corrf - corrf(LL) );

