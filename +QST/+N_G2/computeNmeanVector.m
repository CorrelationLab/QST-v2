function [n] = computeNmeanVector(X)
%% Description:
%   This function estimates a photon-number value from a quadrature dataset and returns an array in which this value
%   is assigned to every quadrature entry.
%
%   The input quadrature data are reshaped such that pulse positions form rows and all measurement segments form
%   columns. After subtracting the global mean, the photon number is estimated from the quadrature variance according
%   to n = langle X^2 rangle - 1/2.
%
%   Negative photon-number estimates are set to zero. The resulting photon-number values are then reshaped to the
%   original dimensions of X.
%
%% Syntax:
%   n = photonNumberVector(X)
%
%% Input:
% required input values:
%   X                                               - quadrature dataset with dimensions
%                                                     [NumberOfPulses, NumberOfSegments, NumberOfPiezoSegments]
%
%% Output:
%   n                                               - photon-number array with the same dimensions as X; each pulse row
%                                                     contains the estimated photon number repeated over all segments
%
%% Notes:
%   The input data are reshaped internally to dimensions
%
%   [NumberOfPulses, NumberOfSegments x NumberOfPiezoSegments].
%
%   All negative estimated photon numbers are replaced by zero.

    
    
    arguments
        X;
    end


    [nPulses,nSegments,nPiezoSegments]=size(X);
    Xres = X(:);
    Xres = reshape(Xres,[nPulses nSegments*nPiezoSegments]); % Consecutive values in columns
    Xres = Xres - mean(mean(Xres));
    ada = mean(Xres.^2)-0.5;
    ada(ada<0) = 0; %set photon numbers < 0 to 0.
    
    n = zeros(size(Xres));
    for iRow = 1:nPulses
        n(iRow,1:end) = ada;
    end
    n = n(:);
    n = reshape(n,size(X));
end