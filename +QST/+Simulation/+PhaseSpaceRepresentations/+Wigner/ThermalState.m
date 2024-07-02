function [ThermalWigner] = ThermalState(Q, P, nPhoton, Options)
    arguments
        Q;
        P;
        nPhoton;
        Options.Norm = 1/sqrt(2);
        Options.ProbMode {mustBeMember(Options.ProbMode,['Prob','Probdensity'])} = 'Prob'
    end
    Norm = Options.Norm;
    ProbMode = Options.ProbMode;

    ThermalWigner = zeros(length(Q),length(P));
    for iP = 1:length(P)
        ThermalWigner(:, iP) = (1/pi)*(2*Norm^2/(2*nPhoton+1))*exp(-2*Norm^2*(Q.^2+P(iP).^2)/(2*nPhoton+1));
    end
    % Normalization
    ThermalWigner = ThermalWigner/sum(ThermalWigner,'all');
    % adjust Prob to Probdensity if wanted
    if isequal(ProbMode,'ProbDensity')
        ThermalWigner = ThermalWigner / (mean(diff(Q))*mean(diff(P)));
    end

end

