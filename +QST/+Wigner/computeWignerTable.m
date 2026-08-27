function [] = computeWignerTable(SaveDirectory, MaxQ, ResolutionQ, MaxFockState)
%% Description:
%   This function computes a table of constructing functions that are necessary to compute the wigner function from an arbitrary density matrix in fock representation.
%   To fasten up the computation this function requires a GPU. The table is finally saved in SaveDirectory. the data is saved as 3d arrays where one 
%   3d array includes the data of one upper side diagonal. The files are called 'WignerPattern_offD'. The used parameters are saved in a file called 'WignerPattern_GridInfo'
%   The fourier transformation included in the formula is executed by a discrete summation over the quantum step variable zeta whereby zeta goes from -2*MaxQ to 2*MaxQ. 
%   The integration is then performed in terms of matrix multiplications. 
%   More information are found in my thesis p. 52
%% Syntax:
%   [] = createWignerTable_GPU(Directory, MaxQ, ResolutionQ, MaxFockState)
%
%% Input:
% required input values;
%   SaveDirectory                                   - array of quadratures. The array can be multidimensional
%   MaxQ;                                           - maximal Q of the considered phase space. The phasespacevariables Q and P then lay in the interval [-MaxQ, MaxQ]
%   ResolutionQ;                                    - resolution of the phase space
%   MaxFockState;                                   - maximal fock state up to which components are taken into account
%
%% Output:
%



    arguments
        SaveDirectory;
        MaxQ;
        ResolutionQ;
        MaxFockState;
    end


    %% 0. Set up the fourier transform variable zeta associated with the quantum step
    maxZeta = 2*MaxQ;
    stepsizeZeta = ResolutionQ;
    
    %% 1. Compute a matrix of all possible occuring values Q+zeta/2 called QplusZetaH
    Q = gpuArray([-MaxQ:ResolutionQ:MaxQ]);
    Zeta = gpuArray([-maxZeta:stepsizeZeta:maxZeta]);
    nQ = length(Q); % number of Q values
    nZeta = length(Zeta); % number of Zeta values
    QplusZetaH = Q+(Zeta/2).'; % axis1: different Zeta, axis2: different Q
    
    
    %% 2. Compute the projections <n,Q+Zeta/2> ; axis1: variation in Zeta, axis2: variation in Q, axis3: variation in n
    Projection__n_QplusZetaH = gpuArray(zeros(nZeta,nQ,MaxFockState+1));
    Projection__n_QplusZetaH(:,:,1) = pi^(-0.25)*exp(-0.5*QplusZetaH.^2);
    Projection__n_QplusZetaH(:,:,2) = Projection__n_QplusZetaH(:,:,1).*QplusZetaH*sqrt(2);
    for i = [3:MaxFockState+1]
        Projection__n_QplusZetaH(:,:,i) = sqrt(2/(i-1))*QplusZetaH.*Projection__n_QplusZetaH(:,:,i-1)-sqrt((i-2)/(i-1))*Projection__n_QplusZetaH(:,:,i-2);
    end

    %% 3. Compute the projections <q-zeta,m> ; axis1: Zeta, axis2:Q, axis3:m. 
    %% As the integration interval is symmetric around 0 they can be ascessed from Projection__n_QplusZetaH
    Projection__QminusZetaH_m = flip(Projection__n_QplusZetaH,1);
    
    
    %% 4. Construct the expontial terms of the fourier transform; axis1: variation in Zeta, axis2: variation in P
    P = Q;
    nP = nQ;
    EXP = exp(-1j*Zeta.'*P);
    
    %% 5. Perform the Fourier transformation to obtain the weight matrices W_mn for individual m and n. As W_mn is self adjunct it is 
    %% suifficient to compute the elements for the upper triangular part of the density matrix. The matrices are saved in 3d arrays
    %% whereby one array corresponds to the matrices of one diagonal   
    if ~isfolder(SaveDirectory)
        mkdir(SaveDirectory)
    end
    for i = 0:MaxFockState
        W_Pattern = gpuArray(complex(zeros(nP,nQ,MaxFockState+1-i)));
        for j = i+1:MaxFockState+1
            W_Pattern(:,:,j-i) = ((Projection__n_QplusZetaH(:,:,j-i).*Projection__QminusZetaH_m(:,:,j)).'*EXP).';
        end
        W_Pattern = (1/(2*pi))*stepsizeZeta*W_Pattern;
        W_Pattern = complex(gather(real(W_Pattern)),gather(imag(W_Pattern)));
        save(strcat(SaveDirectory,filesep,'WignerPattern_offD',num2str(i)),'W_Pattern','-v6');
    end

    %% save the used grid parameters in an extra file
    GridInfo.minQ = -MaxQ;
    GridInfo.maxQ = MaxQ;
    GridInfo.minP = -MaxQ;
    GridInfo.maxP = MaxQ;
    GridInfo.stepQ = ResolutionQ;
    GridInfo.stepP = ResolutionQ;
    GridInfo.maxFock = MaxFockState;
    save(strcat(SaveDirectory,filesep,'WignerPattern_GridInfo'),'GridInfo','-v6');
