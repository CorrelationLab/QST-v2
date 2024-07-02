function [Entropy_Wehrl] = Wehrl_Entropy(HusimiQData,Resolution_Q,Resolution_P)
% WEHRL_ENTROPY Calculates the Wehrl Entropy of a given HusimiQ Density
% Distribution
%
% INPUTS:
% HusimiQData :     Matrix of Husimi Q Probability Density Distribution (It has to be a Probability Density)
% ResolutionQ :     Resolution of the Grid in Variable Q
% ResolutionP :     Resolution of the Grid in Variable P
%
% OUTPUTS:
% Entropy Wehrl :   Wehrl Entropy of the given Husimi Q Density
%                   Distribution. It should be independent of the used the used resolutions
%                   and minimizes for a coherent state to 1.

    arguments(Input)
        HusimiQData
        Resolution_Q {mustBeGreaterThan(Resolution_Q,0)}
        Resolution_P {mustBeGreaterThan(Resolution_P,0)}
    end
    ProbQ = HusimiQData(:)*(Resolution_Q*Resolution_P); 
    ProbQ = ProbQ(ProbQ > 0);% Necessary to remove all Position where nothing was measured
    EntropyByData = -sum(ProbQ.*log(ProbQ));
    EntropyByGrid = log((Resolution_Q*Resolution_P)/(2*pi));
    Entropy_Wehrl = EntropyByData + EntropyByGrid; % Entropy_Wehrl or Wehr_Entropy ??? (for now this is fine I guess)
end

