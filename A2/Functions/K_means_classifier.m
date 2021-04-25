function [y, L] = K_means_classifier(X, C, T)
y = assign_cluster(X, C);
[~, K] = size(C);

L = zeros(1, K);
% Assign each cluster the class that has the most examples in T
for k = 1:K
    % Find the index of the data points which belong to cluster k
    idk = y == k;
    
    % Find the labels of the data points and compute the mode
    Tk = T(idk);
    Mk = mode(Tk);
    L(k) = Mk;
end
end

function d = fxdist(x, C)
    p = 2;
    d = x - C;
    d = (sum(d.^p, 1)).^(1/p);
end

function y = assign_cluster(X, C)
[~, N] = size(X);
y = zeros(N, 1);

for k = 1:N
    % Take next point
    xk = X(:, k);
    
    % Compute distance to each cluster, and find the min
    dk = fxdist(xk, C);
    dmin = min(dk);
    i_dmin = find(dmin == dk);
    
    % Insert 
    y(k) = i_dmin;
end
end