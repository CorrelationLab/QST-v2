function [] = plotRealspace(FilePath, Lenses, X0, Y0, Options)
%% Description:
%   This function loads CCD camera data from an SPE file and creates a two-dimensional real-space intensity plot.
%
%   Pixel coordinates are centered at the specified reference pixel (X0, Y0) and converted to spatial coordinates
%   in micrometers. The conversion accounts for a pixel size of 20 µm and the magnification of the
%   supplied lens system.
%
%   The resulting image is displayed using a hot colormap with configurable spatial limits and color scaling.
%   Optionally, the generated MATLAB figure is saved to a specified file path.
%
%% Syntax:
%   plotRealspace(FilePath, Lenses, X0, Y0)
%   plotRealspace(FilePath, Lenses, X0, Y0, XLim=[-30, 30], YLim=[-30, 30])
%   plotRealspace(FilePath, Lenses, X0, Y0, SavePath="Results/Realspace.fig")
%
%% Input:
% required input values:
%   FilePath                                        - path to the CCD SPE data file loaded by QST.CCD.loadSPE2
%
%   Lenses                                          - vector containing the focal lengths of the lens system in
%                                                     propagation order; used to calculate the optical magnification
%
%   X0                                              - reference pixel position used as the origin of the horizontal
%                                                     spatial coordinate
%
%   Y0                                              - reference pixel position used as the origin of the vertical
%                                                     spatial coordinate
%
% name-value input options:
%   XLim                                            - lower and upper limits of the horizontal plot axis in micrometers
%                                                     (default: [-30, 30])
%
%   YLim                                            - lower and upper limits of the vertical plot axis in micrometers
%                                                     (default: [-30, 30])
%
%   MinModifier                                     - factor applied to the minimum intensity value when setting the
%                                                     lower color-axis limit (default: 1.5)
%
%   SavePath                                        - path and filename used to save the generated MATLAB .fig file;
%                                                     no file is saved when this value is empty (default: '')
%
%% Output:
%   This function does not return output arguments. It creates a real-space intensity plot in a MATLAB figure.
   

    
    arguments
        FilePath;
        Lenses;
        X0;
        Y0;
        Options.XLim = [-30,30];
        Options.YLim = [-30,30];
        Options.MinModifier = 1.5;
        Options.SavePath = '';
    end


    XLim = Options.XLim;
    YLim = Options.YLim;
    MinModifier = Options.MinModifier;
    SavePath = Options.SavePath;

    %% 1. Load in data
    [Data,~,~] = QST.CCD.loadSPE2(FilePath);

    %% 2. Calc the Maginfication of the given lens sytsem
    LensMagnification = QST.CCD.computeLensMagnification(Lenses);
    %% 2. Center X-axis and convert pixel to µm
    Rx = [1:1340];
    Rx = (Rx-X0)*20/LensMagnification;

    %% 3. Center Y-axis and convert pixel to µm
    Ry = [1:400];
    Ry = (Ry-Y0)*20/LensMagnification;

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

