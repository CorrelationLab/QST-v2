function [Nmean] = calc_Nmean(X,Options)


% CALCMEANPHOTONUMBER Calculates the mean Photonumber in a given Set of
% Quadratures
%
% INPUTS:
% QuadratureData :  Set of Quadratures
%
% OUTPUTS:
% MeanPhotonNumber: Mean Photonnumber of the given QuadratureSet
    arguments
        X
        Options.Dimension = 'all'
    end

    %% 1. calc mean Photonumber N along the given axis
    Nmean = mean(X.^2,Options.Dimension) - 0.5;
end

