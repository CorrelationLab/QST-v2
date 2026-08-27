function [Times] = computeTimes(NumberOfQuadratures, AverageMethod, AverageSize, StepSize, Options)
%% Description:
%   This function construct an array of times for e.g. a set of computed photon number or g2 values. To this end one has to give the function
%   the same computation parameterthat are used for the computation of the quantity of interest
%
%% Syntax:
%   [Times] = calcTimes(NumberOfQuadratures, AverageMethod, AverageSize, StepSize, Samplerate=75.3864, FirstQuadIndex = 1)
%
%% Input:
% required input values;
%   NumberOfQuadratures                             - number of quadratures used for the computation of the stochastic quantity of interest (N, G2, HusimiQ)
%   AverageMethod                                   - used method to execute the expectation values ('static' for a blockwise averaging, 'moving' for a rolling window)
%   AverageSize                                     - number of quadratures for the averaging process
%   StepSize                                        - number of quadratures used as stepsize in the rolling window mode
%
% optional input arguments:
%   Samplerate = 75.3864                            - quadrature sampling rate (usually identical to the local oscillator repetition rate)
%   FirstQuadIndex = 1                              - index of the first quadrature taken into account 
%% Output:
%   Times                                           - array of times



    arguments
        NumberOfQuadratures;
        AverageMethod {mustBeMember(AverageMethod,['static','moving'])};
        AverageSize;
        StepSize;
        Options.Samplerate = 75.3864;
        Options.FirstQuadIndex = 1; 
    end


    %% 1. Calculate Times
    switch AverageMethod
        case 'static'
            Times = Options.FirstQuadIndex-1+(0.5:1:NumberOfQuadratures)*AverageSize*1/(Options.Samplerate*1000000);
        case 'moving'
            Times = (Options.FirstQuadIndex-1+((1:1:NumberOfQuadratures)-1)*StepSize+0.5*AverageSize)*1/(Options.Samplerate*1000000);
        otherwise
            error('Only "static" or "moving" are allowed modes');
    end
end
