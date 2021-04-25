%% Data
x0 = [-2 -1 1 2]';
y0 = [1 -1 -1 1]';
x = [-3 -2 -1 0 1 2 4]';
y = [1 1 -1 -1 -1 1 1]';
x0p = x0(y0 > 0);   x0n = setdiff(x0, x0p);
xp = x(y > 0);      xn = setdiff(x, xp);

figure(141);
axis([-4 4.5 0 18])
hold on;
plot(x0p, x0p.^2, 'gs', x0n, x0n.^2, 'rs');
plot(xp, xp.^2, 'g*', xn, xn.^2, 'r*');
hold off;
xlabel('$x$', 'Interpreter', 'Latex', ...
    'Fontsize', 15, 'FontWeight', 'bold')
ylabel('$x^2$', 'Interpreter', 'Latex', ...
    'Fontsize', 15, 'FontWeight', 'bold')
legend('Task 3, y = 1', 'Task 3, y = -1', 'Task 4, y = 1', ...
     'Task 4, y = -1', 'Location', 'NorthWest')
set(gcf, 'Position', [100 100 550 300])
saveas(gcf, 'dataset_comparison', 'png')

g(x)