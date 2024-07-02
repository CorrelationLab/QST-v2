function [] = plot_RxRyData(FilePath,Lenses,Options)
    arguments
        FilePath;
        Lenses = [20,400];
        Options.X0 = 661;
        Options.Y0 = 200;
        Options.XLim = [-30,30];
        Options.YLim = [-30,30];
        Options.MinModifier = 1.5;
        Options.SavePath = '';
    end
    X0 = Options.X0;
    Y0 = Options.Y0;
    XLim = Options.XLim;
    YLim = Options.YLim;
    MinModifier = Options.MinModifier;
    SavePath = Options.SavePath;

    %% 1. Load in data
    [Data,~,~] = QST.CCD.Other.loadSPE2(FilePath);

    %% 2. Calc the Maginfication of the given lens sytsem
    LensMaginification = QST.CCD.Other.calc_MagnificationOfLensSystem(Lenses);
    %% 2. Center X-axis and convert pixel to µm
    Rx = [1:1340];
    Rx = (Rx-X0)*20/LensMaginification;

    %% 3. Center Y-axis and convert pixel to µm
    Ry = [1:400];
    Ry = (Ry-Y0)*20/LensMaginification;

    %% 4. Plot the data
    clf;
    cla;
    Fig(1) = figure();
    imagesc(Rx,Ry,Data')
    set(gca, ydir='normal', LineWidth=2.0, fontname='times');
    colorMap = hot(250);
    colormap(colorMap);
    ylim(XLim);%um
    xlim(YLim);%um
    clim([min(Data(:)*MinModifier) max(Data(:))]);
    axis square
    ax = gca;
    ax.XTick = XLim(1):10:XLim(2);
    ax.YTick = YLim(1):10:YLim(2);
    cax=[0.2 0.2 0.2]; %axis color
    ax.YAxis.FontSize = 40; ax.XAxis.FontSize = 40; ax.XColor = cax; ax.YColor = cax;
    ylabel('y (\mum)','FontSize',40)
    xlabel('x (\mum)','FontSize',40)

    %% 5. Save the plot
    %% 6. If wanted: save the controlplot
    if ~isequal(SavePath,'')
        [DirPath,~,~] = fileparts(SavePath);
        if ~exist(DirPath,'dir')
            mkdir(DirPath);
        end
        savefig(Fig,SavePath);
    end
end

