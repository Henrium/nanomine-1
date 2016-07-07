clc
clear

%     ______
% y2 |      |
%    |      |
% y1 |______|
%   x1      x2

% Define square edges
x1 = 0;  x2 = 1;
y1 = 0;  y2 = 1;

% Generate test point set in a unit square
M = 100;
x = (x2-x1)*rand(M,1) + x1;
y = (y2-y1)*rand(M,1) + y1;

% Calculate individual cell area of each test point
CellArea=SquareBV(x,y,0,[x1,x2,y1,y2]);
% CellArea=SquareBV(x,y,0);
