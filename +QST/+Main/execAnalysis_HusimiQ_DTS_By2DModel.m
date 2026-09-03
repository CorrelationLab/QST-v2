function [SaveStruct] = execAnalysis_HusimiQ_DTS_By2DModel(Options)
%% Description:
%   This function generates and analyses a Husimi Q distribution from two quadrature datasets. The selected
%   quadrature data can be supplied directly or loaded from a MATLAB file. Further one can select data subsets using
%   either index vectors or selected by edge indices,
%
%   The quadratures are optionally rescaled to account for the last beam splitter and differences in the channel
%   photon numbers. A two-dimensional Husimi Q distribution is then generated and analysed using a phase-averaged
%   displaced thermal state (PDTS) model.
%
%   The function returns the Husimi Q distribution, its bin definitions, fitted state parameters, uncertainties,
%   and one-dimensional cut data. Optionally, it creates two- and one-dimensional plots and saves the results.
%
%% Syntax:
%   SaveStruct = execAnalysis_HusimiQ_DTS()
%   SaveStruct = execAnalysis_HusimiQ_DTS(Options)
%
%% Input:
% name-value input options:
%
% quadrature-data options:
%   X1                                              - quadrature data associated with q; can be supplied directly
%                                                     (default: [])
%
%   X2                                              - quadrature data associated with p; can be supplied directly
%                                                     (default: [])
%
%   X1_Indices                                      - indices selecting the data subset of X1 (default: [])
%
%   X2_Indices                                      - indices selecting the data subset of X2 (default: [])
%
%   X1_EdgeIndices                                  - start and end indices defining data subsets of X1 (default: [])
%
%   X2_EdgeIndices                                  - start and end indices defining data subsets of X2 (default: [])
%
%   InputFilePath                                   - path to a MATLAB file from which quadrature data and index data
%                                                     can be loaded (default: '')
%
%   X1String                                        - variable name of X1 in InputFilePath (default: '')
%
%   X2String                                        - variable name of X2 in InputFilePath (default: '')
%
%   X1_IndicesString                                - variable name of X1_Indices in InputFilePath (default: '')
%
%   X2_IndicesString                                - variable name of X2_Indices in InputFilePath (default: '')
%
%   X1_EdgeIndicesString                            - variable name of X1_EdgeIndices in InputFilePath (default: '')
%
%   X2_EdgeIndicesString                            - variable name of X2_EdgeIndices in InputFilePath (default: '')
%
% quadrature-rescaling options:
%   ScaleChannels                                   - logical value specifying whether the quadrature channels are
%                                                     rescaled before generating the Husimi Q distribution
%                                                     (default: true)
%
% Husimi Q-distribution options:
%   Limits_Q                                        - lower and upper limits of the Q-quadrature axis
%                                                     (default: [-10, 10])
%
%   Limits_P                                        - lower and upper limits of the P-quadrature axis
%                                                     (default: [-10, 10])
%
%   Resolution                                      - bin width of the Q- and P-quadrature axes
%                                                     (default: 0.1)
%
% PDTS-analysis options:
%   MonteCarloError                                 - logical value specifying whether parameter uncertainties are
%                                                     estimated using Monte Carlo simulations (default: true)
%
%   nMonteCarloIterations                           - number of Monte Carlo iterations used for uncertainty estimation
%                                                     (default: 1000)
%
%   FitMethod                                       - fitting method passed to the PDTS analysis and plotting functions
%                                                     (default: 'NLSQ-LAR')
%
% plotting options:
%   SaveFigure                                      - logical value specifying whether generated figures are saved
%                                                     (default: true)
%
%   FigureSaveDir                                   - directory in which figures are saved (default: '')
%
%   plot2D                                          - logical value specifying whether the two-dimensional Husimi
%                                                     Q distribution is plotted (default: true)
%
%   FigureSaveName_2D                               - filename of the two-dimensional Husimi Q plot without file
%                                                     extension (default: 'HusimiQ-2D')
%
%   ShowColorBar_2D                                 - logical value specifying whether the color bar is shown in the
%                                                     two-dimensional plot (default: true)
%
%   ShowLegend_2D                                   - logical value specifying whether the legend is shown in the
%                                                     two-dimensional plot (default: true)
%
%   plot1D                                          - logical value specifying whether the one-dimensional cut along
%                                                     P = 0 is plotted (default: true)
%
%   FigureSaveName_1D                               - filename of the one-dimensional Husimi Q cut plot without
%                                                     file extension (default: 'HusimiQ-1D')
%
%   ShowLegend_1D                                   - logical value specifying whether the legend is shown in the
%                                                     one-dimensional plot (default: true)
%
% result-saving options:
%   SaveResults                                     - logical value specifying whether SaveStruct is saved to a MATLAB
%                                                     file (default: false)
%
%   ResultSaveDir                                   - directory in which the result file is saved (default: '')
%
%   ResultSaveName                                  - name of the result file (default: '')
%
%   ResultSaveVariable                              - variable name under which SaveStruct is stored in the result file
%                                                     (default: 'Results_HusimiQ')
%
%% Output:
%   SaveStruct                                      - structure containing the Husimi Q distribution and PDTS
%                                                     analysis results:
%
%       HusimiQ                                     - two-dimensional Husimi Q distribution
%       Bins_Q, Bins_P                              - bin-center vectors of the Q- and P-quadrature axes
%       Edges_Q, Edges_P                            - bin-edge vectors of the Q- and P-quadrature axes
%       nTherm, nThermErr                           - thermal photon number and its uncertainty
%       nCoherent, nCoherentErr                     - coherent photon number and its uncertainty
%       nMean, nMeanErr                             - mean photon number and its uncertainty
%       nRatio, nRatioErr                           - coherent-to-total photon-number ratio and its uncertainty
%       G2, G2Err                                   - second-order correlation function g^{(2)}(0) and its
%                                                     uncertainty
%       Coherence, CoherenceErr                     - coherence and its uncertainty
%       PoissonError                                - Poisson error estimate of the Husimi Q distribution
%       PoissonErrorCut                             - Poisson error estimate of the one-dimensional P = 0 cut
%       HusimiCut                                   - one-dimensional Husimi Q cut along P = 0
%       HusimiCutTheory                             - fitted theoretical Husimi Q cut along P = 0
%
%% Notes:
%   If SaveResults is true, the result structure is dynamically assigned to the variable name specified by
%   ResultSaveVariable before it is saved.



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
        Options.Limits_Q = [-10,10];
        Options.Limits_P = [-10,10];
        Options.Resolution = 0.1;
        % Options for the PDTS analysis
        Options.MonteCarloError = true;
        Options.nMonteCarloIterations = 1000;
        Options.FitMethod = 'NLSQ-LAR';
        %Options for the plots
        Options.SaveFigure = true;
        Options.FigureSaveDir = '';
        Options.plot2D = true;
        Options.FigureSaveName_2D = 'HusimiQ-2D';
        Options.ShowColorBar_2D = true;
        Options.ShowLegend_2D = true;
        Options.plot1D = true;
        Options.FigureSaveName_1D = 'HusimiQ-1D';
        Options.ShowLegend_1D = true;                                 
        % save the results
        Options.SaveResults = false;
        Options.ResultSaveDir = '';
        Options.ResultSaveName = '';
        Options.ResultSaveVariable = 'Results_HusimiQ';
    
    
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
    
    %% 3. generate the husimi Q distribution
    [HusimiQ,...
     Bins_Q,...
     Bins_P,...
     Edges_Q,...
     Edges_P] = QST.HusimiQ.Generate.generateHusimiQ(X1,...
                                                     X2,...
                                                     Limits_Q = Options.Limits_Q,...
                                                     Limits_P=Options.Limits_P,...
                                                     Resolution=Options.Resolution);

    % save the results into the struct
    SaveStruct.HusimiQ = HusimiQ;
    SaveStruct.Bins_Q = Bins_Q;
    SaveStruct.Bins_P = Bins_P;
    SaveStruct.Edges_Q = Edges_Q;
    SaveStruct.Edges_P = Edges_P;


    %% 4. analyze the Husimi Q distribution in the model of the displaced thermal state, state needs to be phaseaveraged

   [nCoherent,...
    nCoherentErr,...
    nTherm,...
    nThermErr,...
    nMean,...
    nMeanErr,...
    nRatio,...
    nRatioErr,...
    G2,...
    G2Err,...
    Coherence,...
    CoherenceErr,...
    PoissonError,...
    PoissonErrorCut,...
    HusimiCut,...
    HusimiCutTheory] = QST.HusimiQ.Analyze.analyzeHusimiQ_PDTS_Main(Bins_Q,...
                                                                    HusimiQ,...
                                                                    Options.Resolution,...
                                                                    length(X1),...
                                                                    MonteCarloError=Options.MonteCarloError,...
                                                                    nMonteCarloIterations=Options.nMonteCarloIterations,...
                                                                    FitMethod=Options.FitMethod);


   % save the results from the PDTS analysis into the savestruct
    SaveStruct.nTherm = nTherm;
    SaveStruct.nThermErr = nThermErr;
    SaveStruct.nCoherent = nCoherent;
    SaveStruct.nCoherentErr = nCoherentErr;
    SaveStruct.nMean = nMean;
    SaveStruct.nMeanErr = nMeanErr;
    SaveStruct.nRatio = nRatio;
    SaveStruct.nRatioErr = nRatioErr;
    SaveStruct.G2 = G2;
    SaveStruct.G2Err = G2Err;
    SaveStruct.Coherence = Coherence;
    SaveStruct.CoherenceErr = CoherenceErr;
    SaveStruct.PoissonError = PoissonError;
    SaveStruct.PoissonErrorCut = PoissonErrorCut;
    SaveStruct.HusimiCut = HusimiCut;
    SaveStruct.HusimiCutTheory = HusimiCutTheory;


    %% 5. Plot the 2D Distribution
    if Options.plot2D
        QST.HusimiQ.Plot.plotHusimiQ_2D(Bins_Q,...
                                        Bins_P,...
                                        HusimiQ,...
                                        SaveFigure=Options.SaveFigure,...
                                        SaveDir=Options.FigureSaveDir,...
                                        SaveName = Options.FigureSaveName_2D,...
                                        FitMethod=Options.FitMethod,...
                                        ShowColorBar=Options.ShowColorBar_2D,...
                                        ShowLegend=Options.ShowLegend_2D,...
                                        nTherm=nTherm,...
                                        nThermErr=nThermErr,...
                                        nCoherent=nCoherent,...
                                        nCoherentErr=nCoherentErr,...
                                        G2=G2,...
                                        G2Err=G2Err,...
                                        Coherence=Coherence,...
                                        CoherenceErr=CoherenceErr);
    end
    

    %% 6. Plot the 1D Cut along the P=0 axis
    if Options.plot1D
        QST.HusimiQ.Plot.plotHusimiQ_1DCut(Bins_Q,...
                                           HusimiCut,...
                                           HusimiCutTheory,...
                                           PoissonErrorCut,...
                                           SaveFigure=Options.SaveFigure,...
                                           SaveDir=Options.FigureSaveDir,...
                                           SaveName=Options.FigureSaveName_1D,...
                                           ShowLegend=Options.ShowLegend_1D,...
                                           FitMethod=Options.FitMethod,...
                                           nTherm=nTherm,...
                                           nCoherent=nCoherent);
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