function [LensMagnification] = computeLensMagnification(Lenses)
%% Description:
%   This function calculates the magnification factor of a sequential lens system from its focal lengths.
%
%   The focal lengths must be ordered according to the propagation direction from the first to the last lens. The
%   magnification is calculated as an alternating product of focal-length ratios.
%
%% Syntax:
%   LensMagnification = computeLensMagnification(Lenses)
%
%% Input:
% required input values:
%   Lenses                                          - vector containing the focal lengths of the lenses in propagation
%                                                     order, from the first lens to the last lens
%
%% Output:
%   LensMagnification                               - calculated magnification factor of the lens system
%


    arguments
    Lenses;
    end


    %% 1. Computes the manificationfactor of a given set of lenses (from first to last) 
    LensMagnification = 1;
    for i = 1:length(Lenses)
        LensMagnification = LensMagnification*Lenses(i)^((-1)^i);
    end
end

