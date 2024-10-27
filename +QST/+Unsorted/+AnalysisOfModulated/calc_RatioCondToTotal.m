function [Ratio_CondToTotal] = calc_RatioCondToTotal(N, N_squareFit, minNForCond)
    arguments
    N;
    N_squareFit;
    minNForCond;
    end

    %% 1. Check where Pulses have been
    isCond_N = (N>=minNForCond);
    isPulse_N_squareFit = (N_squareFit > 0);
    
    %% 2. Calc the ratio Therewas/There
    Ratio_CondToTotal = sum(isCond_N)/sum(isPulse_N_squareFit);
end

