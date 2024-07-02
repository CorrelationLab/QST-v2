function [G2mean] = calc_G2mean(X,Options)
    arguments
        X;
        Options.Nmean = [];
        Options.Dimension = 'all';
    end


    %% 1. Calculate N
    if isempty(Options.Nmean)
        Options.Nmean = QST.Analysis.N.calc_Nmean(X,Options.Dimension);
    end
    %% 2. Calculate G2(0)
    G2mean = (2/3*mean(X.^4,Options.Dimension)-2.*Options.Nmean-0.5)./(Options.Nmean.^2);
end



