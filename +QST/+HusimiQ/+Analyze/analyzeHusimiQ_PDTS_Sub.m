function [nCoherent, nCoherentErr, nTherm, nThermErr,nMean, nRatio, G2, Coherence, CoherenceErr, HusimiCut] = analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQ, Resolution, AlphaSpaceRadial, Options)
%% Description:
%   This function fits a two-dimensional Husimi Q distribution with the phase-averaged displaced thermal state
%   (PDTS) model.
%
%   The fit is performed in radial alpha space using all bins of the two-dimensional distribution. In addition to
%   the thermal and coherent photon numbers, the function determines the mean photon number, photon-number ratio,
%   second-order correlation function g^(2)(0), quantum coherence, and a horizontal Husimi Q cut.
%
%   Initial fit parameters are estimated from the mean photon number and the location of the maximum of a smoothed
%   central Husimi Q cut. The fit includes a non-negative constant background offset.
%
%% Syntax:
%   [nCoherent, nCoherentErr, nTherm, nThermErr, nMean, nRatio, G2, Coherence, CoherenceErr, HusimiCut] = ...
%       analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQ, Resolution, AlphaSpaceRadial, AlphaSpacePhase)
%
%   [...] = analyzeHusimiQ_PDTS_Sub(Bins_Q, HusimiQ, Resolution, AlphaSpaceRadial, AlphaSpacePhase, ...
%       MonteCarloError=true)
%
%% Input:
% required input values:
%   Bins_Q                                          - vector containing the bin centers of the quadrature axes; the
%                                                     same bin vector is assumed for both phase-space axes
%
%   HusimiQ                                         - two-dimensional Husimi Q distribution with dimensions
%                                                     [NumberOfBins, NumberOfBins]
%
%   Resolution                                      - bin width of the quadrature axes
%
%   AlphaSpaceRadial                                - matrix containing the radial \alpha-space coordinate
%                                                     corresponding to every HusimiQ bin
%
%   AlphaSpacePhase                                 - matrix containing the phase angle corresponding to every HusimiQ
%                                                     bin; it is reshaped internally but not otherwise used in the
%                                                     current implementation
%
% optional input options:
%   MonteCarloError                                 - logical value specifying the uncertainty-calculation mode:
%                                                     false: estimate fit-parameter uncertainties from the fit results
%                                                     true:  set fit-parameter uncertainties to zero because Monte Carlo
%                                                            uncertainty estimation is performed externally
%                                                     (default: false)
%
%   FitMethod                                       - fit-method identifier (default: 'NLSQ-LAR')
%
%% Output:
%   nCoherent                                       - coherent photon number obtained from the PDTS fit
%
%   nCoherentErr                                    - estimated standard uncertainty of nCoherent; zero if
%                                                     MonteCarloError is true
%
%   nTherm                                          - thermal photon number obtained from the PDTS fit
%
%   nThermErr                                       - estimated standard uncertainty of nTherm; zero if MonteCarloError
%                                                     is true
%
%   nMean                                           - mean photon number estimated directly from the Husimi Q
%                                                     distribution before fitting
%
%   nRatio                                          - ratio of coherent to thermal photon number
%
%   G2                                              - second-order correlation function calculated from the fitted
%                                                     photon numbers
%
%   Coherence                                       - quantum coherence calculated from the fitted photon numbers
%
%   CoherenceErr                                    - propagated uncertainty of Coherence; zero if MonteCarloError is
%                                                     true
%
%   HusimiCut                                       - central horizontal cut of HusimiQ, corresponding to the
%                                                     P = 0 axis
%
%% Notes:
%   The function requires Curve Fitting Toolbox functions fittype and fit, as well as csaps from the Spline Toolbox.
%   It additionally requires QST.Helper.getStandardErrorsFromFit, QST.Helper.error_propagation, and
%   QST.Simulation.QuantumCoherence.computeQuantumCoherenceDTS.



    arguments
        Bins_Q;
        HusimiQ;
        Resolution;
        AlphaSpaceRadial;
        Options.MonteCarloError=false;
        Options.FitMethod = 'LAR';
    end
    
    
    %% 4. get base Values from the 2D distribution data
    nMean = sum((AlphaSpaceRadial.^2).*HusimiQ,"all")-1;
    
    %% 5. Execute the fit based on the the radial information
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
    FitFunction = fittype('0.5*Resolution^2*(pi*(nTherm+1))^-1 *exp(-(x.^2 + nCoherent)/(nTherm+1)) .* besseli(0,2*x*sqrt(nCoherent)/(nTherm+1))','problem','Resolution'); 
    
    %The Fit
    [Params,gof,~] = fit(alphaFit,HusimiFit,FitFunction,'problem',Resolution,'StartPoint', [nTherm,nCoherent,1e-4],'Lower', [0,0], 'Robust', Options.FitMethod);
    
    % get fitparameter back
    nTherm = Params.nTherm;
    nCoherent = Params.nCoherent;
    % derive nRatio, g2 and the quantum coherence from it
    nRatio = nCoherent/nTherm;
    G2 = 2 - (nCoherent/(nCoherent+nTherm))^2;
    Coherence = QST.Simulation.QuantumCoherence.computeQuantumCoherenceDTS(nCoherent,nTherm);
    
    
    % calculate the uncertainties in case not monte carlo is used
    if Options.MonteCarloError==false
        StandardErrors = QST.Helper.getStandardErrorsFromFit(Params,gof,'t_Distribution');
        nThermErr = StandardErrors(1);
        nCoherentErr = StandardErrors(2);
        [~, CoherenceErr,~, ~] = QST.Helper.error_propagation( @(nCoherent,nTherm) QST.Simulation.QuantumCoherence.computeQuantumCoherenceDTS(nCoherent,nTherm),...
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
