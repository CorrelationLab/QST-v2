function [X1,X2] = rescaleQuadsForHusimiQ(X1,X2,Options)
arguments
    X1;
    X2;
    Options.ScaleChannels=true;
end

%% 1. rescale Data to the Point before the splitting Beamsplitter
X1 = X1(:)*sqrt(2);
X2 = X2(:)*sqrt(2);



%% 2. Rescale the Data according to the found channel dependent photonumbers (maybe critical?)
if Options.ScaleChannels
    nMean_X1 = QST.N_G2.calc_Nmean(X1);
    nMean_X2 = QST.N_G2.calc_Nmean(X2);
    X1 = X1*sqrt(mean([nMean_X1, nMean_X2])/nMean_X1);
    X2 = X2*sqrt(mean([nMean_X1, nMean_X2])/nMean_X2);
end
end