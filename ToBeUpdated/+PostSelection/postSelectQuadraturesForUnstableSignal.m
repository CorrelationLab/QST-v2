function [N_Cond, G2_Cond, Times_Cond,EdgeIndices_Cond,X_Cond,X_Indices_Cond] = postSelectQuadraturesForUnstableSignal(MinNForCond,N,G2,Times,EdgeIndices,X)
    arguments
        MinNForCond
        N
        G2 = [];
        Times = [];
        EdgeIndices = [];
        X = [];
    end

    Indices_N_Cond = find(N >= MinNForCond);
    N_Cond = N(Indices_N_Cond);

    if ~isempty(G2)
        G2_Cond = G2(Indices_N_Cond);
    else
        G2_Cond = [];
    end

    if ~isempty(Times)
        Times_Cond = Times(Indices_N_Cond);
    else
        Times_Cond = [];
    end

    if ~isempty(EdgeIndices)
        EdgeIndices_Cond = EdgeIndices(:,Indices_N_Cond);
    else
        EdgeIndices_Cond = [];
    end

    if ~isempty(X) && ~isempty(EdgeIndices_Cond)
        [X_Cond,X_Indices_Cond] = QST.Data_Managment.Single.calcQuadraturesFromEdgeIndices(X,EdgeIndices_Cond);
    else
        X_Cond = [];
    end

end

