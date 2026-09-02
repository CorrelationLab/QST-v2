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
%   TimeStart                                       - start time of the analysed interval in seconds (default: 0)
%
%   TimeEnd                                         - end time of the analysed interval in seconds (default: 0)
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
%                                                     function (default: 'NLSQ-LAR')
%
% movie options:
%   Framerate                                       - number of movie frames per second (default: 10)
%
% result-saving options:
%   SaveDir                                         - directory in which the movie, figures, and optionally result data
%                                                     are saved (default: '')
%
%   SaveName                                        - base name used for saved movie and figure files (default: '')
%
%   SaveResultData                                  - logical value specifying whether the time-resolved analysis
%                                                     structure is saved to a MATLAB file (default: false)
%
%% Output:
%   This function does not return output arguments.
%
%   The function creates an uncompressed AVI movie named:
%
%   <SaveName>-1DHistogram.avi
%
%   The function additionally saves the following MATLAB figure files:
%
%   <SaveName>-N(t)-.fig                            - mean photon number as a function of time
%   <SaveName>-g2(0,t)-.fig                         - g^{(2)}(0) as a function of time
%   <SaveName>-nTherm(t)-nCoherent(t)-.fig          - thermal and coherent photon numbers as functions of time
%   <SaveName>-QuantumCoherence(t)-.fig             - quantum coherence as a function of time
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
%
%% Notes:
%   The quadratures are rescaled once using the complete input dataset before the selected time interval is divided
%   into analysis windows.
%
%   The analyses of individual time windows are executed in parallel using parfor. A Parallel Computing Toolbox may
%   therefore be required or beneficial.
%
%   If SaveResultData is true, SaveDir and SaveName are inferred from MatFilePath when SaveDir is empty and
%   MatFilePath is provided.

    arguments
        %Option for the quadrature selection
        Options.X1 = [];
        Options.X2 = [];
        Options.X1_EdgeIndices = [];
        Options.X2_EdgeIndices = [];
        Options.MatFilePath = '';
        Options.X1String = '';
        Options.X2String = '';
        % Option for the timeinterval
        Options.TimeStart = 0;
        Options.TimeEnd = 0;
        % Options for the moving average
        Options.UseMovingAverage = true;
        Options.nQuadratures = 10000;
        Options.nStepSize = 10000;
        % Options for the Husimi Q generation
        Options.Limits_R = 10
        Options.Resolution = 0.10;
        Options.ScaleChannels = true;
        % Options for the analysis
        Options.FitMethod = 'NLSQ-LAR';
        % Options for the movie generation
        Options.Framerate = 10;
        % Options for Result saving
        Options.SaveDir = '';
        Options.SaveName = '';
        % Options to save the movie data 
        Options.SaveResultData = false;
    end




    %% 0. set some default parameter
    % load data:
    if ~isequal(Options.X1String,'')
        Options.X1 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X1String));
        Options.X2 = QST.Variable_Managment.getVariableFromFilePath(Options.MatFilePath, string(Options.X2String));
    end

    % calculate the Times and Edge Indices directly in the function to ensure that the edgeindices work together with the rest of the code
    % (Yannik: Iam not completely sure if this is indeed necessary but the function crashes right now without. Iam not yet sure why it seemed to in 2D case)
    if Options.UseMovingAverage == true
        [~,~, Times1, X1_EdgeIndices] = QST.N_G2.computeTimeResolved_N_G2(Options.X1,AverageMethod='moving',AverageSize=Options.nQuadratures,StepSize=Options.nStepSize);
    else
        [~,~, Times1, X1_EdgeIndices] = QST.N_G2.computeTimeResolved_N_G2(Options.X1,AverageMethod='static',AverageSize=Options.nQuadratures);
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
                                                             plotData=false,...
                                                             SaveResults=false);

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
   % determine a fixed upper theshold for the video
   Max_YValue_Data = max(max(vertcat(AnalysisResult.HusimiQ_Radial)));
   Max_YValue_Theory = max(max(vertcat(AnalysisResult.HusimiQ_Radial_Theory)));
   YLim = [-0.05, max(Max_YValue_Data,Max_YValue_Theory)*1.05];
   

   %% 3. create the Movie
   % set figure properties
   axis tight manual
   set(gca,"NextPlot","replacechildren")

   % set movie properties
   if ~exist(Options.SaveDir,'dir')
       mkdir(Options.SaveDir)
   end
   Movie1D = VideoWriter(fullfile(Options.SaveDir,strcat(Options.SaveName,"-1DHistogram.avi")),"Uncompressed AVI");
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

   % save the result
   if Options.SaveResultData
        if isequal(Options.SaveDir,'') && ~isequal(Options.MatFilePath,'')
            [Options.SaveDir, Options.SaveName,~] = fileparts(Options.MatFilePath);
            Options.SaveName = strcat(Options.SaveName,'.mat');
        end
        SavePath = fullfile(Options.SaveDir,Options.SaveName);
        if exist(SavePath,"file")
            save(SavePath,"AnalysisResult",'-append');
        else
            save(SavePath,"AnalysisResult");
        end
   end

  Time_Sets = vertcat(AnalysisResult.Time);
  nCoherent_Sets = vertcat(AnalysisResult.nCoherent);
  nTherm_Sets = vertcat(AnalysisResult.nTherm);
  nMean_Sets = nCoherent_Sets + nTherm_Sets;
  g2_Sets = vertcat(AnalysisResult.G2);
  Coherence_Sets = vertcat(AnalysisResult.Coherence);


  %% create Extra Images
  %% N(t)
  clf
  plot(Time_Sets,nMean_Sets);
  xlim([Time_Sets(1),Time_Sets(end)])
  xlabel('t in s')
  ylabel('Mean Photonumber')
  title('N(t)')
  savefig(strcat(Options.SaveDir,filesep,Options.SaveName,'-N(t)-','.fig'))
%
  %% g^2(0,t)
  clf
  plot(Time_Sets,g2_Sets);
  xlim([Time_Sets(1),Time_Sets(end)])
  ylim([0,2])
  xlabel('t in s')
  ylabel('g^2(0,t)')
  title('g^2(0,t)')
  savefig(strcat(Options.SaveDir,filesep,Options.SaveName,'-g2(0,t)-','.fig'))
%
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
  savefig(strcat(Options.SaveDir,filesep,Options.SaveName,'-nTherm(t)-nCoherent(t)-','.fig'))
%
  %% Quantum Coherence
  plot(Time_Sets,Coherence_Sets);
  xlim([Time_Sets(1),Time_Sets(end)])
  xlabel('t in s')
  ylabel('Quantum Coherence')
  savefig(strcat(Options.SaveDir,filesep,Options.SaveName,'-QuantumCoherence(t)-','.fig'))
end