function [] = createTimeResolvedHusimiMovie_By1DModel(Options)
%% Description:
%   This function performs a time-resolved analysis of a phase-averaged, rotationally symmetric quantum state using
%   the radial, phase-integrated Husimi Q distribution and a displaced thermal state (DTS) model.
%
%   The function divides the dataset consisting of two orthgonal quadrature sets into consecutive time windows, generates a radial Husimi
%   Q distribution for every window, and fits the distribution with the phase-averaged DTS model. The resulting
%   time evolution is visualized as an uncompressed AVI movie.
%
%   Each movie frame contains the measured radial Husimi Q distribution, the corresponding fitted theory curve,
%   and the fitted thermal photon number, coherent photon number, g^{(2)}(0), and quantum coherence.
%
%   Additionally, the function creates and saves MATLAB figure files for the time-dependent mean photon number,
%   g^{(2)}(0), thermal and coherent photon numbers, and quantum coherence.
%
%   This method requires a phase-averaged state with rotational symmetry in phase space. A two-dimensional Husimi
%   Q analysis should be performed beforehand to verify this requirement.
%
%% Syntax:
%   createTimeResolvedHusimiMovie_By1DModel()
%   createTimeResolvedHusimiMovie_By1DModel(Options)
%
%% Input:
% name-value input options:
%   SaveResultData                                  - bool if data should be saved (default: true)
%
%   CreateMovie                                     - bool if a movie should be created (default: true)
%
%   CreateExtraImages                               - bool if the time evolution of the main quantities (N, g2, C) should be plotted
%                                                     in form of extra images
%
% quadrature-data options:
%   X1                                              - quadrature data associated with q; can be supplied directly
%                                                     (default: [])
%
%   X2                                              - quadrature data associated with p; can be supplied directly
%                                                     (default: [])
%
%   X1_EdgeIndices                                  - edge indices associated with X1 (default: [])
%
%   X2_EdgeIndices                                  - edge indices associated with X2 (default: [])
%
%   MatFilePath                                     - path to a MATLAB file from which X1 and X2 can be loaded
%                                                     (default: '')
%
%   X1String                                        - variable name of X1 in MatFilePath; if specified, X1 is loaded
%                                                     from MatFilePath (default: '')
%
%   X2String                                        - variable name of X2 in MatFilePath; if specified, X2 is loaded
%                                                     from MatFilePath (default: '')
%
% time-interval options:
%   StartTime                                       - start time of the analysed interval in seconds (default: 0)
%
%   EndTime                                         - end time of the analysed interval in seconds (default: 0)
%
% moving-average options:
%   UseMovingAverage                                - logical value specifying the time-window method:
%                                                     true:  use overlapping moving windows (default)
%                                                     false: use consecutive static windows
%
%   nQuadratures                                    - number of quadrature values contained in each time window
%                                                     (default: 10000)
%
%   nStepSize                                       - step size between consecutive moving windows in quadrature values;
%                                                     used only when UseMovingAverage is true (default: 10000)
%
% radial Husimi Q-distribution options:
%   Limits_R                                        - upper limit of the radial coordinate |alpha|;
%                                                     the lower limit is zero (default: 10)
%
%   Resolution                                      - bin width of the radial Husimi Q distribution (default: 0.10)
%
%   ScaleChannels                                   - logical value specifying whether the quadrature channels are
%                                                     rescaled before the time-resolved analysis (default: true)
%
% analysis options:
%   FitMethod                                       - fit-method identifier passed to the radial Husimi Q analysis
%                                                     function (default: 'LAR')
%
% movie options:
%   Framerate                                       - number of movie frames per second (default: 10)
%
% result-saving options:
%   ResultSaveDir                                   - directory in which the movie and additional figures
%                                                     are saved (default: ''). if default and if a Matfile is given, 
%                                                     both are saved in an extra 'Result' directory next to 'mat-data'
%
%   ResultDataSavePath                              - path where the result data should be saved (default: ''). if default 
%                                                     and if a matfile is given, the result data is saved as a struct in the matfile%
%% Output:
%   This function does not return output arguments.
%
%   The function creates an uncompressed AVI movie named:
%
%   1DHistogram.avi
%
%   The function additionally saves the following MATLAB figure files:
%
%   N(t)-.fig                                       - mean photon number as a function of time
%   g2(0,t)-.fig                                    - g^{(2)}(0) as a function of time
%   nTherm(t)-nCoherent(t)-.fig                     - thermal and coherent photon numbers as functions of time
%   QuantumCoherence(t)-.fig                        - quantum coherence as a function of time
%
%   If SaveResultData is true, the structure AnalysisResult is stored in the specified MATLAB result file. Each
%   structure entry corresponds to one analysed time window and contains:
%
%       Time                                        - time associated with the analysis window
%       EdgeIndices                                 - start and end quadrature indices of the analysis window
%       HusimiQ_Radial                              - measured radial Husimi Q distribution
%       Bins_R, Edges_R                             - radial histogram bin centers and bin edges
%       HusimiQ_Radial_Theory                       - fitted radial Husimi Q distribution
%       nTherm, nThermErr                           - thermal photon number and its uncertainty
%       nCoherent, nCoherentErr                     - coherent photon number and its uncertainty
%       nRatio, nRatioErr                           - photon-number ratio and its uncertainty
%       G2, G2Err                                   - g^{(2)}(0) and its uncertainty
%       Coherence, CoherenceErr                     - quantum coherence and its uncertainty
%       Options                                     - struct that includes the chosen analysis parameter
%
%% Notes:
%   The quadratures are rescaled once using the complete input dataset before the selected time interval is divided
%   into analysis windows.
%
%   The analyses of individual time windows are executed in parallel using parfor. A Parallel Computing Toolbox may
%   therefore be required or beneficial.

    arguments
        % General option what should be done
        Options.SaveResultData = true;
        Options.CreateMovie = true;
        Options.CreateExtraImages = true;
        % Option for the quadrature selection
        Options.X1 = [];
        Options.X2 = [];
        Options.X1_EdgeIndices = [];
        Options.X2_EdgeIndices = [];
        Options.MatFilePath = '';
        Options.X1String = '';
        Options.X2String = '';
        % Option for the timeinterval
        Options.StartTime = 0;
        Options.EndTime = 0;
        % Options for the moving average
        Options.UseMovingAverage = true;
        Options.nQuadratures = 10000;
        Options.nStepSize = 10000;
        % Options for the Husimi Q generation
        Options.Limits_R = 10
        Options.Resolution = 0.10;
        Options.ScaleChannels = true;
        % Options for the analysis
        Options.FitMethod = 'LAR';
        % Options for the movie generation
        Options.Framerate = 10;
        % Options for Result saving
        % Options for saving
        Options.ResultSaveDir = ''; %% the dir where the results images /movies are saved
        Options.ResultDataSavePath = '' %% the save path where the raw result data is stored
    end




    %% 0. set some default parameter
    % load data:
    if ~isequal(Options.X1String,'')
        Options.X1 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X1String));
        Options.X2 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X2String));
    end

    % calculate the Times and Edge Indices directly in the function to ensure that the edgeindices work together with the rest of the code
    if Options.UseMovingAverage == true
        [~,~, Times1, X1_EdgeIndices] = QST.N_G2.computeTimeResolved_N_G2(Options.X1,AverageMethod='moving',AverageSize=Options.nQuadratures,StepSize=Options.nStepSize);
    else
        [~,~, Times1, X1_EdgeIndices] = QST.N_G2.computeTimeResolved_N_G2(Options.X1,AverageMethod='static',AverageSize=Options.nQuadratures);
        Options.nStepSize = Options.nQuadratures;
    end





   %% 1. Select the overall data by Timeinterval

   % rescale the data best on biggest possible dataset
   [X1,X2] = QST.HusimiQ.Prepare.rescaleQuadsForHusimiQ(Options.X1,Options.X2,ScaleChannels=Options.ScaleChannels);
    
   % get the indices of the dataset inside the chosen time interval
   [Times_Select,~,~,X1_EdgeIndices_Select,~,~,~,~,~,~] = QST.QuadratureSelection.selectQuads_ByTimeInterval(Times1, Options.StartTime, Options.EndTime, EdgeIndices=X1_EdgeIndices);

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
   AnalysisResult(nSubSet) = struct('Time',[], ...
                                    'EdgeIndices',[],...
                                    'HusimiQ_Radial',[],...
                                    'Bins_R',[],...
                                    'Edges_R',[],...
                                    'nTherm',[],...
                                    'nThermErr',[],...
                                    'nCoherent',[],...
                                    'nCoherentErr',[],...
                                    'nRatio',[],...
                                    'nRatioErr',[],...
                                    'G2',[],...
                                    'G2Err',[],...
                                    'Coherence',[],...
                                    'CoherenceErr',[],...
                                    'HusimiQ_Radial_Theory',[]);
   
   parfor iSubSet = 1:nSubSet
       disp(iSubSet)
       disp(Times(iSubSet))
       Result = QST.Main.execAnalysis_HusimiQ_DTS_By1DModel(X1=X1_Set(:,iSubSet),...
                                                             X2=X2_Set(:,iSubSet),...
                                                             Limits_R=Options.Limits_R,...
                                                             Resolution=Options.Resolution,... 
                                                             FitMethod=Options.FitMethod,...
                                                             createFigure=false,...
                                                             SaveResultData=false);

       % Add all the results into the common structarray
       AnalysisResult(iSubSet).Time = Times(iSubSet);
       AnalysisResult(iSubSet).EdgeIndices = X1_EdgeIndices_Select(:,iSubSet);
       AnalysisResult(iSubSet).HusimiQ_Radial = Result.HusimiQ_Radial;
       AnalysisResult(iSubSet).Bins_R = Result.Bins_R;
       AnalysisResult(iSubSet).Edges_R = Result.Edges_R;
       AnalysisResult(iSubSet).nTherm = Result.nTherm;
       AnalysisResult(iSubSet).nThermErr = Result.nThermErr;
       AnalysisResult(iSubSet).nCoherent = Result.nCoherent;
       AnalysisResult(iSubSet).nCoherentErr = Result.nCoherentErr;
       AnalysisResult(iSubSet).nRatio = Result.nRatio;
       AnalysisResult(iSubSet).nRatioErr = Result.nRatioErr;
       AnalysisResult(iSubSet).G2 = Result.G2;
       AnalysisResult(iSubSet).G2Err = Result.G2Err;
       AnalysisResult(iSubSet).Coherence = Result.Coherence;
       AnalysisResult(iSubSet).CoherenceErr = Result.CoherenceErr;
       AnalysisResult(iSubSet).HusimiQ_Radial_Theory = Result.HusimiQ_Radial_Theory;
    end

    Time_Sets = vertcat(AnalysisResult.Time);
    nCoherent_Sets = vertcat(AnalysisResult.nCoherent);
    nTherm_Sets = vertcat(AnalysisResult.nTherm);
    nMean_Sets = nCoherent_Sets + nTherm_Sets;
    g2_Sets = vertcat(AnalysisResult.G2);
    Coherence_Sets = vertcat(AnalysisResult.Coherence);


    % save the result data
    if Options.SaveResultData && isempty(Options.ResultDataSavePath)
        if isempty(Options.MatFilePath)
            error("Submit a valid path in Options.ResultDataSavePath")
        end
        Options.ResultDataSavePath = Options.MatFilePath;

        % create the structure that will be saved
        OptionStruct = struct();
        OptionStruct.StartTime = Options.StartTime;
        OptionStruct.EndTime = Options.EndTime;
        OptionStruct.ScaleChannels = Options.ScaleChannels;
        OptionStruct.nStepSize = Options.nStepSize;
        OptionStruct.nQuadratures = Options.nQuadratures;
        OptionStruct.Limits_R = Options.Limits_R;
        OptionStruct.Resolution = Options.Resolution;
        OptionStruct.FitMethod = Options.FitMethod;
    
        ResultStruct = struct();
        ResultStruct.AnalysisResult = AnalysisResult;
        ResultStruct.Time = Time_Sets;
        ResultStruct.nCoherent = nCoherent_Sets;
        ResultStruct.nTherm = nTherm_Sets;
        ResultStruct.nMean = nMean_Sets;
        ResultStruct.G2 = g2_Sets;
        ResultStruct.Coherence = Coherence_Sets;
        ResultStruct.Options = OptionStruct;

        QST.Helper.saveStructElement(Options.ResultDataSavePath,'TRHusimi_1D',ResultStruct);
    end






   

    %% 3. create the Movie
    % set the file structure
    if Options.CreateMovie
        if isempty(Options.ResultSaveDir)
            if isempty(Options.MatFilePath)
                error("Submit a valid path")
            else
                [Dir,~,~] = fileparts(Options.MatFilePath);
                [Dir,~,~] = fileparts(Dir);
                Options.ResultSaveDir = strcat(Dir,filesep,"Results",filesep,"TRHusimiQ_1D",filesep,...
                                               "Ts",string(Options.StartTime),"_","Te",string(Options.EndTime),"__",...
                                               "nQuad",string(Options.nQuadratures),"__","nStep",string(Options.nStepSize),"__",...
                                               "GridRes",string(Options.Resolution));
            end
        end
        if ~exist(Options.ResultSaveDir,'dir')
            mkdir(Options.ResultSaveDir)
        end

        % determine a fixed upper theshold for the video
        Max_YValue_Data = max(max(vertcat(AnalysisResult.HusimiQ_Radial)));
        Max_YValue_Theory = max(max(vertcat(AnalysisResult.HusimiQ_Radial_Theory)));
        YLim = [-0.05, max(Max_YValue_Data,Max_YValue_Theory)*1.05];

        % set figure properties
        axis tight manual
        set(gca,"NextPlot","replacechildren")
        
        Movie1D = VideoWriter(fullfile(Options.ResultSaveDir,"1DHistogram.avi"),"Uncompressed AVI");
        Movie1D.FrameRate = Options.Framerate;
        
        
        % create the plots
        Frames = cell([nSubSet,1]);
        Bins_R = AnalysisResult(1).Bins_R;
        parfor i = 1:nSubSet
            clf
            cla
            plot(Bins_R, AnalysisResult(i).HusimiQ_Radial);
            hold on
            plot(Bins_R, AnalysisResult(i).HusimiQ_Radial_Theory,LineStyle="-");
            ylim(YLim);
            legend("Data", "Fit");
            title("Time: " + string(AnalysisResult(i).Time) + ...
                  " N Coherent: " + string(AnalysisResult(i).nCoherent) + ...
                  "   N Thermal: " + string(AnalysisResult(i).nTherm) + ...
                  "   g2: " + string(AnalysisResult(i).G2) + ...
                  "   C: " + string(AnalysisResult(i).Coherence))
            Frames{i} = getframe(gcf);
            hold off
        end
        
        % add the finished plots to a movie
        open(Movie1D)
        for i = 1:nSubSet
            Movie1D.writeVideo(Frames{i});
        end
        close(Movie1D)
    end

    %% create Extra Images
    if Options.CreateExtraImages
        %% ensure that the path structure exists
        if isempty(Options.ResultSaveDir)
            if isempty(Options.MatFilePath)
                error("Submit a valid path")
            else
                [Dir,~,~] = fileparts(Options.MatFilePath);
                [Dir,~,~] = fileparts(Dir);
                Options.ResultSaveDir = strcat(Dir,filesep,Results,filesep,"TRHusimiQ_1D",filesep,...
                                               "Ts",string(Option.StartTime),"_","Te",string(Option.EndTime),"__",...
                                               "nQuad",string(Options.nQuadratures),"__","nStep",string(Options.nStepSize),"__",...
                                               "nRes",string(Options.nResolution));
            end
        end
        if ~exist(Options.ResultSaveDir,'dir')
            mkdir(Options.ResultSaveDir)
        end

        %% N(t)
        clf
        plot(Time_Sets,nMean_Sets);
        xlim([Time_Sets(1),Time_Sets(end)]);
        xlabel('t in s');
        ylabel('Mean Photonumber');
        title('N(t)');
        savefig(strcat(Options.ResultSaveDir,filesep,'N(t)','.fig'));
       
        %% g^2(0,t)
        clf
        plot(Time_Sets,g2_Sets);
        xlim([Time_Sets(1),Time_Sets(end)]);
        ylim([0,2]);
        xlabel('t in s');
        ylabel('g^2(0,t)');
        title('g^2(0,t)');
        savefig(strcat(Options.ResultSaveDir,filesep,'g2(0,t)','.fig'));
       
        %% nTherm und nCoherent
        clf
        plot(Time_Sets,nCoherent_Sets);
        hold on
        plot(Time_Sets,nTherm_Sets);
        hold off
        xlim([Time_Sets(1),Time_Sets(end)]);
        xlabel('t in s');
        ylabel('Phtono number');
        legend('nCoherent','nThermal');
        title('Thermal and Coherent Photonnumber');
        savefig(strcat(Options.ResultSaveDir,filesep,'nTherm(t)-nCoherent(t)','.fig'));
      
        %% Quantum Coherence
        plot(Time_Sets,Coherence_Sets);
        xlim([Time_Sets(1),Time_Sets(end)]);
        xlabel('t in s');
        ylabel('Quantum Coherence');
        savefig(strcat(Options.ResultSaveDir,filesep,'-QuantumCoherence(t)','.fig'));
    end
end