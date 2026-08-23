function [] = calcCorrelationPulseGradientOverallGradient(PulseData,Threshold)
    arguments
        PulseData;
        Threshold = 1.5
    end

    %% 1. Filter for pulses which have a direct predecessor and successor
    LastQuad = arrayfun(@(i) i.EdgeIndices(2,end), PulseData);
    Diff = diff(LastQuad);
    meanDiff = mean(Diff);

    meanGradient = [];
    pulseGradient = [];
    meanPulseN = [];
    meanPulseTime = [];
    for i = 2:length(PulseData)-1
        if (Diff(i-1) < Threshold*meanDiff && Diff(i) < Threshold*meanDiff)
            %% 2. calc mean gradient from the pulse to left to the pulse to the right
            %tStart = mean(PulseData(i-1).Times);
            %tEnd = mean(PulseData(i+1).Times);
            %NStart = mean(PulseData(i-1).N);
            %NEnd = mean(PulseData(i+1).N);
            %meanGradient(end+1) = (NEnd-NStart)/(tEnd-tStart);
            % alternative with polyfit
            P = polyfit([PulseData(i-1).Times,PulseData(i).Times,PulseData(i+1).Times],[PulseData(i-1).N,PulseData(i).N,PulseData(i+1).N],1);
            meanGradient(end+1) = P(1);

            %% 3. calc gradient of the center pulse
            P = polyfit(PulseData(i).Times,PulseData(i).N,1);
            pulseGradient(end+1) = P(1);
            %pulseGradient(end+1) = (PulseData(i).N(end)-PulseData(i).N(1))/(PulseData(i).Times(end)-PulseData(i).Times(1));
            %meanPulseN(end+1) = mean(PulseData(i).N);
            %meanPulseTime(end+1) = mean(PulseData(i).Times);
        end
    end

    N_High = cell2mat([arrayfun(@(B) B.N, PulseData, UniformOutput=false)]);
    Times_High = cell2mat([arrayfun(@(B) B.Times, PulseData, UniformOutput=false)]);

    plot(Times_High,N_High)
    hold on
    scatter(meanPulseTime,meanPulseN);
    clf
    scatter(meanGradient,pulseGradient)

end

