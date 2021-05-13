function M = evaluateConfusionMatrix(pred, y)
maxlabel = max(y);
minlabel = min(y);
labels = minlabel:1:maxlabel;

M = zeros(maxlabel);
for k = labels - minlabel + 1
    lk = labels(k);
    yk = (y == lk);
    predk = pred(yk);
    for j = labels - minlabel + 1
        lj = labels(j);
        M(j, k) = sum(predk == lj);
    end
end