function [Wopt, lambdaopt, RMSEval, RMSEest] = ...
    multiframe_lasso_cv(T, X, lambdavec, K)
% [wopt,lambdaopt,VMSE,EMSE] = multiframe_lasso_cv(T,X,lambdavec,n)
% Calculates the LASSO solution for all frames and trains the
% hyperparameter using cross-validation.
%
%   Output:
%   Wopt        - mxnframes LASSO estimate for optimal lambda
%   lambdaopt   - optimal lambda value
%   VMSE        - vector of validation MSE values for lambdas in grid
%   EMSE        - vector of estimation MSE values for lambdas in grid
%
%   inputs:
%   T           - NNx1 data column vector
%   X           - NxM regression matrix
%   lambdavec   - vector grid of possible hyperparameters
%   K           - number of folds

% Define some sizes
NN = length(T);
[N, M] = size(X);
Nlam = length(lambdavec);

% Set indexing parameters for moving through the frames.
framehop = N;
idx = (1:N)';
framelocation = 0;
Nframes = 0;

% Calculate number of frames.
while framelocation + N <= NN
    Nframes = Nframes + 1; 
    framelocation = framelocation + framehop;
end 

% Preallocate
Wopt = zeros(M,Nframes);
SEval = zeros(K,Nlam);
SEest = zeros(K,Nlam);

% Set indexing parameter for the cross-validation indexing
Nval = floor(N/K);
cvidx = (1:Nval)';
cvhop = Nval;

% Select random indices for picking out validation and estimation indices. 
randomind = randperm(N);
    
framelocation = 0;
for kframe = 1:Nframes % First loop over frames
    
    cvlocation = 0;
    
    for kfold = 1:K % Then loop over the folds
        
        % Select validation indices
        valind = randomind(cvlocation + cvidx); 
        % Select estimation indices
        estind = setdiff(randomind, valind);
        % assert empty intersection between valind and estind
        assert(isempty(intersect(valind,estind)), ...
            "There are overlapping indices in valind and estind!"); 
    
        t = T(framelocation + idx); % Set data in this frame
        wold = zeros(M,1);      % Initialize old weights for warm-starting.
        
        for klam = 1:Nlam  % Finally loop over the lambda grid
            tval = t(valind);
            Xval = X(valind, :);
        
            test = t(estind);
            Xest = X(estind, :);
        
            % Calculate LASSO estimate on estimation indices for the current 
            % lambda-value.
            what = lasso_ccd(test, Xest, lambdavec(klam), wold);

            % Calculate validation error for this estimate
            SEval(kfold, klam) = SEval(kfold, klam) + ...
                norm(tval - Xval*what)^2/Nval; 

            % Calculate estimation error for this estimate
            SEest(kfold, klam) = SEest(kfold, klam) + ...
                norm(test - Xest*what)^2/Nval; 

            % Set current estimate as old estimate for next lambda-value.
            wold = what;

            % Display progress through frames, folds and lambda-indices.
            fprintf('Frame: %i, Fold: %i, Hyperparam: %i\n', ...
                kframe, kfold, klam);
        end
        
        cvlocation = cvlocation + cvhop; % Hop to location for next fold.
    end
    
    framelocation = framelocation + framehop; % Hop to location for next frame.
    
end

MSEval = mean(SEval,1); % Average validation error across folds
MSEest = mean(SEest,1); % Average estimation error across folds
q = inf;
MSEweighted = [1, 1/q]*[MSEval; MSEest];

% Select optimal lambda 
lambdaopt = lambdavec(MSEweighted == min(MSEweighted)); 

% Move through frames and calculate LASSO estimates using both estimation
% and validation data, store in Wopt.
framelocation = 0;
for kframe = 1:Nframes
    t = T(framelocation + idx);
    Wopt(:, kframe) = lasso_ccd(t, X, lambdaopt);
    framelocation = framelocation + framehop;
end

RMSEval = sqrt(MSEval);
RMSEest = sqrt(MSEest);

end