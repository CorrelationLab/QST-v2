function [N_Cond, G2_Cond, Times_Cond,EdgeIndices_Cond,X_Cond,X_Indices_Cond] = postSelectQuadraturesForUnstableSignal_ByG2(MaxG2ForCond,G2,N,Times,EdgeIndices,X)
    arguments
        MaxG2ForCond
        G2
        N = []
        Times = [];
        EdgeIndices = [];
        X = [];
    end

    Indices_G2_Cond = find((G2 <= MaxG2ForCond) & (G2 >= 0));
    G2_Cond = G2(Indices_G2_Cond);

    if ~isempty(N)
        N_Cond = G2(Indices_G2_Cond);
    else
        N_Cond = [];
    end

    if ~isempty(Times)
        Times_Cond = Times(Indices_G2_Cond);
    else
        Times_Cond = [];
    end

    if ~isempty(EdgeIndices)
        EdgeIndices_Cond = EdgeIndices(:,Indices_G2_Cond);
    else
        EdgeIndices_Cond = [];
    end

    if ~isempty(X) && ~isempty(EdgeIndices_Cond)
        [X_Cond,X_Indices_Cond] = QST.Data_Managment.Single.calcQuadraturesFromEdgeIndices(X,EdgeIndices_Cond);
    else
        X_Cond = [];
    end

end

