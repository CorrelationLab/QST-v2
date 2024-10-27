function [N, G2, Times,EdgeIndices] = calcTimeResolved_N_G2(X,Options)
% CALCG2_TIMERESOLVED calculates the timeresolved photonnumber and g2
%
%INPUT
% X :                       Quadrature data of the to be analyzed channel
%
%
% OPTIONS
% AverageMethod :           Type of used Average. Possible Values are 'static' and
%                           'moving'
% AverageSize :             Amount of Quadratures used for one Calculation 
% StepSize :                StepSize between consecutively Calculations for the moving Average
% Samplerate :              Samplerate of the Quadratures corresponding to
%                           the repetition rate of the pulsed LO in MHz
%
%
% G2 :                      Vector of the calculated G2(0) values
% N :                       Vector of the calculated N values
% Times :                   Vector of the times, correspondong to the
%                           calculated G2(0) and N

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
            [X, EdgeIndices] = QST.QuadratureSelection.segmentQuads_StaticAverage(X,Options.AverageSize);
        case 'moving'
            [X, EdgeIndices] = QST.QuadratureSelection.segmentQuads_MovingAverage(X,Options.AverageSize,Options.StepSize);
    end

    %% 2. calc Photonumber N
    N = QST.N_G2.calc_Nmean(X,Dimension=1);

    %% 3. calc g^2(0)
    G2 = QST.N_G2.calc_G2mean(X,Dimension=1,Nmean=N);

    %% 4. calc Times
    Times = QST.N_G2.calc_Times(length(G2),Options.AverageMethod,Options.AverageSize,Options.StepSize,Samplerate=Options.Samplerate);



end