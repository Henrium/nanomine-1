function [M_curve]=Morishita_E(image)
%--------------------------------------------------------------------------
% Hongyi Xu, IDEAL Lab, Northwestern University
% This function is used for characterize the binary image in the way of
% using Morishita index.
%
% This is E verson, adapted from version I to cope with large images
%
% INPUT: 
% image: 2D image, any binary image, background should be 0. The width
% should equal to the length (to make the code simpler);
% max_q: how many X-axis points you want in the plot;
% OUTPUT: 
% M_curve, which restores the points for drawing the index curve.
%--------------------------------------------------------------------------
% matlabpool open 4;
M_curve=[];
image=double(image);
image=ceil(image/1000);
[height, width]=size(image); % height & width is image's pixel size
% Here restore all the divisor. In the next step, the images would be
% divided into several sub-squares. At that time, only use a single divisor
% of the combination of divisors with itself or next to each other (in this
% way, the divided sub-squares are more like square)
divide_n=[];
d_count=0;
for ii=1:150 % recommend: 100 for 500*500; 150 for 1500*1500
    if mod(height,ii)==0
        divide_n=[divide_n, ii];
        d_count=d_count+1;
    end
end

N=sum(sum(image));      % N
parfor i=1:d_count
    
    line=divide_n(i);   % line and column is the divide grid number
    column=divide_n(i); % line and column is the divide grid number
    q=line*column;      % q
    V2pixel_X=width/column;
    V2pixel_Y=height/line;
    I_upper=0;          % This is the sum{ni(ni-1)} part in the expression
    for ii=1:1:line
        for jj=1:1:column
            temp=image(   ((ii-1)*V2pixel_Y+1):1:ii*V2pixel_Y , ((jj-1)*V2pixel_X+1):1:jj*V2pixel_X    );  % the nmber here is the width/array or height/array
            ni=sum(sum(temp));         % ni
            I_upper=I_upper+ni*(ni-1);
        end
    end
    Index=q*I_upper/N/(N-1);
    M_curve=[M_curve, Index];
    
end

% matlabpool close;