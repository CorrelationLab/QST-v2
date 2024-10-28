function [Bins1,Bins2,HusimiQ, Radius,nTherm,nThermErr,nCoherent,nCoherentErr,nMean,nMeanErr,nRatio,nRatioErr,G2,G2Err,Coherence,CoherenceErr,poissonErrors,poissonErrorsCut,HusimiCut, HusimiCut_Theory,radMean] = generate_analyzeHusimiQ(X1,X2,Resolution,Limits,Options)

    arguments
        X1;
        X2;
        Resolution = 0.1;
        Limits=[-10,10];
        Options.Edges1 = [];
        Options.Edges2 = [];
        Options.MonteCarloError=false;
        Options.nMonteCarloIterations=1000;
        Options.FitMethod = 'NLSQ-LAR';
        Options.FitFunction = '';
    end

%% 1. create the Husimi Q Distribution and prepare the corresponding alphaspaceRad
[Edges1, Edges2, HusimiQ, Bins1, Bins2, poissonErrors, poissonErrorsCut] = QST.HusimiQ.Generate.generateHusimiQAndPoisson(X1, X2, Limits, Resolution, Edges1=Options.Edges1, Edges2=Options.Edges2);

% preparation to make Monte Carlo faster
[X1Axis,X2Axis] = meshgrid(Bins1,Bins2);
alphaSpaceRad = 1/sqrt(2)*sqrt(X1Axis.^2+X2Axis.^2);
if ~isempty(Edges1) && ~isempty(Edges2)
    Resolution = (Edges1(end)-Edges1(1))/(length(Edges1)-1);
end

    
%% 2. analyze the Husimi Q distribution and its cut along the P=0 axis. Its is also possible to use Monte Carlo error estimation
%2.1 analyze the husimi Q distribution one first time
[nCoherent, nCoherentErr, nTherm, nThermErr, nMean, nRatio, G2, Coherence, CoherenceErr, HusimiCut, Radius, radMean] = QST.HusimiQ.Analyze.analyzeHusimiQ_PDTS(Bins1, HusimiQ, Resolution, alphaSpaceRad, MonteCarloError=false);
%2.2 set uncertainties which are not measureable this way to 0. To get them one has to use Monte Carlo
nMeanErr = 0;
nRatioErr = 0;
G2Err = 0;


%2.3  use Monte Carlo to estimate the uncertainties
if Options.MonteCarloError
    % 2.3.1 preallocate the variables
    [nCoherentRand, nThermRand, nMeanRand, nRatioRand,G2Rand,CoherenceRand] = deal(zeros(Options.nMonteCarloIterations,1));
    
    parfor i = 1:Options.nMonteCarloIterations
        disp(i);
        % 2.3.2 randomize the husimi Q distribution based on the poissonerrors
        HusimiQRandom = normrnd(HusimiQ,poissonErrors);
        % 2.3.3 analyze the randomized husimi Q distribution
        [nCoherent_i, ~, nTherm_i, ~, nMean_i, nRatio_i, G2_i, Coherence_i, ~,~,~,~] = QST.HusimiQ.Analyze.analyzeHusimiQ_PDTS(Bins1, HusimiQRandom, Resolution, alphaSpaceRad, MonteCarloError=true);
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

% 2.4 calculate the the husimicut based on the theoretical model of the displaced thermal state
HusimiCutFunction = 0.5*Resolution^2*(pi*(nTherm+1))^-1 *exp(-(alphaSpaceRad.^2 + nCoherent)/(nTherm+1)) .* besseli(0,2*alphaSpaceRad*sqrt(nCoherent)/(nTherm+1));
HusimiCut_Theory = HusimiCutFunction((length(Bins1)+1)/2,:);
end

