function [SaveStruct] = execAnalysis_HusimiQ_DTS_By1DModel(Options)
% This function analyzes a quadrature set in terms of the phase averaged displaced thermal state model
% For this scheme to work it is important that the state is rotation-symmetric
% In this case one can investigate instead of the 2D phase space distribution the associated phi integrated version which has the form
% Q_1D(|alpha|) = 2*pi*|alpha|*Q_2D(|alpha|)
% By calculating first the |alpha| values associated to the quadrature pairs (q,p) and then second execute the histogram, we are able
% to use the full precision of the measured quadrature values since the number of bins scales inverse-linear with bin resolution and not quadratic
% as in the 2D case. This allows to use either a better binning resolution or the use on smaller datasets without losing precision.
% However one has still to do first a 2D analysis to check if the state is indead rotation symmetric as this cannot ensured from the 1D graph.

% Version Number:
% 1.0 % initial version


% Constraints of this analysis program compared to the 2D case
%   - The poissonErrors are not yet implemented
%   - The Monte Carlo error estimation is not included. Therefore Ratio and g2 have no Errors
%   - nMean is not included
%   - The analysis methods do not have yet separate subfunctions
%   - There is not yet a numeric way to estimate automatically start parameter for the fit.
%     Since our photon numbers are usually small they are set right now on nTherm = 1, nCoherent = 5


arguments
    % Options for the quadratures and their indices
    Options.X1 = [];
    Options.X2 = [];
    Options.X1_Indices = [];
    Options.X2_Indices = [];
    Options.X1_EdgeIndices = [];
    Options.X2_EdgeIndices = [];
    Options.InputFilePath = '';
    Options.X1String = '';
    Options.X2String = '';
    Options.X1_IndicesString = '';
    Options.X2_IndicesString = '';
    Options.X1_EdgeIndicesString = '';
    Options.X2_EdgeIndicesString = '';
    % Options for quadrature rescaling
    Options.ScaleChannels = true;
    % Options for the generation of the Husimi Q distribution 
    Options.Limits_R = 10;
    Options.Resolution = 0.01;
    % Options for the PDTS analysis
    %Options.MonteCarloError = true;
    %Options.nMonteCarloIterations = 1000;
    Options.FitMethod = 'NLSQ-LAR';
    %Options for the plots
    Options.plotData = true;
    Options.ShowLegend = true;
    Options.SaveFigure = true;
    Options.FigureSaveDir = '';
    Options.SaveName = 'HusimiQ-PhiIntegrated';                          
    % save the results
    Options.SaveResults = false;
    Options.ResultSaveDir = '';
    Options.ResultSaveName = '';
    Options.ResultSaveVariable = 'Results_HusimiQ_RadialFit';


