function [] = calcXGridAndPattern(MaxX,XStep,PhiStep, R, MaxQuad,Resolution, SavePathFileName)
% CALCXGRIDANDPATTERN calculates the PatternFunction for POmega defines on a (Q,P)-Grid and saves it
%
% INPUTS:
% MaxX :                Maximum for Amplitude X
% XStep :               StepSize of Amplitude X
% PhiStep :             StepSize of Phase Phi
% R :                   R Value of the wanted POmega Distribution
% MaxQuad :             maximal Quadraturevalue which will be included. The Limits are the same in both Q and P
% Resolution :          StepSize of the QuadratureGrid, defines the Resolution of the later constructed distribution
% SavePathFileName :    Path where the Pattern Function Matrices are saved.
%
% OUTPUTS:
% None
%
% SAVE TO FILE:
% MaxX
% XStep
% PhiStep
% R
% QuadVals :            Quadrature Values of the by MaxQuad and Resolution defined Binning
% Pattern :             2D cell array which stores the calculated TargetPattern Matrices (one matrix for each bin).
%                       The Position of the matrix in the cell array corresponds to the position of the belonging Bin
%                       e.g The Matrix in cell (5.1) corresponds to the Bin with Position (QuadVal(5),QuadVal(1)) 
% -> saveFilePath -> POmega_PatternInfo

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
            PatternResult = QST.POmega_Reconstruction.calcPattern(TargetGrid, R);
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
    % Save all data in one file (in comparison to carolins original solution using many files)
    save(SavePathFileName,'POmega_PatternInfo')   
end

