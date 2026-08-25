function [ Rho_Thermal ] = simulateRho_ThermalState( NThermal, MaxFockState )
%% Description:
%   This function reads in an average thermal photon number and simulates a thermal state
%
%% Syntax:
%   [Rho_Thermal] = simulateRho_ThermalState(NThermal, MaxFockState)
%
%% Input:
% required input values;
%   NCoherent                                       - average coherent photon number
%   MaxFockState                                    - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState

%
%% Output:
%   Rho_Thermal                                    - density matrix of the thermal state of size [MaxFockState+1 x MaxFockState+1]



    arguments(Input)
        NThermal;
        MaxFockState;
    end


    % Compute stationary state of a cavity in a thermal bath with NThermal photons
    Factor = NThermal/(1+NThermal);
    Rho_Thermal = zeros(MaxFockState + 1);
    Rho_Thermal(1,1) = (1-Factor)/(1-Factor^(MaxFockState+1));
    for i = 2:MaxFockState + 1
        Rho_Thermal(i,i) = Rho_Thermal(i-1,i-1)*Factor;
    end

end
