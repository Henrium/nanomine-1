function [roundness, tortousity] = rnd_tort(image)
% -------------------------------------------------------------------------
% Written by Hongyi Xu, Northwestern U
% This function evaluate the roundness and tortousity of the clusters in a 
% binary image
% Roundness = 4 * Area / pi / max distance of 2 points on boundary
% Tortousity = max distance of 2 points on boundary / contour length
% 
% INPUT:
% image, colored image
% 
% OUTPUT:
% tort: the list of tortousity
%
% Function Used:
% find_edge_1.m
% -------------------------------------------------------------------------
% image = double(image);
% image = bwlabel(image);

N = max( max(image) );
roundness = zeros(N,1);
tortousity = zeros(N,1);

for ii = 1:1:N
    
    temp_img = (image == ii);
    temp_img = double(temp_img);
    A = sum(sum(temp_img)); % area of the cluster
    C = find_edge_1(temp_img); 
    M = size(C, 1); % it is also the contour length (in pixel)
    
    for jj = 1:1:M

        expand_c = repmat( C(jj,:) , [M , 1] );
        max_dist = (C - expand_c).^2;
        max_dist = sum( max_dist , 2);
        max_dist = max_dist.^0.5;
        max_dist = max(max_dist);

    end
    
    roundness(ii) = 4 * A / pi / max_dist^2;
    
    if roundness(ii) == Inf
        roundness(ii) = 2/sqrt(pi);
    end
    
    tortousity(ii) = max_dist/M;
    
end
