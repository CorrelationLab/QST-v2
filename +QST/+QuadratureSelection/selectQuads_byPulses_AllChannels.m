function [Results_N_G2_TimeResolved] = selectQuads_byPulses_AllChannels(Results_N_G2_TimeResolved, Channels, f, Threshold, Flank)
    % Does selectQuads_byPulses() for all channels
    arguments
        Results_N_G2_TimeResolved;
        Channels;
        f (1,1) double = 500;
        Threshold (1,1) double = 0.05;
        Flank (1,1) double =0.15;
    end

    for ch = Channels
        chStr = char(ch);

        Time       = Results_N_G2_TimeResolved.(chStr).Time;
        N           = Results_N_G2_TimeResolved.(chStr).N;
        G2          = Results_N_G2_TimeResolved.(chStr).G2;
        EdgeIndices = Results_N_G2_TimeResolved.(chStr).EdgeIndices;


        [Time_Select, N_Select, G2_Select, EdgeIndices_Select] = ...
            QST.QuadratureSelection.selectQuads_byPulses(Time, N, f, Threshold, Flank, G2, EdgeIndices);

        Results_N_G2_TimeResolved.(chStr).Time_Select       = Time_Select;
        Results_N_G2_TimeResolved.(chStr).N_Select           = N_Select;
        Results_N_G2_TimeResolved.(chStr).G2_Select          = G2_Select;
        Results_N_G2_TimeResolved.(chStr).EdgeIndices_Select = EdgeIndices_Select;
    end

    save('matdata.mat', 'Results_N_G2_TimeResolved');
end