function Eimg = find_edge_1_img(image)
% This function find pixels on the edge of '1' clusters in a binary image
% and record their coordinates. This function find the '1's adjacent to the
% '0' 

% INPUTS:
% image:   a binary image, '1' is the inclusions, '0' is the background
% OUTPUTS:
% Eimg:    the img only with edge 

% Used in "Annealing_Microstructure.m"
[x,y]=size(image);

image_ext = zeros([x+2 y+2]); % expanded image
image_ext(2:x+1,2:y+1) = image;

image_tmp = 4*image - image_ext(1:x,2:y+1) - image_ext(3:x+2,2:y+1)...
                    - image_ext(2:x+1,1:y) - image_ext(2:x+1,3:y+2);
% in 'image_tmp': + '1' edge; - '0' edge; 0 interior

clear x y
Eimg = double(image_tmp > 0);
