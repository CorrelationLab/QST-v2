MainDir = "D:\Data\Artifical DTS\18.12.2024\nCoherent_varied_nCoherent10_nThermal0.5";
d = dir(MainDir);
isub = [d(:).isdir]; %# returns logical vector
SeriesDir = {d(isub).name}';
SeriesDir(ismember(SeriesDir,{'.','..'})) = [];
SeriesDir = strcat(MainDir,filesep,SeriesDir);
nSeries = length(SeriesDir);
nFiles = 10;

[N,C,M,P] = deal(zeros([nSeries,nFiles]));

maxFock = 40;
W = [0:maxFock].';
for i = 1:nSeries
    Files = QST.File_Managment.getFilePaths(SeriesDir(i));
    [~,~,Ext] = fileparts(Files);
    Files = Files(strcmp(Ext,".mat"));
    
    for j = 1:nFiles
        Rho = QST.Variable_Managment.getVariableFromFilePath(Files(j),["DensityMatrix_5Sets_1Rho_500It.Rho"]);
        D = diag(Rho);
        N(i,j) = sum(W.*D);
        [C(i,j),M(i,j),P(i,j)] = QST.DensityMatrix.computeQuantities_fromRho(Rho);
    end
end
%take the mean
N = mean(N,2);
C = mean(C,2);
M = mean(M,2);
P = mean(P,2);

scatter(N,C);
hold on
scatter(N,M);
hold on
scatter(N,P);
legend(["C","M","P"]);
