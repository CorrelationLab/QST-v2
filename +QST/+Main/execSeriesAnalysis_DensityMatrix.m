function [] = execSeriesAnalysis_DensityMatrix(Directory, X_String, Options)
%% Description:
%   This function executes the function execSeriesAnalysis_DensityMatrix for a whole series of measurements and saves the results in the according mat files
%
%% Syntax:
%   [] = execSeriesAnalysis_DensityMatrix(Directory,X_String)
%
%% Input:
% required input values;
%   Directory                           - main directory of the recorded series. It must only contain subdirectories with the according mat files.
%                                         While other filetypes will not create a problem other .mat files will lead to an error
%    X_String                           - variable name of the to be used quadrature variable 
%
% optional input arguments;
%   Options.PeriodsPerSegment=2         - initial guess of occuring phasecycles in one segment of nearly linear piezo movement
%   Options.PeakThreshold=0.5           - relative threshold in comparison to the segments extreme values for the detection of peaks
%   Options.IgnoredSegments=[]          - array of segments that should be excluded from the analysis. The segments are identified by their segment index 
%   Options.Accuracy_Spline=1e-14       - spline interpolation accuracy. The value is between 0 and 1. The interpolation accuracy 
%                                         increases nonlinear with increasing value (see documentation of csaps())
%   Options.MaxFockState=50             - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState
%   Options.Iterations=100              - number of iterations used in the algorithm
%   Options.PiezoSegmentsPerRho = 5     - number of piezo segment used for one density matrix reconstruction
%   Options.RhosPerAverage = 1          - number of reconstructed density matrices used for the final averaging process

%% Output:

arguments
    Directory;
    X_String;
    Options.PiezoInfos_String = "PiezoInfos";
    Options.PeriodsPerSegment = 2    
    Options.PeakThreshold = 0.5      
    Options.IgnoredSegments = []     
    Options.Accuracy_Spline = 1e-14                             
    Options.MaxFockState = 50        
    Options.Iterations = 100         
    Options.PiezoSegmentsPerRho = 5
    Options.RhosPerAverage = 1     
end

%% Obtain the absolute paths to all mat files and iterate through them
Paths = QST.File_Managment.getFilePaths(Directory);
[~,~,Ext] = fileparts(Paths);
Paths = Paths(strcmp(Ext,".mat"));
for j = 1:length(Paths)
    
    % display the index of the current reconstruction
    disp(strcat("DensityMatrix Reconstruction ",string(j)," of ",string(length(Paths))));

    %% Load the quadrature data and the meta data from the .mat file
    X = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[X_String]);
    PiezoInfos = QST.Variable_Managment.getVariableFromFilePath(Paths(j),[Options.PiezoInfos_String]);
    PiezoInfos = getfield(PiezoInfos,X_String);
    Shape = PiezoInfos.Shape;
    PiezoSign = PiezoInfos.StartDirection;
    X = reshape(X,Shape);
    Options.RhosPerAverage = min(Shape(3),Options.RhosPerAverage); % if multiple Iterations are used,
                                           % set number iterations or all

    %% construct the density matrix
    [Rho, Rho_Var] = QST.Main.computeDensityMatrix(X, ...
                                                   PiezoSign, ...
                                                   PeriodsPerSegment=Options.PeriodsPerSegment, ...
                                                   PeakThreshold=Options.PeakThreshold, ...
                                                   IgnoredSegments=Options.IgnoredSegments, ...
                                                   Acurracy_Spline=Options.Acurracy_Spline, ...
                                                   MaxFockState=Options.MaxFockState, ...
                                                   Iterations=Options.Iterations, ...
                                                   PiezoSegmentsPerRho = Options.PiezoSegmentsPerRho, ...
                                                   RhosPerAverage = Options.RhosPerAverage);

    %% Save the result in the according .mat file in form of a variable 'DensityMatrices' . 
    %% If the matfile already includes such a variable for e.g. since the calculation has already be 
    %% done previously with different parameters the new density matrix data is appendend
    if ismember('DensityMatrices',who('-file',Paths(j)))
        DensityMatrices = QST.Variable_Managment.getVariableFromFilePath(Paths(j),["DensityMatrices"]);
        nPreviousRhos = length(DensityMatrices);
    else
        nPreviousRhos = 0;
    end
    DensityMatrices(nPreviousRhos+1).Rho = Rho;
    DensityMatrices(nPreviousRhos+1).Rho_Variance = Rho_Var;
    DensityMatrices(nPreviousRhos+1).MaxFockState = Options.MaxFockState;
    DensityMatrices(nPreviousRhos+1).Iterations = Options.Iterations;
    DensityMatrices(nPreviousRhos+1).PiezoSegmentsPerRho = Options.PiezoSegmentsPerRho;
    DensityMatrices(nPreviousRhos+1).RhosPerAverage = Options.RhosPerAverage;
    save(Paths(j),"DensityMatrices","-append");
end
