function [] = execSeriesAnalysis_HusimiQ_DTS(RootDirectory,Channel,Options)

%% A function to create and to analyze the Husimi Q function for a series of given datasets
% Inside the function the Quadratures are called X1 and X2 even when the used Quadratures are called differentely
% By default the QuadratureVariable is called X'ChannelNumber' eg X1 or X2
% By default the Edgeindices are used not the indices which are assumed to be in the struct "Results_N_G2_TimeResolved.Channel" which is created by
% 'execSeriesAnalysis_N_G2'. Latter should be used before this function
% By default the function searches first for condensate filtered Edgeindices with the name EdgeIndices_High, which is done by ''. If these not exists 
% it uses the whole dataset with 'EdgeIndices'


% since it would be quite unhandy to set all the parameters each time, profiles can be set to use the program in different situations

%% 1. Set parameter
arguments
    RootDirectory;
    Channel
    % Option to use a predefined Mode
    Options.AnalysisMode = '';
    % Options to get the data
    Options.X1_IndicesString = '';
    Options.X2_IndicesString = '';
    Options.X1_EdgeIndicesString = '';
    Options.X2_EdgeIndicesString = '';
    % Options for quadrature rescaling
    Options.ScaleChannels = true;
    % Options for the generation of the Husimi Q distribution 
    Options.Limits_Q = [-10,10];
    Options.Limits_P = [-10,10];
    Options.Resolution = 0.1;
    % Options for the PDTS analysis
    Options.MonteCarloError = true;
    Options.nMonteCarloIterations = 1000;
    Options.FitMethod = 'NLSQ-LAR';
    %Options for the plots
    Options.SaveFigure = true;
    Options.FigureSaveDirName = '';
    Options.plot2D = true;
    Options.FigureSaveName_2D = 'HusimiQ-2D';
    Options.ShowColorBar_2D = true;
    Options.ShowLegend_2D = true;
    Options.plot1D = true;
    Options.FigureSaveName_1D = 'HusimiQ-1D';
    Options.ShowLegend_1D = true;
    % for saving the results
    Options.SaveResults = true;

end
    
    %% 1. set the name of the channels
    Options.X1String = strcat("X",string(Channel(1)));
    Options.X2String = strcat("X",string(Channel(2)));

    %% 2. set the Params dependent on the used mode
    switch Options.AnalysisMode
        case 'All'
            Options.X1_IndicesString = '';
            Options.X2_IndicesString = '';
            Options.X1_EdgeIndicesString = '';
            Options.X2_EdgeIndicesString = '';
            Options.ResultSaveVariable = 'Results_HusimiQ_DTS';
            Options.FigureSaveDirName = 'Results HusimiQ DTS';
            Options.FigureSaveName_2D = 'HusimiQ-2D';
            Options.FigureSaveName_1D = 'HusimiQ-1D';
        case 'CondensateOnly'
            Options.X1_IndicesString = '';
            Options.X2_IndicesString = '';
            Options.X1_EdgeIndicesString = [strcat("Results_N_G2_TimeResolved.Channel",string(Channel(1)),".EdgeIndices_High"),...
                                            strcat("Results_N_G2_TimeResolved.Channel",string(Channel(1)),".EdgeIndices")];
            Options.X2_EdgeIndicesString = [strcat("Results_N_G2_TimeResolved.Channel",string(Channel(2)),".EdgeIndices_High"),...
                                            strcat("Results_N_G2_TimeResolved.Channel",string(Channel(2)),".EdgeIndices")];
            Options.ResultSaveVariable = 'Results_HusimiQ_DTS_Condensate';
            Options.FigureSaveDirName = 'Results HusimiQ DTS Condensate';
            Options.FigureSaveName_2D = 'HusimiQ-2D-Condensate';
            Options.FigureSaveName_1D = 'HusimiQ-1D-Condensate';
        otherwise
            
    end











%% 1. get all Mat files
InputFilePaths = QST.File_Managment.getFilePaths(RootDirectory);
[~,~,Ext] = fileparts(InputFilePaths);
InputFilePaths = InputFilePaths(strcmp(Ext,".mat"));
% Add here more code to allow specifying the mat files (e.g. with the validators)
%  go through for all valid Datasets


for i = 1:length(InputFilePaths)
    f = InputFilePaths(i);

    %% 3. set the params for the saving the figures
    DirParts = split(f,filesep);
    DirParts = DirParts(1:end-2);
    ParentDir = join(DirParts,filesep);
    FigureSaveDir = fullfile(ParentDir,Options.FigureSaveDirName);
    [ResultSaveDir,ResultSaveName,~] = fileparts(f);
    ResultSaveName = strcat(ResultSaveName,'.mat');
    



    QST.Main.execAnalysis_HusimiQ_DTS(InputFilePath=f,...
                                      X1String=Options.X1String,...
                                      X2String=Options.X2String,...
                                      X1_IndicesString=Options.X1_IndicesString,...
                                      X2_IndicesString=Options.X2_IndicesString,...
                                      X1_EdgeIndicesString=Options.X1_EdgeIndicesString,...
                                      X2_EdgeIndicesString=Options.X2_EdgeIndicesString,...
                                      ScaleChannels=Options.ScaleChannels,...
                                      Limits_Q=Options.Limits_Q,...
                                      Limits_P=Options.Limits_P,...
                                      Resolution=Options.Resolution,...
                                      MonteCarloError=Options.MonteCarloError,...
                                      nMonteCarloIterations=Options.nMonteCarloIterations,...
                                      FitMethod=Options.FitMethod,...
                                      SaveFigure=Options.SaveFigure,...
                                      FigureSaveDir=FigureSaveDir,...
                                      plot2D=Options.plot2D,...
                                      FigureSaveName_2D=Options.FigureSaveName_2D,...
                                      ShowColorBar_2D=Options.ShowColorBar_2D,...
                                      ShowLegend_2D=Options.ShowLegend_2D,...
                                      plot1D=Options.plot1D,...
                                      FigureSaveName_1D=Options.FigureSaveName_1D,...
                                      ShowLegend_1D=Options.ShowLegend_1D,...
                                      SaveResults=Options.SaveResults,...
                                      ResultSaveDir=ResultSaveDir,...
                                      ResultSaveName=ResultSaveName,...
                                      ResultSaveVariable=Options.ResultSaveVariable)

end





end