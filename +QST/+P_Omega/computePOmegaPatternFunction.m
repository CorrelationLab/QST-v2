function [PatternResult] = computePOmegaPatternFunction(TargetGrid,R)
%% Description:
%   This function calculates the P_Omega pattern function for one point or an array of points of a target grid.
%
%   The pattern function is evaluated by numerically integrating its defining expression over the auxiliary variable
%   U from 0 to 1. The result is scaled by a factor determined by the filter parameter R.
%
%% Syntax:
%   PatternResult = computePOmegaPatternFunction(TargetGrid, R)
%
%% Input:
% required input values:
%   TargetGrid                                      - scalar or array containing target-grid values at which the
%                                                     P_Omega pattern function is evaluated
%
%   R                                               - positive filter parameter used in the P_Omega pattern-function
%                                                     calculation
%
%% Output:
%   PatternResult                                   - calculated P_Omega pattern-function values; has the same
%                                                     array size as TargetGrid
%
%% Notes:
%   The pattern function is calculated as

%   The numerical integration is performed using MATLAB integral with ArrayValued=true, allowing TargetGrid to be an
%   array.
%
%   The parameter R determines the filtering behavior of the reconstructed P_Omega quasiprobability. For
%   theoretical details, refer to the underlying P_Omega-reconstruction formalism.



    arguments
        TargetGrid;
        R;
    end

    % compute the pattern function from the X parameters, see the PhD Thesis of Carolin Lüders
    Function = @(U,TargetGridf,Rf) U .* (acos(U) - U.*sqrt(1 - U.^2)) .* cos(U.*TargetGridf).*exp(2*Rf^2 *U.^2);
    H = integral(@(U)Function(U,TargetGrid,R),0,1,'ArrayValued',true );   
    PatternResult = (16*R^2 / pi^3).*H;
end

