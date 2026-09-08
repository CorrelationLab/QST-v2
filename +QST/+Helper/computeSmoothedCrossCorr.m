function [Y_Smoothed] = computeSmoothedCrossCorr(Xa,Xb,Options)
%% Description:
%   This function reads in two matrices of equal size and computes the cross correlation between both.
%   Afterwards it smoothes the cross correlation with a spline interpolation.
%
%% Syntax:
%   Y_Smoothed = computeSmoothedCrossCorr(Xa, Xb, Options.Acurracy_Spline)
%
%% Input:
% required input values
%   Xa                              - first matrix
%   Xb                              - second matrix
%
% optional input values
%   Options.Accuracy_Spline=1e-14   - spline interpolation accuracy. The value is between 0 and 1. The interpolation accuracy 
%                                     increases nonlinear with increasing value (see documentation of csaps())
%
%% Output:
% Y_Smoothed                        - smoothed cross correlations



    arguments(Input)
        Xa
        Xb
        Options.Accuracy_Spline {mustBeInRange(Options.Accuracy_Spline,0,1)} = 1e-14;
    end

    % calculate cross correlation between Xa and Xb
    XProd = Xa .* Xb;
    
    % smooth the cross correlation with a cubic spline 
    [nPulses,nPieces,nSegments] = size(XProd);
    y = reshape(XProd,[nPulses*nPieces nSegments]);
    x = [1:nPulses*nPieces];
    Y_Smoothed = transpose(csaps(x,y',Options.Accuracy_Spline,x));
end
