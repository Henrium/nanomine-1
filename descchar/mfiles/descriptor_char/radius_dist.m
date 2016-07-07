function radif = radius_dist(cx, cy, L)
% -------------------------------------------------------------------------
% Written by Hongyi Xu, 5/2/2013
% This function evaluate the radius distance function of the image
% Inputs:
% cx, cy:  X Y coordinate list of particle/cluster centers
% Outputs:
% radif: radius distance function
% -------------------------------------------------------------------------
cx = cx(:);
cy = cy(:);

pnt_num = length(cx); % # of center points
pnt_loc = [cx, cy];

BinCntr = round(L/2) + 1;

radif = zeros(1,BinCntr);
r = 1:1:BinCntr;

for i = 1:pnt_num
    
    dist = zeros(1,pnt_num-i+1);
    
    for j = i+1:pnt_num
        
        dx = abs(pnt_loc(i,1)-pnt_loc(j,1));
        dy = abs(pnt_loc(i,2)-pnt_loc(j,2));
        if dx>=L/2; dx = L-dx; end;
        if dy>=L/2; dy = L-dy; end;
        dist(j-i+1) = sqrt(dx*dx+dy*dy);
        
    end
    
    radif = radif + hist(dist,r);
    
end

radif = radif ./ ( 2*pi*pnt_num*r );
radif = radif( 1:BinCntr-1 );

