load('mats/A2_data.mat', 'test_data_01', 'test_labels_01', ...
    'train_data_01', 'train_labels_01');

%% Clustering
K = 6;
[~, C] = K_means_clustering(train_data_01, K);

%% Classifying
[ytrain, Ltrain] = K_means_classifier(test_data_01, C, test_labels_01);
[M, missrate] = Evaluate_K_means(ytrain, test_labels_01, Ltrain);