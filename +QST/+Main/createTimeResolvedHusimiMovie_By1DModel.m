function [] = createTimeResolvedHusimiMovie_By1DModel(Options)
% This function analyzes the a states Husimi-Q distribution based on the displaced thermal model using the phase integrated husimi Q distribution. 
% Requirement for this method is that the state is recorded phase averaged and the 2D distribution is rotation symmetrical

% the function returns an video in uncompressed .avi format featuring the time evolution of the angle integrated phase averaged husimi Q distribution
% found from experimental data and the applied fit using the displaced thermal state model. The investigated time interval can be given freely,
% it must not contains temporal breaks or beforehand quadrature filtering.
% Additionally the temporal resolved quantities N Total, Ncoherent, N thermal, g2 and Quantum coherence are displayed against the time in extra figures

% the function allows to choose which and where the results should be saved.
% The function is complementary to the function 'QST.Main.createTimeResolvedHusimiMovie_By2DModel' as this function does not create the full
% 2D Husimi Q distribution and concentrates on estimating the optimal thermal and coherent contributions with a minimal of quadrature data
% The Results are saved in the same sub dir

% Version
% 1.0 : initial implementation

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
        Options.Times1 = [];
        Options.Times2 = [];
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
        [~,~, Times1, X1_EdgeIndices] = QST.N_G2.calcTimeResolved_N_G2(Options.X1,AverageMethod='moving',AverageSize=Options.nQuadratures,StepSize=Options.nStepSize);
    else
        [~,~, Times1, X1_EdgeIndices] = QST.N_G2.calcTimeResolved_N_G2(Options.X1,AverageMethod='static',AverageSize=Options.nQuadratures);
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
       title("N Coherent: " + string(AnalysisResult(i).nCoherent) + ...
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


  %% Extra Images
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
  %%
  clf
  plot(Time_Sets,Coherence_Sets);
  xlim([Time_Sets(1),Time_Sets(end)])
  xlabel('t in s')
  ylabel('Quantum Coherence')
  savefig(strcat(Options.SaveDir,filesep,Options.SaveName,'-QuantumCoherence(t)-','.fig'))
%

end




  % Set up Colormap
  %MaxProb = max(cellfun(@(y) max(y(:)),DataSets));
  %MinProb = 0;
  %clim manual;
  %clim([MinProb,MaxProb])
  %colorbar
  %set(gca, 'nextplot', 'replacechildren');
%
  %
%
  %%% 3. Set up 2D Movie

%
  %open(Movie2D);
  %Fig = figure;
  %Fig.Position(1:2) = [100,100];
  %Fig.Position(3:4) = [600,800];
%
  %%% 4. create 2D Movie
  %for i = 1:nSetsOfData
  %    % Expanded version of the plots
  %    tiledlayout('flow',TileSpacing="compact");
  %    nexttile([2,2])
  %    pcolor(Bins1,Bins2,DataSets{i})
  %    shading 'flat';
  %    axis on;
  %    axis equal;
  %    colormap hot;
  %    xlabel('q')
  %    ylabel('p')
  %    title(strcat('t = ',string(Time_Sets(i)),' s', ' N1:',string(N1_Sets(i)),' N2:',string(N1_Sets(i))))
  %    
  %    nexttile([2,2])
  %    shadedErrorBar(Bins1,HusimiCut_Sets{i},poissonErrorCut_Sets{i})
  %    hold on 
  %    plot(Bins1,HusimiCutTheory_Sets{i})
  %    hold on
  %    plot(HusimiCut_DataForFit_Sets{i},HusimiCut_DataForFit_H_Sets{i})
  %    hold off
  %    xlabel('q')
  %    ylabel('ProbQ((q,p = 0))');
%
  %    nexttile([1,4]);
  %    plot(Time_Sets(1:i),meanN_Sets(1:i));
  %    xlim([Time_Sets(1),Time_Sets(end)])
  %    ylim([0,max(meanN_Sets)+1])
  %    xlabel('t in s')
  %    ylabel('Mean Photonumber')
%
  %    nexttile([1,4]);
  %    plot(Time_Sets(1:i),nCoherent_Sets(1:i));
  %    %errorbar(Time_Sets(1:i),nCoherent_Sets(1:i),nCoherentErr_Sets(1:i));
  %    hold on
  %    plot(Time_Sets(1:i),nTherm_Sets(1:i));
  %    %errorbar(Time_Sets(1:i),nTherm_Sets(1:i),nThermErr_Sets(1:i));
  %    hold off
  %    xlim([Time_Sets(1),Time_Sets(end)])
  %    ylim([0,max(max(nCoherent_Sets+nCoherentErr_Sets),max(nTherm_Sets+nThermErr_Sets))+0.2])
  %    xlabel('t in s')
  %    ylabel('Phtono number')
  %    legend('nCoherent','nThermal')
%
  %    nexttile([1,4]);
  %    plot(Time_Sets(1:i),g2_Sets(1:i));
  %    xlim([Time_Sets(1),Time_Sets(end)])
  %    ylim([0,2])
  %    xlabel('t in s')
  %    ylabel('g^2(0,t)')
%
  %    nexttile([1,4]);
  %    plot(Time_Sets(1:i),Coherence_Sets(1:i));
  %    %errorbar(Time_Sets(1:i),Coherence_Sets(1:i),CoherenceErr_Sets(1:i));
  %    xlim([Time_Sets(1),Time_Sets(end)])
  %    ylim([0,max(Coherence_Sets+CoherenceErr_Sets)+0.1])
  %    xlabel('t in s')
  %    ylabel('Quantum Coherence')
%
%
%
  %    Frame = getframe(gcf);
  %    writeVideo(Movie2D,Frame)
%
%
  %end
  %close(Movie2D);
%
