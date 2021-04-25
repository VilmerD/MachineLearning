%% Data
x = [-2 -1 1 2]';
y = [1 -1 -1 1]';
n = length(x);

% Compute K-matrix
phi = @(x) [x; x.^2];
K = Kmat(phi, x);