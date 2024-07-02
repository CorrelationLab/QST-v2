function [] = createTimeResolvedHusimiMovie_MovingAverage(X1,X2,Times_1,Times_2,EdgeIndices_1,EdgeIndices_2,TimeStart,TimeEnd,nQuadratures,nStepSize,nResolution,nLimits,Options)
    arguments
        X1;
        X2;
        Times_1;
        Times_2;
        EdgeIndices_1;
        EdgeIndices_2;
        TimeStart;
        TimeEnd;
        nQuadratures;
        nStepSize;
        nResolution = 0.1;
        nLimits = [-8,8]
        Options.SavePath = '';
        Options.Filename = '';
        Options.Framerate = 10;
    end

   %% 0. prepare Data for HusimiQ
   [X1,X2] = QST.Plotting.prepareDataForHusimiQ(X1,X2,ScaleChannels=true);

   %% 1. Select Data by Time
   [Time_1_Select,~,~,EdgeIndices_1_Select,X1_Indices_Select,~,~,~,~,~] = QST.Data_Managment.Single.selectQuadraturesFromTime(TimeStart,TimeEnd,Times_1,[],[],EdgeIndices_1,[]);
   [Time_2_Select,~,~,EdgeIndices_2_Select,X2_Indices_Select,~,~,~,~,~] = QST.Data_Managment.Single.selectQuadraturesFromTime(TimeStart,TimeEnd,Times_2,[],[],EdgeIndices_2,[]);
   X_Indices_select = intersect(X1_Indices_Select,X2_Indices_Select);



   %% 2. Create Histogram Data Sets
   nSetsOfData = floor((length(X_Indices_select)-nQuadratures+nStepSize)/nStepSize);
   DataSets = cell(nSetsOfData,1);
   N1_Sets = zeros(nSetsOfData,1);
   N2_Sets = zeros(nSetsOfData,1);
   Time_Sets = zeros(nSetsOfData,1);
   
   % Sets for the Different Results
   nTherm_Sets = zeros(nSetsOfData,1);
   nThermErr_Sets = zeros(nSetsOfData,1);
   nCoherent_Sets = zeros(nSetsOfData,1);
   nCoherentErr_Sets = zeros(nSetsOfData,1);
   meanN_Sets = zeros(nSetsOfData,1);
   g2_Sets = zeros(nSetsOfData,1);
   Coherence_Sets = zeros(nSetsOfData,1);
   CoherenceErr_Sets = zeros(nSetsOfData,1);
   poissonErrorCut_Sets = cell(nSetsOfData,1);
   HusimiCut_Sets = cell(nSetsOfData,1);
   HusimiCutTheory_Sets = cell(nSetsOfData,1);
   HusimiCut_DataForFit_Sets = cell(nSetsOfData,1);
   HusimiCut_DataForFit_H_Sets = cell(nSetsOfData,1);


   Bins1 = [];
   Bins2 = [];
   for i = 1:nSetsOfData
       % Select Data Subset
       X1_Use = X1(X_Indices_select((i-1)*nStepSize+1:(i-1)*nStepSize+nQuadratures));
       X2_Use = X2(X_Indices_select((i-1)*nStepSize+1:(i-1)*nStepSize+nQuadratures));

       N1_Use = mean(X1_Use.^2)-1;
       N2_Use = mean(X2_Use.^2)-1;
       %Time_Use = Time_1_Select(1)+(i-0.5)*(nQuadratures/(75.3864*10^6));
       Time_Use = (EdgeIndices_1_Select(1)-1+(i-1)*nStepSize+0.5*nQuadratures)/(75.3864*10^6);

       % Select Edges
       Edges1 = [nLimits(1)-nResolution/2:nResolution:nLimits(2)+nResolution/2];% ensures one central bin around zero
       Edges2 = Edges1;
       Bins1 = (Edges1(1:end-1) + Edges1(2:end))/2;
       Bins2 = (Edges2(1:end-1) + Edges2(2:end))/2;

       % create Husimi Distribution
       [HusimiQ,~,~,~,nTherm,nThermErr,nCoherent,nCoherentErr,meanN,~,~,g2,Coherence,CoherenceErr,~,poissonErrorCut,HusimiCut,HusimiCutTheory,HusimiCut_DataForFit,HusimiCut_DataForFit_H] = QST.Plotting.calcHusimiAfterCarolin(X1_Use,X2_Use,[],[],Edges1= Edges1,Edges2=Edges2,CalcStatistics=true);
       DataSets{i} = HusimiQ;
       N1_Sets(i) = N1_Use;
       N2_Sets(i) = N2_Use;
       Time_Sets(i) = Time_Use;
       % The derived Quantities from the Fit
       nTherm_Sets(i) = nTherm;
       nThermErr_Sets(i) = nThermErr;
       nCoherent_Sets(i) = nCoherent;
       nCoherentErr_Sets(i) = nCoherentErr;
       meanN_Sets(i) = meanN;
       g2_Sets(i) = g2;
       Coherence_Sets(i) = Coherence;
       CoherenceErr_Sets(i) = CoherenceErr;
       poissonErrorCut_Sets{i} = poissonErrorCut;
       HusimiCut_Sets{i} = HusimiCut;
       HusimiCutTheory_Sets{i} = HusimiCutTheory;
       [HusimiCut_DataForFit,Idx] = sort(HusimiCut_DataForFit);
       HusimiCut_DataForFit_Sets{i} = HusimiCut_DataForFit;
       HusimiCut_DataForFit_H_Sets{i} = HusimiCut_DataForFit_H(Idx);



   end
   % Set up Colormap
   MaxProb = max(cellfun(@(y) max(y(:)),DataSets));
   MinProb = 0;
   clim manual;
   clim([MinProb,MaxProb])
   colorbar
   set(gca, 'nextplot', 'replacechildren');

   

   %% 3. Set up 2D Movie
   Movie2D = VideoWriter(strcat(Options.SavePath,filesep,Options.Filename,'.avi'),"Uncompressed AVI");
   Movie2D.FrameRate = Options.Framerate;

   open(Movie2D);
   Fig = figure;
   Fig.Position(1:2) = [100,100];
   Fig.Position(3:4) = [600,800];

   %% 4. create 2D Movie
   for i = 1:nSetsOfData
       % Expanded version of the plots
       tiledlayout('flow',TileSpacing="compact");
       nexttile([2,2])
       pcolor(Bins1,Bins2,DataSets{i})
       shading 'flat';
       axis on;
       axis equal;
       colormap hot;
       xlabel('q')
       ylabel('p')
       title(strcat('t = ',string(Time_Sets(i)),' s', ' N1:',string(N1_Sets(i)),' N2:',string(N1_Sets(i))))
       
       nexttile([2,2])
       shadedErrorBar(Bins1,HusimiCut_Sets{i},poissonErrorCut_Sets{i})
       hold on 
       plot(Bins1,HusimiCutTheory_Sets{i})
       hold on
       plot(HusimiCut_DataForFit_Sets{i},HusimiCut_DataForFit_H_Sets{i})
       hold off
       xlabel('q')
       ylabel('ProbQ((q,p = 0))');

       nexttile([1,4]);
       plot(Time_Sets(1:i),meanN_Sets(1:i));
       xlim([Time_Sets(1),Time_Sets(end)])
       ylim([0,max(meanN_Sets)+1])
       xlabel('t in s')
       ylabel('Mean Photonumber')

       nexttile([1,4]);
       plot(Time_Sets(1:i),nCoherent_Sets(1:i));
       %errorbar(Time_Sets(1:i),nCoherent_Sets(1:i),nCoherentErr_Sets(1:i));
       hold on
       plot(Time_Sets(1:i),nTherm_Sets(1:i));
       %errorbar(Time_Sets(1:i),nTherm_Sets(1:i),nThermErr_Sets(1:i));
       hold off
       xlim([Time_Sets(1),Time_Sets(end)])
       ylim([0,max(max(nCoherent_Sets+nCoherentErr_Sets),max(nTherm_Sets+nThermErr_Sets))+0.2])
       xlabel('t in s')
       ylabel('Phtono number')
       legend('nCoherent','nThermal')

       nexttile([1,4]);
       plot(Time_Sets(1:i),g2_Sets(1:i));
       xlim([Time_Sets(1),Time_Sets(end)])
       ylim([0,2])
       xlabel('t in s')
       ylabel('g^2(0,t)')

       nexttile([1,4]);
       plot(Time_Sets(1:i),Coherence_Sets(1:i));
       %errorbar(Time_Sets(1:i),Coherence_Sets(1:i),CoherenceErr_Sets(1:i));
       xlim([Time_Sets(1),Time_Sets(end)])
       ylim([0,max(Coherence_Sets+CoherenceErr_Sets)+0.1])
       xlabel('t in s')
       ylabel('Quantum Coherence')



       Frame = getframe(gcf);
       writeVideo(Movie2D,Frame)


   end
   close(Movie2D);

   % Extra Images
   % N(t)
   clf
   plot(Time_Sets,meanN_Sets);
   xlim([Time_Sets(1),Time_Sets(end)])
   xlabel('t in s')
   ylabel('Mean Photonumber')
   title('N(t)')
   savefig(strcat(Options.SavePath,filesep,Options.Filename,'-N(t)-','.fig'))

   % g^2(0,t)
   clf
   plot(Time_Sets,g2_Sets);
   xlim([Time_Sets(1),Time_Sets(end)])
   ylim([0,2])
   xlabel('t in s')
   ylabel('g^2(0,t)')
   title('g^2(0,t)')
   savefig(strcat(Options.SavePath,filesep,Options.Filename,'-g2(0,t)-','.fig'))

   % nTherm und nCoherent
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
   savefig(strcat(Options.SavePath,filesep,Options.Filename,'-nTherm(t)-nCoherent(t)-','.fig'))

   %
   clf
   plot(Time_Sets,Coherence_Sets);
   xlim([Time_Sets(1),Time_Sets(end)])
   xlabel('t in s')
   ylabel('Quantum Coherence')
   savefig(strcat(Options.SavePath,filesep,Options.Filename,'-QuantumCoherence(t)-','.fig'))



end