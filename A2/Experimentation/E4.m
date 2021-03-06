%% Load data
load('mats/A2_data.mat', 'test_data_01', 'test_labels_01', ...
    'train_data_01', 'train_labels_01');
load('mats/centroids', 'C2')

%% Classifying
[ytrain, Ltrain] = K_means_classifier(train_data_01, C2, train_labels_01);
[ytest, Ltest] = K_means_classifier(test_data_01, C2, test_labels_01);

%%
[Mtrain, missrate_test] = ...
    Evaluate_K_means(ytrain, train_labels_01, Ltrain);
[Mtest, missrate_train] = ...
    Evaluate_K_means(ytest, test_labels_01, Ltest);