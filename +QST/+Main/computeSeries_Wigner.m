function [] = computeSeries_Wigner(Dir_Data,Dir_WignerTable,DensityMatrixIndex)
%% Description:
%   This function computes Wigner functions for selected density matrices in a series of measurement files found
%   recursively in Dir_Data.
%
%   For every .mat file, the function loads the density matrix specified by DensityMatrixIndex 
%   and calculates its Wigner function using the Wigner-pattern table in Dir_WignerTable.
%
%   The calculated Wigner function is fitted using a displaced thermal state model to obtain the thermal and coherent
%   photon numbers. The corresponding quantum coherence and phase-space grid information are also calculated and
%   stored.
%
%   The results are appended to the variable WignerFunctions in each processed measurement file. If WignerFunctions
%   already exists, a new entry is appended to the existing structure array.
%
%% Syntax:
%   computeSeries_Wigner(Dir_Data, Dir_WignerTable)
%   computeSeries_Wigner(Dir_Data, Dir_WignerTable, DensityMatrixIndex)
%
%% Input:
% required input values:
%   Dir_Data                                        - root directory recursively searched for MATLAB .mat files
%                                                     containing density matrices
%
%   Dir_WignerTable                                 - directory containing the Wigner-pattern table and the file
%                                                     WignerPattern_GridInfo.mat
%
% optional input values:
%   DensityMatrixIndex                              - index of the density matrix selected from the DensityMatrices
%                                                     structure array (default: 1)
%
%% Output:
%   This function does not return output arguments.
%
%   For every processed .mat file, the function appends an entry to the WignerFunctions structure array containing:
%
%       Wigner                                      - calculated Wigner function
%       nTherm                                      - thermal photon number obtained from the DTS fit
%       nCoherent                                   - coherent photon number obtained from the DTS fit
%       QuantumCoherence                            - quantum coherence calculated from nCoherent and nTherm
%       minQ                                        - minimum quadrature value of the Wigner-function grid
%       stepsizeQ                                   - quadrature-grid step size
%       maxQ                                        - maximum quadrature value of the Wigner-function grid
%
%% Notes:
% The size of the created wigner functions depend on the used WignerTable. The used discretized phase space has equal size in q and p



    arguments
        Dir_Data;
        Dir_WignerTable;
        DensityMatrixIndex = 1;
    end
    
    
    % get information about the used Wigner Table
    GridInfo = QST.Variable_Managment.getVariableFromFilePath(strcat(Dir_WignerTable,filesep,"WignerPattern_GridInfo.mat"),["GridInfo"]);
    Q_Def = [GridInfo.minQ,GridInfo.stepQ,GridInfo.maxQ];
    
    % set Rho_String
    Rho_String = strcat("DensityMatrices(",string(DensityMatrixIndex),").Rho");

    % calculates the density matrix for agiven dataset
    Paths = QST.File_Managment.getFilePaths(Dir_Data);
    [~,~,Ext] = fileparts(Paths);
    Paths = Paths(strcmp(Ext,".mat"));% take only the mat files
    for j = 1:length(Paths)
        % load Data
        Rho = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[Rho_String]);
        % cut the densitymatrix to a useable size
        Rho = Rho(1:76,1:76);
    
        % compute the wigner function
        WF = QST.Wigner.computeWignerFromDensityMatrix(Rho,Dir_WignerTable);
        % compute the wigner function
        [nThermal, nCoherent] = QST.Wigner.fitDTSToWigner(WF,Q_Def,false);
    
        % save the results
        if ismember('WignerFunctions',who('-file',Paths(j)))
            WignerFunctions = QST.Variable_Managment.getVariableFromFilePath(Paths(j),["WignerFunctions"]);
            nPreviousW = length(WignerFunctions);
        else
            nPreviousW = 0;
        end

        WignerFunctions(nPreviousW+1).Wigner = WF;
        WignerFunctions(nPreviousW+1).nTherm = nThermal;
        WignerFunctions(nPreviousW+1).nCoherent = nCoherent;
        WignerFunctions(nPreviousW+1).QuantumCoherence = QST.Simulation.QuantumCoherence.computeQuantumCoherenceDTS(nCoherent,nThermal);
        WignerFunctions(nPreviousW+1).minQ = Q_Def(1);
        WignerFunctions(nPreviousW+1).stepsizeQ = Q_Def(2);
        WignerFunctions(nPreviousW+1).maxQ = Q_Def(3);
        save(Paths(j),"WignerFunctions","-append");
    end
end
