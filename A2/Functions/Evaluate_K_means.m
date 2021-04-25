function [M, missrate] = K_means_classification_results(y, T, L)
K = max(y);
N = length(y);
M = zeros(K, 5);
for k = 1:K
    M(k, 1) = k;
    % Get data points in this cluster
    idk = y == k;
    yk = y(idk);
    nk = length(yk);
    
    % Get number of target 0's and 1's in this set
    tk = T(idk);
    tk0 = find(tk == 0);
    ntk0 = length(tk0);
    ntk1 = nk - ntk0;
    M(k, 2:3) = [ntk0, ntk1];
    
    % Assigned to class
    Lk = L(k);
    M(k, 4) = Lk;
    
    % Number of missclassified
    M(k, end) = ntk0*(Lk == 1) + ntk1*(Lk == 0);
end
nmissclassified = sum(M(:, end));
missrate = nmissclassified/N;
end