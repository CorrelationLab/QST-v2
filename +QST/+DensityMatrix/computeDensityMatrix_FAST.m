function [nextRho] = computeDensityMatrix_FAST( X, Theta, Options)
%COMPUTEDENSITYMATRIX Summary of this function goes here
%
%   X and THETA must ...
%       - be 1D-Arrays
%       - have their NaN values at the same places.

%% Validate and parse input arguments
arguments
    X;
    Theta;
    Options.MaxFockState = 50;
    Options.Iterations = 100;
end
Xtp = X(~isnan(Theta) & ~isnan(X));
Theta = Theta(~isnan(Theta) & ~isnan(X));
X = Xtp;
clear Xtp;


%% Iteration
nX = length(X);
nextRho = gpuArray(single(ones(Options.MaxFockState+1,Options.MaxFockState+1)));
nextRho = nextRho /trace(nextRho);
A = gpuArray(single(QST.DensityMatrix.computeProjector1D_FAST( X, Theta, Options.MaxFockState)));
B = A';
tic
for iRho = 1:Options.Iterations
    rhoGPU = nextRho;
    Prob = sum((B*rhoGPU).*(A.'),2).'; % delivers the same result but is way faster
    Fact = single(1./(nX*Prob));
    R = (A.*Fact)*B;
    nextRho = R*rhoGPU*R; % ITERATION step
    nextRho = nextRho/trace(nextRho); % normalization
end
toc

end
