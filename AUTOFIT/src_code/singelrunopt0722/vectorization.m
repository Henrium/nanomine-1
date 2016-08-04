function [V] = vectorization(A)

% ========================================================================
% Creates a vectorization of matrix A (dimensionality of 2 or 3)
% Input: A - Matrix to be vectorized
% Output: V - Vectorization of A
% Created by: Paul Arendt
% Date Created: 3/5/2010
% ========================================================================

N = size(A);

if length(N) == 1;  % A is already a vector
    V = A;
elseif length(N) == 2;      % Vectorize the 2 dimensional matrix A
    V = zeros(N(1)*N(2),1);
    for j = 1:N(2)
        V((j-1)*N(1)+1:j*N(1),1) = A(:,j);
    end
elseif length(N) == 3;      % Vectorize the 3 dimensional matrix A
    temp_V = zeros(N(1)*N(2),N(3));
    V = zeros(N(1)*N(2)*N(3),1);
    for k = 1:N(3)
        for j = 1:N(2)
            temp_V((j-1)*N(1)+1:j*N(1),k) = A(:,j,k);
        end
        V((k-1)*N(1)*N(2)+1:k*N(1)*N(2),1) = temp_V(:,k);
    end
else
    disp('A has dimension greater than 3');
end