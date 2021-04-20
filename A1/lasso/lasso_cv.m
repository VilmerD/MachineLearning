function [wopt, lambdaopt, RMSEval, RMSEest] = lasso_cv(t, X, lambdavec, K)
% [wopt,lambdaopt,VMSE,EMSE] = lasso_cv(t,X,lambdavec)
% Calculates the LASSO solution problem and trains the hyperparameter using
% cross-validation.
%
%   Output: 
%   wopt        - mx1 LASSO estimate for optimal lambda
%   lambdaopt   - optimal lambda value
%   MSEval      - vector of validation MSE values for lambdas in grid
%   MSEest      - vector of estimation MSE values for lambdas in grid
%
%   inputs: 
%   y           - nx1 data column vector
%   X           - nxm regression matrix
%   lambdavec   - vector grid of possible hyperparameters
%   K           - number of folds

[N,M] = size(X);
Nlam = length(lambdavec);

% Preallocate
SEval = zeros(K, Nlam);
SEest = zeros(K, Nlam);

% cross-validation indexing
randomind = randperm(N); % Select random indices for validation and estimation
location = 0; % Index start when moving through the folds
Nval = floor(N/K); % How many samples per fold
Nest = N - Nval;
cvidx = (1:Nval)';
hop = Nval; % How many samples to skip when moving to the next fold.


for kfold = 1:K
   
    % Select validation indices
    valind = randomind(location + cvidx); 
    % Select estimation indices
    estind = setdiff(randomind, valind);
    assert(isempty(intersect(valind,estind)), ...
        "There are overlapping indices in valind and estind!");
    % assert empty intersection between valind and estind
    wold = zeros(M,1); % Initialize estimate for warm-starting.
    
    for klam = 1:Nlam
        tval = t(valind);
        Xval = X(valind, :);
        
        test = t(estind);
        Xest = X(estind, :);
        
        % Calculate LASSO estimate on estimation indices for the current 
        % lambda-value.
        what = lasso_ccd(test, Xest, lambdavec(klam), wold);
        
        % Calculate validation error for this estimate
        SEval(kfold, klam) = norm(tval - Xval*what)^2/Nval; 
        
        % Calculate estimation error for this estimate
        SEest(kfold, klam) = norm(test - Xest*what)^2/Nest; 
        
        % Set current estimate as old estimate for next lambda-value.
        wold = what;
        
        % Display current fold and lambda-index.
        fprintf('Fold: %i, lambda-index: %i\n', kfold, klam) 
        
    end
    
    location = location + hop; % Hop to location for next fold.
end

% Calculate MSE_val as mean of validation error over the folds.
MSEval = mean(SEval, 1);
% Calculate MSE_est as mean of estimation error over the folds.
MSEest = mean(SEest, 1);

% Select optimal lambda 
lambdaopt = lambdavec(MSEval == min(MSEval)); 

RMSEval = sqrt(MSEval);
RMSEest = sqrt(MSEest);

% Calculate LASSO estimate for selected lambda using all data.
wopt = lasso_ccd(t, X, lambdaopt);
end

