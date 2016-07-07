function lcorr = linearpath(image)
% -------------------------------------------------------------------------
% Written by Hongyi Xu, 4/27/2013
% This function evaluate the linear path correlation of the "1" phase of a
% binary 2D image
% Inputs:
% image: binary image, the phase to be characterized is "1". The column
% direction is characterized. The size of the image is L X L
% Outputs:
% lcorr: linear path correlation function
% -------------------------------------------------------------------------
image = double(image);
L = length(image);
lcorr = zeros(L,1);

FC = L:-1:1;
FC = FC(:) * L;

for ii = 1:1:L  % Go through all the columns
    
    clm = image(:,ii);
    clm = bwlabel(clm);
    maxnum = max(clm);
        
    if maxnum > 0
        for jj = 1:1:maxnum

            cnt = sum( clm==jj );
            for kk = 1:1:cnt
                lcorr(kk) = lcorr(kk) + cnt - kk + 1;
            end

        end
    end
    
end

lcorr = lcorr./FC;
