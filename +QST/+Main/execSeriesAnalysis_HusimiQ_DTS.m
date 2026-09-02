function [] = execSeriesAnalysis_HusimiQ_DTS(RootDirectory,Channel,Options)
%% Description:
%   This function performs a Husimi Q-distribution analysis based on the phase-averaged displaced thermal state
%   (DTS) model for all MATLAB measurement files found recursively in RootDirectory.
%
%   For each measurement file, the function selects two quadrature channels, prepares a selected subset of their
%   data, generates a two-dimensional Husimi Q distribution, and analyses the distribution using the DTS model.
%   The results and optionally generated figures are saved for every processed dataset.
%
%   The quadrature variables are expected to be named X<ChannelNumber>, for example X1 and X2. Data selection may be
%   performed using explicit index vectors or edge-index arrays stored in Results_N_G2_TimeResolved. By default,
%   selection fields can be configured using one of the predefined analysis modes.
%
%   This function is intended to be used after execSeriesAnalysis_N_G2, which generates the
%   Results_N_G2_TimeResolved structure containing the default edge-index information.
%
%% Syntax:
%   execSeriesAnalysis_HusimiQ_DTS(RootDirectory, Channel)
%   execSeriesAnalysis_HusimiQ_DTS(RootDirectory, Channel, Options)
%   execSeriesAnalysis_HusimiQ_DTS(RootDirectory, [1, 2], AnalysisMode='All')
%   execSeriesAnalysis_HusimiQ_DTS(RootDirectory, [1, 2], AnalysisMode='CondensateOnly')
%   execSeriesAnalysis_HusimiQ_DTS(RootDirectory, [1, 2], AnalysisMode='PulseSelected')
%
%% Input:
% required input values:
%   RootDirectory                                   - root directory recursively searched for MATLAB .mat measurement
%                                                     files
%
%   Channel                                         - two-element vector containing the channel numbers used as the
%                                                     first and second quadratures, for example [1, 2]
%
% optional input options:
% analysis-mode option:
%   AnalysisMode                                    - predefined data-selection and naming profile:
%
%                                                     'All': analyse the complete quadrature datasets
%
%                                                     'CondensateOnly': analyse edge-index subsets stored in
%                                                     EdgeIndices_High; if unavailable, use EdgeIndices as fallback
%
%                                                     'PulseSelected': analyse edge-index subsets stored in
%                                                     EdgeIndices_Select; if unavailable, use EdgeIndices as fallback
%
%                                                     Any other value leaves the manual selection and naming options
%                                                     unchanged (default: '')
%
% data-selection options:
%   X1_IndicesString                                - variable name or path of the index vector selecting X1 data
%                                                     (default: '')
%
%   X2_IndicesString                                - variable name or path of the index vector selecting X2 data
%                                                     (default: '')
%
%   X1_EdgeIndicesString                            - variable name or path of the edge-index array selecting X1 data;
%                                                     multiple entries may define fallback names (default: '')
%
%   X2_EdgeIndicesString                            - variable name or path of the edge-index array selecting X2 data;
%                                                     multiple entries may define fallback names (default: '')
%
% quadrature-rescaling options:
%   ScaleChannels                                   - logical value specifying whether the selected quadrature channels
%                                                     are rescaled before generating the Husimi Q distribution
%                                                     (default: true)
%
% Husimi Q-distribution options:
%   Limits_Q                                        - lower and upper limits of the Q-quadrature axis
%                                                     (default: [-10, 10])
%
%   Limits_P                                        - lower and upper limits of the P-quadrature axis
%                                                     (default: [-10, 10])
%
%   Resolution                                      - bin width of the Q- and P-quadrature axes
%                                                     (default: 0.1)
%
% PDTS-analysis options:
%   MonteCarloError                                 - logical value specifying whether Monte Carlo simulations are used
%                                                     to estimate fit-parameter uncertainties (default: true)
%
%   nMonteCarloIterations                           - number of Monte Carlo iterations used for uncertainty estimation
%                                                     (default: 1000)
%
%   FitMethod                                       - fitting method passed to the DTS analysis function
%                                                     (default: 'NLSQ-LAR')
%
% plotting options:
%   SaveFigure                                      - logical value specifying whether generated Husimi Q figures
%                                                     are saved (default: true)
%
%   FigureSaveDirName                               - name of the figure-output directory created relative to the
%                                                     parent directory of each measurement file (default: '')
%
%   plot2D                                          - logical value specifying whether the two-dimensional Husimi
%                                                     Q distribution is plotted (default: true)
%
%   FigureSaveName_2D                               - base name of the two-dimensional Husimi Q figure
%                                                     (default: 'HusimiQ-2D')
%
%   ShowColorBar_2D                                 - logical value specifying whether the color bar is displayed in
%                                                     the two-dimensional figure (default: true)
%
%   ShowLegend_2D                                   - logical value specifying whether the legend is displayed in the
%                                                     two-dimensional figure (default: true)
%
%   plot1D                                          - logical value specifying whether the one-dimensional cut along
%                                                     P = 0 is plotted (default: true)
%
%   FigureSaveName_1D                               - base name of the one-dimensional Husimi Q cut figure
%                                                     (default: 'HusimiQ-1D')
%
%   ShowLegend_1D                                   - logical value specifying whether the legend is displayed in the
%                                                     one-dimensional figure (default: true)
%
% result-saving options:
%   SaveResults                                     - logical value specifying whether the Husimi Q analysis result
%                                                     structure is appended to every processed measurement file
%                                                     (default: true)
%
%% Output:
%   This function does not return output arguments.
%
%   For every processed MATLAB file, the function calls execAnalysis_HusimiQ_DTS and optionally appends its output
%   structure to the file. The output variable name depends on AnalysisMode:
%
%   Results_HusimiQ_DTS                             - used for AnalysisMode = 'All'
%
%   Results_HusimiQ_DTS_Condensate                  - used for AnalysisMode = 'CondensateOnly'
%
%   Results_HusimiQ_DTS_PulseSelected               - used for AnalysisMode = 'PulseSelected'
%
%   If SaveFigure is true, the function saves the requested one- and two-dimensional Husimi Q figures in a
%   subdirectory of the parent directory of each measurement file.
%
%% Notes:
%   The variables X1String and X2String are set internally from Channel and cannot be configured directly. For
%   example, Channel = [1, 2] selects the variables X1 and X2.
%
%   In CondensateOnly and PulseSelected mode, the specified selection field is passed together with EdgeIndices.
%   The data-preparation function is expected to use EdgeIndices as a fallback if the preferred selection field is
%   unavailable.



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
        case 'PulseSelected'
            Options.X1_IndicesString = '';
            Options.X2_IndicesString = '';
            Options.X1_EdgeIndicesString = [strcat("Results_N_G2_TimeResolved.Channel",string(Channel(1)),".EdgeIndices_Select"),...
                                            strcat("Results_N_G2_TimeResolved.Channel",string(Channel(1)),".EdgeIndices")];
            Options.X2_EdgeIndicesString = [strcat("Results_N_G2_TimeResolved.Channel",string(Channel(2)),".EdgeIndices_Select"),...
                                            strcat("Results_N_G2_TimeResolved.Channel",string(Channel(2)),".EdgeIndices")];
            Options.ResultSaveVariable = 'Results_HusimiQ_DTS_PulseSelected';
            Options.FigureSaveDirName = 'Results HusimiQ DTS PulseSelected';
            Options.FigureSaveName_2D = 'HusimiQ-2D-PulseSelected';
            Options.FigureSaveName_1D = 'HusimiQ-1D-PulseSelected';
        otherwise
            
    end



    %% 1. get all Mat files
    InputFilePaths = QST.File_Managment.getFilePaths(RootDirectory);
    [~,~,Ext] = fileparts(InputFilePaths);
    InputFilePaths = InputFilePaths(strcmp(Ext,".mat"));
    % Add here more code to allow specifying the mat files (e.g. with the validators)
    %  go through for all valid Datasets
    
    
    for i = 1:length(InputFilePaths)
        CurrentFilePath = InputFilePaths(i);
    
        %% 2. set the params for the saving the figures
        DirParts = split(CurrentFilePath,filesep);
        DirParts = DirParts(1:end-2);
        ParentDir = join(DirParts,filesep);
        FigureSaveDir = fullfile(ParentDir,Options.FigureSaveDirName);
        [ResultSaveDir,ResultSaveName,~] = fileparts(CurrentFilePath);
        ResultSaveName = strcat(ResultSaveName,'.mat');
    
        %% 3. perform the analysis on the individual files
        QST.Main.execAnalysis_HusimiQ_DTS_By2DModel(InputFilePath=CurrentFilePath,...
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