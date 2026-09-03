function [Amplitude, Phase] = convertCartToPol(X1, X2, Options)
%% Description:
%   This function converts Cartesian phase-space coordinates into polar coordinates. For each coordinate pair
%   (X_1, X_2), it calculates the radial amplitude and phase angle.
%
%   The phase origin can optionally be shifted by specifying the angular position of the desired zero axis.
%
%% Syntax:
%   [Amplitude, Phase] = QST.Helper.convertCartToPol(X1, X2)
%   [Amplitude, Phase] = QST.Helper.convertCartToPol(X1, X2, ZeroAxis=0)
%
%% Input:
% required input values:
%   X1                                              - Cartesian q-coordinate or first quadrature value
%
%   X2                                              - Cartesian p-coordinate or second quadrature value
%
% optional input options:
%   ZeroAxis                                        - angular offset in radians defining the location of phase zero;
%                                                     an offset of 0 corresponds to the positive horizontal axis
%                                                     (default: 0)
%
%% Output:
%   Amplitude                                       - radial amplitude of every Cartesian coordinate pair
%
%   Phase                                           - phase angle of every Cartesian coordinate pair in radians, shifted
%                                                     by ZeroAxis
%



    arguments
        X1
        X2
        Options.ZeroAxis {mustBeNumeric} = 0;
    end


    [Phase, Amplitude] = cart2pol(X1,X2);
    Phase = Phase - Options.ZeroAxis;
end

