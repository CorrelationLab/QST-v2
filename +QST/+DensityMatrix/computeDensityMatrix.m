function [Rho] = performDensityMatrixReconstruction( X, Theta, Options)
%% Description:
%   This function reads in an array of quadratures and an array of associated phases and constructs the density matrix in fock representation
%   which is the most likely to reproduce this results. It is based on J. Opt. B: Quantum Semiclass. Opt. 6 S556
%
%% Syntax:
%   Rho = computeDensityMatrix(X, Theta, Options.MaxFockState, Options.Iterations)
%
%% Input:
% required input values;
%   X                                   - row array of quadratures
%   Theta                               - row array of phases
%
% optional input arguments;
%   Options.MaxFockState=50             - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState
%   Options.Iterations=100              - number of iterations used in the algorithm

%% Output:
%   Rho                                - complex density matrix. It has the form of [MaxFockState+1 x MaxFockState+1]


    arguments(Input)
        X;
        Theta;
        Options.MaxFockState = 50;
        Options.Iterations = 100;
    end

    % Removal of Nans
    Xtp = X(~isnan(Theta) & ~isnan(X));
    Theta = Theta(~isnan(Theta) & ~isnan(X));
    X = Xtp;
    clear Xtp;
    
    %% compute the projections from the data set
    PI1D = gpuArray(single(QST.DensityMatrix.computeProjector1D( X, Theta, Options.MaxFockState)));
    PI1D_Dag = PI1D';

    %% initialize Rho
    nX = length(X);
    Rho = gpuArray(single(ones(Options.MaxFockState+1,Options.MaxFockState+1)));
    Rho = Rho /trace(Rho);


    %% Fast density matrix computation as implemented in my thesis 
    for iRho = 1:Options.Iterations
        Prob = sum((PI1D_Dag*Rho).*(PI1D.'),2).';
        Fact = single(1./(nX*Prob));
        R = (PI1D.*Fact)*PI1D_Dag;
        Rho = R*Rho*R;
        Rho = Rho/trace(Rho);
    end
end
