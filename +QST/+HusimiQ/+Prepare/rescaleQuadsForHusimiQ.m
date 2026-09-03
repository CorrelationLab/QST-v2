function [X1_Rescaled, X2_Rescaled] = rescaleQuadsForHusimiQ(X1, X2, Options)
%% Description:
%   This function rescales two quadrature datasets for the generation of a Husimi Q distribution.
%
%   First, both quadrature datasets are multiplied by sqrt{2} to refer the quadrature amplitudes to the point
%   before a 50:50 splitting beam splitter.
%
%   Optionally, the two channels are subsequently scaled to equalize their mean photon numbers. The scaling factors
%   are calculated such that both output channels have the arithmetic mean of their original mean photon numbers.
%
%% Syntax:
%   [X1_Rescaled, X2_Rescaled] = rescaleQuadsForHusimiQ(X1, X2)
%   [X1_Rescaled, X2_Rescaled] = rescaleQuadsForHusimiQ(X1, X2, ScaleChannels=true)
%
%% Input:
% required input values:
%   X1                                              - first quadrature dataset
%
%   X2                                              - second quadrature dataset
%
% optional input options:
%   ScaleChannels                                   - logical value specifying whether X1 and X2 are additionally
%                                                     rescaled to equalize their mean photon numbers
%                                                     (default: true)
%
%% Output:
%   X1_Rescaled                                     - rescaled first quadrature dataset as a column vector

%   X2_Rescaled                                     - rescaled second quadrature dataset as a column vector
%



    arguments
        X1;
        X2;
        Options.ScaleChannels=true;
    end
    

    %% 1. rescale Data to the Point before the splitting Beamsplitter
    X1_Rescaled = X1(:)*sqrt(2);
    X2_Rescaled = X2(:)*sqrt(2);
     
    %% 2. Rescale the Data according to the found channel dependent photonumbers (maybe critical?)
    if Options.ScaleChannels
        nMean_X1 = QST.N_G2.computeNmean(X1_Rescaled);
        nMean_X2 = QST.N_G2.computeNmean(X2_Rescaled);
        X1_Rescaled = X1_Rescaled*sqrt(mean([nMean_X1, nMean_X2])/nMean_X1);
        X2_Rescaled = X2_Rescaled*sqrt(mean([nMean_X1, nMean_X2])/nMean_X2);
    end
end