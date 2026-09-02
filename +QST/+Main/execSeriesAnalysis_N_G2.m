function []  = execSeriesAnalysis_N_G2(RootDirectory,Channels,Options)
%% Description:
%   This function performs a time-resolved analysis of the mean photon number N and the second-order correlation
%   function g^{(2)}(0) for selected quadrature channels in all MATLAB measurement files below RootDirectory.
%
%   For every .mat file and selected channel, the function loads the specified quadrature data, calculates N and
%   g^{(2)}(0) in moving or block-wise averaging windows, creates a figure containing both quantities, and saves
%   the results in the original measurement file.
%
%   The generated MATLAB figure files are saved in a Results/N_G2_TimeResolved subfolder located relative to each
%   measurement file.
%
%% Syntax:
%   execSeriesAnalysis_N_G2(RootDirectory, Channels)
%   execSeriesAnalysis_N_G2(RootDirectory, Channels, QuadratureDefiner="X")
%   execSeriesAnalysis_N_G2(RootDirectory, Channels, Averagemethod="moving", AverageSize=10000, StepSize=1000)
%
%% Input:
% required input values:
%   RootDirectory                                   - root directory recursively searched for MATLAB .mat measurement
%                                                     files
%   Channels                                        - vector containing the channel numbers to be analysed
%
% optional input options:
%   QuadratureDefiner                               - prefix used for the quadrature variable names in the measurement
%                                                     files; e.g. "X" loads X1 for channel 1 (default: "X")
%
%   Averagemethod                                   - method used for time-resolved averaging; passed to
%                                                     computeTimeResolved_N_G2 (default: 'moving')
%
%   AverageSize                                     - number of quadrature values used in each averaging window
%                                                     (default: 10000)
%
%   StepSize                                        - distance between consecutive averaging windows in quadrature
%                                                     values (default: 1000)
%
%   Samplerate                                      - quadrature sampling rate in samples per second, used to calculate
%                                                     the time axis (default: 74.3864)
%
%% Output:
%   This function does not return output arguments.
%
%   For each analysed channel, it appends the structure Results_N_G2_TimeResolved to the respective .mat file. The
%   structure contains the fields N, G2, Times, and EdgeIndices.
%
%   It additionally saves a MATLAB figure file named N_G2_TimeResolved_Channel_<Channel>.fig for every analysed
%   channel.
%



    arguments
        RootDirectory;
        Channels;
        Options.QuadratureDefiner = "X";
        Options.Averagemethod = 'moving';
        Options.AverageSize = 10000;
        Options.StepSize = 1000;
        Options.Samplerate = 74.3864;
        Options.VacuumCorrection = false;
    end


    MatPaths = QST.File_Managment.getFilePaths(RootDirectory);
    [~,~,Ext] = fileparts(MatPaths); 
    MatPaths = MatPaths(strcmp(Ext,".mat"));
    
    for j = 1:length(MatPaths)
        CurrentMatPath = MatPaths(j);
        SavePath = split(CurrentMatPath,filesep);
        SavePath = SavePath(1:end-2);
        SavePath = join(SavePath,filesep);
        SavePath = strcat(SavePath,filesep,'Results',filesep,'N_G2_TimeResolved');
        FigureName = 'N_G2_TimeResolved_Channel_';
    
        for i = Channels
            %% 1. Load Data
            Q = load(CurrentMatPath, strcat(Options.QuadratureDefiner,string(i)));
            Q = Q.(strcat(Options.QuadratureDefiner,string(i)));
            %% 2. Calculate N and G2
            [N, G2, Times,EdgeIndices] = QST.N_G2.computeTimeResolved_N_G2(Q, AverageMethod=Options.Averagemethod,AverageSize=Options.AverageSize, StepSize=Options.StepSize,Samplerate=Options.Samplerate);
    
            %% 3. Plot N and G2 in two seperate plots
            Fig(1) = figure;
            tiledlayout(2,1);
            nexttile;
            plot(Times, G2);
            ylim([0, 2]);
            xlabel('t in s');
            ylabel('g2(0)');
            title('g2(0,t)');
            nexttile;
            plot(Times, N)
            ylim([0,max(N)+0.5]);
            xlabel('t in s')
            ylabel('N');
            title('N(t)');
    
            %% 4. Save the Figure
            if ~exist(SavePath,'dir')
                mkdir(SavePath)
            end
            Path = strcat(SavePath,filesep,FigureName,string(i),'.fig');
            savefig(Fig,Path);
    
            %% 5. Save the gained Information
            Results_N_G2_TimeResolved.(strcat('Channel',string(i))).N = N;
            Results_N_G2_TimeResolved.(strcat('Channel',string(i))).G2 = G2;
            Results_N_G2_TimeResolved.(strcat('Channel',string(i))).Times = Times;
            Results_N_G2_TimeResolved.(strcat('Channel',string(i))).EdgeIndices = EdgeIndices;
            save(CurrentMatPath,'Results_N_G2_TimeResolved', '-append');
        end
    end
end
