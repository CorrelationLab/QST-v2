function [Rho] = DisplaceRho(Rho,alpha)
% used to displace a State
nArray = sqrt([1:size(Rho,1)-1]);
A = diag(nArray,1);
Adag = A';
D = expm(alpha*Adag-conj(alpha)*A);

Rho = (D')*Rho*D;

end

