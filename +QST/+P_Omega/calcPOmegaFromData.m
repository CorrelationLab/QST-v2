function [POmega,POmega_Sigma,POmega_QuadVals] = calcPOmegaFromData(X_Target_Selected, Theta_Selected, POmega_PatternInfo)
% CALCPOMEGAFROMDATA reconstructs the POmega Distribution from a postselected Region in targetChannel of a 3 Channel measurement
%
% INPUTS:
% X_Target_Selected :       Selected Dataset from TargetChannel
% Theta_Selected :          Selected Dataset from Theta
% POmega_PatternInfo :      Variable which includes the Precalculated Pattern Function Matrices. They can be created using 'calcXGridAndPattern'.
%
% OUTPUTS:
% POmega :                  Matrix of the calculated POmega Function
% POmega_Sigma :            Standard Deviation of the calculated POmega Function
% POmega_Quadvals :         Values of the used Quadrature Binning

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

