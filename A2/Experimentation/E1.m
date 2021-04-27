%% Load data
load('mats/A2_data.mat', 'train_data_01', 'train_labels_01');

% Index of 0s and 1s
idx0 = find(train_labels_01 == 0);
length_train_data = length(train_labels_01);
idx1 = setdiff(1:length_train_data, idx0)';

%% Zero mean
m = mean(train_data_01, 1);
zm_train_data = train_data_01 - m;

%% PCA
[U, ~, ~] = svd(zm_train_data);
U2 = U(:, [1, 2]);
save('mats/basis.mat', 'U2');
%% Projection
train_data_2D = U2'*train_data_01;

%% Plot
f211 = figure(211);
plot(train_data_2D(1, idx0), train_data_2D(2, idx0), 'rs')
hold on;
plot(train_data_2D(1, idx1), train_data_2D(2, idx1), 'gs')
xlabel('dimension 1'), ylabel('dimension 2'), legend('t = 0', 't = 1')
title('Dimensionality reduced train data')
set(f211, 'Position', [100 100 500 300])