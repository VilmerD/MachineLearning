function cifar10_starter()
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
    
    % Network
    net.layers = {};
    net.layers{end+1} = struct('type', 'input', ...
        'params', struct('size', [32, 32, 3]));
    
    net.layers{end+1} = struct('type', 'convolution',...
        'params', struct('weights', 0.1*randn(5,5,3,32)/sqrt(5*5*3/2), ...
        'biases', zeros(32,1)), ...
        'padding', [2 2]); 
    net.layers{end+1} = struct('type', 'relu');
    net.layers{end+1} = struct('type', 'maxpooling');
    
    net.layers{end+1} = struct('type', 'convolution',...
        'params', struct('weights', 0.1*randn(5,5,32,64)/sqrt(5*5*32/2), ...
        'biases', zeros(64,1)), ...
        'padding', [2 2]);  
    net.layers{end+1} = struct('type', 'relu');
    net.layers{end+1} = struct('type', 'maxpooling');
    
    net.layers{end+1} = struct('type', 'convolution',...
        'params', struct('weights', 0.1*randn(5,5,64,64)/sqrt(5*5*64/2), ...
        'biases', zeros(64,1)), ...
        'padding', [2 2]);
    net.layers{end+1} = struct('type', 'convolution',...
        'params', struct('weights', 0.1*randn(5,5,64,64)/sqrt(5*5*64/2), ...
        'biases', zeros(64,1)), ...
        'padding', [2 2]);
    net.layers{end+1} = struct('type', 'convolution',...
        'params', struct('weights', 0.1*randn(5,5,64,48)/sqrt(5*5*64/2), ...
        'biases', zeros(48,1)), ...
        'padding', [2 2]);
    net.layers{end+1} = struct('type', 'relu');
    net.layers{end+1} = struct('type', 'maxpooling');
    
    net.layers{end+1} = struct('type', 'fully_connected',...
        'params', struct('weights', randn(768,768)/sqrt(768/2), ...
        'biases', zeros(768,1)));
    net.layers{end+1} = struct('type', 'fully_connected',...
        'params', struct('weights', randn(10,768)/sqrt(768/2), ...
        'biases', zeros(10,1)));
    
    net.layers{end+1} = struct('type', 'softmaxloss');
    
    load('cifar10_04.mat', 'net');
    
    % see the layer sizes
    [~, ~] = evaluate(net, x_train(:,:,:,1:8), y_train(1:8), true);
    
    % Training
    training_opts = struct('learning_rate', 20e-3,...
        'iterations', 1000,...
        'batch_size', 16,...
        'momentum', 0.90,...
        'weight_decay', 0.001);
    
    net = training(net, x_train, y_train, x_val, y_val, training_opts);
    save('models/cifar10_01', 'net');
    
    training_opts.learning_rate = 5e-3;
    training_opts.momentum = 0.95;
    training_opts.iterations = 2000;
    
    net = training(net, x_train, y_train, x_val, y_val, training_opts); 
    save('models/cifar10_02', 'net');
    
    training_opts.learning_rate = 8e-4;
    training_opts.momentum = 0.99;
    training_opts.iterations = 1000;
    
    net = training(net, x_train, y_train, x_val, y_val, training_opts);
    save('models/cifar10_03', 'net');
    
    net = training(net, x_train, y_train, x_val, y_val, training_opts);
    save('models/cifar10_04', 'net');
    
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