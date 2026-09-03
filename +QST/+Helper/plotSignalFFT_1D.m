function [Frequencies,AmplitudeSpectrum] = plotSignalFFT_1D(Times,Signal,Options)
%% Description:
%   This function calculates the single-sided amplitude spectrum of a one-dimensional signal using the fast Fourier
%   transform (FFT).
%
%   The sampling frequency is estimated from the supplied time vector. The function returns the frequency vector and
%   the corresponding single-sided amplitude spectrum. Optionally, it creates a plot of the spectrum.
%
%% Syntax:
%   [Frequencies, AmplitudeSpectrum] = plotSignalFFT_1D(Times, Signal)
%   [Frequencies, AmplitudeSpectrum] = plotSignalFFT_1D(Times, Signal, plotFFT=true)
%
%% Input:
% required input values:
%   Times                                           - time vector associated with Signal; assumed to have uniformly
%                                                     spaced entries
%
%   Signal                                          - one-dimensional signal for which the amplitude spectrum is
%                                                     calculated
%
% name-value input options:
%   plotFFT                                         - logical value specifying whether the single-sided amplitude
%                                                     spectrum is plotted (default: true)
%
%% Output:
%   Frequencies                                     - frequency vector of the single-sided spectrum in hertz
%
%   AmplitudeSpectrum                               - single-sided amplitude spectrum of Signal
%
%% Notes:
%   The calculation is based on the example on the matlab documentation: https://www.mathworks.com/help/matlab/ref/fft.html



    arguments
        Times;
        Signal;
        Options.plotFFT = true;
    end


    %% 1. Compute the FFT
    SamplingFrequency = 1/((Times(end)-Times(1))/(length(Times)-1));
    L = length(Times);
    
    Frequencies = SamplingFrequency/L*(0:L/2);
    P2 = abs(fft(Signal)/L);
    AmplitudeSpectrum = P2(1:L/2+1);
    AmplitudeSpectrum(2:end-1) = 2*AmplitudeSpectrum(2:end-1);
    
    %% 2. Plot the result
    if Options.plotFFT
        plot(Frequencies,AmplitudeSpectrum)
        xlabel('Frequencies in Hz')
    end
end

