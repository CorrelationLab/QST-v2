function [HusimiQ, Bins_Q, Bins_P, Edges_Q,Edges_P] = generateHusimiQ(X1, X2,Options)
% Creates the HusimiQ Distribution with given Orthogonal set of quadratures in a region defined within the rectangle set by Limits in Q and P axis.
% The resolution is fixed
arguments
    X1;
    X2;
    Options.Limits_Q = [-10,10];
    Options.Limits_P = [-10,10];
    Options.Resolution=0.1;
end
Limits_Q = Options.Limits_Q;
Limits_P = Options.Limits_P;
Resolution = Options.Resolution;


%% 1. create Husimi Distribution
BinsLeft_Q = flip([-Resolution/2:-Resolution:Limits_Q(1)-Resolution/2]);
BinsRight_Q = [Resolution/2:Resolution:Limits_Q(2)+Resolution/2];
Edges_Q = cat(2,BinsLeft_Q,BinsRight_Q);

BinsLeft_P = flip([-Resolution/2:-Resolution:Limits_P(1)-Resolution/2]);
BinsRight_P = [Resolution/2:Resolution:Limits_P(2)+Resolution/2];
Edges_P = cat(2,BinsLeft_P,BinsRight_P);


[HusimiQ] = histcounts2(X1,X2,Edges_Q,Edges_P,Normalization="probability");
Bins_Q = (Edges_Q(1:end-1) + Edges_Q(2:end))/2;
Bins_P = (Edges_P(1:end-1) + Edges_P(2:end))/2;




end