function [] = plot_KyEData(FilePath,Lenses,Options)
    arguments
        FilePath;
        Lenses = [20,700,400];
        Options.Y0 = 190;
        Options.LambdaEmission = 0.771;
        Options.ELim = [1.6025 1.61];
        Options.KyLim = [-2.1 2.1];
        Options.MinModifier = 1.5;
        Options.SavePath = '';
    end

    Y0 = Options.Y0;
    ELim = Options.ELim;
    KyLim = Options.KyLim;
    LambdaEmission = Options.LambdaEmission;
    MinModifier = Options.MinModifier;
    SavePath = Options.SavePath;

    %% 1. Load in data
    [Data,WavelengthData,~] = QST.CCD.Other.loadSPE2(FilePath);

    %% 2. Calc the Maginfication of the given lens sytsem
    LensMaginification = QST.CCD.Other.calc_MagnificationOfLensSystem(Lenses);
    %% 2. Center X-axis (Ky) and convert pixel to 1/µm: (2*pi/lambda(in mm))*pixelsize/magnification
    Ky = [1:400];
    Ky = (Ky-Y0)*(2*pi/(LambdaEmission))*20*LensMaginification/1000;

    %% 3.Convert pixel to eV for the Energy axis
    E = 1240./WavelengthData;

    %% 4. Plot the data
    clf;
    cla;
    Fig(1) = figure();
    imagesc(Ky,E,Data)
    set(gca, ydir='normal', LineWidth=2.0, fontname='times');
    colorMap = hot(250);
    colormap(colorMap);
    xlim(KyLim);% 1/um
    ylim(ELim);% eV
    clim([min(Data(:)*MinModifier) max(Data(:))]);
    axis square
    ax = gca;
    cax=[0.2 0.2 0.2]; %axis color
    ax.YAxis.FontSize = 40; ax.XAxis.FontSize = 40; ax.XColor = cax; ax.YColor = cax;
    xlabel('k_{y} (\mum^{-1})','FontSize',40)
    ylabel('E (eV)','FontSize',40)
    %title(['k_{x} = 0 \mum^{-1}'])


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

