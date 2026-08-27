function [G2mean] = computeG2mean(X,Options)
%% Description:
%   This function insert a set of quadratures and computes the associated g2(tau=0). to this end the phase at which the quadratures has been recorded
%   has to be uniform over the data set 
%
%% Syntax:
%   [G2mean] = computeG2mean(X, Dimension=1, Nmean = [])
%
%% Input:
% required input values;
%   X                                               - array of quadratures. The array can be multidimensional
%
% optional input arguments:
%   Dimension=1                                     - axis of average computation in case of multidimensional arrays
%   nMean=[]                                        - an already precomputed average photon number. can speed up the computation
%
%% Output:
%   G2mean                                          - average G2(0) or array of G2(0)




arguments
        X;
        Options.Dimension = 1;
        Options.Nmean = [];
    end


    %% 1. Calculate N if not given
    if ~isempty(Options.Nmean)
        Nmean = Options.Nmean;
    else
    Nmean = QST.N_G2.computeNmean(X,Dimension=Options.Dimension);
    end
    
    %% 2. Calculate G2(0)
    G2mean = (2/3*mean(X.^4,Options.Dimension)-2.*Nmean-0.5)./(Nmean.^2);
end



