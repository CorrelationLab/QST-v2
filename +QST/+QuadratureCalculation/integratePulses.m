function [ X ] = integratePulses( Data8bit, Config, Options)
%% Description:
%   This function identifies periodic pulses in 8-bit ADC data and integrates the samples around each detected pulse
%   center. The integrated pulse values are returned as quadratures for every recording segment and ADC channel.
%
%   Pulse centers are detected from the pointwise variance over a selected number of measurement segments. The first
%   and last detected pulses are excluded to ensure that their integration windows remain within the recorded segment.
%
%   For measurements with multiple channels, small timing differences between the detected pulse trains are accounted
%   for by removing unmatched first or last pulse centers. The integration window width is defined as a fraction of
%   the mean pulse spacing.
%
%% Syntax:
%   X = integratePulses(Data8bit, Config, Options)
%
%% Input:
% required input values:
%   Data8bit                                        - int8 ADC measurement data with dimensions
%                                                     [SamplesPerSegment, NumberOfSegments, NumberOfChannels]
%
%   Config                                          - measurement configuration structure 
%
%
% optional input values:
%
%   Options.LO_RepetitionRate                        - local-oscillator repetition rate used to estimate the expected
%                                                     number of pulses per recorded segment
%
% optional Options fields:
%   Options.RowsForPointwiseVariance                 - maximum number of segments used to compute the pointwise
%                                                     variance (default: 200)
%
%   Options.IntegrationDutyCycle                     - fraction of the mean pulse spacing used for the integration
%                                                     window width (default: 1/3)
%
%   Options.VectorizePWVarianceComputation           - logical value selecting pointwise-variance computation:
%                                                     false: compute the variance in a loop (default)
%                                                     true:  use a vectorized computation with higher memory usage
%
%% Output:
%   X                                               - integrated pulse quadratures with dimensions
%                                                     [NumberOfPulses, NumberOfSegments, NumberOfChannels]
%
%% Notes:
%   The minimum peak distance is calculated as the ADC sampling rate divided by 125. At an ADC sampling rate of
%   1.25 GHz, this corresponds to a separation of 10 samples.
%
%   The integration windows are centered at every detected pulse center.
%
%   The function expects Data8bit to contain complete pulse windows. Pulses near the beginning and end of a segment
%   are discarded before integration.



    arguments(Input)
        Data8bit;
        Config;
        Options.MinPeakDistance
        Options.RowsForPointwiseVariance=200;
        Options.IntegrationDutyCycle=1/3;
        Options.VectorizePWVarianceComputation=false;
    end


    %% 1. Compute the pointwise variance in the individual channels
    [nRows, nSegments, nChannels] = size(Data8bit);
    Xpointwise = double(Data8bit(:,1:min(Options.RowsForPointwiseVariance, nSegments),:));
    Xpointwise = Xpointwise - mean(Xpointwise,1);
    if Options.VectorizePWvarianceComputation % full vectorized is faster but consumes more memory
        PointwiseVariance = squeeze(var(double(Xpointwise),0,2));
    else
        PointwiseVariance = zeros(nRows,1);
        for i=1:nRows
            PointwiseVariance(i) = var(double(Xpointwise(i,:)));
        end
    end
    
    %% 2. Compute the Pulses    
    % Set options for findpeaks
    ADC_SamplingRate = Config.SpectrumCard.Clock.SamplingRate0x28MHz0x29_DBL;
    MinPeakDistance = floor(ADC_SamplingRate / 125); % this corresponds to 10 points at an ADC sampling rate of 1.25 GHz
    MinPeakHeight = 0.5*mean(PointwiseVariance,1);
    PulseCenter = cell([nChannels,1]);
    Theory_SamplesPerPulse = (ADC_SamplingRate / Options.LO_RepetitionRate) * nRows;
    % Find the locations of the pulse centers
    for iCh = 1:nChannels
        [~,PulseCenter{iCh}] = findpeaks(PointwiseVariance(:,iCh),MinPeakDistance=MinPeakDistance,MinPeakHeight=MinPeakHeight(iCh));
        Experiment_nPulses = length(PulseCenter{iCh});
        if abs(-Theory_SamplesPerPulse) > 3
            warning(["Warning: ", string(Theory_SamplesPerPulse), " are expected but ", string(Experiment_nPulses), "have been found !"])
        end
        PulseCenter{iCh} = PulseCenter{iCh}.';
        PulseCenter{iCh} = PulseCenter{iCh}(2:end-1); % remove the first and last pulse to ensure that the integration window does exceed the segment 
    end

    %% 3. Account for timing errors between the different channels
    CommonPulseCenter = PulseCenter{1};
    if nChannels > 1
        for iCh = 2:nChannels
        % Account for small timing errors between channels
            if length(CommonPulseCenter) > length(PulseCenter{iCh})
                if abs(CommonPulseCenter(1)-PulseCenter{iCh}(1))>abs(CommonPulseCenter(end)-PulseCenter{iCh}(end))
                    % First entry in CommonPulseCenter needs to be deleted
                    PulseCenter{1:iCh-1} = PulseCenter{1:iCh-1}(2:end);
                else
                    % Last entry in CommonPulseCenter needs to be deleted
                    PulseCenter{1:iCh-1} = PulseCenter{1:iCh-1}(1:end-1);
                end
            CommonPulseCenter = PulseCenter{iCh};
            elseif length(CommonPulseCenter) < length(PulseCenter{iCh})
                    if abs(CommonPulseCenter(1)-PulseCenter{iCh}(1))>abs(CommonPulseCenter(end)-PulseCenter{iCh}(end))
                        % First entry in PulseCenter needs to be deleted
                        PulseCenter{iCh} = PulseCenter{iCh}(2:end);
                    else
                        % Last entry in PulseCenter needs to be deleted
                        PulseCenter{iCh} = PulseCenter{iCh}(1:end-1);
                    end
            end
        end
    end
    
    %% 4. Perform the integration over the pulses via an integrationwindow matrix that stores the used information. This is faster than a loop
    % compute the Integration matrix
    nWindow = int32(ceil(mean(diff(PulseCenter{1}))*Options.IntegrationDutyCycle/2));
    PulseCenter = int32(cell2mat(PulseCenter)).';
    nLocs = size(PulseCenter,1);
    PulseCenter = PulseCenter(:);
    WindowT = [-nWindow:nWindow];
    IntegrationMatrix = (PulseCenter+WindowT).'; % Integrationmatrix includes the indices of all elements of data that should be integrated
    IntegrationMatrix = IntegrationMatrix(:);
    IntegrationMatrix = reshape(IntegrationMatrix, nLocs*(2*nWindow+1), nChannels);    
    % compute the final quadratures
    X = zeros(nLocs,nSegments,nChannels);
    for iCh = 1:nChannels
        X(:,:,iCh) = sum(single(reshape(Data8bit(IntegrationMatrix(:,iCh),:,iCh),2*nWindow+1,nLocs,nSegments)),1);
    end
end