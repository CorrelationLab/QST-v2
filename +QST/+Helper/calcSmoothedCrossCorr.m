function [Y_Smoothed] = calcSmoothedCrossCorr(Xa,Xb,Options)
% SMOOTHCROSSCORR returns the crosscorrelation of two Matrices of same
% shape and smoothes it using either Spline Interpolation or MovingWindow
% Averaging
%
% INPUTS:
% Xa :                  First Matrix
% Xb :                  Second Matrix

% OPTIONS:
% Type :                    Type of Interpolation. It has to be either "Spline" for Spline Interpolation
%                           or "MovingAverage" for Moving Window Averaging. For
%                           later an algorithm of Carlos Adrián Vargas Aguilera
%                           has been used. The Accuracy of the smoothing is
%                           given by the to Accuracy Options
% Accuracy_Spline :         Accuracy of the Spline Interpolation. The Value has
%                           to be between 0 and 1, where the actual accuracy to the data increases
%                           nonlinear towards 1 (see csaps doc). Default Value
%                           is 1e-15
% Accuracy_MovingAverage:   Accuracy of the Moving Window Average Interpolation. It defines the Size of the used Window in datapoints.
%                           Default value is 20
%
% OUTPUTS:
% Y_Smoothed :              Smoothed Crosscorrelation of Xa and Xb

    arguments(Input)
        Xa
        Xb
        Options.Type {mustBeMember(Options.Type, ["Spline","MovingAverage"])} = "Spline"
        Options.Accuracy_Spline {mustBeInRange(Options.Accuracy_Spline,0,1)} = 1e-15;
        Options.Accuracy_MovingAverage {mustBeNonnegative} = 20;
    end

    % calculate Cross-Correlation between Xa and Xb
    XProd = Xa .* Xb;
    % Smooth the Cross Correlation by using either cubic Spline
    % interpolation or moving average
    [nPulses,nPieces,nSegments] = size(XProd);
    y = reshape(XProd,[nPulses*nPieces nSegments]);
    switch Options.Type
        case "Spline"
            x = [1:nPulses*nPieces];
            Y_Smoothed = transpose(csaps(x,y',Options.Accuracy_Spline,x));
        case "Moving"
            [Y_Smoothed,~] = QST.Helper_Data.moving_average(y,Options.Accuracy_MovingAverage,1); % Function is still the old one, one can remove unnecessary content from it
    end
end
