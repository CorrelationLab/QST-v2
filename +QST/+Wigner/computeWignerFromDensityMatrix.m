function [Wigner] = computeWignerFromDensityMatrix(Rho, Directory_WignerTable)
%% Description:
%   This function takes a densitymatrix in fock representation Rho and uses a WignerTable created with 'QST.Wigner.computeWignerTable' to construct the
%   associated Wigner distribution. More information are found in my thesis p. 52 
%% Syntax:
%   [Wigner] = QST.Wigner.computeWignerFunctionFromDensityMatrix(Rho, Directory_WignerTable)
%
%% Input:
% required input values;
%   Rho                                             - densitymatrix of the state of interest
%   Directory_WignerTable;                          - directory to the prior constructed WignerTable
%
%% Output:
%   Wigner                                          - Wigner function associated with the density matrix. Resolution and size are determined by the Wigner table



    arguments
        Rho;
        Directory_WignerTable;
    end


    %% 1. Computation based on the main diagonal elements
    W_Pattern = load(strcat(Directory_WignerTable,filesep,"WignerPattern_offD0.mat"));
    Wigner = real(sum(reshape(diag(Rho),1,1,[]).*W_Pattern(:,:,1:size(Rho,1)),3));
    MaxFockState = size(Rho,1)-1;
    
    %% 2. Computation based on the side diagonal elements
    for i = 1:MaxFockState
        W_Pattern = load(strcat(Directory_WignerTable,filesep,"WignerPattern_offD",num2str(i),".mat"));
        D = diag(Rho,i);
        nD = length(D);
        Wigner = Wigner + 2*real(sum(reshape(D,1,1,[]).*W_Pattern(:,:,1:nD),3));
    end
end

