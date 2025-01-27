function [WF] = WignerFromRho(Rho,Dir_Pattern)
%WIGNERFROMRHO calculates the Wignerfunction based on a given Pattern

% main diagonal
load(strcat(Dir_Pattern,filesep,"WignerPattern_offD0.mat"));
WF = real(sum(reshape(diag(Rho),1,1,[]).*W_Pattern(:,:,1:size(Rho,1)),3));

maxFock = size(Rho,1)-1;
% side diagonals
for i = 1:maxFock
    load(strcat(Dir_Pattern,filesep,"WignerPattern_offD",num2str(i),".mat"));
    D = diag(Rho,i);
    nD = length(D);
    WF = WF + 2*real(sum(reshape(D,1,1,[]).*W_Pattern(:,:,1:nD),3));
end



end

