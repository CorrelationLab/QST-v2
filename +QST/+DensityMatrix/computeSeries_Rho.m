function [] = computeSeries_Rho(Dir,Options)
% This function allows to construct the densitymatrices for a whole Series. 

arguments
    % arguments to get the files and variables
    Dir;
    Options.X1_String = "X1";
    Options.PiezoInfos_String = "PiezoInfos";
    % arguments for the reconstruction algorithm
    Options.maxFock = 150;
    Options.Iterations = 500;
    Options.nPiezoSegmentsPerRho = 5;
    Options.nRhoForAveraging = 1;

end

Paths = QST.File_Managment.getFilePaths(Dir);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));% take only the mat files
for j = 1:length(Paths)
    tic
    disp(strcat("DensityMatrix Reconstruction ",string(j)," of ",string(length(Paths))));
    % load Data
    X1 = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[Options.X1_String]);
    PiezoInfos = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[Options.PiezoInfos_String]);
    PiezoInfos = getfield(PiezoInfos,Options.X1_String);
    Shape = PiezoInfos.Shape;
    StartDirection = PiezoInfos.StartDirection;

    % reshape Data
    X1 = reshape(X1,Shape);
    
    Options.nRhoForAveraging = min(Shape(3),Options.nRhoForAveraging); % if multiple Iterations are used,
                                           % set number iterations or all
    X1 = X1(:,:,1:Options.nRhoForAveraging*Options.nPiezoSegmentsPerRho);
    Theta = QST.Helper.computePhase(X1,1,StartDirection);% compute the Phase
    X1 = reshape(X1,[Shape(1)*Shape(2),Options.nRhoForAveraging*Options.nPiezoSegmentsPerRho]); % reshape X1 so it fits to the for loop

    Rhos = zeros(Options.maxFock+1,Options.maxFock+1,Options.nRhoForAveraging);
    i=1;
    k=1;
    while i <= Options.nRhoForAveraging*Options.nPiezoSegmentsPerRho
        Rhos(:,:,k) = QST.DensityMatrix.computeDensityMatrix_FAST(reshape(X1(:,i:i+Options.nPiezoSegmentsPerRho-1),[],1),reshape(Theta(:,i:i+Options.nPiezoSegmentsPerRho-1),[],1),MaxFockState=Options.maxFock,Iterations=Options.Iterations); % compute Rho using the GPU
        k = j+1;
        i = i+Options.nPiezoSegmentsPerRho;
    end
    
    Rho = mean(Rhos,3);
    varRho = var(Rhos,[],3);


    % save the results
    % 1. search for the variable Densitymatrices. If it not exists create
    % it and fill it with the data
    if ismember('DensityMatrices',who('-file',Paths(j)))
        DensityMatrices = QST.Variable_Managment.getVariableFromFilePath(Paths(j),["DensityMatrices"]);
        nPreviousRhos = length(DensityMatrices);
    else
        nPreviousRhos = 0;
    end
    DensityMatrices(nPreviousRhos+1).Rho = Rho;
    DensityMatrices(nPreviousRhos+1).Rho_Variance = varRho;
    DensityMatrices(nPreviousRhos+1).maxFock = Options.maxFock;
    DensityMatrices(nPreviousRhos+1).Iterations = Options.Iterations;
    DensityMatrices(nPreviousRhos+1).nPiezoSegmentsPerRho = Options.nPiezoSegmentsPerRho;
    DensityMatrices(nPreviousRhos+1).nRhoForAveraging = Options.nRhoForAveraging;
    % 2. save it
    save(Paths(j),"DensityMatrices","-append");
    toc
end
