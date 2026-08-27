function [Nmean] = computeNmean(X,Options)
%% Description:
%   This function insert a set of quadratures and computes the associated average photon number. to this end the phase at which the quadratures has been recorded
%   has to be uniform over the data set 
%
%% Syntax:
%   [Nmean] = computeNmean(X, Dimension='all')
%
%% Input:
% required input values;
%   X                                               - array of quadratures. The array can be multidimensional
%
% optional input arguments:
%   Dimension=1                                     - axis of average computation in case of multidimensional arrays
%
%% Output:
%   Nmean                                           - average photon number or array of photon numbers



    arguments
        X
        Options.Dimension = 1
    end


    %% 1. calc mean Photonumber N along the given axis
    Nmean = mean(X.^2,Options.Dimension) - 0.5;
end

