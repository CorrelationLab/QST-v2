Dir = "D:\Data\Artifical DTS\25.11.2024\nCoherent_Constant__nThermal_Varied"; % dir of the Series
Paths = QST.File_Managment.getFilePaths(Dir);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));% take only the mat files
maxFock=50;

[N, C, M, P] = deal(zeros([length(Paths),1]));
W = [0:maxFock].';
for i = 1:length(Paths)
    Rho = QST.Variable_Managment.getVariableFromFilePath(Paths(i),"DensityMatrix.Rho");
    D = diag(Rho);
    N(i) = sum(W.*D);
    [C(i),M(i),P(i)] = QST.DensityMatrix.computeQuantities_fromRho(Rho);
end
scatter(N,C);
hold on
scatter(N,M);
hold on
scatter(N,P);
legend(["C","M","P"]);
