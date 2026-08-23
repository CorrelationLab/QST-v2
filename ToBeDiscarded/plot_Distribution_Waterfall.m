function [] = plot_Distribution_Waterfall(DistributionCell,Axis,Options)
    arguments
        DistributionCell;
        Axis
        Options.xLabel = '';
        Options.yLabel = '';
        Options.Title = '';
        Options.Limits = [];
        Options.Resolution = 100;
        Options.AsProb = true;
        Options.SavePath = '';
        Options.Filename = '';
    end
    

    %% Get the Histogram Limits
    if ~isempty(Options.Limits)
        Edges = [Options.Limits(1):2/(Options.Resolution):Options.Limits(2)];
    else
        Max = max(cellfun(@max, DistributionCell));
        Min = min(cellfun(@min, DistributionCell));
        Edges = [Min:(Max-Min)/(Options.Resolution):Max];
    end
    HistPoints = (Edges(1:end-1)+Edges(2:end))/2;

    WaterfallMatrix = zeros(Options.Resolution,length(DistributionCell));
    for i = 1:length(DistributionCell)
        if Options.AsProb == true
            Hist = histcounts(DistributionCell{i},Edges,Normalization='probability');
        else
            Hist = histcounts(DistributionCell{i},Edges);
        end

        WaterfallMatrix(:,i) = Hist;
    end

    clf
    Fig = figure;
    waterfall(HistPoints,Axis,WaterfallMatrix');
    xlabel(Options.xLabel);
    ylabel(Options.yLabel);
    title(Options.Title);
    if ~isempty(Options.SavePath) && ~isempty(Options.Filename)
        savefig(Fig,strcat(Options.SavePath,filesep,Options.Filename,'.fig'));
    end
end

