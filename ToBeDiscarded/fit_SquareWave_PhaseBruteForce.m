function [N_squareFit,optimalPhase,optimalLeastSquares] = fit_SquareWave_PhaseBruteForce(N, Times,Frequency,Dutycycle,minNForPulse,Options)
    arguments
        N;
        Times;
        Frequency;
        Dutycycle;
        minNForPulse;
        Options.Accuracy = 100
        Options.showControlPlot = true
    end
    Accuracy = Options.Accuracy;
    showControlPlot = Options.showControlPlot;

    %% 1. Set the meanPulseLevel and initialize the variables
    meanPulseLevel = mean(N(N>=minNForPulse));
    phases_Fit = 0:2*pi/Accuracy:2*pi;
    leastSquares = zeros([length(phases_Fit),1]);
    
    %% Bruteforce the optimal phase offset of the squarewave
    for i = 1:length(phases_Fit)
        N_fit = meanPulseLevel*(square(Times*2*pi*Frequency+phases_Fit(i),Dutycycle)+1)/2;
        leastSquares(i) = sum((N-N_fit).^2);
    end

    %% 3. Calculate the the optimal phaseoffset and the corresponding Fitdata
    [optimalLeastSquares, idx] = min(leastSquares);
    optimalPhase = phases_Fit(idx);
    N_squareFit = (square(Times*2*pi*Frequency+optimalPhase,Dutycycle)+1)/2;

    %% 4. If wanted: create a controlplot to check if the fit is suefficient and also if start parameter are maybe not correct
    plot(Times,N)
    hold on
    plot(Times,N_squareFit)
    hold off
    xlabel('Times in s')
    ylabel('Photon number')
    legend('Raw data', 'Squarewave Fit')
end

