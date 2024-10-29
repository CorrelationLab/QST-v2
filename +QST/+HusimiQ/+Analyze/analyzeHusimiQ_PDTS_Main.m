function [nCoherent,nCoherentErr,nTherm,nThermErr,nMean,nMeanErr,nRatio,nRatioErr,G2,G2Err,Coherence,CoherenceErr,PoissonError,PoissonErrorCut,HusimiCut,HusimiCutTheory] = analyzeHusimiQ_PDTS_Main(Bins_Q, HusimiQ, Resolution, nQuads, Options)
% function that sets the main setps to analyze the Husimi Q distribution with the model of a phase averaged displaced thermal state (PDTS).
% The fit is however is executed in the subfunction analyzeHusimiQ_PDTS_Sub. This function mainly prepares the dataset and coordinates
% the use of Monte carlo for a better error estimation.
    arguments
        Bins_Q;
        HusimiQ;
        Resolution;
        nQuads;
        Options.MonteCarloError=false;
        Options.nMonteCarloIterations=1000;
        Options.FitMethod = 'NLSQ-LAR';
    end


%% 1. calc Poissonerrors
PoissonError = sqrt(HusimiQ.*(1-HusimiQ)/nQuads);
PoissonErrorCut = PoissonError((length(Bins_Q)+1)/2,:);


%% 2. calc Alphaspaces radial component
[X1Axis,X2Axis] = meshgrid(Bins_Q,Bins_Q);
AlphaSpaceRadial = 1/sqrt(2)*sqrt(X1Axis.^2+X2Axis.^2);

    
%% 3. analyze the Husimi Q distribution and its cut along the P=0 axis. Its is also possible to use Monte Carlo error estimation
%2.1 analyze the Husimi Q distribution one first time
[nCoherent, nCoherentErr, nTherm, nThermErr, nMean, nRatio, G2, Coherence, CoherenceErr, HusimiCut] = QST.HusimiQ.Analyze.analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQ, Resolution, AlphaSpaceRadial, MonteCarloError=false,FitMethod=Options.FitMethod);
%2.2 set uncertainties which are not measureable this way to 0. To get them one has to use Monte Carlo
nMeanErr = 0;
nRatioErr = 0;
G2Err = 0;




%% 4.  use Monte Carlo to estimate the uncertainties
if Options.MonteCarloError
    % 2.3.1 preallocate the variables
    [nCoherentRand, nThermRand, nMeanRand, nRatioRand,G2Rand,CoherenceRand] = deal(zeros(Options.nMonteCarloIterations,1));
    
    parfor i = 1:Options.nMonteCarloIterations
        % 2.3.2 randomize the husimi Q distribution based on the poissonerrors
        HusimiQRandom = normrnd(HusimiQ,PoissonError);
        % 2.3.3 analyze the randomized husimi Q distribution
        [nCoherent_i, ~, nTherm_i, ~, nMean_i, nRatio_i, G2_i, Coherence_i, ~, ~] = QST.HusimiQ.Analyze.analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQRandom, Resolution, AlphaSpaceRadial, MonteCarloError=true);
        % 2.3.4 save the results in the preallocated array
        nCoherentRand(i) = nCoherent_i;
        nThermRand(i) = nTherm_i;
        nMeanRand(i) = nMean_i;
        nRatioRand(i) = nRatio_i;
        G2Rand(i) = G2_i;
        CoherenceRand(i) = Coherence_i;
    end
    
    % 2.3.5 calculate the uncertainties from the distributions std (for some reason Carolin used only the std from the monte carlo but not the means)
    nCoherentErr = std(nCoherentRand);
    nThermErr = std(nThermRand);
    nMeanErr = std(nMeanRand);
    nRatioErr = std(nRatioRand);
    G2Err = std(G2Rand);
    CoherenceErr = std(CoherenceRand);
end

%% 5. calculate the the husimicut based on the theoretical model of the displaced thermal state
HusimiCutFunction = 0.5*Resolution^2*(pi*(nTherm+1))^-1 *exp(-(AlphaSpaceRadial.^2 + nCoherent)/(nTherm+1)) .* besseli(0,2*AlphaSpaceRadial*sqrt(nCoherent)/(nTherm+1)); % this function should be moved to simulation
HusimiCutTheory = HusimiCutFunction((length(Bins_Q)+1)/2,:);


end

