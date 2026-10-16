function [ X, Theta ] = simulateQSTExperiment(Rho, Options)
%% Description:
%   This function simulates quadrature measurements for a quantum state described by a density matrix. It generates
%   randomly distributed quadrature values according to the phase-dependent quadrature probability distributions of
%   the supplied density matrix.
%
%   The density matrix is normalized to unit trace before the simulation. For every phase value in PHASE_RANGE, the
%   function calculates the corresponding quadrature probability distribution on QUADRATURE_RANGE and draws
%   N_X_PER_ANGLE random quadrature samples.
%
%   The simulated quadrature values and their associated phase angles are returned as column vectors suitable for
%   quantum state tomography procedures. For some reason it only seems to work for phase averaged states
%
%% Syntax:
%   [X, Theta] = simulateQSTExperiment(Rho)
%   [X, Theta] = simulateQSTExperiment(Rho, N_X_PER_ANGLE=50000)
%   [X, Theta] = simulateQSTExperiment(Rho, QUADRATURE_RANGE=-20:0.01:20)
%   [X, Theta] = simulateQSTExperiment(Rho, PHASE_RANGE=0:0.1:pi)
%
%% Input:
% required input values:
%   Rho                                             - density matrix representing the quantum state to be simulated;
%                                                     it is normalized internally to have unit trace
%
% name-value input options:
%   N_X_PER_ANGLE                                   - number of random quadrature values generated for every phase
%                                                     angle in PHASE_RANGE (default: 50000)
%
%   QUADRATURE_RANGE                                - vector defining the discrete quadrature values at which the
%                                                     phase-dependent probability distributions are evaluated
%                                                     (default: -20:0.01:20)
%
%   PHASE_RANGE                                     - vector defining the phase angles in radians for which quadrature
%                                                     measurements are simulated (default: 0:0.1:pi)
%
%% Output:
%   X                                               - column vector containing all simulated quadrature values; values
%                                                     are ordered by increasing phase angle
%
%   Theta                                           - column vector containing the phase angle associated with every
%                                                     entry of X



    arguments
        Rho;
        Options.N_X_PER_ANGLE = [50000];
        Options.QUADRATURE_RANGE = [-20:0.01:20];
        Options.PHASE_RANGE = [0:0.1:pi];
    end
    

    % Normalize density matrix
    Rho = Rho/trace(Rho);
    
    % Discretize X, Theta
    Theta = Options.PHASE_RANGE;
    X = zeros(Options.N_X_PER_ANGLE,length(Theta));
    Quadratures = zeros(length(Options.QUADRATURE_RANGE),length(Theta));
    prob = Quadratures;
    for iTheta = 1:length(Theta)
        % compute probability density for the current Theta-value
        Quadratures(:,iTheta) = Options.QUADRATURE_RANGE;
        PI1D = QST.DensityMatrix.computeProjector1D(Quadratures(:,iTheta), Theta(iTheta), length(Rho)-1);
        for iQuad=1:length(Quadratures)
            prob(iQuad,iTheta) = PI1D(:,iQuad)' * Rho * PI1D(:,iQuad);
        end
        prob(:,iTheta) = prob(:,iTheta)/sum(prob(:,iTheta));
    
        % compute quadrature values according to this probability distribution
        X(:,iTheta) = QST.Helper.distributeRandomly(Options.N_X_PER_ANGLE, ...
            Quadratures(:,iTheta), prob(:,iTheta));
    end
    
    % build X and Theta as column vectors
    X = X(:);
    Theta = ones(Options.N_X_PER_ANGLE,1) * Theta;
    Theta = Theta(:); 
end