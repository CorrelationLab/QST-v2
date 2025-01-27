

% calculates the density matrix for agiven dataset
Q_Def = [-10,0.125/2,10];
Rho_String = "DensityMatrix_5Sets_1Rho_500It.Rho";
Dir = "D:\Data\Artifical DTS\18.12.2024"; % dir of the Series
Dir_Pattern = "D:\Programming\Wignertables\Start_m10__Step0i0625__End_10__maxFock_50";




Paths = QST.File_Managment.getFilePaths(Dir);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));% take only the mat files
for j = 1:length(Paths)
    % load Data
    Rho = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[Rho_String]);
    %calculate wigner
    WF = QST.Wigner.WignerFromRho(Rho,Dir_Pattern);
    % analyse wigner
    [Qwidth,Pwidth,Qcenter,Pcenter] = QST.Wigner.Fit2DGaussian(WF,Q_Def,false);
    nThermal = (Qwidth^2)-0.5;
    nCoherent = 0.5*(Qcenter^2+Pcenter^2);
    
    Wigner_5Sets_1Rho_500It.Wigner = WF;
    Wigner_5Sets_1Rho_500It.nTherm = nThermal;
    Wigner_5Sets_1Rho_500It.nCoherent = nCoherent;
    Wigner_5Sets_1Rho_500It.QuantumCoherence = QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent,nThermal);
    save(Paths(j),"Wigner_5Sets_1Rho_500It","-append");
end
