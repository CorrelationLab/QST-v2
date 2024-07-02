function [HusimiQ,Bins1,Bins2] = calc_HusimiQByBinNumber(X1,X2,Options)
arguments
    X1;
    X2;
    Options.nBins = 100;
    Options.Limits = [-10, 10];
end


X1 = X1(:);
X2 = X2(:);
% Set Limits regarding to data if not yet defined
if isempty(Options.Limits)
    MaxQuad = max(abs(X1),abs(X2));
    Options.Limits = [-MaxQuad,MaxQuad];
end
Resolution = (Options.Limit(2)-Options.Limits(1))/nBins;

% Set the Edges of the used Binning (so its centered around the origin)
Edges = [Options.Limits(1):Resolution:Options.Limits(2)];
% calculate the Histogram
HusimiQ = histcounts2(X1,X2,Edges,Edges);
Bins1 = (Edges(1:end-1) + Edges(2:end))/2;
Bins2 = Bins1;
end