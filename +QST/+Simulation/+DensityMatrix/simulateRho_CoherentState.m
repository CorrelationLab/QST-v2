function [ Rho_Coherent ] = simulateRho_CoherentState(NCoherent, MaxFockState, Options)
%% Description:
%   This function reads in an average coherent photon number and simulates a coherent state.
%
%% Syntax:
%   [Rho_Coherent] = simulateRho_CoherentState(NCoherent, MaxFockState, Theta=0)
%
%% Input:
% required input values;
%   NCoherent                                       - average coherent photon number
%   MaxFockState                                    - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState

%
%% Output:
%   Rho_Coherent                                    - density matrix of the coherent state of size [MaxFockState+1 x MaxFockState+1]



    arguments(Input)
        NCoherent;
        MaxFockState;
        Options.Theta = 0;
    end

    
    % Create the vacuum state
    Rho_Vacuum = zeros([MaxFockState+1,MaxFockState+1]);
    Rho_Vacuum(1,1) = 1;

    % Displace the vacuum state
    Alpha = sqrt(NCoherent)*exp(1i*Options.Theta);
    Rho_Coherent = QST.Simulation.DensityMatrix.displaceRho(Rho_Vacuum,Alpha);
end
