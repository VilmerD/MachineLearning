pol_eval_tols = 10.^(-4:4);
pol_evals = zeros(9, 1);
pol_its = zeros(9, 1);
for k = 1:length(pol_eval_tols)
    pol_eval_tol = pol_eval_tols(k);
    snake;
    pol_evals(k) = nbr_pol_eval;
    pol_its(k) = nbr_pol_iter;
end

%%
sform = '%8i& %8i& %8i\\\\\n';
s = sprintf(sform, [(-4:4)', pol_its, pol_evals]')