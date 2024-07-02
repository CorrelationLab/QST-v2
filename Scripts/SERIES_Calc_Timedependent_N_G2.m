%% 0. Set Setup Parameter
DataDirPath = 'E:\Paper Powerdependency\Threshold Series';
Channels = [1,2];
QuadratureDefiner = 'X';
DataFilePaths = QST.File_Managment.getFilePathsFromFolder(DataDirPath,FileTypes="*.mat",IncludeSubFolders=true);

for f = DataFilePaths
    SavePath = split(f,filesep);
    SavePath = SavePath(1:end-2);
    SavePath = join(SavePath,filesep);
    SavePath = strcat(SavePath,filesep,'Results',filesep,'N_G2_TimeResolved');
    FigureName = 'N_G2_TimeResolved_Channel_';

    for i = Channels
        %% 1. Load Data
        Q = load(f, strcat(QuadratureDefiner,string(i)));
        Q = Q.(strcat(QuadratureDefiner,string(i)));
        %% 2. Calculate N and G2
        [N, G2, Times,EdgeIndices] = QST.Analysis.G2.calc_N_G2_TimeResolved(Q, AverageMethod='moving',AverageSize=30000, StepSize=1000,Samplerate=74.3864);

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