function dldx = softmaxloss_backward(x, labels)
    % Inputs:
    %    x - Features. See the reshape command below. It is reshaped as for
    %        the fully connected layer.
    %    labels - It is a vector with the correct labels. For
    %        instance if we have a batch of two where the first example is
    %        class 4 and the second example is class 7, labels is [4 7].
    %
    % Outputs:
    %    dldx - Partial derivative of L with respect to x. Remember that in
    %           the forward pass you average over the batch elements.
    labels = vec(labels);
    sz = size(x);
    batches = sz(end);
    features = prod(sz(1:end-1));

    % suitable for matrix multiplication
    x = reshape(x, [features, batches]);
    % for numerical stability. Convince yourself that the result is the same.
    x = bsxfun(@minus, x, min(x, [], 1));

    ex = exp(x);
    z = ex./sum(ex, 1);
    
    i = vec(double(labels)) + vec((0:batches-1)*features);
    delta_ic = zeros(features, batches);
    delta_ic(i) = 1;
    dldx = (z - delta_ic)/batches;
end
