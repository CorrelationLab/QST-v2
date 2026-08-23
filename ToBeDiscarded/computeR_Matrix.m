function [R] = computeR_Matrix(PI1D,rho,nX)    
% compute R
    A = PI1D;
    B = A';
    Prob = sum((B*rho).*(A.'),2).'; % delivers the same result but is way faster
    Fact = 1./(nX*Prob);
    R = (A.*Fact)*B;
end