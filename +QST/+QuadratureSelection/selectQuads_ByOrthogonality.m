function [X_PsFast_Orth, X_PsSlow_Orth, X_Target_Orth, Theta_Orth, Indices_Orth] = selectQuads_ByOrthogonality(X_PsFast, X_PsSlow, PiezoSign, Options)
% SELECTORTHOGONAL calculates the orthogonal Subset between to channels (In case of 2-Channel measurements these two, in case of 3-Channel Measrements
% the two Postselection channels). The Result can then be expanded to the data a possible Targetchannel or a Phase
%
% X_PsFast :                            First Channel, which has the faster Piezomodulation.
% X_PsSlow :                            Second Channel, which has the slower Piezomodulation.
% PiezoSign :                           Sign of Piezomovement of first Segment (1: positive, way gets longer, -1: negative, way gets shorter)
%
%
% OPTIONS:
% X_Target :                            In case of 3-Channel Measurements a third Targetchannel can be added, on which the postseletion is process is
%                                       then also applied. Default is NaN
% Theta :                               In case of 3-Channel Measurements the Phase between PsFast and Target Theta can be added, on which the postseletion is process is
%                                       then also applied. Default is NaN
% OrthWidth :                           Relative Width of the Window around zero, which is used in the process to postselect the
%                                       orthogonal subset. The width is relative to the Segments maximum. The width includes the
%                                       values to both direction eg. 5% means from -2.5% to 2.5%
% Shift :                               Shiftconstant which is used to differ between phases of pi/2 and 3/2pi. Is by Default 10000 
%                                       Points and most probably can be left like that.
% Smoothing_Type :                      Type of Crosscorrelationsmoothing used in
%                                       the Postselecting Orthogonal Process. Default is 'Spline'.
% Smoothing_Accuracy_Spline :           Accuracy of the Spline Interpolation Method for the
%                                       CrossCorrelation Smoothing used in the Postselecting Orthogonal Process. Default is 1e-15.
% Smoothing_Accuracy_MovingAverage :    Accuracy of the Moving Window Average Method for the
%                                                CrossCorrelation Smoothing used in the Postselecting Orthogonal Process. Default is 20.
%
%
% OUTPUTS:
% X_PsFast_Orth :                       Orthogonal Subset from first Channel
% X_PsSlow_Orth :                       Orthogonal Subset from second Channel
% X_Target_Orth :                       Orthogonal Subset from Target Channel. Default is NaN.
% Theta_Orth :                          Orthogonal Subset from Theta. Default is NaN.
% Indices_Orth :                        Indices of the Orthogonal Subset

    arguments(Input)
        X_PsFast
        X_PsSlow
        PiezoSign {mustBeMember(PiezoSign,[-1, 1])};
        Options.X_Target = NaN;
        Options.Theta = NaN;
        Options.OrthWidth = 0.05;
        Options.Shift {mustBeInteger, mustBeNonnegative} = 10000;
        Options.Smoothing_Type {mustBeMember(Options.Smoothing_Type, ["Spline","MovingAverage"])} = "Spline";
        Options.Smoothing_Accuracy_Spline {mustBeInRange(Options.Smoothing_Accuracy_Spline,0,1)} = 1e-15;
        Options.Smoothing_Accuracy_MovingAverage {mustBeNonnegative} = 20;
    end
    % Calculate smoothed CrossCorrelation between the X_PsFast and X_Target
    Y_Smoothed = QST.Helper.computeSmoothedCrossCorr(X_PsFast,X_PsSlow, Accuracy_Spline=Options.Smoothing_Accuracy_Spline);
    % Calculate Parameter for the postselection of the orthogonal subset
    GlobalMax = max(Y_Smoothed(:));
    GlobalMin = min(Y_Smoothed(:));
    HalfWidth = Options.OrthWidth * (GlobalMax-GlobalMin) / 2;
    % Find Indices which smoothed CrossCorrelation is inside the by HalfWidth definded region
    Indices_Orth = find(Y_Smoothed<HalfWidth & Y_Smoothed>-HalfWidth);
    % Apply found Indices on the Data
    X_PsFast_Orth = X_PsFast(Indices_Orth);
    X_PsSlow_Orth = X_PsSlow(Indices_Orth);
    if ~isnan(Options.X_Target)
        X_Target_Orth = Options.X_Target(Indices_Orth);
    else
        X_Target_Orth = NaN;
    end
    if ~all(isnan(Options.Theta(1,:)))
        Theta_Orth = Options.Theta(Indices_Orth);
    else
        Theta_Orth = NaN;
    end
    % Check for Data in X_PsSlow which Flanks are negative
    Y_Smoothed_Shifted = circshift(Y_Smoothed,Options.Shift,1);
    Indices_NegativeFlank = find((Indices_Orth>Options.Shift) & ((Y_Smoothed(Indices_Orth)-Y_Smoothed_Shifted(Indices_Orth))<0));
    Y_Smoothed_Shifted = circshift(Y_Smoothed,-Options.Shift,1);
    Indices_NegativeFlank = [Indices_NegativeFlank; find((Indices_Orth<=Options.Shift) & ((Y_Smoothed(Indices_Orth)-Y_Smoothed_Shifted(Indices_Orth))>0))];
    X_PsSlow_Orth(Indices_NegativeFlank) = -X_PsSlow_Orth(Indices_NegativeFlank);
    X_PsSlow_Orth = PiezoSign * X_PsSlow_Orth;
end

