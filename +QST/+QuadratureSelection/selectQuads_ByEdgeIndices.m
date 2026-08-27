function [X_Select,XIndices_Select] = selectQuads_ByEdgeIndices(X, EdgeIndices)
%% Description:
%   This function takes a set of quadratures X and a set of EdgeIndices and returns the with the EdgeIndices associated set of quadratures
%   as well of the regular quadrature indices. X can be empty if only the indices are of interest.
%
%% Syntax:
%   [X_Select, XIndices_Select] = selectQuads_ByEdgeIndices(X, EdgeIndices)
%
%% Input:
% required input values;
%   X                                               - set of quadratures
%   EdgeIndices                                     - two-dimensional array which marks the segments in the quadrature array used to compute N and g2.
%                                                     The first row contains the indices of the first quadratures of the individual segment,
%                                                     the second row contains the indices of the respective final quadratures
%
%% Output:
%   X_Select                                        - 1D array of the postselected quadratures. It returns [] when X is [].
%   XIndices_Select                                 - 1D array of the postselected quadrature indices  

    arguments
        X;
        EdgeIndices;
    end


    XIndices_Select = [];
    LastQuad = 0;
    EdgeIndices = EdgeIndices';

    %% 1. Compute the selected XIndices from the EdgeIndices
    for j = 1:size(EdgeIndices,1)
        NewXIndices_Select = max(LastQuad+1,EdgeIndices(j,1)):EdgeIndices(j,2);
        XIndices_Select = cat(2,XIndices_Select,NewXIndices_Select);
        LastQuad = EdgeIndices(j,2);
    end

    %% 2. Return the asscoiated quadrature subset 
    if ~isempty(X)
        X_Select = X(XIndices_Select);
    end
end