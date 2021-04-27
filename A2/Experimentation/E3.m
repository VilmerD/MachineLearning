%% Load data
load 'mats/centroids.mat'

%% Images
f231 = figure(231);
for k = 1:2
    Ck = C2(:, k);
    ik = reshape(1-Ck, [28 28]);
    subplot(1, 2, k);
    imshow(ik);
    title(sprintf('Centroid: %i', k))
end
sgtitle('K-means clustering with 2 clusters')
set(f231, 'Position', [100 100 500 300])

f232 = figure(232);
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
    title(sprintf('Centroid: %i', k))
end
sgtitle('K-means clustering with 5 clusters')
set(f232, 'Position', [100 100 500 300])