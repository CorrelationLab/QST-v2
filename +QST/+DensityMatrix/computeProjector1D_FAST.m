function [ PI1D ] = computeProjector1D_FAST( X, Theta, maxFockState )
% improved version of the projection calculator. scales linear instead of
% quadratic with fock space dimension. runs on my laptop faster than the
% old version on the beefy lab pc. Can be further improved by using the
% GPU.



X = X.';
Theta = Theta.';
tic
PI1D = complex(zeros(maxFockState+1,length(X)));
PI1D(1,:) = pi^(-0.25)*exp(-0.5*X.^2);
PI1D(2,:) = PI1D(1,:).*X*sqrt(2);

for i=3:maxFockState+1
    PI1D(i,:) = sqrt(2/(i-1))*X.*PI1D(i-1,:)-sqrt((i-2)/(i-1))*PI1D(i-2,:);
end
N = (0:maxFockState).';
Phase = N*Theta;
PI1D = PI1D .*exp(1i*Phase);
toc
end
