function [Time_Select,X_Select,X_Indices_Select] = selectQuads_ByStartTime(TimeStart,nQuadratures,Times,EdgeIndices,X)
    arguments
        TimeStart
        nQuadratures;
        Times;
        EdgeIndices;
        X = [];
    end

    
    [~,TimeInd_Select] = min(abs(Times-TimeStart));
    Time_Select = Times(TimeInd_Select);
    [~,X_Indices_Select] = QST.Data_Managment.Single.calcQuadraturesFromEdgeIndices([],EdgeIndices(:,TimeInd_Select));
    X_Indices_Select = X_Indices_Select(1);
    X_Indices_Select = [X_Indices_Select:1:X_Indices_Select+nQuadratures-1];

    if ~isempty(X)
        X = X(:);
        X_Select = X(X_Indices_Select);
    else
        X_Select = [];
    end

end