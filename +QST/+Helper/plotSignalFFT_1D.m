function [Spectrum,P1] = plotSignalFFT_1D(Times,Signal,Options)
    arguments
        Times;
        Signal;
        Options.plotFFT = true;
    end
SamplingFrequency = 1/((Times(end)-Times(1))/(length(Times)-1));
L = length(Times);

Spectrum = SamplingFrequency/L*(0:L/2);
P2 = abs(fft(Signal)/L);
P1 = P2(1:L/2+1);
P1(2:end-1) = 2*P1(2:end-1);

if Options.plotFFT
    plot(Spectrum,P1)
    xlabel('Spectrum in Hz')
end
end

