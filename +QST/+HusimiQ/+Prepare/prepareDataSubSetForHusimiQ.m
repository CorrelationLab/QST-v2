function [X1,X2,Ind] = prepareDataSubSetForHusimiQ(Options)
%% Description:
%   This function loads or receives two quadrature datasets and prepares a common subset for calculating a Husimi
%   Q distribution. The first quadrature X1 corresponds to the q phase-space coordinate, and the second
%   quadrature X2 corresponds to the p phase-space coordinate.
%
%   The quadrature data can be supplied directly through the workspace or loaded from a MATLAB file. A common subset
%   can be selected using explicit quadrature indices or edge-index arrays. When selections are defined for both
%   channels, only the intersection of their index sets is used.
%
%   If no subset information is supplied, all values of X1 and X2 are returned. The output index vector Ind is then
%   set to [-1] to indicate that no selection was applied.
%
%% Syntax:
%   [X1, X2, Ind] = prepareDataSubSetForHusimiQ()
%   [X1, X2, Ind] = prepareDataSubSetForHusimiQ(Options)
%
%% Input:
% name-value input options:
%
% workspace quadrature-data options:
%   X1                                              - first quadrature dataset corresponding to the q coordinate
%                                                     (default: [])
%
%   X2                                              - second quadrature dataset corresponding to the p coordinate
%                                                     (default: [])
%
%   X1_Indices                                      - indices selecting a subset of X1 (default: [])
%
%   X2_Indices                                      - indices selecting a subset of X2 (default: [])
%
%   X1_EdgeIndices                                  - start and end indices defining selected ranges of X1
%                                                     (default: [])
%
%   X2_EdgeIndices                                  - start and end indices defining selected ranges of X2
%                                                     (default: [])
%
% file-input options:
%   FilePath                                        - path to a MATLAB file containing X1, X2, and optionally selection
%                                                     variables; if empty, workspace input is used (default: '')
%
%   X1String                                        - variable name or variable path of X1 in FilePath (default: '')
%
%   X2String                                        - variable name or variable path of X2 in FilePath (default: '')
%
%   X1_IndicesString                                - variable name or variable path of X1_Indices in FilePath
%                                                     (default: '')
%
%   X2_IndicesString                                - variable name or variable path of X2_Indices in FilePath
%                                                     (default: '')
%
%   X1_EdgeIndicesString                            - variable name or variable path of X1_EdgeIndices in FilePath
%                                                     (default: '')
%
%   X2_EdgeIndicesString                            - variable name or variable path of X2_EdgeIndices in FilePath
%                                                     (default: '')
%
%% Output:
%   X1                                              - selected first quadrature data as a column vector
%
%   X2                                              - selected second quadrature data as a column vector
%
%   Ind                                             - common index vector used to select X1 and X2; [-1] indicates that
%                                                     all quadrature values were returned without subset selection
%



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

