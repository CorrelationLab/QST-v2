function [] = plotHusimiQ_2D( BinsQ, BinsP, HusimiQ, Resolution, FitMethod, SaveDir, SaveName, Options)
% PLOTHUSIMIQ plots a given HusimiQ Distribution and saves it if wanted. IN CONSTRUCTION
%
% INPUTS:
% HusimiQ :         Matrix of HusimiQ Distribution
% Bins_Q :          Array of the Binning Positions along the first Phasespace Axis (Q)
% Bins_P :          Array of the Binning Positions along the second Phasespace Axis (P)
%
% OPTIONS:
% SaveFigure :      Bool if the Figure of the plot will be saved or not. Default is false
% SavePath :        Path where the figure should be saved if wanted
    arguments(Input)
        BinsQ;
        BinsP;
        HusimiQ;
        Resolution,
        FitMethod;
        SaveDir = '';
        SaveName='';
        Options.ShowLegend = true;
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
    % set basic figure
    Fig(1) = figure;
    pcolor(BinsQ,BinsP,HusimiQ);
    shading('flat');
    axis on;
    colormap('hot')
    hBar = colorbar;
    hold on

    % set labels
    xlabel('q');
    ylabel('p');
    pbaspect([1 1 1]);
    graphicsSettings;grid;
    ax = gca;
    set(ax,'FontSize',36,'FontName','Arial', 'TickDir','out');
    % set colorbar
    BarPos = get(hBar,'Position');
    set(hBar,'Position',BarPos+[0.03 0 0 -0.1]);
    hBar.FontSize = 25;
    % set legend
    if Options.ShowLegend
        Legend = legend('location','bestoutside');
        Legend.FontSize = 10;
        text(min(BinsQ),max(BinsP)*0.8,...
            ['n_{Th} = ', num2str(Options.nTherm,'%.6f'), ' \pm ' , num2str(Options.nThermErr,'%.6f'), newline, ...
             ' n_{Coh} = ' num2str(Options.nCoherent,'%.6f'),' \pm ', num2str(Options.nCoherentErr,'%.6f'), newline,...
             ' g^2 = ' num2str(Options.G2,'%.6f'),' \pm ', num2str(Options.G2Err,'%.6f'), newline,...
             ' C = ' num2str(Options.Coherence,'%.6f'), ' \pm ', num2str(Options.CoherenceErr,'%.6f') ], ...
            Color='g');

    end

    %% 2. save Figure if wanted
    if ~isempty(SaveDir)
        SavePath=strcat(SaveDir, filesep, SaveName, '-Resolution-', num2str(Resolution),'-FitMethod-', FitMethod, '-Legend-', '-Husimi_2D.fig');
        savefig(Fig,SavePath);
    end
end