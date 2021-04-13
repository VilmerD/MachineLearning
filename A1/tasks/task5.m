% Load data
load('A1_data.mat')

% Create lambda grid
lambda_min = 1e-3;
lambda_max = lambda_min;
[xi, lx] = size(X);
for k = 1:lx
    lambda_max = max(lambda_max, abs(X(:, k)'*t));
end
N_lambda = 30;
lambda_grid = exp(linspace(log(lambda_min), log(lambda_max), N_lambda));

% K-fold optimization
K = 10;
[wopt, lambdaopt, RMSEval, RMSEest] = lasso_cv(t, X, lambda_grid, K);

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

%% Reconstruction
% Plotting/Axis data
tmin = 0.02;
tmax = 0.48;

nt = length(n);
tt = linspace(tmin, tmax, nt);

nti = length(ninterp);
tti = linspace(tmin, tmax, nti);

% Compute lasso estimation
what = lasso_ccd(t, X, lambdaopt);
y = X*what;
yinterp = Xinterp*what;

% Plotting parameters
ax = [tmin, tmax, min(t), max(t)];

figure(2);
axis(ax)
xlabel('Time [s]')
hold on;

marks = ["b^", "rs", "g"];
% Original data
plot(tt, t, marks(1), 'DisplayName', 't');

% Recreated data
plot(tt, y, marks(2), 'DisplayName', 'y');

% Interpolated data
plot(tti, yinterp, marks(3), 'DisplayName', 'y interp.');

legend();
set(2, 'Position', [100, 900, 585, 225]);
tit = sprintf('Lasso estimation with lambda: %2.1f', lambdaopt);
title(tit);
    
number_non_zero = sum(what ~= 0);
figname = sprintf('lasso%1.2e.png', lambdaopt);
saveas(2, figname, 'png');