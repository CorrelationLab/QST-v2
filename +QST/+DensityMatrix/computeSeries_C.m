Dir = "D:\Data\Artifical DTS\15.11.2024\nRatio_Constant__nTotal_Varied"; % dir of the Series
Paths = QST.File_Managment.getFilePaths(Dir);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));% take only the mat files


[N, C, M, P] = deal(zeros([length(Paths),1]));
W = [0:200].';
for i = 1:length(Paths)
    Rho = QST.Variable_Managment.getVariableFromFilePath(Paths(i),"DensityMatrix.Rho");
    D = diag(Rho);
    N(i) = sum(W.*D);
    [C(i),M(i),P(i)] = QST.DensityMatrix.computeQuantities_fromRho(Rho);
end
plot(N,C);
hold on
plot(N,M);
hold on
plot(N,P);
legend(["C","M","P"]);
