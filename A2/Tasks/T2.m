%% Data
x = [-2 -1 1 2]';
y = [1 -1 -1 1]';
n = length(x);

% Compute K-matrix
phi = @(x) [x; x.^2];
K = Kmat(phi, x);

% Compute the coefficients for the 2:nd degree polynomial
k0 = 4;
k1 = -1/2*sum(y*y'.*K, 'all');
ahat = -k0/(2*k1);

%% Classification function
g1 = sum(ahat*y.*x);
g2 = sum(ahat*y.*x.^2);

i = 2;
b = 1/y(i) - sum(ahat*y.*K([1 2 3 4], i));
g = @(x) g2*x.^2 + g1*x + b;