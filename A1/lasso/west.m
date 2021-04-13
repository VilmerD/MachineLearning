% Computes lasso estimate
function wstar = west(xi, ri, lambda)
p = xi'*ri;
ap = abs(p);
nx = xi'*xi;

wstar = (p/(nx*ap))*(ap - lambda);
wstar = wstar*(ap > lambda);
end
