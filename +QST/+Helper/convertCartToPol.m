function [Amplitude, Phase] = convertCartToPol(X1, X2, Options)
% CALC_AMPLITUDE_PHASE calculates the individual amplitude and phase of a coordinate in phase space

% INPUTS:
% X1 :          Quadratures of First Channel
% X2 :          Quadratures of Second Channel
%
% OPTIONS:
% ZeroAxis :    Defines the Position of an angle of zero (usual convention). Default value cooresponds to the horizontal axis to the right
%
% OUTPUTS:
% Amplitude :   Amplitudes of the Quadrature Coordinatepairs
% Phase :       Phase of the Quadrature Coordinatepairs


    arguments
        X1
        X2
        Options.ZeroAxis {mustBeNumeric} = 0;
    end
    [Phase, Amplitude] = cart2pol(X1,X2);
    Phase = Phase - Options.ZeroAxis;

end

