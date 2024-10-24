function [Datacleaned] = CorrRemove_All(Data,nMean_Min,Delta)
% Data:         Correlated Data of one channel
% nSeg:         Number of Elements in one segment
% nMean_Min:    Minimal Number of elements used for the mean values
% Delta:        Number of prior quadratures which are used for cleaning
arguments
    Data;
    nMean_Min = 1000000;
    Delta = 50;
end


Data = Data(:);
nData = length(Data);

% First case: data is shorter than given minimal nMean
if nData < nMean_Min
  warning('Data is shorter than allowed minimal nMean. All data is used');
  nSeg = 1;
  nMean = nData-Delta;
else % Data is longer than minimal nMean (this should be the normal case)
    nSeg = floor((nData-Delta)/nMean_Min);
    nMean = floor((nData-Delta)/nSeg);
end

% create matrix for gram schmidt 
M = zeros([Delta+nSeg,nMean]);
%get first matrix of the indices
for i = 1:nMean
    M(:,i) = (1:Delta+nSeg) + (i-1)*nSeg;
end
% fill the matrix according to the indices
M = Data(M);
% execute modified gram schmidt
Mcleaned = QST.QuadratureCalculation.mgsog(M.');
Mcleaned = Mcleaned.';
% place the cleaned data in Datacleaned
Datacleaned = Mcleaned(Delta+1:end,:);
Datacleaned = Datacleaned(:);

end