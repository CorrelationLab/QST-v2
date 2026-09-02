function [] = createTimeResolvedHusimiMovie_By2DModel(Options)
%% Description:
%   This function creates a time-resolved movie of the two-dimensional Husimi Q distribution from a two channel dataset.
%   The selected time interval is divided into consecutive or overlapping subsets, and a Husimi Q
%   distribution is generated and analysed for every subset using a phase-averaged displaced thermal state model.
%
%   The function creates an uncompressed AVI movie showing the time evolution of the two-dimensional Husimi
%   Q distribution in the q-p phase space. It additionally creates MATLAB figure files showing the
%   time-dependent mean photon number, g^{(2)}(0), thermal and coherent photon numbers, and quantum coherence.
%
%   Quadrature data, time vectors, and edge indices can either be supplied directly or loaded from a MATLAB file.
%   When data are loaded from a file, default names for time vectors and edge indices can be generated from the
%   specified quadrature variable names.
%
%% Syntax:
%   createTimeResolvedHusimiMovie_By2DModel()
%   createTimeResolvedHusimiMovie_By2DModel(Options)
%
%% Input:
% name-value input options:
%
% quadrature-data options:
%   X1                                              - quadrature data associated with q; can be supplied directly
%                                                     (default: [])
%
%   X2                                              - quadrature data associated with p; can be supplied directly
%                                                     (default: [])
%
%   X1_EdgeIndices                                  - start and end indices of time-resolved subsets associated with X1
%                                                     (default: [])
%
%   X2_EdgeIndices                                  - start and end indices of time-resolved subsets associated with X2
%                                                     (default: [])
%
%   MatFilePath                                     - path to the MATLAB file containing quadrature data and associated
%                                                     time-resolved analysis results (default: '')
%
%   X1String                                        - variable name of X1 in MatFilePath; specifying this option causes
%                                                     X1, X2, time vectors, and edge indices to be loaded from file
%                                                     (default: '')
%
%   X2String                                        - variable name of X2 in MatFilePath (default: '')
%
%   X1_EdgeIndicesString                            - variable name of X1 edge indices in MatFilePath; if empty, a
%                                                     default name based on X1String is used (default: [])
%
%   X2_EdgeIndicesString                            - variable name of X2 edge indices in MatFilePath; if empty, a
%                                                     default name based on X2String is used (default: [])
%
% time-interval options:
%   TimeStart                                       - start time of the analysed interval in seconds (default: 0)
%
%   TimeEnd                                         - end time of the analysed interval in seconds (default: 0)
%
%   Times1                                          - time vector associated with X1; required if X1 is supplied directly
%                                                     (default: [])
%
%   Times2                                          - time vector associated with X2; required if X2 is supplied directly
%                                                     (default: [])
%
%   Times1String                                    - variable name of Times1 in MatFilePath; if empty, a default name
%                                                     based on X1String is used (default: '')
%
%   Times2String                                    - variable name of Times2 in MatFilePath; if empty, a default name
%                                                     based on X2String is used (default: '')
%
% time-window options:
%   UseMovingAverage                                - logical value intended to select moving or static averaging windows;
%                                                     currently declared but not used within this function (default: true)
%
%   nStepSize                                       - step size between consecutive analysis windows in quadrature values
%                                                     (default: 10000)
%
%   nQuadratures                                    - number of quadrature values in each analysis window
%                                                     (default: 30000)
%
% Husimi Q-distribution options:
%   Limits_Q                                        - lower and upper limits of the q-quadrature axis
%                                                     (default: [-10, 10])
%
%   Limits_P                                        - lower and upper limits of the p-quadrature axis
%                                                     (default: [-10, 10])
%
%   Resolution                                      - bin width of the q- and p-quadrature axes (default: 0.1)
%
%   ScaleChannels                                   - logical value specifying whether the quadrature channels are
%                                                     rescaled before the analysis (default: true)
%
% PDTS-analysis options:
%   FitMethod                                       - fitting method passed to execAnalysis_HusimiQ_DTS
%                                                     (default: 'NLSQ-LAR')
%
%   MonteCarloError                                 - logical value specifying whether Monte Carlo uncertainty
%                                                     estimation is performed (default: false)
%
%   nMonteCarloIterations                           - number of Monte Carlo iterations used for uncertainty estimation
%                                                     (default: 1000)
%
% movie options:
%   Framerate                                       - number of movie frames per second (default: 10)
%
% movie-saving options:
%   MovieSaveDir                                    - directory intended for saving the movie (default: '');
%
%   MovieSaveName                                   - base name intended for the movie file (default: '');
%
% result-saving options:
%   SaveMovieData                                   - logical value specifying whether the AnalysisResult structure is
%                                                     saved to a MATLAB file (default: false)
%
%   MovieDataSaveDir                                - directory intended for saving AnalysisResult (default: '');
%
%   MovieDataSaveName                               - filename intended for saving AnalysisResult (default: '');
%
%% Output:
%   This function does not return output arguments.
%
%   It creates an uncompressed AVI movie containing the two-dimensional Husimi Q distributions of the analysed
%   time windows. Each movie frame shows the Husimi Q distribution in the q-p plane at one time point.
%
%   It additionally creates MATLAB figure files for the time evolution of:
%
%   N(t)                                        - mean photon number
%   g^{(2)}(0,t)                                - second-order correlation function
%   n_Coherent(t) and n_Thermal(t)              - coherent and thermal photon numbers
%   C(t)                                        - quantum coherence
%
%   If SaveMovieData is true, the function saves the AnalysisResult. Each structure entry contains the calculated Husimi
%   Q distribution, bin information, fitted photon numbers, correlation data, coherence, and fit-error data.
%
%% Notes:
%   The data are rescaled using the complete input dataset before the selected time interval is split into analysis
%   windows.
%
%   Individual time-window analyses and movie-frame generation are executed using parfor. The Parallel Computing
%   Toolbox may therefore be required or beneficial.
%



    arguments
        %Option for the quadrature selection
        Options.X1 = [];
        Options.X2 = [];
        Options.X1_EdgeIndices = [];
        Options.X2_EdgeIndices = [];
        Options.MatFilePath = '';
        Options.X1String = '';
        Options.X2String = '';
        Options.X1_EdgeIndicesString = [];
        Options.X2_EdgeIndicesString = [];
        % Option for the timeinterval
        Options.TimeStart = 0;
        Options.TimeEnd = 0;
        Options.Times1 = [];
        Options.Times2 = [];
        Options.Times1String = '';
        Options.Times2String = '';
        % Options for the moving average
        Options.UseMovingAverage = true;
        Options.nStepSize = 10000;
        % Options for the Husimi Q generation
        Options.nQuadratures = 30000;
        Options.Limits_Q = [-10,10]
        Options.Limits_P = [-10,10]
        Options.Resolution = 0.1;
        Options.ScaleChannels = true;
        % Options for the analysis
        Options.FitMethod = 'NLSQ-LAR';
        Options.MonteCarloError = false;
        Options.nMonteCarloIterations = 1000;
        % Options for the movie generation
        Options.Framerate = 10;
        % Options for the movie saving
        Options.MovieSaveDir = '';
        Options.MovieSaveName = '';
        % Options to save the movie data 
        Options.SaveMovieData = false;
        Options.MovieDataSaveDir = '';
        Options.MovieDataSaveName = '';

    end


    %% 0. set some default parameter
    % set default values:
    if ~isempty(Options.X1) % Data is given by workspace
        if isempty(Options.Times1)
            error('no Times are given, default values are only possible when using the file mode')
        end
        if isempty(Options.X1_EdgeIndices)
            error('no EdgeIndices are given, default values are only possible when using the file mode')
        end
    elseif ~isempty(Options.X1String) % Data is given per file
        if isequal(Options.Times1String,'')
            % for the default names the Quadratures have to have the form 'X Channelnumber'
            Options.Times1String = strcat("Results_N_G2_TimeResolved.Channel",Options.X1String(2),".Times");
            Options.Times2String = strcat("Results_N_G2_TimeResolved.Channel",Options.X2String(2),".Times");
        end
        if isequal(Options.X1_EdgeIndicesString,'')
            % for the default names the Quadratures have to have the form 'X Channelnumber'
            Options.X1_EdgeIndicesString = strcat("Results_N_G2_TimeResolved.Channel",Options.X1String(2),".EdgeIndices");
            Options.X2_EdgeIndicesString = strcat("Results_N_G2_TimeResolved.Channel",Options.X2String(2),".EdgeIndices");
        end
    end
    % if variables are given by strings load the variables (for now this is easier and just want it to work)
    if ~isequal(Options.X1String,'')
        Options.X1 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X1String));
        Options.X2 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X2String));
        Options.X1_EdgeIndices = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X1_EdgeIndicesString));
        Options.X2_EdgeIndices = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X2_EdgeIndicesString));
        Options.Times1 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.Times1String));
        Options.Times2 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.Times2String));
    end





    %% 1. Select the overall data by Timeinterval
    
    % rescale the data best on biggest possible dataset
    [X1,X2] = QST.HusimiQ.Prepare.rescaleQuadsForHusimiQ(Options.X1,Options.X2,ScaleChannels=Options.ScaleChannels);
    
    % get the indices of the dataset inside the chosen time interval
    [Times_Select,~,~,X1_EdgeIndices_Select,~,~,~,~,~,~] = QST.QuadratureSelection.selectQuads_ByTimeInterval(Options.TimeStart,Options.TimeEnd,Times1,[],[],X1_EdgeIndices,[]);
    
    % get the number of subsets % Diese formel scheint falsch zu sein
    nSubSet = size(X1_EdgeIndices_Select,2);
    
    % define the datasets , this can get bigger in RAM but it hopefully is faster
    X1_Set = zeros(Options.nQuadratures,nSubSet);
    X2_Set = zeros(Options.nQuadratures,nSubSet);
    for iSubSet = 1: nSubSet
        X1_Set(:,iSubSet) = X1(X1_EdgeIndices_Select(1,iSubSet):X1_EdgeIndices_Select(2,iSubSet));
        X2_Set(:,iSubSet) = X2(X1_EdgeIndices_Select(1,iSubSet):X1_EdgeIndices_Select(2,iSubSet));
    end
    Times = Times_Select;

    %% 2. execute the analysis
    AnalysisResult(nSubSet) = struct('HusimiQ',[],'Bins_Q',[],'Bins_P',[],'Edges_Q',[],'Edges_P',[],...
                                     'nTherm',[],'nThermErr',[],'nCoherent',[],'nCoherentErr',[],'nMean',[],'nMeanErr',[],'nRatio',[],'nRatioErr',[],...
                                     'G2',[],'G2Err',[],'Coherence',[],'CoherenceErr',[],'PoissonError',[],'PoissonErrorCut',[],'HusimiCut',[],'HusimiCutTheory',[]);
    parfor iSubSet = 1:nSubSet
        disp(iSubSet)
        disp(Times(iSubSet))
        Result = QST.Main.execAnalysis_HusimiQ_DTS_By2DModel(X1=X1_Set(:,iSubSet),...
                                                             X2=X2_Set(:,iSubSet),...
                                                             Limits_Q=Options.Limits_Q,...
                                                             Limits_P=Options.Limits_P,...
                                                             Resolution=Options.Resolution,...
                                                             plot1D=false,...
                                                             plot2D=false,...
                                                             FitMethod=Options.FitMethod,...
                                                             MonteCarloError=Options.MonteCarloError,...
                                                             nMonteCarloIterations=Options.nMonteCarloIterations, ...
                                                             SaveResults=false);
   
        % Add all the results into the common structarray
        AnalysisResult(iSubSet).Time = Times(iSubSet);
        AnalysisResult(iSubSet).HusimiQ = Result.HusimiQ;
        AnalysisResult(iSubSet).Bins_Q = Result.Bins_Q;
        AnalysisResult(iSubSet).Bins_P = Result.Bins_P;
        AnalysisResult(iSubSet).Edges_Q = Result.Edges_Q;
        AnalysisResult(iSubSet).nTherm = Result.nTherm;
        AnalysisResult(iSubSet).nThermErr = Result.nThermErr;
        AnalysisResult(iSubSet).nCoherent = Result.nCoherent;
        AnalysisResult(iSubSet).nCoherentErr = Result.nCoherentErr;
        AnalysisResult(iSubSet).nMean = Result.nMean;
        AnalysisResult(iSubSet).nMeanErr = Result.nMeanErr;
        AnalysisResult(iSubSet).nRatio = Result.nRatio;
        AnalysisResult(iSubSet).nRatioErr = Result.nRatioErr;
        AnalysisResult(iSubSet).G2 = Result.G2;
        AnalysisResult(iSubSet).G2Err = Result.G2Err;
        AnalysisResult(iSubSet).Coherence = Result.Coherence;
        AnalysisResult(iSubSet).CoherenceErr = Result.CoherenceErr;
        AnalysisResult(iSubSet).PoissonError = Result.PoissonError;
        AnalysisResult(iSubSet).PoissonErrorCut = Result.PoissonErrorCut;
        AnalysisResult(iSubSet).HusimiCut = Result.HusimiCut;
        AnalysisResult(iSubSet).HusimiCutTheory = Result.HusimiCutTheory;
    end

    Time_Sets = vertcat(AnalysisResult.Time);
    nCoherent_Sets = vertcat(AnalysisResult.nCoherent);
    nTherm_Sets = vertcat(AnalysisResult.nTherm);
    nMean_Sets = nCoherent_Sets + nTherm_Sets;
    g2_Sets = vertcat(AnalysisResult.G2);
    Coherence_Sets = vertcat(AnalysisResult.Coherence);


   
    %% 3. create the Movie
    % set figure properties
    axis tight manual
    set(gca,"NextPlot","replacechildren")
    
    % set movie properties
    if ~exist(Options.MovieSaveDir,'dir')
        mkdir(Options.MovieSaveDir)
    end
    
    % Create the plots
    Movie2D = VideoWriter(fullfile(Options.MovieSaveDir,strcat(Options.MovieSaveName,"-2DHistogram.avi")),"Uncompressed AVI");
    Movie2D.FrameRate = Options.Framerate;
    Frames = cell([nSubSet,1]);
    parfor iSubSet = 1:nSubSet
        clf
        cla
        pcolor(AnalysisResult(iSubSet).Bins_Q, AnalysisResult(iSubSet).Bins_P, AnalysisResult(iSubSet).HusimiQ)
        shading 'flat';
        axis on;
        axis equal;
        colormap hot;
        xlabel('q')
        ylabel('p')
        title(strcat('t = ',string(Time_Sets(iSubSet))))
        Frames{iSubSet} = getframe(gcf);
        hold off
    end
    
    % add the finished plots to a movie
    open(Movie2D)
    for iSubSet = 1:nSubSet
        Movie2D.writeVideo(Frames{iSubSet});
    end
    close(Movie2D)

    % save the results
    if Options.SaveResultData
         if isequal(Options.MovieDataSaveDir,'') && ~isequal(Options.MatFilePath,'')
             [Options.MovieDataSaveDir, Options.MovieDataSaveName,~] = fileparts(Options.MatFilePath);
             Options.MovieDataSaveName = strcat(Options.MovieDataSaveName,'.mat');
         end
         SavePath = fullfile(Options.MovieDataSaveDir,Options.MovieDataSaveName);
         if exist(SavePath,"file")
             save(SavePath,"AnalysisResult",'-append');
         else
             save(SavePath,"AnalysisResult");
         end
    end

    %% create Extra Images
    %% N(t)
    clf
    plot(Time_Sets,nMean_Sets);
    xlim([Time_Sets(1),Time_Sets(end)])
    xlabel('t in s')
    ylabel('Mean Photonumber')
    title('N(t)')
    savefig(strcat(Options.MovieSaveDir,filesep,Options.MovieSaveName,'-N(t)-','.fig'))
    
    %% g^2(0,t)
    clf
    plot(Time_Sets,g2_Sets);
    xlim([Time_Sets(1),Time_Sets(end)])
    ylim([0,2])
    xlabel('t in s')
    ylabel('g^2(0,t)')
    title('g^2(0,t)')
    savefig(strcat(Options.MovieSaveDir,filesep,Options.MovieSaveName,'-g2(0,t)-','.fig'))
    
    %% nTherm und nCoherent
    clf
    plot(Time_Sets,nCoherent_Sets);
    hold on
    plot(Time_Sets,nTherm_Sets);
    hold off
    xlim([Time_Sets(1),Time_Sets(end)])
    xlabel('t in s')
    ylabel('Phtono number')
    legend('nCoherent','nThermal')
    title('Thermal and Coherent Photonnumber')
    savefig(strcat(Options.MovieSaveDir,filesep,Options.MovieSaveName,'-nTherm(t)-nCoherent(t)-','.fig'))
    
    %% Quantum Coherence
    plot(Time_Sets,Coherence_Sets);
    xlim([Time_Sets(1),Time_Sets(end)])
    xlabel('t in s')
    ylabel('Quantum Coherence')
    savefig(strcat(Options.MovieSaveDir,filesep,Options.MovieSaveName,'-QuantumCoherence(t)-','.fig'))
end