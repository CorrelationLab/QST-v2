function [Histogram, Bins_A, Bins_B] = histogram2D_ByRes(A, B, Resolution_A, Resolution_B)
% HISTOGRAM2D_BYRES calculates the frequencyhistogram of Pairs (Ai,Bi) with
% a given Resolution. This corresponds if used for two othogonal subsets of Quadratures 
% except for a normalization factor to the HusimiQ Probability
% Distribution. The Resolution in this function is fixed, the actual range
% (maxA,maxB) in both axis is determined from the data.
%
% INPUTS:
% A :               Dataset of the first axis
% B :               Dataset of the second axis
% Resolution_A :    Resolution along Axis of A
% Resolution_B :    Resolution along Axis of B
%
% OUTPUTS:
% Histogram :       Frequency Histogram of the Data pairs (Ai,Bi) with the
%                   used Resolution
% Bins_A :          Binning Position along Axis A
% Bins_B :          Binning Position along Axis B

    arguments(Input)
        A
        B
        Resolution_A {mustBeNonnegative}
        Resolution_B {mustBeNonnegative}
    end
        A = A(:);
        B = B(:);
        % create Binning based on the resolution (I have to clear if this is useful, or if not what were the advantages of the old technique)
        MaxQuad = max(-min(A),max(A))*2;
        Bins_A = -MaxQuad:Resolution_A:MaxQuad;
        
        MaxQuad = max(-min(B),max(B))*2;
        Bins_B = -MaxQuad:Resolution_B:MaxQuad;
        
        N_Bins_A = length(Bins_A);
        N_Bins_B = length(Bins_B);

        % Map the Data into the Bins using Interpolation
        A_Interpol = round(interp1(Bins_A,1:N_Bins_A,A,'linear','extrap'));
        B_Interpol = round(interp1(Bins_B,1:N_Bins_B,B,'linear','extrap'));
        % limit indices to [1,N_Bins]
        A_Interpol = max(min(A_Interpol,N_Bins_A),1);
        B_Interpol = max(min(B_Interpol,N_Bins_B),1);
        % Count number of elements in each bin
        Histogram = accumarray([A_Interpol(:) B_Interpol(:)], 1, [N_Bins_A, N_Bins_B]).';

end