end



    %% 1. load the selected quadrature subset
    [X1,X2] = QST.HusimiQ.Prepare.prepareDataSubSetForHusimiQ(X1=Options.X1,...
                                                              X2=Options.X2,...
                                                              X1_Indices=Options.X1_Indices,...
                                                              X2_Indices=Options.X2_Indices,...
                                                              X1_EdgeIndices=Options.X1_EdgeIndices,...
                                                              X2_EdgeIndices=Options.X2_EdgeIndices,...
                                                              FilePath=Options.InputFilePath,...
                                                              X1String=Options.X1String,...
                                                              X2String=Options.X2String,...
                                                              X1_IndicesString=Options.X1_IndicesString,...
                                                              X2_IndicesString=Options.X2_IndicesString,...
                                                              X1_EdgeIndicesString=Options.X1_EdgeIndicesString,...
                                                              X2_EdgeIndicesString=Options.X2_EdgeIndicesString);
    
    %% 2. rescale the quadratures to the point before the last beamsplitter and fix differences in the photon numbers
    [X1,X2] = QST.HusimiQ.Prepare.rescaleQuadsForHusimiQ(X1,X2,ScaleChannels=Options.ScaleChannels);
    

    %% 3. generate the phase averaged Husimi Q distribution only dependent on the radial component

    % 3.1 calculate the quadratures radial component in alpha space
    XR = 1/sqrt(2)*sqrt(X1.^2+X2.^2);


    % create the quadrature histogram based on the radial component. The lower limit begins always at 0.
    Edges_R = [0:Options.Resolution:Options.Limits_R];
    Bins_R = (Edges_R(1:end-1) + Edges_R(2:end))/2;
    [HusimiQ_Radial] = histcounts(XR,Edges_R,Normalization="pdf");
    
    % save the results into the struct
    SaveStruct.HusimiQ_Radial = HusimiQ_Radial;
    SaveStruct.Bins_R = Bins_R;
    SaveStruct.Edges_R = Edges_R;


    %% 4. analyze the Husimi Q distribution in the model of the displaced thermal state, state needs to be phaseaveraged
    % Define the fit function: phi integrated phase averaged Husimi-Q distribution in polar coordinates
    FitFunction = fittype('2*pi*x*(pi*(a1+1))^-1 *exp(-(x.^2 + b1)/(a1+1)) .* besseli(0,2*x*sqrt(b1)/(a1+1))'); % 
    
    % Get start parameter:

    % Execute the fit
    [Params,gof,~] = fit(Bins_R(:),HusimiQ_Radial(:),FitFunction,'StartPoint', [1,5],'Lower',[0,0],'Robust','LAR' );
    % Store the found values for coherent and thermal photon number
    nTherm = Params.a1;
    nCoherent = Params.b1;
    % derive nRatio, g2 and the quantum coherence from both photon numbers using the dispplaced thermal state model
    nRatio = nCoherent/nTherm;
    G2 = 2 - (nCoherent/(nCoherent+nTherm))^2;
    Coherence = QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent,nTherm);

    % Estimate the standard uncertainties for nTherm and nCoherent from the gof
    StandardErrors = QST.Helper.getStandardErrorsFromFit(Params,gof,'method1');
    nThermErr = StandardErrors(1);
    nCoherentErr = StandardErrors(2);
    % Estimate the uncertainties for the quantum coherence using error propagation
    [~, CoherenceErr,~, ~] = QST.Helper.error_propagation( @(nCoherent,nTherm) QST.Simulation.QuantumCoherence.coherencePDTS(nCoherent,nTherm),...
                                                          nCoherent, ...
                                                          nTherm, ...
                                                          nCoherentErr, ...
                                                          nThermErr);
    CoherenceErr(isnan(CoherenceErr)) = 0;

    % The uncertainties for nRatio and g2 were calculated using using monte carlo based uncertainty estimation.
    % As it is not yet implemented for the 1D analysis methods the uncertainties are set to 0 for now.
    % 0 means in this context that no error was calculated.
    % Iam not yet sure if one could calculate both uncertainties also using regular error propagation, but I guess Monte Carlo is the better approach
    nRatioErr = 0;
    G2Err = 0;
    
    % calculate the Fit function based on the displaced thermal state model to be able to compare the quality of the fit
    HusimiQ_Radial_Theory = 2*pi*Bins_R.*(pi*(nTherm+1))^-1 .*exp(-(Bins_R.^2 + nCoherent)/(nTherm+1)) .* besseli(0,2*Bins_R*sqrt(nCoherent)/(nTherm+1));

    % save the results from the PDTS analysis into the savestruct
    SaveStruct.nTherm = nTherm;
    SaveStruct.nThermErr = nThermErr;
    SaveStruct.nCoherent = nCoherent;
    SaveStruct.nCoherentErr = nCoherentErr;
    SaveStruct.nRatio = nRatio;
    SaveStruct.nRatioErr = nRatioErr; 
    SaveStruct.G2 = G2;
    SaveStruct.G2Err = G2Err;
    SaveStruct.Coherence = Coherence;
    SaveStruct.CoherenceErr = CoherenceErr;
    SaveStruct.HusimiQ_Radial = HusimiQ_Radial;
    SaveStruct.HusimiQ_Radial_Theory = HusimiQ_Radial_Theory;


    %% 5. Plot the 2D Distribution
    if Options.plotData
        %% 1. create 1D Graph for the Data
        Fig(1) = figure;
        Line = plot(Bins_R, HusimiQ_Radial,LineWidth=1);
        Line.DisplayName= 'Data';
        hold on;
        %% 2. create Graph for the optimal fit with a displaced thermal state integrated along phi
        if Options.ShowLegend
            plot(Bins_R,HusimiQ_Radial_Theory,'r',LineWidth=1, DisplayName=['Theory, n_{Th} = ', num2str(nTherm,'%.4f'), ', n_{Coh} = ', num2str(nCoherent,'%.4f')]);
        else
            plot(Bins_R,HusimiQ_Radial_Theory,'r',LineWidth=1)
        end
        %% 3. set the axis labels
        xlabel('|alpha|');
        legend('location','southwest');
        QST.Helper.graphicsSettings();% a function from carolin to set some plotmaker properties
        Axes = gca;
        set(Axes,fontsize=50,fontname='Arial',linewidth=3);
        Resolution = abs(Bins_R(2)-Bins_R(1));
        Axes.XLim = [Bins_R(1)-Resolution/2, Bins_R(end)+Resolution/2];
        %% 4. Save the plot
        if Options.SaveFigure
            assert(~isequal(Options.FitMethod,''),'No Fitmethod given');
            SaveNameFull = strcat(Options.SaveName, '-Resolution', num2str(Resolution), '-FitMethod-', Options.FitMethod, '-IncludesResults-', string(Options.ShowLegend),'.fig');
            if ~exist(Options.FigureSaveDir,'dir')
                mkdir(Options.FigureSaveDir);
            end
            SavePath = fullfile(Options.FigureSaveDir, SaveNameFull);
            savefig(Fig,SavePath);
        end
    end

    %% 7. Save the Results
    if Options.SaveResults
        ResultSavePath = fullfile(Options.ResultSaveDir,Options.ResultSaveName);
        eval([Options.ResultSaveVariable '= SaveStruct;']); % rename the Variable . This is a bad design
        if exist(ResultSavePath,'file')
            save(ResultSavePath,Options.ResultSaveVariable, '-append');
        else
            if ~exist(Options.ResultSaveDir,'dir')
                mkdir(Options.ResultSaveDir);
            end
            save(ResultSavePath,Options.ResultSaveVariable);
        end
    end
end