function [] = createTimeResolvedHusimiMovie(Options)
% function that creates a movie based on a timeresolved Husimi Q distribution
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

   [~,~,~,X1_EdgeIndices_Select,X1_Indices_Select,~,~,~,~,~] = QST.QuadratureSelection.selectQuads_ByTimeInterval(Options.TimeStart,Options.TimeEnd,Options.Times1,[],[],Options.X1_EdgeIndices,[]);
   [~,~,~,~,X2_Indices_Select,~,~,~,~,~] = QST.QuadratureSelection.selectQuads_ByTimeInterval(Options.TimeStart,Options.TimeEnd,Options.Times2,[],[],Options.X2_EdgeIndices,[]);
   X_Indices_Select = intersect(X1_Indices_Select,X2_Indices_Select);
   



   % get the number of subsets
   nSubSet = floor((length(X_Indices_Select)-Options.nQuadratures+Options.nStepSize)/Options.nStepSize);

   % define the datasets , this can get bigger in RAM but it hopefully is faster
   X1_Set = zeros(Options.nQuadratures,nSubSet);
   X2_Set = zeros(Options.nQuadratures,nSubSet);
   for iSubSet = 1: nSubSet
       X1_Set(:,iSubSet) = X1(X_Indices_Select((iSubSet-1)*Options.nStepSize+1:(iSubSet-1)*Options.nStepSize+Options.nQuadratures));
       X2_Set(:,iSubSet) = X2(X_Indices_Select((iSubSet-1)*Options.nStepSize+1:(iSubSet-1)*Options.nStepSize+Options.nQuadratures));
   end
   Times = (X1_Indices_Select(1)-1+(1:length(X1_EdgeIndices_Select))*Options.nStepSize+0.5*Options.nQuadratures)/(75.3864*10^6);

   %% 2. execute the analysis
   AnalysisResult(nSubSet) = struct('HusimiQ',[],'Bins_Q',[],'Bins_P',[],'Edges_Q',[],'Edges_P',[],...
                                    'nTherm',[],'nThermErr',[],'nCoherent',[],'nCoherentErr',[],'nMean',[],'nMeanErr',[],'nRatio',[],'nRatioErr',[],...
                                    'G2',[],'G2Err',[],'Coherence',[],'CoherenceErr',[],'PoissonError',[],'PoissonErrorCut',[],'HusimiCut',[],'HusimiCutTheory',[]);
   parfor iSubSet = 1:nSubSet
       disp(iSubSet)
       disp(Times(iSubSet))
       Result = QST.Main.execAnalysis_HusimiQ_DTS(X1=X1_Set(:,iSubSet),...
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
   

   %% 3. create the Movie
   % set figure properties
   axis tight manual
   set(gca,"NextPlot","replacechildren")

   % set movie properties
   Movie2D = VideoWriter(fullfile(Options.MovieSaveDir,strcat(Options.MovieSaveName,".avi")),"Uncompressed AVI");
   Movie2D.FrameRate = Options.Framerate;


   % create the plots
   Frames = cell([nSubSet,1]);
   Bins_Q = AnalysisResult(1).Bins_Q;
   Bins_P = AnalysisResult(1).Bins_P;
   parfor i = 1:nSubSet
       pcolor(Bins_Q, Bins_P, AnalysisResult(i).HusimiQ);
       shading 'flat';
       axis on;
       axis equal;
       colormap hot;
       Frames{i} = getframe(gcf);
   end

   % add the finished plots to a movie
   open(Movie2D)
   for i = 1:nSubSet
       Movie2D.writeVideo(Frames{i});
   end
   close(Movie2D)
   if Options.SaveMovieData
        if isequal(Options.MovieDataSaveDir,'') && ~isequal(Options.MatFilePath,'')
            [Options.MovieDataSaveDir, Options.MovieDataSaveName,~] = fileparts(Options.MatFilePath);
            Options.MovieDataSaveName = strcat(Options.MovieDataSaveName,'.mat');
        end
        SavePath = fullfile(Options.MovieDataSaveDir,Options.MovieDataSaveName);
        save(SavePath,"AnalysisResult",'-append');
   end
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
  %% Extra Images
  %% N(t)
  %clf
  %plot(Time_Sets,meanN_Sets);
  %xlim([Time_Sets(1),Time_Sets(end)])
  %xlabel('t in s')
  %ylabel('Mean Photonumber')
  %title('N(t)')
  %savefig(strcat(Options.SavePath,filesep,Options.Filename,'-N(t)-','.fig'))
%
  %% g^2(0,t)
  %clf
  %plot(Time_Sets,g2_Sets);
  %xlim([Time_Sets(1),Time_Sets(end)])
  %ylim([0,2])
  %xlabel('t in s')
  %ylabel('g^2(0,t)')
  %title('g^2(0,t)')
  %savefig(strcat(Options.SavePath,filesep,Options.Filename,'-g2(0,t)-','.fig'))
%
  %% nTherm und nCoherent
  %clf
  %plot(Time_Sets,nCoherent_Sets);
  %hold on
  %plot(Time_Sets,nTherm_Sets);
  %hold off
  %xlim([Time_Sets(1),Time_Sets(end)])
  %xlabel('t in s')
  %ylabel('Phtono number')
  %legend('nCoherent','nThermal')
  %title('Thermal and Coherent Photonnumber')
  %savefig(strcat(Options.SavePath,filesep,Options.Filename,'-nTherm(t)-nCoherent(t)-','.fig'))
%
  %%
  %clf
  %plot(Time_Sets,Coherence_Sets);
  %xlim([Time_Sets(1),Time_Sets(end)])
  %xlabel('t in s')
  %ylabel('Quantum Coherence')
  %savefig(strcat(Options.SavePath,filesep,Options.Filename,'-QuantumCoherence(t)-','.fig'))
%