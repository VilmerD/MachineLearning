%% Load network
load('models/cifar10_refine3', 'net')

%% Plot the filters of the first convolutional layer
first_layer = net.layers{1, 2}.params.weights;
f1 = figure(1);
for k = 1:16
    subplot(4, 4, k)
    filter_k = first_layer(:, :, :, k);
    imshow(40*filter_k)
end
sgtitle('Filters of the first convolutional layer')
set(f1, 'Position', [100, 100, 500, 500]);
saveas(f1, 'filterscifar.png', 'png')
%% Evaluate the predictions so more analysis can be made
[x_train, y_train, x_test, y_test, classes] = load_cifar10(1);

pred = zeros(numel(y_test),1);
batches = 16;
for i=1:batches:size(y_test)
    idx = i:min(i+batches-1, numel(y_test));
    % note that y_test is only used for the loss and not the prediction
    y = evaluate(net, x_test(:,:,:,idx), y_test(idx));
    [~, p] = max(y{end-1}, [], 1);
    pred(idx) = p;
end
pred = uint8(pred);
%% Plot some incorrectly labeld images
% Check which are incorrectly labeled
incorrect = abs(pred - y_test) > 0;
index_incorrect = find(incorrect);

% Randomly choose 9 of the incorrectly labeled images
N = 4;  r = 2;
i = randperm(numel(index_incorrect), N);

% Plot them
f2 = figure(2);
for n = 1:N
    subplot(r, r, n);
    in = index_incorrect(i(n));
    xn = x_test(:, :, :, in);
    imshow(xn/255);
    tit = {sprintf('Label: %s', classes{y_test(in)}), ...
        sprintf('Prediction: %s', classes{pred(in)})};
    title(tit);
end
sgtitle('Some misclassified images')
set(f2, 'Position', [100, 100, 500, 500]);
saveas(f2, 'missclassifiedcifar.png', 'png')
%% Confusion matrix
M = evaluateConfusionMatrix(pred, y_test);
precision = diag(M)'./sum(M, 1);
recall = diag(M)./sum(M, 2);
save('ConfusionCifar', 'M', 'recall', 'precision');

%% Formating for latex
M_string = sprintf([repmat(['%i & \t'], 1, 9), '%i \t\\\\ \n'], M');
f = [repmat(['%0.3f & \t'], 1, 9), '%0.3f \t\\\\'];
precision_string = sprintf(f, precision);
recall_string = sprintf(f, recall);

disp('Confusion matrix in string format')
disp(M_string);
disp('Precision')
disp(precision_string);
fprintf('\nRecall\n')
disp(recall_string);