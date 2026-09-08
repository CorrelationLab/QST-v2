function [] = computeSeriesDensityMatrix(Directory, X_String,PiezoInfos_String, Options)
%% Description:
%   This function reconstructs density matrices from a selected quadrature dataset for all MATLAB measurement files
%   found recursively in Directory.
%
%   For every .mat file, the function loads the quadrature data specified by X_String and the corresponding piezo
%   information specified by PiezoInfos_String. The quadrature data are reshaped according to the stored piezo shape
%   and passed to QST.Main.computeDensityMatrix.
%
%   The reconstructed density matrix, its variance, and the reconstruction parameters are appended to the
%   DensityMatrix structure array in the corresponding MATLAB file. If DensityMatrix does not yet exist in a file, a
%   new structure array is created.
%
%% Syntax:
%   computeSeriesDensityMatrix(Directory, X_String, PiezoInfos_String)
%
%   computeSeriesDensityMatrix(Directory, X_String, PiezoInfos_String, Options)
%
%   computeSeriesDensityMatrix(Directory, "X1", "PiezoInfos")
%
%   computeSeriesDensityMatrix(Directory, "X1", "PiezoInfos", MaxFockState=75, Iterations=200)
%
%% Input:
% required input values:
%   Directory                                       - root directory recursively searched for MATLAB .mat measurement
%                                                     files
%
%   X_String                                        - variable name or variable path of the quadrature dataset in every
%                                                     measurement file; it must also match a field name within the piezo
%                                                     information structure
%
%   PiezoInfos_String                               - variable name or variable path of the piezo-information structure
%                                                     in every measurement file
%
% optional input options:
%   PeriodsPerSegment                               - number of piezo periods contained in one measurement segment
%                                                     (default: 2)
%
%   PeakThreshold                                   - threshold used for peak identification during density-matrix
%                                                     reconstruction (default: 0.5)
%
%   Acurracy_Spline                                 - accuracy parameter used in spline-based calculations
%                                                     (default: 1* 10^-14)
%
%   MaxFockState                                    - highest Fock state included in the reconstructed density matrix
%                                                     (default: 50)
%
%   Iterations                                      - number of reconstruction iterations (default: 100)
%
%   PiezoSegmentsPerRho                             - number of piezo segments used to reconstruct one density matrix
%                                                     (default: 5)
%
%   RhosPerAverage                                  - number of reconstructed density matrices combined per averaged
%                                                     output density matrix (default: 1)
%
%% Output:
%   This function does not return output arguments.
%
%   For every processed MATLAB file, the function appends a new entry to the DensityMatrix structure array. Each
%   entry contains:
%
%       Rho                                         - reconstructed average density matrix in the Fock-state representation
%
%       varRho                                      - variance over the set of reconstructed density matrices
%
%       nPiezoSegmentsPerRho                        - number of piezo segments used for one density-matrix
%                                                     reconstruction
%
%       nIterations                                 - number of iterations used for the reconstruction
%
%       nRhosPerAverage                             - number of density matrices used per averaged result
%
%% Required file contents:
%   Every processed MATLAB file must contain:
%
%   <X_String>                                      - quadrature dataset used for density-matrix reconstruction
%
%   <PiezoInfos_String>                             - piezo-information structure containing a field named X_String
%
%   <PiezoInfos_String>.(X_String).Shape            - dimensions used to reshape the quadrature dataset
%
%   <PiezoInfos_String>.(X_String).StartDirection   - direction of the first piezo movement used for reconstruction
%
%% Notes:
%   Only files with the .mat extension are processed.
%
%   The density-matrix calculation is performed by QST.Main.computeDensityMatrix. The IgnoredSegments option is
%   passed as an empty array.
%
%   Existing DensityMatrix entries are preserved. The newly calculated result is appended as the final structure
%   entry and the updated structure array is saved with the '-append' option.
%
%   All existing elements of DensityMatrix must use the same set of fields. Older files containing DensityMatrix
%   structures with a different field layout must be migrated before new entries can be appended.
%
%   This function requires QST.File_Managment.getFilePaths,
%   QST.Variable_Managment.getVariableFromFilePath, and QST.Main.computeDensityMatrix.



    arguments
        Directory;
        X_String;
        PiezoInfos_String;
        Options.PeriodsPerSegment = 2;
        Options.PeakThreshold = 0.5;
        Options.Acurracy_Spline = 1e-14;
        Options.MaxFockState = 50;
        Options.Iterations = 100;
        Options.PiezoSegmentsPerRho = 5;
        Options.RhosPerAverage = 1;
    end

    
    Paths = QST.File_Managment.getFilePaths(Directory);
    [~,~,Ext] = fileparts(Paths);
    Paths = Paths(strcmp(Ext,".mat"));% take only the mat files
    for i = 1:length(Paths)

        FilePath = Paths(i);

        % Load Data
        X = QST.Variable_Managment.getVariableFromFilePath(FilePath,[X_String]);
        PiezoInfos = QST.Variable_Managment.getVariableFromFilePath(FilePath,[PiezoInfos_String]);
        PiezoInfos = getfield(PiezoInfos,X_String);
        Shape = PiezoInfos.Shape;
        StartDirection = PiezoInfos.StartDirection;
        X =  reshape(X, Shape);
        
        % Construct the density matrix
        [Rho, Rho_Var] = QST.Main.computeDensityMatrix(X,...
                                                       StartDirection,...
                                                       PeriodsPerSegment=Options.PeriodsPerSegment, ...
                                                       PeakThreshold=Options.PeakThreshold,...
                                                       Acurracy_Spline=Options.Acurracy_Spline,...
                                                       IgnoredSegments=[],...
                                                       MaxFockState=Options.MaxFockState,...
                                                       Iterations=Options.Iterations,...
                                                       PiezoSegmentsPerRho=Options.PiezoSegmentsPerRho,...
                                                       RhosPerAverage=Options.RhosPerAverage);

        % save the results
        VariablesInFile = who('-file', Paths(i));
        if ~ismember('DensityMatrix', VariablesInFile)
            DensityMatrix = struct( ...
                'Rho', {}, ...
                'varRho', {}, ...
                'nPiezoSegmentsPerRho', {}, ...
                'nIterations', {}, ...
                'nRhosPerAverage', {});
        else
            LoadedData = load(FilePath, 'DensityMatrix');
            DensityMatrix = LoadedData.DensityMatrix; 
        end
        DensityMatrix(end + 1).Rho = Rho;
        DensityMatrix(end).varRho = Rho_Var;
        DensityMatrix(end).nPiezoSegmentsPerRho = Options.PiezoSegmentsPerRho;
        DensityMatrix(end).nIterations = Options.Iterations;
        DensityMatrix(end).nRhosPerAverage = Options.RhosPerAverage;
        save(FilePath, 'DensityMatrix', '-append');
    end
end