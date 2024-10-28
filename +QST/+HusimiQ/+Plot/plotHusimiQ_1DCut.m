function [] = plotHusimiQ_1DCut(BinsQ,HusimiCut,HusimiCutTheory,PoissonErrorsCut,Resolution,FitMethod,nTherm,nCoherent,Limits,SaveDir,SaveName)
    arguments
        BinsQ;
        HusimiCut;
        HusimiCutTheory;
        PoissonErrorsCut;
        Resolution;
        FitMethod;
        nTherm;
        nCoherent;
        Limits;
        SaveDir,
        SaveName;

    end

    clf
    Fig(1) = figure;

    %% 1. create 1D Graph for the Data
    Line = QST.Helper.shadedErrorBar(BinsQ,HusimiCut,PoissonErrorsCut,'lineProps',{'k-','Linewidth',3});
    Line.DisplayName= 'Data';
    hold on;

    %% 2. create Graph for the optimal fit with a displaced thermal state
    plot(BinsQ,HusimiCutTheory,'r','Linewidth',3,...
        displayname=['Theory, n_{Th} = ', num2str(nTherm,'%.2f'), ', n_{Coh} = ', num2str(nCoherent,'%.2f')]);

    %% 3. set the axis labels
    xlabel('q');
    ylabel('Q(q,p = 0)');
    legend('location','southwest');

    QST.Helper.graphicsSettings();% a function from carolin to set some plotmaker properties
    Axes = gca;
    set(Axes,fontsize=50,fontname='Arial',linewidth=3);
    Axes.XLim = Limits;

    %% 4. Save the plot
    if ~isempty(SaveDir)
        SavePath = strcat(SaveDir, filesep, SaveName, '-Resolution-', num2str(Resolution),'-FitMethod-', FitMethod, '-Husimi_Cut.fig');
        savefig(Fig,SavePath);
    end
end

