%% A script to create and to analyze the Husimi Q function for a series of given datasets

%% 1. Set parameter

% Maindirectory of the series
DataDirPath = 'E:\Paper Powerdependency\Threshold Series';


% set quadrature identifier
X1String = "X1";
X2String = "X2";

% select a quadrature subset by indices or edgeindices ('' means all data is used)
X1_IndicesString = '';
X2_IndicesString = '';

X1_EdgeIndicesString = ["Results_N_G2_TimeResolved.Channel1.EdgeIndices_High","Results_N_G2_TimeResolved.Channel1.EdgeIndices"];
X2_EdgeIndicesString = ['Results_N_G2_TimeResolved.Channel2.EdgeIndices_High',"Results_N_G2_TimeResolved.Channel2.EdgeIndices"];


% Set Options for the analysis
Resolution = 0.15;
Limits = [-10,10];
MonteCarloError = true;
nMonteCarloIterations = 1000;
PlotsSaveDir_relative = strcat('Results',filesep,'HusimiQ_High');
ResultsSaveVariableName = 'Results_HusimiQ_High';



DataFilePaths = QST.File_Managment.getFilePathsFromFolder(DataDirPath,FileTypes="*.mat",IncludeSubFolders=true);
for i = 1:length(DataFilePaths)
    f = DataFilePaths(i);
    disp(f);
    % set the absolute path to the plots savedir
    d = split(f,filesep);
    d = d(1:end-2);
    d = join(d,filesep);
    PlotsSaveDir_absolute = strcat(d,filesep,PlotsSaveDir_relative);
    if ~exist(PlotsSaveDir_absolute,'dir')
        mkdir(PlotsSaveDir_absolute)
    end

    % set the name of the result file by using the identifier (here it is the power)
    PlotsSaveName = strcat('Pow',string(QST.File_Managment.getInformationFromFilePath(f,"[0-9]+[i|.]?[0-9]*[mW]?[µW]?","[0-9]+[i|.]?[0-9]*",Type='String')));

    % load selected quadrature subset
    [X1,X2] = QST.Plotting.prepareDataSubSetForHusimiQ(FilePath=f,...
                                                       X1String=X1String,...
                                                       X2String=X2String,...
                                                       X1_IndicesString=X1_IndicesString,...
                                                       X2_IndicesString=X2_IndicesString,...
                                                       X1_EdgeIndicesString=X1_EdgeIndicesString,...
                                                       X2_EdgeIndicesString=X2_EdgeIndicesString);
    
    % create the husimi Q function and analyze it
    QST.HusimiQ_Reconstruction.analyizeHusimiQFromQuadratures(X1,...
                                                              X2,...
                                                              Resolution,...
                                                              Limits,...
                                                              MonteCarloError=MonteCarloError,...
                                                              nMonteCarloIterations=nMonteCarloIterations,...
                                                              PlotsSaveDir=PlotsSaveDir_absolute,...
                                                              PlotsSaveName=PlotsSaveName,...
                                                              ResultsSaveFile=f,...
                                                              ResultsSaveVariableName = ResultsSaveVariableName)
end