function [] = plotHusimiQ_2D( Bins_Q, Bins_P, HusimiQ, Options)
% PLOTHUSIMIQ plots a given HusimiQ Distribution and saves it if wanted.
%
% INPUTS:
% HusimiQ :         Matrix of HusimiQ Distribution
% Bins_Q :          Array of the Binning Positions along the first Phasespace Axis (Q)
% Bins_P :          Array of the Binning Positions along the second Phasespace Axis (P)
%
% OPTIONS:
% SaveFigure :      Bool if the Figure of the plot will be saved or not. Default is false
% SaveDir :         Path where the figure should be saved if wanted
% SaveName:         Name of the file

% ShowLegend:       Show a legend with the PDTS analysis results. in case they have also be added 

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