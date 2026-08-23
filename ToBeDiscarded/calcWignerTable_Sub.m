function Wnm = calcWignerTable_Sub(n,m,qval,pval,qintstep,minq,maxq)
%WIGNERNM evaluates the Wigner function at (qval,pval)
qrange=minq:qintstep:maxq;
Wnm=(1/(2*pi))*sum(qintstep*(QST.DensityMatrix.fockstate(n,qval+(0.5*qrange)).*QST.DensityMatrix.fockstate(m,qval-(0.5*qrange)).*exp(-1i*pval.*qrange)));
end

