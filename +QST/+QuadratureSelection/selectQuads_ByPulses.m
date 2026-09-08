function [Time_Select,N_Select,G2_Select,EdgeIndices_Select,Times_Vac,N_Vac,G2_Vac,EdgeIndices_Vac] = selectQuads_ByPulses(Time,N,f,Threshold,Flank,G2,EdgeIndices)
%% Description:
%   This function selects signal pulses from time-resolved photon-number data using a threshold criterion and returns
%   the selected pulse data together with the complementary vacuum data.
%
%   Samples with photon numbers above Threshold are identified as pulse candidates. Short gaps below the threshold
%   within a pulse are included in the pulse if their duration is less than 5 % of the expected pulse period.
%
%   The beginning and end of every detected pulse are shortened by the fraction specified by Flank. This removes pulse
%   flanks and retains only the central region of each pulse. Incomplete pulses at the end of the dataset are removed.
%
%   The function returns the selected pulse data as concatenated vectors and provides edge indices for the contiguous
%   vacuum regions. Optional g^(2)(0) data and edge-index data can be selected together with the photon-number
%   data.
%
%% Syntax:
%   [Time_Select, N_Select, G2_Select, EdgeIndices_Select, Times_Vac, N_Vac, G2_Vac, EdgeIndices_Vac] = ...
%       selectQuads_ByPulses(Time, N)
%
%   [...] = selectQuads_ByPulses(Time, N, f, Threshold, Flank)
%
%   [...] = selectQuads_ByPulses(Time, N, f, Threshold, Flank, G2, EdgeIndices)
%
%% Input:
% required input values:
%   Time                                            - time vector associated with the photon-number data
%
%   N                                               - time-resolved photon-number data used to detect signal pulses
%
% optional input values:
%   f                                               - expected pulse repetition frequency in hertz; used to determine
%                                                     the maximum duration of threshold gaps within a pulse
%                                                     (default: 500)
%
%   Threshold                                       - photon-number threshold above which samples are identified as
%                                                     belonging to a signal pulse (default: 0.05)
%
%   Flank                                           - fraction of the detected pulse length removed at both the start
%                                                     and end of every pulse (default: 0.15)
%
%   G2                                              - optional time-resolved second-order correlation data associated
%                                                     with N (default: [])
%
%   EdgeIndices                                     - optional edge-index array associated with the input data
%                                                     (default: [])
%
%% Output:
%   Time_Select                                     - concatenated time values of all selected central pulse regions
%
%   N_Select                                        - concatenated photon-number values of all selected central pulse
%                                                     regions
%
%   G2_Select                                       - concatenated g^{(2)}(0) values of all selected pulse regions;
%                                                     [] if G2 is not supplied
%
%   EdgeIndices_Select                              - selected edge-index data corresponding to the selected pulse
%                                                     regions; [] if EdgeIndices is not supplied
%
%   Times_Vac                                       - time values of all samples not classified as selected pulse data
%
%   N_Vac                                           - photon-number values of all samples not classified as selected
%                                                     pulse data
%
%   G2_Vac                                          - g^{(2)}(0) values of all vacuum samples; [] if G2 is not
%                                                     supplied
%
%   EdgeIndices_Vac                                 - 2 x N array containing the start and end sample indices
%                                                     of all contiguous vacuum regions
%
%% Notes:
%   The sampling interval is estimated from the mean time difference, and the expected pulse period is calculated as
%
%   T = 1 / f.
%
%   A temporary gap within a pulse is filled if its duration is shorter than
%
%   0.05 x T.
%
%   The Flank option is applied independently to every detected pulse. For a pulse with length L, the number of
%   removed samples at each side is mathrm{round}(L cdot mathrm{Flank}).
%
%   Pulses for which the flank removal leaves no remaining samples are discarded. 

    

    arguments
        Time;
        N;
        f (1,1) double = 500;
        Threshold (1,1) double = 0.05;
        Flank (1,1) double =0.15;
        G2 = [];
        EdgeIndices = [];
    end   


    % Period
    dt = mean(diff(Time));         % sampling time
    T  = 1/f;                       % period

    % Detect area above the threshold
    above_threshold = N > Threshold;

    %% Outliers below the threshold within the pulse are not cut out
    % Defining the gap time of an outlier
    max_gap_time = 0.05 * T;
    max_gap_samples = max_gap_time/dt;  % Necessary because start_inds and end_inds work with sample-indices

    % Defining temporary pulsedges
    edges = diff([0, above_threshold, 0]);  % 0 so that pulses at the edge are also detected
    start_inds_temp = find(edges == 1);
    end_inds_temp = find(edges == -1) - 1;  % Minus 1 because diff shifts the index by 1
 
    % Checking for Outliers
    for i = 1:length(end_inds_temp)-1
        gap = start_inds_temp(i+1) - end_inds_temp(i) - 1;  % Minus 1 because diff shifts the index by 1
        if gap <= max_gap_samples
            above_threshold(end_inds_temp(i):start_inds_temp(i+1))=true;
        end
    end

    %% Defining the new pulsedges with possible Outliers included
    edges = diff([0, above_threshold, 0]);  
    start_inds = find(edges == 1);
    end_inds = find(edges == -1) - 1;

    %% Removing uncompleted pulses on the end
    if ~isempty(end_inds) && end_inds(end) >= length(N) - 1 
        start_inds(end) = [];
        end_inds(end) = [];
    end

    %% Puls flank cutting
    puls_lengths = end_inds-start_inds + 1;
    remove_samples = round(puls_lengths * Flank);

    start_inds = start_inds + remove_samples;
    end_inds = end_inds - remove_samples;

    valid = (end_inds > start_inds);    %keeping valid pulses
    start_inds = start_inds(valid);
    end_inds   = end_inds(valid);

    %% Build signal mask 
    signalMask = false(size(N));

    for k = 1:length(start_inds)
        signalMask(start_inds(k):end_inds(k)) = true;
    end

    %% Vacuum mask = complement of signal mask
    
    vacuumMask = ~signalMask;
    Times_Vac = Time(vacuumMask);
    N_Vac     = N(vacuumMask);

    if ~isempty(G2)
        G2_Vac = G2(vacuumMask);
    else
        G2_Vac = [];
    end
    
    edges_vac = diff([0, vacuumMask, 0]);
    start_vac = find(edges_vac == 1);
    end_vac   = find(edges_vac == -1) - 1;
    EdgeIndices_Vac = [start_vac; end_vac];
    

    %% Extract pulses and concatenate them
    Time_Select = [];
    N_Select  = [];
    G2_Select = [];
    EdgeIndices_Select = [];


    % iteration over every pulse
    for k = 1:length(start_inds)
        startIdx = start_inds(k);
        endIdx   = min(end_inds(k), length(N));

        % Concatenate the pulses
        N_Select = [N_Select, N(startIdx:endIdx)];
        Time_Select = [Time_Select, Time(startIdx:endIdx)];

        %% Cutting other values
        if ~isempty(G2)
            G2_Select = [G2_Select, G2(startIdx:endIdx)];
        end

        if ~isempty(EdgeIndices)
            EdgeIndices_Select = [EdgeIndices_Select, EdgeIndices(:, startIdx:endIdx)];
        end
    end
end
