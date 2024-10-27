function [X,Indices_X] = selectQuads_ByEdgeIndices(X,EdgeIndices)
    Indices_X = [];
    LastQuad = 0;
    EdgeIndices = EdgeIndices';
    for j = 1:size(EdgeIndices,1)
        NewIndices_X = max(LastQuad+1,EdgeIndices(j,1)):EdgeIndices(j,2);
        Indices_X = cat(2,Indices_X,NewIndices_X);
        LastQuad = EdgeIndices(j,2);
    end
    if ~isempty(X)
        X = X(Indices_X);
    end
end