Dir = "D:\Data\Tests\12.06.24 Improve Rho\Datasize\nRatio_Constant__nTotal_Varied";
Paths = QST.File_Managment.getFilePaths(Dir);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));% take only the mat files


[nThermal_DTS_Wigner,nThermal_DTS_Dens, nCoherent_DTS_Wigner,nCoherent_DTS_Dens, nTotal_Dens, C_DTS_Wigner,C_Dens,C_DTS_Dens] = deal(zeros([length(Paths),1]));
for i = 1:length(Paths)
    % results from the Wignerfunction
    nThermal_DTS_Wigner(i) = QST.Variable_Managment.getVariableFromFilePath(Paths(i),"Wigner_10Sets_1Rho_500It.nTherm");
    nCoherent_DTS_Wigner(i) = QST.Variable_Managment.getVariableFromFilePath(Paths(i),"Wigner_10Sets_1Rho_500It.nCoherent");
    C_DTS_Wigner(i) = QST.Variable_Managment.getVariableFromFilePath(Paths(i),"Wigner_10Sets_1Rho_500It.QuantumCoherence");
    % compare with the results of the densitymatrix itsself
    Rho = QST.Variable_Managment.getVariableFromFilePath(Paths(i),"DensityMatrix_10Sets_1Rho_500It.Rho");
    N = diag([0:size(Rho,1)-1]);
    nTotal_Dens(i) = trace(N*Rho);
    [C_Dens(i),~,~] = QST.DensityMatrix.computeQuantities_fromRho(Rho);
    % results from the DTS model based on the denisty matrix (nTotal and g2)
    [nThermal_DTS_Dens(i),nCoherent_DTS_Dens(i)] = QST.DensityMatrix.DTSComponentsFromRho(Rho);
    C_DTS_Dens(i) = QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent_DTS_Dens(i),nThermal_DTS_Dens(i));
end
% total photon numbers
nTotal_DTS_Wigner = nThermal_DTS_Wigner+nCoherent_DTS_Wigner;
nTotal_DTS_Dens = nThermal_DTS_Dens+nCoherent_DTS_Dens;


% different approach to look at the the ratio nC/nTot, csales more
% comparable
nRatio_C_Wigner = nCoherent_DTS_Wigner./nTotal_DTS_Wigner;
nRatio_T_Wigner = nThermal_DTS_Wigner./nTotal_DTS_Wigner;

nRatio_C_Dens = nCoherent_DTS_Dens./nTotal_DTS_Dens;
nRatio_T_Dens = nThermal_DTS_Dens./nTotal_DTS_Dens;

% plotting C for different methods
scatter(nTotal_Dens,C_Dens);
hold on
scatter(nTotal_DTS_Wigner,C_DTS_Wigner);
hold on
scatter(nTotal_DTS_Dens,C_DTS_Dens);
legend(["C_{DensityMatrix}","C_{DTS from Wigner}","C_{DTS from Densitymatrix}"]);
hold off



% check the ratios
nRatio_DTS_Wigner = nCoherent_DTS_Wigner./nThermal_DTS_Wigner;
nRatio_DTS_Dens = nCoherent_DTS_Dens./nThermal_DTS_Dens;
%
%scatter(nTotal_DTS_Wigner,nRatio_DTS_Wigner);
%hold on
%scatter(nTotal_DTS_Dens,nRatio_DTS_Dens);
%legend(["nRatio_{DTS from Wigner}","nRatio_{DTS from Densitymatrix}"]);
%hold off

%check the more comparable ratios
%scatter(nTotal_DTS_Wigner,nRatio_C_Wigner);
%hold on
%scatter(nTotal_DTS_Dens,nRatio_C_Dens);
%legend(["Coherent Ratio_{DTS from Wigner}","Coherent Ratio_{DTS from Densitymatrix}"]);
%hold off

%scatter(nTotal_DTS_Wigner,nRatio_T_Wigner);
%hold on
%scatter(nTotal_DTS_Dens,nRatio_T_Dens);
%legend(["Thermal Ratio_{DTS from Wigner}","Thermal Ratio_{DTS from Densitymatrix}"]);
%hold off

