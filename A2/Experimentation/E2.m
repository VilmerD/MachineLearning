%% PCA
E1;

%%
K = 2;
[y, C] = K_means_clustering(train_data_01, K);

%% Plot
figure(221);
title(sprintf('K-means clustering with %i clusters', K))
colors = ['r', 'g', 'b', 'y', 'k'];
hold on;
for k = 1:K
    ck = y == k;
    Ck = C(:, k);
    ckdimension_1 = train_data_2D(1, ck);
    ckdimension_2 = train_data_2D(2, ck);
    plot(ckdimension_1, ckdimension_2, [colors(k), 's'], 'Displayname', ...
        sprintf('Class: %i', k));
    
    Ck2D = U2'*Ck;
    s = sprintf('C%i', k);
    plot(Ck2D(1), Ck2D(2), 'kx', 'LineWidth', 2, 'Displayname', s);
end
xlabel('Dimension 1'), ylabel('Dimenstion 2'), legend();