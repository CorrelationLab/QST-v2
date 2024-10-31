function [X1,X2,Ind] = prepareDataSubSetForHusimiQ(Options)

% Function to collect and prepare a subset of quadratures for the calculation of the husimi Q distribution
% The connection is X1->q, X2->p. The Quadrature given should not be filtered beforehand. The selection of a specific
% subset is determined by either Indices or Edgeindices.

arguments
    % Input options for quadratures in the workspace 
    Options.X1 = [];
    Options.X2 = [];
    Options.X1_Indices = [];
    Options.X2_Indices = [];
    Options.X1_EdgeIndices = [];
    Options.X2_EdgeIndices = [];
    % Input options for the quadrature saved in one common file at filepath
    Options.FilePath = '';
    Options.X1String = '';
    Options.X2String = '';
    Options.X1_IndicesString = '';
    Options.X2_IndicesString = '';
    Options.X1_EdgeIndicesString = '';
    Options.X2_EdgeIndicesString = '';
end



%% 1. Load Data of the quadratures and the subset information
% Default case for the used Indices is that all indices are used. This is marked by Ind = [-1]. Otherwise it includes the quadrature indices which are used.
Ind = [-1];
% is the Data given by File or is it in the workspace

if isequal(Options.FilePath,'')
    %% 1.1 Data is in workspace 

    %% 1.1.1 Subset information is given by general Quadrature indices
    if ~isempty(Options.X1_Indices) && ~isempty(Options.X2_Indices)
        Ind = intersect(Options.X1_Indices,Options.X2_Indices);

    %% 1.1.2 Subset information is given by Edgeindices
    elseif ~isempty(Options.X1_EdgeIndices) && ~isempty(Options.X2_EdgeIndices)
        [~,Options.X1_Indices] = QST.Helper.calcQuadraturesFromEdgeIndices([],Options.X1_EdgeIndices);
        [~,Options.X2_Indices] = QST.Helper.calcQuadraturesFromEdgeIndices([],Options.X2_EdgeIndices);
        Ind = intersect(Options.X1_Indices,Options.X2_Indices);
    end


    
else
    %% 1.2 Data is given by filepath
    % Load quadrature data
    Options.X1 = QST.Variable_Managment.getVariableFromFilePath(Options.FilePath,Options.X1String);
    Options.X2 = QST.Variable_Managment.getVariableFromFilePath(Options.FilePath,Options.X2String);

    %% 1.2.1 Subset information is given by general Quadrature indices
    if ~isequal(Options.X1_IndicesString,'') && ~isequal(Options.X2_IndicesString,'')
        Options.X1_Indices = QST.Variable_Managment.getVariableFromFilePath(Options.FilePath,Options.X1_IndicesString);
        Options.X2_Indices = QST.Variable_Managment.getVariableFromFilePath(Options.FilePath,Options.X2_IndicesString);    
        Ind = intersect(Options.X1_Indices,Options.X2_Indices);

    %% 1.2.2 Subset information is given by Edgeindices   
    elseif ~isequal(Options.X1_EdgeIndicesString,'') && ~isequal(Options.X2_EdgeIndicesString,'')
        Options.X1_EdgeIndices = QST.Variable_Managment.getVariableFromFilePath(Options.FilePath,Options.X1_EdgeIndicesString);
        Options.X2_EdgeIndices = QST.Variable_Managment.getVariableFromFilePath(Options.FilePath,Options.X2_EdgeIndicesString);
        [~,Options.X1_Indices] = QST.Helper.calcQuadraturesFromEdgeIndices([],Options.X1_EdgeIndices);
        [~,Options.X2_Indices] = QST.Helper.calcQuadraturesFromEdgeIndices([],Options.X2_EdgeIndices);        
        Ind = intersect(Options.X1_Indices,Options.X2_Indices);
    end
end


%% 2. Apply the indices on the set of data
X1 = Options.X1(:);
X2 = Options.X2(:);
if Ind(1) ~= -1
        X1 = X1(Ind);
        X2 = X2(Ind);
end


end

