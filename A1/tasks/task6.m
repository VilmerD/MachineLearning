load('A1_data.mat', 'Ttrain', 'Xaudio');

% Create lambda grid
lambda_min = 1e-3;
lambda_max = lambda_min;
[xi, lx] = size(Xaudio);
t = Ttrain(1:xi);
for k = 1:lx
    lambda_max = max(lambda_max, abs(Xaudio(:, k)'*t));
end
N_lambda = 50;
lambda_grid = exp(linspace(log(lambda_min), log(lambda_max), N_lambda));

%% Training
K = 8;
[wopt, lambdaopt, RMSEval, RMSEest] = ...
    multiframe_lasso_cv(Ttrain, Xaudio, lambda_grid, K);

save('lambdaopt.mat', 'lambdaopt')

%% Plots
figure(1)
RMSEmax = max([RMSEval, RMSEest]);
RMSEmin = min([RMSEval, RMSEest]);
axi = [lambda_min, lambda_max, RMSEmin, RMSEmax];

semilogx(lambda_grid, RMSEval, 'bs-', 'DisplayName', 'RMSEval');
hold on;  
semilogx(lambda_grid, RMSEest, 'r^-', 'DisplayName', 'RMSEest');

plot([lambdaopt, lambdaopt], [RMSEmax*2, 0], 'k--', 'DisplayName', 'LambdaOpt');
axis(axi);

legend('Location', 'NorthWest');
xlabel('Lambda')
ylabel('RMSE')
title('RMSE for K-fold cross-validation scheme')
set(1, 'Position', [100, 100, 600, 400])