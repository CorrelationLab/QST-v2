function [ PI1D ] = computeProjector1D( X, Theta, MaxFockState )
%% Description:
%   This function reads in an array of quadratures and an array of associated phases and calculates the 1d dimensional projections <X_Theta,n>.
%   To this end it uses the algorithm proposed in Eur. J. Phys. 39 015402
%
%% Syntax:
%   PI1D = computeProjector1D(X, Theta, MaxFockState)
%
%% Input:
% required input values;
%   X                                   - row array of quadratures
%   Theta                               - row array of phases
%   MaxFockState                        - highest fock state which is taken into account. The outcome matrix then includes entries from 0 up to MaxFockState
%
%% Output:
%   PID1                                - matrix of <X_Theta,n> entries. It has the form of [MaxFockState+1 x #X] 



    arguments(Input)
        X
        Theta
        MaxFockState;
    end


    X = X.';
    Theta = Theta.';
    
    %% compute F_n = <X_0,n>
    PI1D = complex(zeros(MaxFockState+1,length(X)));
    % compute F_0
    PI1D(1,:) = pi^(-0.25)*exp(-0.5*X.^2);
    % compute F_1
    PI1D(2,:) = PI1D(1,:).*X*sqrt(2);
    % compute F_n n>=2
    for i=3:MaxFockState+1
        PI1D(i,:) = sqrt(2/(i-1))*X.*PI1D(i-1,:)-sqrt((i-2)/(i-1))*PI1D(i-2,:);
    end
    
    %% Perform a rotation to obtain <X_Theta,n>
    N = (0:MaxFockState).';
    Phase = N*Theta;
    PI1D = PI1D .*exp(1i*Phase);
end
