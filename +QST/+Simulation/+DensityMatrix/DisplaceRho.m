function [Rho_Displaced] = displaceRho(Rho,Alpha)
%% Description:
%   This function reads in a density matrix in fock representation and a displacement and computes the density matrix of the displaced state
%
%% Syntax:
%   [Rho_Displaced] = displaceRho(Rho, Alpha)
%
%% Input:
% required input values;
%   Rho                                             - density matrix of the initial state
%   Alpha                                           - complex valued displacement with |Alpha|^2 = NCoherent

%
%% Output:
%   Rho                                             - density matrix of the displaced state [MaxFockState+1 x MaxFockState+1]



    arguments(Input)
        Rho;
        Alpha;
    end

    
    % Create displacement operator Disp from the annihilation and creation operators A and Adag 
    nArray = sqrt([1:size(Rho,1)-1]);
    A = diag(nArray,1);
    Adag = A';
    Disp = expm(Alpha*Adag-conj(Alpha)*A);
    
    % Perform the displacement operation
    Rho_Displaced = Disp*Rho*(Disp');
end

