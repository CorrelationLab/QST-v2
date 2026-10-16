function [Rho] = computeDensityMatrix( X, Theta, Options)
%% Description:
%   This function reads in an array of quadratures and an array of associated phases and constructs the density matrix in fock representation
%   which is the most likely to reproduce this results. It is based on J. Opt. B: Quantum Semiclass. Opt. 6 S556
%
%% Syntax:
%   Rho = computeDensityMatrix(X, Theta, Options.MaxFockState, Options.nIterations)
%
%% Input:
% required input values;
%   X                                   - row array of quadratures
%   Theta                               - row array of phases
%
% optional input arguments;
%   Options.useGPU=false                - speed up computation with GPU (default: false)
%   Options.MaxFockState=50             - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState
%   Options.nIterations=100             - number of iterations used in the algorithm

%% Output:
%   Rho                                 - complex density matrix. It has the form of [MaxFockState+1 x MaxFockState+1]



    arguments(Input)
        X;
        Theta;
        Options.useGPU = false;
        Options.MaxFockState = 50;
        Options.nIterations = 100;
    end


    % Removal of Nans
    Xtp = X(~isnan(Theta) & ~isnan(X));
    Theta = Theta(~isnan(Theta) & ~isnan(X));
    X = Xtp;
    clear Xtp;
    
    %% compute the projections from the data set
    if Options.useGPU
        PI1D = gpuArray(single(QST.DensityMatrix.computeProjector1D( X, Theta, Options.MaxFockState)));
    else
        PI1D = single(QST.DensityMatrix.computeProjector1D( X, Theta, Options.MaxFockState));
    end
    PI1D_Dag = PI1D';

    %% initialize Rho
    nX = length(X);
    if Options.useGPU
        Rho = gpuArray(single(ones(Options.MaxFockState+1,Options.MaxFockState+1)));
    else
        Rho = single(ones(Options.MaxFockState+1,Options.MaxFockState+1));
    end
    Rho = Rho /trace(Rho);


    %% Fast density matrix computation as implemented in my thesis 
    for iRho = 1:Options.nIterations
        Prob = sum((PI1D_Dag*Rho).*(PI1D.'),2).';
        Fact = single(1./(nX*Prob));
        R = (PI1D.*Fact)*PI1D_Dag;
        Rho = R*Rho*R;
        Rho = Rho/trace(Rho);
    end
end
