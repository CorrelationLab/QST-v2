function [Results_N_G2_TimeResolved] = seperateQuads_ByN(Results_N_G2_TimeResolved,Channels,nMinForHigh,autoControl)
for ch = Channels
    % access data
    N = Results_N_G2_TimeResolved.(ch).N;
    G2 = Results_N_G2_TimeResolved.(ch).G2;
    Times = Results_N_G2_TimeResolved.(ch).Times;
    EdgeIndices = Results_N_G2_TimeResolved.(ch).EdgeIndices;
    % find the indices for high and low level
    [~,I_High] = find(N >= nMinForHigh);
    I_Low = find(N < nMinForHigh);

    if autoControl
        if isempty(I_High) || isempty(I_Low)
            continue
        end
    end

    % High level
    Results_N_G2_TimeResolved.(ch).N_High = N(I_High);
    Results_N_G2_TimeResolved.(ch).G2_High = G2(I_High);
    Results_N_G2_TimeResolved.(ch).Times_High = Times(I_High);
    Results_N_G2_TimeResolved.(ch).EdgeIndices_High = EdgeIndices(:,I_High);

    % Low level
    Results_N_G2_TimeResolved.(ch).N_Low = N(I_Low);
    Results_N_G2_TimeResolved.(ch).G2_Low = G2(I_Low);
    Results_N_G2_TimeResolved.(ch).Times_Low = Times(I_Low);
    Results_N_G2_TimeResolved.(ch).EdgeIndices_Low = EdgeIndices(:,I_Low);
end

end

