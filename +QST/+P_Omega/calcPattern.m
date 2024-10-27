function [PatternResult] = calcPattern(TargetGrid,R)
% CALCPATTERN calculates the Pattern for one point in the Grid (which defines then the TargetGrid again).
%
% INPUTS:
% TargetGrid :      Grid which is based on the actual PatternFunction Grid and the x and p coordinates (for more look into calcXGridAndPattern)
% R :               R Factor used for the calculation of the PatternFunction. More Details about the Theory can be found in the Thesis of Carolin Lüders
%
% OUTPUTS:
% PatternResult :   Patterngrid for one point in the actual Calculationgrid 

 % compute the pattern function from the X parameters, see Jans notes, equ. 14 and 15
    Function = @(U,TargetGridf,Rf) U .* (acos(U) - U.*sqrt(1 - U.^2)) .* cos(U.*TargetGridf).*exp(2*Rf^2 *U.^2);
    H = integral(@(U)Function(U,TargetGrid,R),0,1,'ArrayValued',true );   
    PatternResult = (16*R^2 / pi^3).*H;
end

