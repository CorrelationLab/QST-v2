function [rho,history] = computeDensityMatrix( X, theta, varargin )
%COMPUTEDENSITYMATRIX Summary of this function goes here
%
%   X and THETA must ...
%       - be 1D-Arrays
%       - have their NaN values at the same places.
%
% Optional Input Arguments:
%   'Iterations': Default is 100. How many iterations take place in a loop.
%   'Threshold': EXPERIMENTAL. Default is 0. Stop loop,
%       when |rho - nextrho| < threshold.

%% Validate and parse input arguments
p = inputParser;
defaultDebug = false;
addParameter(p,'Debug',defaultDebug,@islogical);
defaultHistory = false;
addParameter(p,'History',defaultHistory,@islogical);
defaultIterations = 50;
addParameter(p,'Iterations',defaultIterations,@isnumeric);
defaultMaxFockState = 100;
addParameter(p,'MaxFockState',defaultMaxFockState,@isnumeric);
defaultRho = [];
addParameter(p,'Rho',defaultRho,@ismatrix);
defaultThreshold = 0;
addParameter(p,'Threshold',defaultThreshold,@isnumeric);
parse(p,varargin{:});
c = struct2cell(p.Results);
[debug,historyOpt,N_ITERATIONS,maxFockState,nextRho,threshold] = c{:};

if isempty(nextRho)
    nextRho = QST.DensityMatrix.normalize(ones(maxFockState+1,maxFockState+1));
end

% Stripping off NaN values
QST.Helper.dispstat('','init');
QST.Helper.dispstat('Strip X and THETA off their NaN values.','timestamp','keepthis');
if sum(isnan(X))~=sum(isnan(theta))
    warning(['X and THETA should have the same ',...
        'length after stripping all NaN values!']);
end
Xtp = X(~isnan(theta) & ~isnan(X));
theta = theta(~isnan(theta) & ~isnan(X));
X = Xtp;
clear Xtp;

%% History
% The _history_ variable will contain all calculated density
% matrices. It is only saved when the output is required.
if historyOpt
    history = zeros(maxFockState+1,maxFockState+1,N_ITERATIONS);
end

%% Iteration
PI1D = QST.DensityMatrix.computeProjector1D( X, theta, maxFockState);
 %G =PI1D*PI1D';
nX = length(X);
%prob = zeros(nX, 1);
for iRho = 1:N_ITERATIONS
    % Iteration operator R = sum_i(Projector(theta_i,x_i)/prob_thetai(x_i))
    % Iteration: rho_k+1 = norm(R rho_k R)
    %QST.Helper.dispstat(['Iteration: ' num2str(iRho) ' of ' ...
    %    num2str(N_ITERATIONS) '.'], 'timestamp');
    rho = nextRho;
    
    %rho = G^-0.5*nextRho* G^-0.5;
    %R = QST.DensityMatrix.computeR(PI1D,rho,nX,maxFockState);
    %tic
    %R = QST.DensityMatrix.computeR_Matrix(PI1D,rho,nX);
    %toc
    R = QST.DensityMatrix.computeR_MatrixGPU(PI1D,rho,nX);
   % RG = G^-0.5 * R * G^-0.5;
   
    %nextRho = RG * nextRho * RG; 

    nextRho = R * rho * R; % ITERATION step
    nextRho = QST.DensityMatrix.normalize(nextRho); % normalization
    
    % Update history output
    if historyOpt
        history(:,:,iRho) = nextRho;
    end
    
    % Stop when change is smaller than threshold
    if sum(sum(abs(rho-nextRho))) < threshold
        rho = nextRho;
        QST.Helper.dispstat(['Iteration: ',num2str(iRho),' of ', ...
            num2str(N_ITERATIONS),'. Threshold reached!'], ...
            'timestamp','keepthis');
        break;
    end
    
    % Plot in debug mode
    if debug
        QST.DensityMatrix.plotRho(nextRho);
        pause(1);
    end
    %profile viewer
end

end
