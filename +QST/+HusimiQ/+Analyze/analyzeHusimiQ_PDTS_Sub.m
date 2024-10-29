function [nCoherent, nCoherentErr, nTherm, nThermErr,nMean, nRatio, G2, Coherence, CoherenceErr, HusimiCut] = analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQ, Resolution, AlphaSpaceRadial, Options)

arguments
    Bins_Q;
    HusimiQ;
    Resolution;
    AlphaSpaceRadial;
    Options.MonteCarloError=false;
    Options.FitMethod = 'NLSQ-LAR';
end



%% 4. get base Values from the 2D distribution data


nMean = sum((AlphaSpaceRadial.^2).*HusimiQ,"all")-1;


%% 5. The Horizontal Cut
HusimiCut = HusimiQ((length(Bins_Q)+1)/2,:);
% Calc Start Parameter for the Fit
HusimiCut_Soft = transpose(csaps(Bins_Q,HusimiCut,0.6,Bins_Q));
[~,I] = max(HusimiCut_Soft);
Radius = abs(Bins_Q(I));
nCoherent = 0.5*Radius^2; % the factor of 0.5 comes bcause its calculated from the q-p space
nTherm = nMean-nCoherent;

% Set Up Data for Fit in alpha space (data only bases on radial value)
alphaFit = AlphaSpaceRadial(:);
HusimiFit = HusimiQ(:);

% the actual fit
FitFunction = fittype('0.5*Resolution^2*(pi*(a1+1))^-1 *exp(-(x.^2 + b1)/(a1+1)) .* besseli(0,2*x*sqrt(b1)/(a1+1))','problem','Resolution'); 

%The Fit
[Params,gof,~] = fit(alphaFit,HusimiFit,FitFunction,'problem',Resolution,'StartPoint', [nTherm,nCoherent],'Lower',[0,0],'Robust','LAR' );

% get fitparameter back
nTherm = Params.a1;
nCoherent = Params.b1;
% derive nRatio, g2 and the quantum coherence from it
nRatio = nCoherent/nTherm;
G2 = 2 - (nCoherent/(nCoherent+nTherm))^2;
Coherence = QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent,nTherm);


% calculate the uncertainties in case not monte carlo is used
if Options.MonteCarloError==false
    StandardErrors = QST.Helper.getStandardErrorsFromFit(Params,gof,'method1');
    nThermErr = StandardErrors(1);
    nCoherentErr = StandardErrors(2);
    [~, CoherenceErr,~, ~] = QST.Helper.error_propagation( @(nCoherent,nTherm) QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent,nTherm),...
                                                          nCoherent, ...
                                                          nTherm, ...
                                                          nCoherentErr, ...
                                                          nThermErr);
    CoherenceErr(isnan(CoherenceErr)) = 0;

% set the values to zero since they are not needed
else 
    nCoherentErr = 0;
    nThermErr = 0;
    CoherenceErr = 0;
end

end