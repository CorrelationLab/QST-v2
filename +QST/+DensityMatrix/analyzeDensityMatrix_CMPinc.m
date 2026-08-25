function [QuantumCoherence,Mixedness,Purity_Inc] = analyzeDensityMatrix_CMPinc(Rho)
%% Description:
%   This function reads in a density matrix in fock representation and computes its quantum coherence, its mixedness and the purity
%   of the closest incoherent state P_Inc. The quantum coherence is computed using the l2 norm. The three quantities sum up to 1.
%
%% Syntax:
%   [QuantumCoherence,Mixedness,Purity_Inc] = analyzeDensityMatrix_CMPinc(Rho)
%
%% Input:
% required input values;
%   Rho                                             - complex valued density matrix in fock representation

%
%% Output:
%   QuantumCoherence                                - quantum coherence of the asociated density matrix
%   Mixedness                                       - mixedness of the asociated density matrix
%   Purity_Inc                                      - purity of the density matrix closest incoherent counterpart



    arguments(Input)
        Rho
    end


    % Compute the purity of the state
    Purity = real(trace(Rho^2));
    
    % Compute the purity of the state's closest incoherent counterpart
    Rho_Inc = diag(diag(Rho));
    Purity_Inc = real(trace(Rho_Inc^2));
    
    % Compute mixedness and quantum coherence
    Mixedness = 1-Purity;
    QuantumCoherence = Purity-Purity_Inc;
end

