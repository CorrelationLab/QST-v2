function [] = plotHusimiQ_2D( Bins_Q, Bins_P, HusimiQ, Options)
%% Description:
%   This function creates a two-dimensional pseudocolor plot of a Husimi Q distribution in the q-p phase
%   space.
%
%   The plot can optionally include a color bar and a text annotation containing parameters obtained from a
%   phase-averaged displaced thermal state (PDTS) analysis. The figure can optionally be saved as a MATLAB .fig file.
%
%% Syntax:
%   plotHusimiQ_2D(Bins_Q, Bins_P, HusimiQ)
%   plotHusimiQ_2D(Bins_Q, Bins_P, HusimiQ, SaveFigure=true, SaveDir="Results")
%   plotHusimiQ_2D(Bins_Q, Bins_P, HusimiQ, ShowColorBar=true, ShowLegend=true)
%
%% Input:
% required input values:
%   Bins_Q                                          - vector containing the bin centers along the q-quadrature axis
%
%   Bins_P                                          - vector containing the bin centers along the p-quadrature axis
%
%   HusimiQ                                         - two-dimensional Husimi Q distribution; rows correspond to
%                                                     Bins_Q and columns correspond to Bins_P
%
% optional input options:
% figure-saving options:
%   SaveFigure                                      - logical value specifying whether the generated figure is saved
%                                                     as a MATLAB .fig file (default: false)
%
%   SaveDir                                         - directory in which the figure is saved; it is created if necessary
%                                                     (default: '')
%
%   SaveName                                        - base name of the saved figure file (default: 'HusimiQ-2D')
%
%   FitMethod                                       - identifier of the applied fitting method; included in the saved
%                                                     filename and required when SaveFigure is true (default: '')
%
% plot-display options:
%   ShowColorBar                                    - logical value specifying whether a color bar is displayed
%                                                     (default: false)
%
%   ShowLegend                                      - logical value specifying whether PDTS fit results are displayed
%                                                     as a text annotation in the plot (default: false)
%
% PDTS-result options:
%   nTherm                                          - thermal photon number displayed when ShowLegend is true
%                                                     (default: [])
%
%   nThermErr                                       - uncertainty of the thermal photon number displayed when ShowLegend
%                                                     is true (default: [])
%
%   nCoherent                                       - coherent photon number displayed when ShowLegend is true
%                                                     (default: [])
%
%   nCoherentErr                                    - uncertainty of the coherent photon number displayed when
%                                                     ShowLegend is true (default: [])
%
%   G2                                              - second-order correlation function g^{(2)}(0) displayed when
%                                                     ShowLegend is true (default: [])
%
%   G2Err                                           - uncertainty of g^{(2)}(0) displayed when ShowLegend is true
%                                                     (default: [])
%
%   Coherence                                       - quantum coherence displayed when ShowLegend is true (default: [])
%
%   CoherenceErr                                    - uncertainty of the quantum coherence displayed when ShowLegend is
%                                                     true (default: [])
%
%% Output:
%   This function does not return output arguments. It creates a pseudocolor plot in the current MATLAB figure.
%
%   If SaveFigure is true, the figure is saved using the filename:
%
%   <SaveName>-Resolution<Resolution>-FitMethod-<FitMethod>-IncludesResults-<ShowLegend>.fig
%
%% Notes:
%   The distribution is plotted with pcolor using the 'hot' colormap and flat shading.
%
%   The figure uses an equal plot-box aspect ratio and applies the display settings defined by
%   QST.Helper.graphicsSettings.



    arguments(Input)
        % basic Inputs
        Bins_Q;
        Bins_P;
        HusimiQ;
        Options.SaveFigure = false;
        Options.SaveDir = '';
        Options.SaveName='HusimiQ-2D';
        Options.FitMethod = '';
        Options.ShowColorBar = false;
        Options.ShowLegend = false;
        Options.nTherm=[];
        Options.nThermErr = [];
        Options.nCoherent= [];
        Options.nCoherentErr = [];
        Options.G2 = [];
        Options.G2Err = [];
        Options.Coherence = [];
        Options.CoherenceErr = [];
    end


    %% 1.create Figure and the 2D plot
    clf
    cla
    % set basic figure
    Fig(1) = figure;
    pcolor(Bins_Q,Bins_P,HusimiQ);
    colormap('hot')
    shading('flat');
    axis on;

    %% 2. set the colorbar
    if Options.ShowColorBar
        colorbar;
    end

    %% 3. set the labels
    xlabel('q');
    ylabel('p');
    pbaspect([1 1 1]);
    QST.Helper.graphicsSettings();
    grid off;
    ax = gca;
    set(ax,'FontSize',36,'FontName','Arial', 'TickDir','out');

    %% 5. set the legend with additonl infos from the PDTS model fit
    if Options.ShowLegend
        Legend = legend('location','bestoutside');
        Legend.FontSize = 10;
        text(min(Bins_Q),max(Bins_P)*0.8,...
            ['n_{Th} = ', num2str(Options.nTherm,'%.6f'), ' \pm ' , num2str(Options.nThermErr,'%.6f'), newline, ...
             'n_{Coh} = ' num2str(Options.nCoherent,'%.6f'),' \pm ', num2str(Options.nCoherentErr,'%.6f'), newline,...
             'g^2 = ' num2str(Options.G2,'%.6f'),' \pm ', num2str(Options.G2Err,'%.6f'), newline,...
             'C = ' num2str(Options.Coherence,'%.6f'), ' \pm ', num2str(Options.CoherenceErr,'%.6f') ], ...
            Color='g');
    end

    %% 6. save Figure
    if Options.SaveFigure
        assert(~isequal(Options.FitMethod,''),'No Fitmethod given');
        Resolution = abs(Bins_Q(2)-Bins_Q(1));
        SaveNameFull = strcat(Options.SaveName, '-Resolution', num2str(Resolution), '-FitMethod-', Options.FitMethod, '-IncludesResults-', string(Options.ShowLegend),'.fig');
        if ~exist(Options.SaveDir,'dir')
            mkdir(Options.SaveDir);
        end
        SavePath = fullfile(Options.SaveDir, SaveNameFull);
        savefig(Fig,SavePath);
    end
end