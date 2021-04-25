function [y, C] = K_means_clustering(X, K)

% Calculating cluster centroids and cluster assignments for:
% Input:    X   DxN matrix of input data
%           K   Number of clusters
%
% Output:   y   Nx1 vector of cluster assignments
%           C   DxK matrix of cluster centroids

[D, N] = size(X);

intermax = 50;
conv_tol = 1e-6;
% Initialize
C = repmat(mean(X, 2), 1, K) + repmat(std(X, [], 2), 1, K).*randn(D, K);
y = zeros(N,1);
Cold = C;

for kiter = 1:intermax
    % Step 1: Assign to clusters
    y = step_assign_cluster(X, C);
    
    % Step 2: Assign new clusters
    C = step_compute_mean(y, X);
        
    if fcdist(C, Cold) < conv_tol
        return
    end
    Cold = C;
    fprintf('Iteration number: %i\n', kiter)
end

end

function d = fxdist(x, C)
    d = x - C;
    d = sqrt(sum(d.^2, 1));
end

function d = fcdist(C1, C2)
    d = C1 - C2;
    d = sqrt(sum(d.^2, 1));
    d = norm(d);
end

function y = step_assign_cluster(X, C)
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

function C = step_compute_mean(y, X)
[D, ~] = size(X);
Ncluster = max(y);
C = zeros(D, Ncluster);
for k = 1:Ncluster
    idk = y == k;
    C(:, k) = mean(X(:, idk), 2);
end
end