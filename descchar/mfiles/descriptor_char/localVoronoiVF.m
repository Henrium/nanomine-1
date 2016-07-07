function [localVF, CVimg] = localVoronoiVF(image, x, y)
% -------------------------------------------------------------------------
% Written by Hongyi Xu, Northwestern U
% 5/1/2013
% This function calculate the list of VF in each Voronoi polygon
% 
% INPUT:
% x, y:     the X Y coordinate list of the particle/cluster centers
% image:    the binary image, '1' for filler, '0' for matrix
% 
% OUTPUT:
% localVF:  list of local VF in each Voronoi polygon
% CVimg:    the Voronoi diagram, polygons are marked by different values
% 
% FUNCTION USED:
% voronoi_mark.m
% -------------------------------------------------------------------------
[Lx Ly] = size(image);
CVimg = voronoi_mark(x, y, Lx, Ly); % colored voronoi image
N = size(x);
localVF = zeros([N,1]);
% inside_areas = zeros([N,1]);  % For checking
% matlabpool open 6;
for ii = 1:N
    
    sp = (CVimg == ii); % single polygon in the image
    sp = double(sp);
    poly_area = sum(sum(sp));  % Voronoi polygon area
    clu_area = image .* sp;
    area_inside = sum( sum( clu_area ) ); % cluster area inside the polygon
    localVF(ii) = area_inside/poly_area;
%     inside_areas(ii) = area_inside;
    
end
% matlabpool close;
