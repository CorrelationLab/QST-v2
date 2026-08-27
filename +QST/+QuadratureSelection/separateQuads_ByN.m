function [Results_N_G2_TimeResolved] = separateQuads_ByN(Results_N_G2_TimeResolved, Channels, NThreshold, Options)
%% Description:
%   This function takes the variable Results_N_G2_TimeResolved (created by QST.Main.execSeriesAnalysis_N_G2) in which the general channel dependent N and G2 results are saved and further
%   seperates the data according to photon number into a subset of low photon number and a subset of high photon number. these results are then 
%   saved into new struct elements with the variable Appendix '_Low' and 'High' as for e.g.  Results_N_G2_TimeResolved.(ch).N_Low.
%   It can also be applied on a subset of analyzed   
%
%% Syntax:
%   [Results_N_G2_TimeResolved] = seperateQuads_ByN(Results_N_G2_TimeResolved, Channels, NThreshold, Options)
%
%% Input:
% required input values;
%   Results_N_G2_TimeResolved                       - variable in which the N and G2 results are saved. Created by QST.Main.execSeriesAnalysis_N_G2
%   Channels                                        - array of the channels, called by their channelIDs, whose data should be separated.
%
%% Output:
%   X_Select                                        - 1D array of the postselected quadratures. It returns [] when X is [].
%   Results_N_G2_TimeResolved                       - variable in which the N and G2 results are saved.



    arguments
        Results_N_G2_TimeResolved;
        Channels;
        NThreshold;
        Options.CheckIfSeparationPossible
    end
    
        
    for ch = Channels
        %% 1. Access the data
        N = Results_N_G2_TimeResolved.(ch).N;
        G2 = Results_N_G2_TimeResolved.(ch).G2;
        Times = Results_N_G2_TimeResolved.(ch).Times;
        EdgeIndices = Results_N_G2_TimeResolved.(ch).EdgeIndices;
    
        %% 2. Find the indices of the _low and _High result subsets
        % find the indices for high and low level
        [~,ResultIndices_High] = find(N >= NThreshold);
        ResultIndices_Low = find(N < NThreshold);
    
        if Options.CheckIfSeparationPossible
            if isempty(ResultIndices_High) || isempty(ResultIndices_Low)
                continue
            end
        end
    
        %% Save the subsets in Results_N_G2_TimeResolved
        % High level
        Results_N_G2_TimeResolved.(ch).N_High = N(ResultIndices_High);
        Results_N_G2_TimeResolved.(ch).G2_High = G2(ResultIndices_High);
        Results_N_G2_TimeResolved.(ch).Times_High = Times(ResultIndices_High);
        Results_N_G2_TimeResolved.(ch).EdgeIndices_High = EdgeIndices(:,ResultIndices_High);
    
        % Low level
        Results_N_G2_TimeResolved.(ch).N_Low = N(ResultIndices_Low);
        Results_N_G2_TimeResolved.(ch).G2_Low = G2(ResultIndices_Low);
        Results_N_G2_TimeResolved.(ch).Times_Low = Times(ResultIndices_Low);
        Results_N_G2_TimeResolved.(ch).EdgeIndices_Low = EdgeIndices(:,ResultIndices_Low);
    end

end

