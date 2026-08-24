function [Rho, Rho_Var] = execAnalysis_DensityMatrix(X, PiezoSign, Options)
%% Description:
%   This function takes a set of quadratures measured with a four-port homodyne detection scheme and a stable sinusoidal phase relationship
%   between signal and local oscillator and computes the density matrix. Further it allows to compute the density matrix based on multiple consecutive piezo segments
%   and it allows to perform an automatic averaging over multiple reconstructed density matrices to minimize errors
%
%% Syntax:
%   [Rho, Rho_Var] = execAnalysis_DensityMatrix(X, PiezoSign, PeriodsPerSegment = 2, PeakThreshold = 0.5, IgnoredSegments = [], Acurracy_Spline = 1e-14, MaxFockState = 50, Iterations = 100, PiezoSegmentsPerRho = 5, RhosPerAverage = 1)
%
%% Input:
% required input values;
%   X                                   - matrix of quadratures [#quadratures per piezo segment x #piezo segments]
%
% optional input arguments;
%   Options.PeriodsPerSegment=2         - initial guess of occuring phasecycles in one segment of nearly linear piezo movement
%   Options.PeakThreshold=0.5           - relative threshold in comparison to the segments extreme values for the detection of peaks
%   Options.IgnoredSegments=[]          - array of segments that should be excluded from the analysis. The segments are identified by their segment index 
%   Options.Accuracy_Spline=1e-14       - spline interpolation accuracy. The value is between 0 and 1. The interpolation accuracy 
%                                         increases nonlinear with increasing value (see documentation of csaps())
%   Options.MaxFockState=50             - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState
%   Options.Iterations=100              - number of iterations used in the algorithm
%   Options.PiezoSegmentsPerRho = 5     - number of piezo segment used for one density matrix reconstruction
%   Options.RhosPerAverage = 1          - number of reconstructed density matrices used for the final averaging process

%% Output:
%   Rho                                - averaged complex density matrix. It has the form of [MaxFockState+1 x MaxFockState+1]
%   Rho_Var                            - variance of the averaging process. It has the form of [MaxFockState+1 x MaxFockState+1]



    arguments
        X;
        PiezoSign;
        Options.PeriodsPerSegment = 2
        Options.PeakThreshold = 0.5
        Options.IgnoredSegments = []
        Options.Acurracy_Spline = 1e-14
        Options.MaxFockState = 50;
        Options.Iterations = 100;
        Options.PiezoSegmentsPerRho = 5;
        Options.RhosPerAverage = 1
    end
    
    % Reshape data to the required subset
    X = X(:,:,1:Options.RhosPerAverage*Options.NPiezoSegmentsPerRho);

    %% Compute Theta
    [Theta, ~, ~] = QST.DensityMatrix.computeRelativePhase(X, ...
                                                           1, ...
                                                           PiezoSign, ...
                                                           PeriodsPerSegment=Options.PeriodsPerSegment, ...
                                                           PeakThreshold=Options.PeakThreshold, ...
                                                           IgnoredSegments=Options.IgnoredSegments, ...
                                                           Acurracy_Spline=Options.Acurracy_Spline);
    
    %% Compute Rho as average over multiple piezo segments. This is necessary as Rho tends to instabilites
    Rho = zeros(Options.MaxFockState+1,Options.MaxFockState+1,Options.RhosPerAverage);
    i=1;
    k=1;
    while i <= Options.RhosPerAverage*Options.NPiezoSegmentsPerRho
        Rho(:,:,k) = QST.DensityMatrix.computeDensityMatrix(reshape(X(:,i:i+Options.NPiezoSegmentsPerRho-1),[],1), ...
                                                            reshape(Theta(:,i:i+Options.NPiezoSegmentsPerRho-1),[],1), ...
                                                            MaxFockState=Options.MaxFockState, ...
                                                            Iterations=Options.Iterations);
        k = k+1;
        i = i+Options.nPiezoSegmentsPerRho;
    end

    %% Take the average
    Rho_Var = var(Rho,[],3);
    Rho = mean(Rho,3);
end
