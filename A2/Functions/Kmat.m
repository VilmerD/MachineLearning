function K = Kmat(phi, x)
n = length(x);
K = zeros(n);
for i = 1:n
    xi = x(i);
    for j = 1:n
        xj = x(j);
        kij = phi(xi)'*phi(xj);
        K(i, j) = kij;
    end
end
end

