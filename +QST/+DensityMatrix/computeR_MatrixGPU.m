function [R] = computeR_MatrixGPU(PI1D,rho,nX)    
% compute R
    A = gpuArray(single(PI1D));
    B = A';
    rhoGPU = gpuArray(single(rho));
    tic

    toc
end