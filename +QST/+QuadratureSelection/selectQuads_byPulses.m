function [Time_Select,N_Select,G2_Select,EdgeIndices_Select,Times_Vac,N_Vac,G2_Vac,EdgeIndices_Vac] = selectQuads_byPulses(Time,N,f,Threshold,Flank,G2,EdgeIndices)
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
    Times_Vac = Times(vacuumMask);
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
