function [G2mean] = calc_G2mean(X,Options)
    arguments
        X;
        Options.Dimension = 'all';
        Options.Nmean = [];
    end


    %% 1. Calculate N if not given
    if ~isempty(Options.Nmean)
        Nmean = Options.Nmean;
    else
    Nmean = QST.N_G2.calc_Nmean(X,Dimension=Options.Dimension);
    end
    %% 2. Calculate G2(0)
    G2mean = (2/3*mean(X.^4,Options.Dimension)-2.*Nmean-0.5)./(Nmean.^2);
end



