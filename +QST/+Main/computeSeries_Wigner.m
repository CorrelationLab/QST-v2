function [] = computeSeries_Wigner(Dir_Data,Dir_WignerTable,DensityMatrixIndex)
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

    %calculate wigner
    WF = QST.Wigner.WignerFromRho(Rho,Dir_WignerTable);
    % analyse wigner
    [nThermal, nCoherent] = QST.Wigner.fitDTS(WF,Q_Def,false);
    

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
