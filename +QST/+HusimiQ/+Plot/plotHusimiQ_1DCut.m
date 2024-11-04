function [] = plotHusimiQ_1DCut(Bins_Q,HusimiCut,HusimiCutTheory,PoissonErrorCut,Options)
    arguments
        Bins_Q;
        HusimiCut;
        HusimiCutTheory;
        PoissonErrorCut;
        Options.SaveFigure = false;
        Options.SaveDir = '';
        Options.SaveName='HusimiQ-1DCut';
        Options.ShowLegend = false;
        Options.FitMethod = '';
        Options.nTherm = [];
        Options.nCoherent = [];

    end

    clf
    %% 1. create 1D Graph for the Data
    Fig(1) = figure;
    Line = QST.Helper.shadedErrorBar(Bins_Q, HusimiCut, PoissonErrorCut, 'lineProps', {'k-','Linewidth',3});
    Line.DisplayName= 'Data';
    hold on;

    %% 2. create Graph for the optimal fit with a displaced thermal state
    if Options.ShowLegend
        plot(Bins_Q,HusimiCutTheory,'r',LineWidth=3, DisplayName=['Theory, n_{Th} = ', num2str(Options.nTherm,'%.2f'), ', n_{Coh} = ', num2str(Options.nCoherent,'%.2f')]);
    else
        plot(Bins_Q,HusimiCutTheory,'r',LineWidth=3)
    end

    %% 3. set the axis labels
    xlabel('q');
    ylabel('Q(q,p = 0)');
    legend('location','southwest');
    QST.Helper.graphicsSettings();% a function from carolin to set some plotmaker properties
    Axes = gca;
    set(Axes,fontsize=50,fontname='Arial',linewidth=3);
    Resolution = abs(Bins_Q(2)-Bins_Q(1));
    Axes.XLim = [Bins_Q(1)-Resolution/2, Bins_Q(end)+Resolution/2];

    %% 4. Save the plot
    if Options.SaveFigure
        assert(~isequal(Options.FitMethod,''),'No Fitmethod given');
        SaveNameFull = strcat(Options.SaveName, '-Resolution', num2str(Resolution), '-FitMethod-', Options.FitMethod, '-IncludesResults-', string(Options.ShowLegend),'.fig');
        if ~exist(Options.SaveDir,'dir')
            mkdir(Options.SaveDir);
        end
        SavePath = fullfile(Options.SaveDir, SaveNameFull);
        savefig(Fig,SavePath);
    end
end

