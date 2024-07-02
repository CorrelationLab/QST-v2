function [HusimiQ,Bins1,Bins2] = calc_HusimiQByRes(X1,X2,Options)
arguments
    X1;
    X2;
    Options.Resolution = 0.1;
    Options.Limits = [-10, 10];
end


X1 = X1(:);
X2 = X2(:);
% Set Limits regarding to data if not yet defined
if isempty(Options.Limits)
    MaxQuad = max(abs(X1),abs(X2));
    MaxQuad = ceil(MaxQuad/Options.Resolution)*Options.Resolution;
    Options.Limits = [-MaxQuad,MaxQuad];
end
% Set the Edges of the used Binning (so its centered around the origin)
Edges = [Limits(1)-Options.Resolution/2:Options.Resolution:Limits(2)+Options.Resolution/2];
HusimiQ = histcounts2(X1,X2,Edges,Edges);
Bins1 = (Edges(1:end-1) + Edges(2:end))/2;
Bins2 = Bins1;
end