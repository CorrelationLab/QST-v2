function [nT,nC] = DTSComponentsFromRho(Rho)
% calculates nTherm and nCoherent from the model of the displaced thermal state (DTS) from a given densitymatrix
%it uses therfore the formulas of nMean, and g2

%nTot: mean total amount of photons
% nt: mean total amount of thermal photons
%nc: mean total amount of coherent photons

%g2(DTS) = 2-(nC/nTot)^2
%nTot = nMean = nC + nT
nArray = sqrt([1:size(Rho,1)-1]);
A = diag(nArray,1);
Adag = A';

nTot = trace(Rho*Adag*A);

g2 = trace(Rho*Adag*Adag*A*A)/(nTot^2); 

nC = sqrt(2-g2)*nTot;
nT = nTot-nC;
end

