function [B_hat] = unvectorization(B,m,n)

% ========================================================================
% Descripition: Creates a matrix from a vectorized vector B.
% inputs: B - Vectorized vector (dimensions should be m*n by 1)
%         m - number of rows in output matrix B_hat
%         n - number of columns in output matrix B_hat
% outputs: B_hat - matix of vector B
% Author: Paul Arendt
% Date crated: March 31, 2010
% ========================================================================

% Check to make sure B is the correct dimeensions
[q,r] = size(B);
if r > 1
    disp('Error: B has more than 1 column and cannot be unvectorized')
    B_hat = 1;
elseif q ~= m*n
    disp('Error: B does not have the correct number of rows for inputs m and n');
    B_hat = 1;
else
    B_hat = zeros(m,n);
    for i = 1:n
        B_hat(1:m,i) = B((i-1)*m+1:i*m,1);
    end
end