function [Y_Smoothed] = calcSmoothedCrossCorr(Xa,Xb,Options)
% SMOOTHCROSSCORR returns the crosscorrelation of two Matrices of same
% shape and smoothes it using either Spline Interpolation or MovingWindow
% Averaging
%
% INPUTS:
% Xa :                  First Matrix
% Xb :                  Second Matrix

% OPTIONS:
% Accuracy_Spline :         Accuracy of the Spline Interpolation. The Value has
%                           to be between 0 and 1, where the actual accuracy to the data increases
%                           nonlinear towards 1 (see csaps doc). Default Value
%                           is 1e-15
%
% OUTPUTS:
% Y_Smoothed :              Smoothed Crosscorrelation of Xa and Xb

    arguments(Input)
        Xa
        Xb
        Options.Accuracy_Spline {mustBeInRange(Options.Accuracy_Spline,0,1)} = 1e-15;
    end

    % calculate Cross-Correlation between Xa and Xb
    XProd = Xa .* Xb;
    % Smooth the Cross Correlation by using either cubic Spline
    % interpolation or moving average
    [nPulses,nPieces,nSegments] = size(XProd);
    y = reshape(XProd,[nPulses*nPieces nSegments]);
    x = [1:nPulses*nPieces];
    Y_Smoothed = transpose(csaps(x,y',Options.Accuracy_Spline,x));
end
