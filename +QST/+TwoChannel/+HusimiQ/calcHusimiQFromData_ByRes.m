function [HusimiQ,Bins_PsFast,Bins_PsSlow] = calcHusimiQFromData_ByRes(X_PsFast_Orth,X_PsSlow_Orth,Options)
% CALCHUSIMI calculates the HusimiQ Distribution from a Set of two
% Quadratures which are suificcient orthogonal to each other using a fixed
% Resolution for the Quadratures Q and P, independent of the range of the
% found data.The outer Ranges of the Distribution (maxQ, maxP) are still
% defined by the found data. X_PsFast is used for first Axis (Q) and X_PsSlow is used for second Axis (P). 
%
% INPUTS:
% X_PsFast_Orth :       Orthogonal Quadratures from the first measured Channel. In
%                       case of three-Channel Measurements this is the
%                       Postselection channel with the faster piezo modulation
% X_PsSlow :            Othogonal Quadratures from the second measured
%                       Channel. In case of three-Channel Measurements this is the
%                       Postselection channel with the slower piezo modulation
% OPTIONS:
% Resolution_Q :        Resolution of the calculated HusimiQ Distribution
%                       along the first Quadrature Axis (here called Q). Default Value is 0.25
% Resolution_P :        Resolution of the calculated HusimiQ Distribution
%                       along the second Quadrature Axis (here called P). Default Value is 0.25
%Probabilitytype :      Defines if the HusimiQ Distribution should either
%                       describe a probability ('Prob') a Probabilty Density ('ProbDensity').
%
%OUTPUTS:
% HusimiQ :             Matrix of the calculated Husimi Q Distribution
% Bins_PsFast:          Array of the used BinningPositions along the first
%                       axis (Q)
% Bins_PsSlow:          Array of the used BinningPositions along the second
%                       axis (P)

    arguments(Input)
        X_PsFast_Orth
        X_PsSlow_Orth
        Options.Resolution_Q {mustBeGreaterThan(Options.Resolution_Q,0)}= 0.25
        Options.Resolution_P {mustBeGreaterThan(Options.Resolution_P,0)} = 0.25
        Options.ProbabilityType {mustBeMember(Options.ProbabilityType,['Prob','ProbDensity'])} = 'Prob'
    end
    %% 1. Reconstructing the Husimi Q Function
    [HusimiQ,Bins_PsFast,Bins_PsSlow] = QST.HusimiQ_Reconstruction.histogram2D_ByRes(X_PsFast_Orth, X_PsSlow_Orth, Options.Resolution_Q, Options.Resolution_P);
    if isequal(Options.ProbabilityType,'Prob')
        HusimiQ = HusimiQ./sum(sum(HusimiQ)); % Probability
    else
        HusimiQ = HusimiQ./(sum(sum(HusimiQ))*(Options.Resolution_Q*Options.Resolution_P)); % Probability Density
    end
end

