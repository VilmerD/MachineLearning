%% PCA
load('mats/A2_data.mat', 'train_data_01')
load 'mats/basis.mat'
train_data_2D = U2'*train_data_01;

%% Using 2 clusters
K = 2;
f221 = figure(221);
C2 = cluster_and_plot(K, f221, train_data_01, train_data_2D);

%% Using 5 clusters
K = 5;
f222 = figure(222);
C5 = cluster_and_plot(K, f222, train_data_01, train_data_2D);

%% Saving data
save('mats/centroids.mat', 'C2', 'C5');

%% Function
function CK = cluster_and_plot(K, f, X, X2D)
[yK, CK] = K_means_clustering(X, K);

% Plot
axes1 = axes('Parent', f);
hold(axes1, 'on')
title(sprintf('K-means clustering with %i clusters', K))
colors = ['r', 'g', 'b', 'm', 'k'];
for k = 1:K
    ck = yK == k;
    Ck = CK(:, k);
    ckdimension_1 = X2D(1, ck);
    ckdimension_2 = X2D(2, ck);
    plot(ckdimension_1, ckdimension_2, [colors(k), 's'], 'Displayname', ...
        sprintf('Class: %i', k));
    
%     Ck2D = U2'*Ck;
%     s = sprintf('Centroid: %i', k);
%     plot(Ck2D(1), Ck2D(2), 'kx', 'LineWidth', 2, 'Displayname', s);
end
% Labels
xlabel('Dimension 1'), ylabel('Dimension 2')

hold(axes1, 'off')

% Sets legend
legend1 = legend(axes1, 'show'); set(legend1, 'Location', 'SouthWest')
set(f, 'Position', [100 100 500 300])
end