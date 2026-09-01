function [Datacleaned] = removeDetectorResponse(Data,nMean_Min,Delta)
%% Description:
%   This function removes correlated detector-response contributions from a one-dimensional quadrature dataset.
%
%   The data are divided into segments, and each segment is cleaned using a modified Gram-Schmidt orthogonalization.
%   For this purpose, the preceding Delta quadrature values are used as reference vectors. The initial Delta cleaned
%   values are discarded because they serve only as reference data for the orthogonalization.
%
%   The segment size is selected such that at least nMean_Min values are used to estimate the orthogonalization for
%   each segment. If the input data contain fewer values than nMean_Min, all available data are used in one segment.
%
%% Syntax:
%   Datacleaned = removeDetectorResponse(Data)
%   Datacleaned = removeDetectorResponse(Data, nMean_Min)
%   Datacleaned = removeDetectorResponse(Data, nMean_Min, Delta)
%
%% Input:
% required input values:
%   Data                                            - correlated quadrature data of one detector channel
%
% optional input values:
%   nMean_Min                                       - minimum number of data values used per segment for the
%                                                     orthogonalization procedure (default: 1000000)
%   Delta                                           - number of preceding quadrature values used as reference vectors
%                                                     for detector-response removal (default: 50)
%
%% Output:
%   Datacleaned                                     - cleaned one-dimensional quadrature data; its length is
%                                                     length(Data) - Delta
%
%% Notes:
%   The input Data is converted into a column vector before processing.
%
%   More detailed information about the used data relocation are explained in "Characterization of Classical Light Fields
%   For Quantum applications via Optical Homodyne Tomography" p.46-47




    arguments
        Data;
        nMean_Min = 1000000;
        Delta = 50;
    end
    
    
    Data = Data(:);
    nData = length(Data);
    
    %% 1. Reshape the data and create the matrix M which includes the indices to prepare the data for the modified gram schmidt algorithm
    if nData < nMean_Min
      warning('Data is shorter than allowed minimal nMean. All data is used');
      nSeg = 1;
      nMean = nData-Delta;
    else % Data is longer than minimal nMean (this should be the normal case)
        nSeg = floor((nData-Delta)/nMean_Min);
        nMean = floor((nData-Delta)/nSeg);
    end
    
    % create matrix for the modified gram schmidt 
    M = zeros([Delta+nSeg,nMean]);
    % get first matrix of the indices
    for i = 1:nMean
        M(:,i) = (1:Delta+nSeg) + (i-1)*nSeg;
    end

    %% execute the modified Gram-Schmidt algorithm
    % fill the matrix according to the indices
    M = Data(M);
    % execute modified gram schmidt
    Mcleaned = QST.QuadratureCalculation.computeModifiedGramSchmidt(M.');
    Mcleaned = Mcleaned.';
    % place the cleaned data in Datacleaned
    Datacleaned = Mcleaned(Delta+1:end,:);
    Datacleaned = Datacleaned(:);
end