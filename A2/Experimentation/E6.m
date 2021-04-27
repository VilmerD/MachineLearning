%% Loading data
load('mats/A2_data.mat', 'train_data_01', 'train_labels_01', ...
    'test_data_01', 'test_labels_01');

%% Training using SVM
model = fitcsvm(train_data_01', train_labels_01', ...
    'Verbose', 1);
[Ltrain, ~] = predict(model, train_data_01');
[Ltest, ~] = predict(model, test_data_01');

%% Evaluating
[Mtrain, missrate_train] = ...
    Evaluate_SVM(Ltrain, train_labels_01);
[Mtest, missrate_test] = ...
    Evaluate_SVM(Ltest, test_labels_01);