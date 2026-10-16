function [] = plotDispersion(FilePath, Lenses, Y0, Options)
%% Description:
%   This function loads CCD camera data from an SPE file and creates a two-dimensional energy-momentum dispersion
%   plot.
%
%   The horizontal camera coordinate is converted into the in-plane momentum component k_y using the supplied
%   emission wavelength, CCD pixel size, and optical magnification of the lens system. The spectral coordinate is
%   converted from wavelength to photon energy.
%
%   The resulting intensity distribution is displayed as a function of k_y and energy E. Optionally, the
%   generated MATLAB figure is saved to a specified file path.
%
%% Syntax:
%   plotDispersion(FilePath, Lenses, Y0)
%   plotDispersion(FilePath, Lenses, Y0, LambdaEmission=0.771)
%   plotDispersion(FilePath, Lenses, Y0, ELim=[1.6025, 1.61], KyLim=[-2.1, 2.1])
%   plotDispersion(FilePath, Lenses, Y0, SavePath="Results/Dispersion.fig")
%
%% Input:
% required input values:
%   FilePath                                        - path to the CCD SPE data file loaded by QST.CCD.loadSPE2
%
%   Lenses                                          - vector containing the focal lengths of the lens system in
%                                                     propagation order in milli meters; used to calculate the optical magnification.
%
%   Y0                                              - reference pixel position defining k_y = 0
%
% optional input options:
%   LambdaEmission                                  - emission wavelength used for momentum calibration in micrometers
%                                                     (default: 0.771)
%
%   ELim                                            - lower and upper limits of the energy axis in electronvolts
%                                                     (default: [1.6025, 1.61])
%
%   KyLim                                           - lower and upper limits of the k_y axis in
%                                                     \mu\mathrm{m}^{-1} (default: [-2.1, 2.1])
%
%   MinModifier                                     - factor applied to the minimum intensity value when setting the
%                                                     lower color-axis limit (default: 1.5)
%
%   SavePath                                        - path and filename used to save the generated MATLAB .fig file;
%                                                     no file is saved when this value is empty (default: '')
%
%% Output:
%   This function does not return output arguments. It creates an energy-momentum dispersion plot in a MATLAB figure.
%



    arguments
        FilePath;
        Lenses;
        Y0;
        Options.LambdaEmission = 0.771;
        Options.ELim = [1.6025 1.61];
        Options.KyLim = [-2.1 2.1];
        Options.MinModifier = 1.5;
        Options.SavePath = '';
    end


    ELim = Options.ELim;
    KyLim = Options.KyLim;
    LambdaEmission = Options.LambdaEmission;
    MinModifier = Options.MinModifier;
    SavePath = Options.SavePath;

    %% 1. Load in data
    [Data,WavelengthData,~] = QST.CCD.loadSPE2(FilePath);

    %% 2. Calc the Maginfication of the given lens sytsem
    LensMaginification = QST.CCD.computeLensMagnification(Lenses);
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

