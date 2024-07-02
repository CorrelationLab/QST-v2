function [Times_Select,N_Select,G2_Select,EdgeIndices_Select,Indices_X_Select,X_Select,TimeStart,TimeEnd,TimeStartInd,TimeEndInd] = selectQuads_ByTimeInterval(TimeStart,TimeEnd,Times,N,G2,EdgeIndices,X)
    arguments
        TimeStart;
        TimeEnd;
        Times
        N = [];
        G2 = [];
        EdgeIndices = [];
        X = [];
    end

    [~,TimeStartInd] = min(abs(Times-TimeStart));
    [~,TimeEndInd] = min(abs(Times-TimeEnd));
    TimeStart = Times(TimeStartInd);
    TimeEnd = Times(TimeEndInd);

    Times_Select = Times(TimeStartInd:TimeEndInd);

    if ~isempty(N)
        N_Select = N(TimeStartInd:TimeEndInd);
    else
        N_Select = [];
    end

    if ~isempty(G2)
        G2_Select = G2(TimeStartInd:TimeEndInd);
    else
        G2_Select = [];
    end

    if ~isempty(EdgeIndices)
        EdgeIndices_Select = EdgeIndices(:,TimeStartInd:TimeEndInd);
        if ~isempty(X)
            [X_Select,Indices_X_Select] = QST2.DataManagment.Single.Quadratures.selectQuads_ByEdgeIndices(X,EdgeIndices_Select);
        else
            [~,Indices_X_Select] = QST2.DataManagment.Single.Quadratures.selectQuads_ByEdgeIndices([],EdgeIndices_Select);
            X_Select = [];
        end
    else
        EdgeIndices_Select = [];
        X_Select = [];
    end
end

