function [QuantumCoherence] = computeQuantumCoherenceDTS(NCoherent,NThermal)
%% Description:
%   This function reads in a coherent and a thermal photon number and computes the optimal quantum coherence neglecting dephasing effects
%
%% Syntax:
%   [QuantumCoherence] = computeQuantumCoherenceDTS(NCoherent, NThermal)
%
%% Input:
% required input values;
%   NCoherent                                       - coherent photon number of the state
%   NThermal                                        - thermal photon number of the state
%
%% Output:
%   QuantumCoherence                                - to be expected optimal quantum coherence of the state based on the DTS model in absence of dephasing
   


    arguments(Input)
        NCoherent;
        NThermal;
    end

    
    % Compute the quantum coherence
    Factor = 2*NThermal + 1;
    QuantumCoherence = (1 - exp(-2*NCoherent./Factor) .* besseli(0,2*NCoherent./Factor ) )./Factor;
end

