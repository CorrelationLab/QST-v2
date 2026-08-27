function [N, G2, Times, EdgeIndices] = computeTimeResolved_N_G2(X, Options)
%% Description:
%   This function takes a set of quadratures and computes the time resolved N and G2(0) for it. The according computation parameters can be set 
%   manually.
%% Syntax:
%   [N, G2, Times, EdgeIndices] = computeTimeResolved_N_G2(X, AverageMethod = 'moving', AverageSize = 10000, StepSize = 1000, Samplerate = 75.3864, FirstQuadIndex = 1)
%
%% Input:
% required input values;
%   X                                               - array of quadratures. The array can be multidimensional
%
% optional input arguments:
%   AverageMethod = 'moving'                        - used method to execute the expectation values ('static' for a blockwise averaging, 'moving' for a rolling window)
%   AverageSize = 10000                             - number of quadratures for the averaging process
%   StepSize = 1000                                 - number of quadratures used as stepsize in the rolling window mode
%   Samplerate = 75.3864                            - quadrature sampling rate (usually identical to the local oscillator repetition rate)
%   FirstQuadIndex = 1                              - index of the first quadrature taken into account 
%
%% Output:
%   Nmean                                           - average photon number or array of photon numbers
%   G2mean                                          - average G2(0) or array of G2(0)
%   Times                                           - array of times
%   EdgeIndices                                     - two-dimensional array which marks the segments in the quadrature array used to compute N and g2.
%                                                     The first row contains the indices of the first quadratures of the individual segment,
%                                                     the second row contains the indices of the respective final quadratures



    arguments(Input)
        X
        Options.AverageMethod {mustBeMember(Options.AverageMethod,['static','moving'])} = 'moving';
        Options.AverageSize {mustBeInteger,mustBePositive} = 10000;
        Options.StepSize {mustBeInteger,mustBePositive} = 1000;
        Options.Samplerate {mustBeNumeric, mustBePositive} = 74.3864
    end


%% 1. Segment Data according to the Averagemethod
    switch Options.AverageMethod
        case 'static'
            [X, EdgeIndices] = QST.QuadratureSelection.segmentQuads_StaticWindow(X,Options.AverageSize);
        case 'moving'
            [X, EdgeIndices] = QST.QuadratureSelection.segmentQuads_RollingWindow(X,Options.AverageSize,Options.StepSize);
    end

    %% 2. Compute Photonumber N
    N = QST.N_G2.computeNmean(X,Dimension=1);

    %% 3. Compute g^2(0)
    G2 = QST.N_G2.computeG2mean(X,Dimension=1,Nmean=N);

    %% 4. Compute the Times
    Times = QST.N_G2.computeTimes(length(G2),Options.AverageMethod,Options.AverageSize,Options.StepSize,Samplerate=Options.Samplerate);
end
