function [Widths_isCond,Width_isPulse] = calc_CondWidths(N, N_squareFit, minNForCond,Options)
    arguments
        N;
        N_squareFit;
        minNForCond;
        Options.Times = [];
    end
    Times = Options.Times;


    %% 1. Check where Pulses have been
    isCond = (N>=minNForCond);
    isPulseData = (N_squareFit > 0);

    %% 2. Calc the start and endposition of the timeintervals with a pulse, where a condensate could be possible
    [Widths_isPulseData,pulseStart,pulseEnd] = pulsewidth(double(isPulseData));
    Width_isPulse = Widths_isPulseData(1); 

    %% 3. Calc the 'widths' of the condensate ATTENTION: this width does not care were exactly part of the condensate broke down (left, right, or even a splitted pulse)
    Widths_isCond = zeros([length(Widths_isPulseData),1]);
    for i = 1:length(Widths_isPulseData)
        Widths_isCond(i) = sum(isCond(round(pulseStart(i)):round(pulseEnd(i))));
    end

    %% 4. If the Times are also given, calculate the Widths in seconds
    if ~isequal(Times,[])
        timeResolution = mean(diff(Times));
        Widths_isCond = Widths_isCond*timeResolution;
        Width_isPulse = Widths_isPulse*timeResolution;
    end
end

