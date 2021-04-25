%% Load data
load('mats/A2_data.mat', 'train_data_01');

%% Clustering
K = 2;
[y2, C2] = K_means_clustering(train_data_01, K);

K = 5;
[y5, C5] = K_means_clustering(train_data_01, K);

%% Images
figure(231);
for k = 1:2
    Ck = C2(:, k);
    ik = reshape(1-Ck, [28 28]);
    subplot(1, 2, k);
    imshow(ik);
    title(sprintf('C%i', k))
end
sgtitle('K-means clustering with 2 clusters')

figure(232);
for k = 1:5
    Ck = C5(:, k);
    ik = reshape(1-Ck, [28 28]);
    if k < 4
        pos = (2*k-1):(2*k);
    else
        pos = (2*k):(2*k + 1);
    end
    subplot(2, 6, pos);
    imshow(ik);
    title(sprintf('C%i', k))
end
sgtitle('K-means clustering with 5 clusters')