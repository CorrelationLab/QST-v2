function [ NCoherent, NThermal] = fitDTSToWigner(Wigner, QAxis, Options)
%% Description:
%   This function takes a Wignerfunction and an array to reconstruct the Q and P axis and applies a 2D-gaussian fit to extract the coherent and Thermal photon number 
%% Syntax:
%   [ NCoherent, NThermal] = fitDTSToWigner(Wigner, QAxis, Options)
%
%% Input:
% required input values;
%   Wigner                                          - Wigner function of a DTS
%   QAxis;                                          - axis data of the Q or P axis
%
% optional input values;
%   Options.InitialParameterGuess = [1,0,50,0,50]   - initial guess for the fit parameters. the parameters are: 
%                                                     [Amplitude, sigmax, y0, sigmay, angel(in rad)]
%
%% Output:
%   NCoherent                                       - coherent photon number
%   NThermal                                        - thermal photon number 



    arguments
        Wigner;
        QAxis;
        Options.InitialParameterGuess = [1,0,50,0,50]
    end



    %% 1. Set up the Q-P grid
    [QQ,PP] = meshgrid(QAxis);
    QPData = zeros(size(QQ,1),size(PP,2),2);
    QPData(:,:,1) = QQ;
    QPData(:,:,2) = PP;

    %% 2. Execute the fit
    MdataSize = size(Wigner,1); % Size of nxn data matrix
    LowerBoundary = [0,-MdataSize/2,0,-MdataSize/2,0];
    UpperBoundary = [realmax('double'),MdataSize/2,(MdataSize/2)^2,MdataSize/2,(MdataSize/2)^2];
    [FitParameter,resnorm,residual,exitflag] = lsqcurvefit(@D2GaussFunction, Options.InitialParameterGuess, QPData, Wigner, LowerBoundary, UpperBoundary);
    Q_Center = FitParameter(2);
    Q_Sigma = FitParameter(3);
    P_Center = FitParameter(4);
    P_Sigma = FitParameter(5);

    %% 3. Compute the thermal and coherent photon numbers
    NThermal = 0.5*((Q_Sigma^2)-0.5 + (P_Sigma^2)-0.5); % average thermal photon number in q and p
    NCoherent = 0.5*(Q_Center^2+P_Center^2);
end




function [Gaussian2D] = D2GaussFunction(Parameter, GridData)
%% Description:
%   This function takes a set of parameters and a 2d grid and computes the corresponding 2d gaussian distribution 
%% Syntax:
%   [Gaussian2D] = D2GaussFunction(x, xdata)
%
%% Input:
% required input values;
%   Parameter                           - parameter that describes the 2d gaussian [Amplitude, sigmax, y0, sigmay, angel(in rad)]
%   GridData                            - coordinate grid for the computation 
%
%% Output:
%   Gaussian2D                          - two dimensional gaussian



    arguments
        Parameter;
        GridData;
    end


    Gaussian2D = Parameter(1)*exp(-((GridData(:,:,1)-Parameter(2)).^2/(2*Parameter(3)^2) + (GridData(:,:,2)-Parameter(4)).^2/(2*Parameter(5)^2)));
end