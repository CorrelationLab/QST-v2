% this is for now a script, but it can be converted into a proper function
% as some point

% calculates the density matrix for agiven dataset
Iterations_DataSet = 1;
maxFock = 40;
Iterations_DesityConstructor = 500;
DataSetsPerRho = 5;

X1_String = "X1";
PiezoInfos_String = "PiezoInfos";
Dir = "D:\Data\Artifical DTS\18.12.2024"; % dir of the Series

Paths = QST.File_Managment.getFilePaths(Dir);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));% take only the mat files
for j = 1:length(Paths)
    tic
    % load Data
    X1 = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[X1_String]);
    PiezoInfos = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[PiezoInfos_String]);
    PiezoInfos = getfield(PiezoInfos,X1_String);
    Shape = PiezoInfos.Shape;
    StartDirection = PiezoInfos.StartDirection;

    % reshape Data
    X1 = reshape(X1,Shape);
    
    Iterations_DataSet = min(Shape(3),Iterations_DataSet); % if multiple Iterations are used,
                                           % set number iterations or all
    X1 = X1(:,:,1:Iterations_DataSet*DataSetsPerRho);
    Theta = QST.Helper.computePhase(X1,1,StartDirection);% compute the Phase
    X1 = reshape(X1,[Shape(1)*Shape(2),Iterations_DataSet*DataSetsPerRho]); % reshape X1 so it fits to the for loop

    Rhos = zeros(maxFock+1,maxFock+1,Iterations_DataSet);
    i=1;
    k=1;
    while i <= Iterations_DataSet*DataSetsPerRho
        Rhos(:,:,k) = QST.DensityMatrix.computeDensityMatrix_FAST(reshape(X1(:,i:i+DataSetsPerRho-1),[],1),reshape(Theta(:,i:i+DataSetsPerRho-1),[],1),MaxFockState=maxFock,Iterations=Iterations_DesityConstructor); % compute Rho using the GPU
        k = j+1;
        i = i+DataSetsPerRho;
    end
    %pause(3);% pause the computation so the GPU can cool down again
    Rho = mean(Rhos,3);
    varRho = var(Rhos,[],3);
    DensityMatrix_5Sets_1Rho_500It.Rho = Rho;
    DensityMatrix_5Sets_1Rho_500It.Rho_Varianz = varRho;
    save(Paths(j),"DensityMatrix_5Sets_1Rho_500It","-append");
    toc
end
