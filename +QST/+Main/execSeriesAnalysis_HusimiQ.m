function [] = execSeriesAnalysis_HusimiQ(RootDirectory,Channel,Options)

%% A function to create and to analyze the Husimi Q function for a series of given datasets
% Inside the function the Quadratures are called X1 and X2 even when the used Quadratures are called differentely
% By default the QuadratureVariable is called X'ChannelNumber' eg X1 or X2
% By default the Edgeindices are used not the indices which are assumed to be in the struct "Results_N_G2_TimeResolved.Channel" which is created by
% 'execSeriesAnalysis_N_G2'. Latter should be used before this function
% By default the function searches first for condensate filtered Edgeindices with the name EdgeIndices_High, which is done by ''. If these not exists 
% it uses the whole dataset with 'EdgeIndices'

%% 1. Set parameter
arguments
    RootDirectory; % Maindirectory of the series
    Channel; % used Channel
    % Parameter of the dataselection
    Options.X1String = strcat("X",string(Channel(1))); % Quadrature variablename as String
    Options.X2String = strcat("X",string(Channel(2)));
    Options.X1_IndicesString = ''; % Indices Variablename as String
    Options.X2_IndicesString = '';
    Options.X1_EdgeIndicesString = [strcat("Results_N_G2_TimeResolved.Channel",string(Channel(1)),".EdgeIndices_High"),... % Edgeindices Variablename as String
                                    strcat("Results_N_G2_TimeResolved.Channel",string(Channel(1)),".EdgeIndices")];
    Options.X2_EdgeIndicesString = [strcat("Results_N_G2_TimeResolved.Channel",string(Channel(2)),".EdgeIndices_High"),...
                                    strcat("Results_N_G2_TimeResolved.Channel",string(Channel(2)),".EdgeIndices")];
    %Parameter of the analysis
    Options.Resolution = 0.15;
    Options.Limits = [-10,10];
    Options.MonteCarloError = true;
    Options.nMonteCarloIterations = 1000;
    Options.PlotsSaveDir_relative = strcat('Results',filesep,'HusimiQ_High');
    Options.ResultsSaveVariableName = 'Results_HusimiQ_High';

end

X1String = Options.X1String;
X2String = Options.X2String;
X1_IndicesString = Options.X1_IndicesString;
X2_IndicesString = Options.X2_IndicesString;
X1_EdgeIndicesString = Options.X1_EdgeIndicesString;
X2_EdgeIndicesString = Options.X2_EdgeIndicesString; 
Resolution = Options.Resolution;
Limits = Options.Limits;
MonteCarloError = Options.MonteCarloError;
nMonteCarloIterations = Options.nMonteCarloIterations;
PlotsSaveDir_relative = Options.PlotsSaveDir_relative;
ResultsSaveVariableName = Options.ResultsSaveVariableName;




DataFilePaths = QST.File_Managment.getFilePaths(RootDirectory);
[~,~,Ext] = fileparts(DataFilePaths);
DataFilePaths = DataFilePaths(strcmp(Ext,".mat"));

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
    %PlotsSaveName = strcat('Pow',string(QST.File_Managment.getInformationFromFilePath(f,"[0-9]+[i|.]?[0-9]*[mW]?[µW]?","[0-9]+[i|.]?[0-9]*",Type='String')));
    PlotsSaveName = "Test"; % This part has to be fixed to work properly in future


    % load selected quadrature subset
    [X1,X2] = QST.HusimiQ.Prepare.prepareDataSubSetForHusimiQ(FilePath=f,...
                                                       X1String=X1String,...
                                                       X2String=X2String,...
                                                       X1_IndicesString=X1_IndicesString,...
                                                       X2_IndicesString=X2_IndicesString,...
                                                       X1_EdgeIndicesString=X1_EdgeIndicesString,...
                                                       X2_EdgeIndicesString=X2_EdgeIndicesString);
    
    % create the husimi Q function and analyze it
    QST.HusimiQ.generate_analyze_plotHusimiQ(X1,...
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