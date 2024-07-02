function [PulseIndicesStruct,PulseIndicesTotal,ZerolevelIndices] = get_PulseIndices(N_SquareWaveFit)
    arguments
        N_SquareWaveFit;
    end

    %% 1. Get the start and end position of each complete pulse
    [~,pulseStart,pulseEnd] = pulsewidth(double(N_SquareWaveFit));
    pulseStart = round(pulseStart);
    pulseEnd = round(pulseEnd);

    %% 2. Calc the corresponding Indices and sort them into a Struct
    PulseIndicesStruct(length(pulseStart)) = struct();
    for i = 1:length(pulseStart)
        PulseIndicesStruct(i).Idx = [pulseStart(i):pulseEnd(i)];
    end

    %% 3. Transfer the indices of all pulses to one array
    PulseIndicesTotal = [];
    for i = 1:length(PulseIndicesStruct)
        PulseIndicesTotal = [PulseIndicesTotal,PulseIndicesStruct(i).Idx];
    end

    %% 4.Get the zerolevelindices (this is necessary since incomplete pulses are not recognized as pulses, but if they would be ignored they would falsify a potential zerolevel correction)
    IndexStart = PulseIndicesTotal(1);
    IndexEnd = PulseIndicesTotal(end);
    ZerolevelIndices = [IndexStart:IndexEnd];
    ZerolevelIndices = ZerolevelIndices(~ismember(ZerolevelIndices,PulseIndicesTotal));

end
%% Idea for further optimization: Remove the first and last zerolevelpoints to get a better zerolevel

