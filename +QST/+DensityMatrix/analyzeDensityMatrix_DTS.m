function [NThermal, NCoherent, NTotal, G2] = analyzeDensityMatrix_DTS(Rho)
%% Description:
%   This function reads in a density matrix in fock representation and computes the photo number and g2.
%   On this base it further computes the coherent and thermal photon number based on the displaced thermal state model.
%
%% Syntax:
%   [NThermal, NCoherent, NTotal, G2] = analyzeDensityMatrix_DTScomponents(Rho)
%
%% Input:
% required input values;
%   Rho                                             - complex valued density matrix in fock representation

%
%% Output:
%   NThermal                                        - thermal photon number
%   NCoherent                                       - coherent photon number
%   NTotal                                          - total photon number computed from <adag*adag*a*a> 
%   G2                                              - second order correlation function for tau=0



    arguments(Input)
        Rho
    end


    % create the matrices of the representations of the annihilation and creation operator  A and Adag 
    nArray = sqrt([1:size(Rho,1)-1]);
    A = diag(nArray,1);
    Adag = A';
    
    % compute NTotal and G2
    NTotal = real(trace(Rho*Adag*A));
    G2 = real(trace(Rho*Adag*Adag*A*A)/(NTotal^2));
    
    % compute NThermal and NCoherent
    NCoherent = sqrt(2-G2)*NTotal;
    NThermal = NTotal-NCoherent;
end

