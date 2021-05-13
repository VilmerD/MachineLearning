function cifar10_refine(net)
    addpath(genpath('./'));

    % argument=2 is how many 10000 images that are loaded. 20000 in this
    % example. Load as much as your RAM can handle.
    [x_train, y_train, x_test, y_test, classes] = load_cifar10(5);
    
    % visualize the images?
    if false
        for i=1:6
            for j=1:6
                subplot(6,6,6*(i-1)+j);
                imagesc(x_train(:,:,:,6*(i-1)+j)/255);
                colormap(gray);
                title(classes(y_train(6*(i-1)+j)));
                axis off;
            end
        end
        return;
    end
    
    % Always subtract the mean. Optimization will work much better if you do.
    data_mean = mean(mean(mean(x_train, 1), 2), 4); % mean RGB triplet
    x_train = bsxfun(@minus, x_train, data_mean);
    x_test = bsxfun(@minus, x_test, data_mean);
    % and shuffle the examples. Some datasets are stored so that all 
    % elements of class 1 are consecurantive. Training will not work on those
    % datasets if you don't shuffle
    perm = randperm(numel(y_train));
    x_train = x_train(:,:,:,perm);
    y_train = y_train(perm);

    % we use 2000 validation images
    x_val = x_train(:,:,:,end-2000:end);
    y_val = y_train(end-2000:end);
    x_train = x_train(:,:,:,1:end-2001);
    y_train = y_train(1:end-2001);
    
    load('cifar10_refine2.mat', 'net');
    
    % see the layer sizes
    [~, ~] = evaluate(net, x_train(:,:,:,1:8), y_train(1:8), true);
    
    % Training
    training_opts = struct('batch_size', 16, ...
                           'weight_decay', 4e-4, ...
                           'learning_rate', 8e-4, ...
                           'momentum', 0.99, ...
                           'iterations', 5000);
    
    for k = 1:10
        net = training(net, x_train, y_train, x_val, y_val, training_opts);
        save('models/cifar10_refine3', 'net');
    end
    
    % evaluate on the test set
    pred = zeros(numel(y_test),1);
    batch = training_opts.batch_size;
    for i=1:batch:size(y_test)
        idx = i:min(i+batch-1, numel(y_test));
        % note that y_test is only used for the loss and not the prediction
        y = evaluate(net, x_test(:,:,:,idx), y_test(idx));
        [~, p] = max(y{end-1}, [], 1);
        pred(idx) = p;
    end
    
    fprintf('Accuracy on the test set: %f\n', mean(vec(pred) == vec(y_test)));
end