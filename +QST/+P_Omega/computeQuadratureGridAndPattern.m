function [] = computeQuadratureGridAndPattern(MaxX,XStep,PhiStep, R, MaxQuad,Resolution, SavePathFileName)
%% Description:
%   This function calculates and saves the pattern-function matrices required for reconstructing the P_Omega
%   quasiprobability distribution.
%
%   The pattern function is evaluated for all combinations of an amplitude grid X and a phase grid Phi. For
%   every grid combination, a two-dimensional target grid in quadrature phase space is generated and the associated
%   P_Omega pattern function is calculated.
%
%   All generated grids, calculation parameters, and pattern-function matrices are stored in the structure
%   POmega_PatternInfo and saved to the specified MATLAB file.
%
%% Syntax:
%   computeQuadratureGridAndPattern(MaxX, XStep, PhiStep, R, MaxQuad, Resolution, SavePathFileName)
%
%% Input:
% required input values:
%   MaxX                                            - maximum absolute value of the amplitude grid X
%
%   XStep                                           - spacing between adjacent amplitude-grid values
%
%   PhiStep                                         - spacing between adjacent phase-grid values in radians
%
%   R                                               - filter parameter of the P_Omega pattern function
%
%   MaxQuad                                         - maximum absolute quadrature value of the Q- and P-axis
%                                                     grids
%
%   Resolution                                      - spacing between adjacent quadrature-grid values
%
%   SavePathFileName                                - path and filename of the MATLAB file in which
%                                                     POmega_PatternInfo is saved
%
%% Output:
%   This function does not return output arguments. It saves the structure POmega_PatternInfo to SavePathFileName.
%
%% Saved variable:
%   POmega_PatternInfo                              - structure containing the precalculated pattern information:
%
%       XStep                                       - amplitude-grid spacing
%       PhiStep                                     - phase-grid spacing
%       XGrid                                       - amplitude grid from -abs(MaxX) to abs(MaxX)
%       PhiGrid                                     - phase grid from 0 to 2pi
%       QuadVals                                    - quadrature grid from -abs(MaxQuad) to abs(MaxQuad)
%       Pattern                                     - cell array of structures containing TargetGrid and PatternResult
%                                                     for every combination of XGrid and PhiGrid
%



    arguments(Input)
        MaxX {mustBeNumeric}
        XStep {mustBeNumeric}
        PhiStep {mustBeNumeric}
        R {mustBeNumeric}
        MaxQuad {mustBeNumeric}
        Resolution {mustBeNumeric}
        SavePathFileName
    end


    % calculate the necessary Position for the PatternFunction and allocate
    % Space for the Patternfunction results
    XGrid = -abs(MaxX):XStep:abs(MaxX);
    PhiGrid = 0:PhiStep:2*pi;
    XGridSize = length(XGrid);
    PhiGridSize = length(PhiGrid);
    FunctionPattern = cell(XGridSize,PhiGridSize);
    

    QuadVals=-abs(MaxQuad):Resolution:abs(MaxQuad);
    [QAxis,PAxis]=meshgrid(QuadVals,QuadVals);
    PhaseMatrix = atan2(PAxis,QAxis) - pi/2; %-pi/2 for the correct axis 
    AmplMatrix = sqrt(QAxis.^2 + PAxis.^2);
    AlphaAmplMatrix = AmplMatrix/2; % relationship between X,P and alpha has factor 2

    for X_Position = 1:XGridSize
        for Phi_Position = 1:PhiGridSize
            X = XGrid(X_Position);
            Phi = PhiGrid(Phi_Position);
            TargetGrid = 2*R*(X - 2*AlphaAmplMatrix.*cos(Phi + PhaseMatrix));
            PatternResult = QST.P_Omega.computePOmegaPatternFunction(TargetGrid, R);
            FunctionPattern{X_Position,Phi_Position} = struct('TargetGrid',TargetGrid,'PatternResult',PatternResult);
        end
    end
    % Placing all relevant Information together in one struct (makes it easier to use in other Functions, since all params are needed)
    POmega_PatternInfo.XStep = XStep;
    POmega_PatternInfo.PhiStep = PhiStep;
    POmega_PatternInfo.XGrid = XGrid;
    POmega_PatternInfo.PhiGrid = PhiGrid;
    POmega_PatternInfo.QuadVals = QuadVals;
    POmega_PatternInfo.Pattern = FunctionPattern;
    % Save all data in one file
    save(SavePathFileName,'POmega_PatternInfo')   
end

