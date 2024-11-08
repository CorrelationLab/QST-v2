function [ PI1D ] = computeProjector1D( X, theta, maxFockState )
%COMPUTEPROJECTOR1D <n|X,theta> for n = 0:maxFockState

PI1D = complex(zeros(maxFockState+1,length(X)));
parfor n=0:maxFockState
    PI1D(n+1,:) = QST.DensityMatrix.fockstate(n,X) .*exp(1i*n*theta);
end

end
