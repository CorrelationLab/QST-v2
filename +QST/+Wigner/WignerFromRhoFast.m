Dir = "C:\Users\LabCorr Homodyne\Desktop\WignerTest2";

maxFock = 50;
Rho = zeros(maxFock+1);
Rho(1,1) = 1;
%Rho = QST.DensityMatrix.Rho_ThermalState(maxFock,1);
Rho = QST.DensityMatrix.DisplaceRho(Rho,2+2j);


% main diagonal
load(strcat(Dir,filesep,"WignerPattern_offD0.mat"));
W = real(sum(reshape(diag(Rho),1,1,[]).*W_Pattern(),3));
% side diagonals
for i = 1:maxFock
    load(strcat(Dir,filesep,"WignerPattern_offD",num2str(i),".mat"));
    D = diag(Rho,i);
    nD = length(D);
    W = W + 2*real(sum(reshape(D,1,1,[]).*W_Pattern(:,:,1:nD),3));
end

% is vacuum fine? YES
% is coherent state shape fine? shape is gaussian, IMPORTANT:
% Wignerfunction is in qp space not alpha space -> amplitude is stretched
% by sqrt(2)
