function [nCoherent,nCoherentErr,nTherm,nThermErr,nMean,nMeanErr,nRatio,nRatioErr,G2,G2Err,Coherence,CoherenceErr,PoissonError,PoissonErrorCut,HusimiCut,HusimiCutTheory] = analyzeHusimiQ_PDTS_Main(Bins_Q, HusimiQ, Resolution, nQuads, Options)
%% Description:
%   This function analyses a two-dimensional Husimi Q distribution using a phase-averaged displaced thermal state
%   (PDTS) model. It only works on Husimi Q distributions constructed on a quadratic grid.
%
%   It transforms the Cartesian quadrature-bin coordinates into
%   radial and phase coordinates in alpha space, and fits the Husimi Q distribution using
%   analyzeHusimiQ_PDTS_Sub. 
%
%   Optionally, the function performs a Monte Carlo simulation to estimate uncertainties of the fitted thermal and
%   coherent photon numbers, mean photon number, photon-number ratio, g^{(2)}(0), and quantum coherence.
%   To this end it assumes Poisson-based histogram uncertainties,
%
%   In addition to the fitted state parameters, the function returns the measured Husimi Q cut along the
%   P = 0 axis and the corresponding theoretical cut calculated from the fitted PDTS parameters.
%
%% Syntax:
%   [nCoherent, nCoherentErr, nTherm, nThermErr, nMean, nMeanErr, nRatio, nRatioErr, ...
%    G2, G2Err, Coherence, CoherenceErr, PoissonError, PoissonErrorCut, HusimiCut, HusimiCutTheory] = ...
%       analyzeHusimiQ_PDTS_Main(Bins_Q, HusimiQ, Resolution, nQuads)
%
%   [...] = analyzeHusimiQ_PDTS_Main(Bins_Q, HusimiQ, Resolution, nQuads, MonteCarloError=true)
%
%   [...] = analyzeHusimiQ_PDTS_Main(Bins_Q, HusimiQ, Resolution, nQuads, nMonteCarloIterations=1000)
%
%% Input:
% required input values:
%   Bins_Q                                          - vector containing the bin centers of the quadrature axes;
%                                                     the same bin vector is assumed for both phase-space axes
%
%   HusimiQ                                         - two-dimensional Husimi Q distribution with dimensions
%                                                     [NumberOfBins, NumberOfBins]
%
%   Resolution                                      - bin width of the quadrature axes
%
%   nQuads                                          - number of quadrature pairs used to generate HusimiQ
%
% optional input options:
%   MonteCarloError                                 - logical value specifying whether Monte Carlo simulations are used
%                                                     to estimate parameter uncertainties (default: false)
%
%   nMonteCarloIterations                           - number of randomized Husimi Q distributions analysed during
%                                                     Monte Carlo uncertainty estimation (default: 1000)
%
%   FitMethod                                       - fitting method passed to analyzeHusimiQ_PDTS_Sub during the
%                                                     initial PDTS fit (default: 'NLSQ-LAR')
%
%% Output:
%   nCoherent                                       - fitted coherent photon number
%
%   nCoherentErr                                    - uncertainty of the coherent photon number; determined from Monte
%                                                     Carlo simulations when enabled
%
%   nTherm                                          - fitted thermal photon number
%
%   nThermErr                                       - uncertainty of the thermal photon number; determined from Monte
%                                                     Carlo simulations when enabled
%
%   nMean                                           - fitted mean photon number
%
%   nMeanErr                                        - uncertainty of the mean photon number; zero when Monte Carlo
%                                                     uncertainty estimation is disabled
%
%   nRatio                                          - photon-number ratio
%
%   nRatioErr                                       - uncertainty of nRatio; zero when Monte Carlo uncertainty
%                                                     estimation is disabled
%
%   G2                                              - second-order correlation function g^(2)(0)
%
%   G2Err                                           - uncertainty of g^(2)(0); zero when Monte Carlo uncertainty
%                                                     estimation is disabled
%
%   Coherence                                       - quantum coherence calculated from the fitted PDTS parameters
%
%   CoherenceErr                                    - uncertainty of the quantum coherence; determined from Monte
%                                                     Carlo simulations when enabled
%
%   PoissonError                                    - element-wise Poisson-based uncertainty estimate of HusimiQ
%
%   PoissonErrorCut                                 - Poisson-based uncertainty estimate along the P = 0 cut
%
%   HusimiCut                                       - measured Husimi Q distribution along the P = 0 axis
%
%   HusimiCutTheory                                 - theoretical Husimi Q cut along the P = 0 axis calculated
%                                                     from nCoherent and nTherm
%
%% Notes:
%   The Poisson-based uncertainty estimate is calculated as
%
%   sigma_Q = sqrt(Q(1-Q)/n_Quads).
%
%   The radial alpha-space coordinate is calculated from the Cartesian quadrature-bin coordinates as
%
%   |alpha| = 1/sqrt(2)*sqrt(Q^2 + P^2).
%
%   During Monte Carlo uncertainty estimation, each Husimi Q bin is independently randomized using a normal
%   distribution with its PoissonError as standard deviation. The reported uncertainties are the standard deviations
%   of the resulting fitted-parameter distributions.
%
%   Monte Carlo iterations are executed using parfor. The Parallel Computing Toolbox may therefore be required or
%   beneficial.



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
    [Radial,Phase] = QST.Helper.convertCartToPol(X1Axis,X2Axis);
    
    AlphaSpaceRadial = 1/sqrt(2)*Radial;
    AlphaSpacePhase = Phase;
    
    
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
            [nCoherent_i, ~, nTherm_i, ~, nMean_i, nRatio_i, G2_i, Coherence_i, ~, ~] = QST.HusimiQ.Analyze.analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQRandom, Resolution, AlphaSpaceRadial, MonteCarloError=true,FitMethod=Options.FitMethod);
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

