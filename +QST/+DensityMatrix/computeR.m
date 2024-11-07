function [R] = computeR(PI1D,rho,nX,maxFockState)    
% compute R
    R = zeros(maxFockState+1,maxFockState+1);
    prob = zeros(nX, 1);
    for i = 1:nX
            prob(i) = PI1D(:,i)' * rho * PI1D(:,i);
            R = R + (PI1D(:,i)*PI1D(:,i)')/(nX*prob(i));
    end
end