function [X, Indices_X] = calcQuadraturesFromEdgeIndices(X, EdgeIndices)
%% Description:
%   This function converts start and end edge indices into a vector of quadrature indices. Optionally, it uses the
%   calculated indices to select the corresponding values from an input quadrature dataset.
%
%   Overlapping edge-index ranges are merged implicitly. If a new range begins before or within the preceding range,
%   only indices that have not yet been included are added.
%
%% Syntax:
%   [X, Indices_X] = calcQuadraturesFromEdgeIndices(X, EdgeIndices)
%   [~, Indices_X] = calcQuadraturesFromEdgeIndices([], EdgeIndices)
%
%% Input:
% required input values:
%   X                                               - quadrature dataset from which the selected values are extracted;
%                                                     use [] to calculate only the index vector
%
%   EdgeIndices                                     - 2 x N array containing the start and end indices of
%                                                     N selected quadrature ranges; each column has the form
%                                                     [StartIndex; EndIndex]
%
%% Output:
%   X                                               - selected quadrature values corresponding to Indices_X; unchanged
%                                                     as [] if the input X is empty
%
%   Indices_X                                       - row vector containing all indices defined by EdgeIndices, with
%                                                     overlapping ranges merged
%
%% Notes:
%   EdgeIndices is transposed internally. Therefore, its expected input format is 2 x N, with one selected
%   range per column.
%
%   The function assumes that the edge-index ranges are ordered by ascending end index. Unsorted ranges can lead to
%   incomplete or unexpected index selections.
%
%   When a new range overlaps a preceding range, the new index range begins at LastQuad + 1 to prevent duplicate
%   indices.



    arguments
        X;
        EdgeIndices;
    end


    %% 1. Convert EdgeIndices into quadrature indices
    Indices_X = [];
    LastQuad = 0;
    EdgeIndices = EdgeIndices';
    for i = 1:size(EdgeIndices,1)
        NewIndices_X = max(LastQuad+1,EdgeIndices(i,1)):EdgeIndices(i,2);
        Indices_X = cat(2,Indices_X,NewIndices_X);
        LastQuad = EdgeIndices(i,2);
    end

    %% 2. Extract the associated quadrature subset 
    if ~isempty(X)
        X = X(Indices_X);
    end
end