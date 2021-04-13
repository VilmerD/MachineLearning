lambdas = [1e-1, 1e1, 2];

% Load data
load('A1_data', 't', 'X', 'n', 'Xinterp', 'ninterp');

% Plotting/Axis data
tmin = 0.02;
tmax = 0.48;

nt = length(n);
tt = linspace(tmin, tmax, nt);

nti = length(ninterp);
tti = linspace(tmin, tmax, nti);

marks = ["b^", "rs", "g"];

number_non_zero = zeros(1, 3);
W = zeros(nti, 3);
for k = 1:3
    lambdak = lambdas(k);
    
    % Compute lasso estimation
    whatk = lasso_ccd(t, X, lambdak);
    W(:, k) = whatk;
    y = X*whatk;
    yinterp = Xinterp*whatk;

    % Plotting parameters
    ax = [tmin, tmax, min(t), max(t)];

    figure(k);
    axis(ax)
    xlabel('Time [s]')
    hold on;

    % Original data
    plot(tt, t, marks(1), 'DisplayName', 't');

    % Recreated data
    plot(tt, y, marks(2), 'DisplayName', 'y');

    % Interpolated data
    plot(tti, yinterp, marks(3), 'DisplayName', 'y interp.');

    legend();
    set(k, 'Position', [100, 900 - 350*(k - 1), 585, 225]);
    tit = sprintf('Lasso estimation with lambda: %2.1f', lambdak);
    title(tit);
    
    number_non_zero(k) = sum(whatk ~= 0);
    figname = sprintf('lasso%1.2e.png', lambdak);
    saveas(k, figname, 'png');
end

disp('Number of nonzero variables: ')
fprintf('\t lambda: %1.0e, nonzero w: %1i \n', [lambdas; number_non_zero]);