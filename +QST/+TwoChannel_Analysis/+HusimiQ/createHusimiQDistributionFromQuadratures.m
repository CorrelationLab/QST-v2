function [Edges1, Edges2, HusimiQ, Bins1, Bins2, poissonErrors, poissonErrorsCut] = createHusimiQDistributionFromQuadratures(X1, X2, Limits, Resolution,Options)
% Creates the HusimiQ Distribution with given Orthogonal set of quadratures in a region definded in  a square region from [Limits(1),Limits(2)] with a fixed resolution.
% Alternative one can use already specified Edges for the binning 
arguments
    X1;
    X2;
    Limits = 10;
    Resolution=0.05
    Options.Edges1 = [];
    Options.Edges2 = [];
end


%% 1. create Husimi Distribution
if isempty(Options.Edges1) || isempty(Options.Edges2)
    BinsLeft = flip([-Resolution/2:-Resolution:Limits(1)-Resolution/2]);
    BinsRight = [Resolution/2:Resolution:Limits(2)+Resolution/2];
    Edges1 = cat(2,BinsLeft,BinsRight);
    %Edges1 = [Limits(1)-Resolution/2:Resolution:Limits(2)+Resolution/2];% ensures one central bin around zero
    Edges2 = Edges1;
end

[HusimiQ] = histcounts2(X1,X2,Edges1,Edges2,Normalization="probability");
Bins1 = (Edges1(1:end-1) + Edges1(2:end))/2;
Bins2 = (Edges2(1:end-1) + Edges2(2:end))/2;

%% 2. calc Poissonerrors
poissonErrors = sqrt(HusimiQ.*(1-HusimiQ)/length(X1));
poissonErrorsCut = poissonErrors((length(Bins1)+1)/2,:);
end