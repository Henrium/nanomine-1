function image = voronoi_mark(x, y, Lx, Ly)
% -------------------------------------------------------------------------
% Written by Hongyi Xu, Northwestern U
% 5/1/2013
% This function mark the different regions of a Voronoi diagram using
% different pixel values
% 
% INPUT:
% x, y:   the X Y coordinate list of the particle/cluster centers
% Lx, Ly: the length of the image in X Y directions
% 
% OUTPUT:
% image:  where different Voronoi polygon is marked with different values
% -------------------------------------------------------------------------
image = zeros(Lx, Ly);

L = length(x);
N = 1:1:L;
N = N(:);
x = x(:); % x as Line
y = y(:); % y as Column

cl = [x y];

% matlabpool open 6;
for ii = 1:Lx
    for jj = 1:1:Ly
        
        expand_p = repmat( [ii jj] , [L , 1] );
        dist = (cl - expand_p).^2;
        dist = sum( dist , 2);
        dist = dist.^0.5;
        
        min_dist = min(dist);
        
        indi = (dist == min_dist);
        indi = max( N.* double(indi) );
        
        image(ii,jj) = indi;
        
    end
end

% matlabpool close;
