function []  = execSeriesAnalysis_N_G2(RootDirectory,Channels,Options)
    arguments
        RootDirectory;
        Channels;
        Options.QuadratureDefiner = 'X';
    end

MatPaths = QST.File_Managment.getFilePaths(RootDirectory);
[~,~,Ext] = fileparts(MatPaths); 
MatPaths = MatPaths(isequal(Ext,'.mat'));

for f = MatPaths
    SavePath = split(f,filesep);
    SavePath = SavePath(1:end-2);
    SavePath = join(SavePath,filesep);
    SavePath = strcat(SavePath,filesep,'Results',filesep,'N_G2_TimeResolved');
    FigureName = 'N_G2_TimeResolved_Channel_';

    for i = Channels
        %% 1. Load Data
        Q = load(f, strcat(Options.QuadratureDefiner,string(i)));
        Q = Q.(strcat(Options.QuadratureDefiner,string(i)));
        %% 2. Calculate N and G2
        [N, G2, Times,EdgeIndices] = QST.N_G2.calcTimeResolved_N_G2(Q, AverageMethod='moving',AverageSize=10000, StepSize=1000,Samplerate=74.3864);

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
        save(f,'Results_N_G2_TimeResolved', '-append')
    end
end
end