function [POmega,POmega_Sigma,POmega_QuadVals] = computePOmegaFromQuadratures(X_Target_Selected, Theta_Selected, POmega_PatternInfo)
%% Description:
%   This function reconstructs the P_Omega quasiprobability distribution from selected target-channel
%   quadrature values and their associated phase angles.
%
%   The reconstruction uses a precalculated pattern function stored in POmega_PatternInfo. The selected quadrature
%   and phase values are binned on the specified X- and Phi-grids. For each bin, the relative occurrence
%   probability is calculated and used to weight the corresponding pattern-function result.
%
%   In addition to the normalized P_Omega distribution, the function estimates its standard deviation and
%   returns the quadrature values associated with the reconstructed distribution.
%
%% Syntax:
%   [POmega, POmega_Sigma, POmega_QuadVals] = computePOmegaFromQuadratures( ...
%       X_Target_Selected, Theta_Selected, POmega_PatternInfo)
%
%% Input:
% required input values:
%   X_Target_Selected                               - selected quadrature values of the target channel
%
%   Theta_Selected                                  - phase values associated with X_Target_Selected
%
%   POmega_PatternInfo                              - structure containing the precalculated P_Omega pattern
%                                                     information, including XStep, PhiStep, XGrid, PhiGrid, Pattern,
%                                                     and QuadVals
%
%% Output:
%   POmega                                          - normalized reconstructed P_Omega quasiprobability
%                                                     distribution
%
%   POmega_Sigma                                    - estimated standard deviation of POmega
%
%   POmega_QuadVals                                 - quadrature-axis values associated with the reconstructed
%                                                     P_Omega distribution
%
%% Notes:
%   For every pair of X- and Phi-grid positions, the function determines the relative occurrence weight
%
%   w(X,Phi) = N(X,Phi) / N(Phi),
%
%   where N(X,Phi) is the number of selected values within the respective quadrature and phase bin, and
%   N(Phi) is the number of selected values within the respective phase bin.
%
%   The weighted pattern-function results are summed over all quadrature and phase bins. The resulting distribution
%   is multiplied by pi / N_Phi and normalized such that the sum of all POmega entries equals one.
%
%   The standard deviation is calculated from the weighted first and second pattern-function moments and the total
%   number of selected quadrature values.
%
%   The function expects every entry of POmega_PatternInfo.Pattern to contain a field named PatternResult.
%
%   If a phase bin contains no selected values, N(Phi) = 0 and the weight calculation produces NaN or Inf.
%   The supplied phase grid and selected data must therefore ensure populated phase bins.



    arguments
        X_Target_Selected;
        Theta_Selected;
        POmega_PatternInfo;
    end


    % to make Variablenames a bit shorter
    XStep = POmega_PatternInfo.XStep;
    PhiStep = POmega_PatternInfo.PhiStep;
    XGrid = POmega_PatternInfo.XGrid;
    PhiGrid = POmega_PatternInfo.PhiGrid;
    Pattern = POmega_PatternInfo.Pattern;

    Sum1 = 0;
    Sum2 = 0;
    for Phi_Position = 1:length(PhiGrid)
            for X_Position = 1:length(XGrid)
                X = XGrid(X_Position);
                Phi = PhiGrid(Phi_Position);
                BinX = [X-XStep/2, X+XStep/2];
                BinPhi = [Phi-PhiStep/2, Phi+PhiStep/2];
                N = length(X_Target_Selected(X_Target_Selected>min(BinX) & X_Target_Selected<max(BinX) & Theta_Selected > min(BinPhi) & Theta_Selected < max(BinPhi)));
                N2 = length(X_Target_Selected(Theta_Selected > min(BinPhi) & Theta_Selected < max(BinPhi)));
                Weight = N/N2;
                PatternResult = getfield(Pattern{X_Position,Phi_Position},'PatternResult');
                Sum1 = Sum1 + Weight * PatternResult;
                Sum2 = Sum2 + Weight * PatternResult.^2;
            end
    end
    % Calculate P_Omega and normalize it 
    POmega = Sum1 * pi / length(PhiGrid);
    POmegaSquare = Sum2 * pi^2 / length(PhiGrid);
    POmega = POmega ./ sum(POmega(:));
    
    % Calculate Sigma of P_Omega
    NTotal = length(X_Target_Selected);
    POmega_Sigma = sqrt((POmegaSquare - POmega.^2)/(NTotal-1));
    
    % Take QuadVals from the Struct (I know it seems unnecessary and it is)
    POmega_QuadVals = POmega_PatternInfo.QuadVals;
end

