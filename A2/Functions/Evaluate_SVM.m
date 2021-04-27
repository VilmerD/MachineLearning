function [M, missrate] = Evaluate_SVM(y, T)
ids = [0, 1];
nids = length(ids);
N = length(y);
M = zeros(2, 3);
for k = 1:nids
    idk = ids(k);
    % Get data points in this cluster
    indexk = y == idk;
    tk = T(indexk);
    
    % Get number of target 0's and 1's in this set
    ntk = length(tk);
    ntk0 = sum(tk == 0);
    ntk1 = ntk - ntk0;
    M(k, 1:2) = [ntk0, ntk1];
    
    % Number of missclassified
    M(k, end) = ntk0*(idk == 1) + ntk1*(idk == 0);
end
nmissclassified = sum(M(:, end));
missrate = nmissclassified/N;
end