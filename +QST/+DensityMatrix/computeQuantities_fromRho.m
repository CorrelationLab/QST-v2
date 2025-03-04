function [C,Mixedness,Purity_Inc] = computeQuantities_fromRho(Rho)
Rho_Inc = diag(diag(Rho));
B = real(trace(Rho^2));
Purity_Inc = real(trace(Rho_Inc^2));
Mixedness = 1-B;
C = B-Purity_Inc;
end

