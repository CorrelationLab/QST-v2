function [] = postSelectOrthogonal(FilePath, X_PsFast, X_PsSlow, X_Target, Options)
% POSTSELECTORTHOGONAL Takes a 3 Channel Measurement Quadrature File and
% calculates the Phase Theta between the Target Channel (X_Target) and the Postselection Channel with the faster Piezo
% Movement (X_PsFast) as well as an orthogonal Data Subset of all Quadratures and Phase regarding the Orthogonality
% between the two PostSelection Channels (X_PsFast and X_PsSlow). The
% Result can then be saved to the already existing File or to a new one.
%
% INPUTS:
% FilePath :                    FilePath to the .mat File which includes
%                               the calculated Quadratures (normally called X1 ... Xn)
% X_PsFast :                    String which corresponds to the VariableName
%                               of the PostSelection Channel with the fast Piezo Movement
% X_PsSlow :                    String which corresponds to the VariableName
%                               of the PostSelection Channel with the slow Piezo Movement
% X_Target :                    String which corresponds to the VariableName
%                               of the TargetChannel
%
%
% OPTIONS GENERAL:
% SaveFilePath:                 Path to the File where the result should be saved. By Default
%                               the calculated Quantities are appended to original File
% SaveTheta :                   Bool which decides if the not postselected Theta should be saved. Default is false
%
%
% OPTIONS MODULATION REMOVAL:
% ModFix_Done :                                 Bool which decides if the result should be cleaned from may occured
%                                               Photonnumberchanges during the recording of the Measurementseries. Default is true
% ModFix_N_PsFast_SeriesMean :                  MeanPhotonnumber in PsFast Channel of the
%                                               whole Series. Has to be calculated before executing this function. By
%                                               Default it is 0, which is understand by the code as unknown and which
%                                               lets the programm fail.
% ModFix_N_PsSlow_SeriesMean :                  MeanPhotonnumber in PsSlow Channel of the
%                                               whole Series. Has to be calculated before executing this function. By
%                                               Default it is 0, which is understand by the code as unknown and which
%                                               lets the programm fail.
% ModFix_N_Target_SeriesMean :                  MeanPhotonnumber in Target Channel of the
%                                               whole Series. Has to be calculated before executing this function. By
%                                               Default it is 0, which is understand by the code as unknown and which
%                                               lets the programm fail.
% ModFix_N_Range :                              Range of allowed Photonumbers. By Default it is [0,20].
%    
%
% OPTIONS PHASECALCULATION:
% CalcPhase_PeriodsPerSegment :                 Guessed count of occuring phasepasses in
%                                               the Crosscorelation of X_PsFast and
%                                               X_Target. Default is 4.
% CalcPhase_PeakThreshold :                     Relative Threshold (compared to Segments Maximum) for Detection of Peaks.
%                                               Default is 0.5
% CalcPhase_IgnoredSegments:                    Array of Indices of in the calculation
%                                               ignored Segments. Default is []
% CalcPhase_Smoothing_Type :                    Type of Crosscorrelationsmoothing used in
%                                               the Phasecalculationprocess. Default is 'Spline'.
% CalcPhase_Smoothing_Accuracy_Spline :         Accuracy of the Spline Interpolation Method for the
%                                               CrossCorrelation Smoothing used in the Phasecalculationprocess. Default is 1e-14.
% CalcPhase_Smoothing_Accuracy_MovingAverage :  Accuracy of the Moving Window Average Method for the
%                                               CrossCorrelation Smoothing used in the Phasecalculationprocess. Default is 20.
%
%
% OPTIONS POSTSELECT ORTHOGONAL
% PostOrth_OrthWidth :                          Relative Width of the Window around zero, which is used in the process to postselect the
%                                               orthogonal subset. The width is relative to the Segments maximum. The width includes the
%                                               values to both direction eg. 5% means from -2.5% to 2.5%
% PostOrth_Shift :                              Shiftconstant which is used to differ between phases of pi/2 and 3/2pi. Is by Default 10000 
%                                               Points and most probably can be left like that.
% PostOrth_Smoothing_Type :                     Type of Crosscorrelationsmoothing used in
%                                               the Postselecting Orthogonal Process. Default is 'Spline'.
% PostOrth_Smoothing_Accuracy_Spline :          Accuracy of the Spline Interpolation Method for the
%                                               CrossCorrelation Smoothing used in the Postselecting Orthogonal Process. Default is 1e-15.
% PostOrth_Smoothing_Accuracy_MovingAverage :   Accuracy of the Moving Window Average Method for the
%                                               CrossCorrelation Smoothing used in the Postselecting Orthogonal Process. Default is 20.
%
%
% OUTPUTS:
% None
%
% THE FOLLOWING COULD BE EXPLAINED IN MORE DETAIL
%
% SAVE TO FILE:
% X_PsFast_Orth :                               Orthogonal Quadrature Subset for the PostSelection Channel with the faster Piezomodulation    
% X_PsSlow_Orth :                               Orthogonal Quadrature Subset for the PostSelection Channel with the slower Piezomodulation
% X_Target_Orth :                               Orthogonal Quadrature Subset for the Target Channel
% Theta_Orth :                                  Orthogonal Subset for Theta, the Phase between PsFast and Target
% -> SaveFilePath
%
% All Input Options:
% -> SaveFilePath -> Quantities.InputOptions.PostOrth_3Ch
% PhotonNumbers:                                
% -> SaveFilePath -> Quantities.Analysis.PhotoNumbers

    arguments(Input)
        FilePath
        X_PsFast
        X_PsSlow
        X_Target
        %
        Options.SaveFilePath = FilePath
        Options.SaveTheta = true
        % Modulation Removal
        Options.ModFix_Done = true
        Options.ModFix_N_PsFast_SeriesMean = 0 % maybe NaN works better for user convienience
        Options.ModFix_N_PsSlow_SeriesMean = 0
        Options.ModFix_N_Target_SeriesMean = 0
        Options.ModFix_N_Range = [0,20]
        % PhaseCalculation
        Options.CalcPhase_PeriodsPerSegment {mustBeNonnegative} = 4
        Options.CalcPhase_PeakThreshold {mustBeInRange(Options.CalcPhase_PeakThreshold,0,1)} = 0.5
        Options.CalcPhase_IgnoredSegments = []
        Options.CalcPhase_Smoothing_Type {mustBeMember(Options.CalcPhase_Smoothing_Type, ["Spline","MovingAverage"])} = "Spline"
        Options.CalcPhase_Smoothing_Accuracy_Spline {mustBeInRange(Options.CalcPhase_Smoothing_Accuracy_Spline,0,1)} = 1e-14;
        Options.CalcPhase_Smoothing_Accuracy_MovingAverage {mustBeNonnegative} = 20;
        % PostSelection Orthogonal
        Options.PostOrth_OrthWidth = 0.05;
        Options.PostOrth_Shift {mustBeInteger, mustBeNonnegative} = 10000;
        Options.PostOrth_Smoothing_Type {mustBeMember(Options.PostOrth_Smoothing_Type, ["Spline","MovingAverage"])} = "Spline";
        Options.PostOrth_Smoothing_Accuracy_Spline {mustBeInRange(Options.PostOrth_Smoothing_Accuracy_Spline,0,1)} = 1e-15;
        Options.PostOrth_Smoothing_Accuracy_MovingAverage {mustBeNonnegative} = 20;

    end
    

    %% 1. In Case of wanted RemoveModulation, check that the Photonumbers exists and that the Range makes sense
    if Options.ModFix_Done == true
        assert((Options.ModFix_N_PsFast_SeriesMean > 0) && (Options.ModFix_N_PsSlow_SeriesMean > 0) && (Options.ModFix_N_Target_SeriesMean));
        assert((Options.ModFix_N_Range(1) >= 0) && (Options.ModFix_N_Range(2) >= 0) && (Options.ModFix_N_Range(1) < Options.ModFix_N_Range(2)));
    end
    
    %% Load Data and assign the Channels to it
    Variables = {whos('-file',FilePath).name};
    assert(all(ismember({X_PsFast,X_PsSlow, X_Target, 'piezoSign'}, Variables)))

    if ismember('Quantities', Variables)
        MatData = {X_PsFast, X_PsSlow, X_Target, 'piezoSign', 'Quantities'};
        MatData = load(FilePath, MatData{:});
        Quantities = MatData.('Quantities');
    else
        MatData = {X_PsFast, X_PsSlow, X_Target, 'piezoSign'};
        MatData = load(FilePath, MatData{:});
    end
        X_PsFast = MatData.(X_PsFast);
        X_PsSlow = MatData.(X_PsSlow);
        X_Target = MatData.(X_Target);
        PiezoSign = MatData.('piezoSign');
    clear MatData

    %% 3. Calculate the Phase
    Theta = QST.PostSelection.computePhase( X_PsFast,...
                                            X_Target,...
                                            PiezoSign,...
                                            PeriodsPerSegment=Options.CalcPhase_PeriodsPerSegment,...
                                            PeakThreshold=Options.CalcPhase_PeakThreshold,...
                                            IgnoredSegments=Options.CalcPhase_IgnoredSegments,...
                                            Smoothing_Type=Options.CalcPhase_Smoothing_Type,...
                                            Smoothing_Accuracy_Spline=Options.CalcPhase_Smoothing_Accuracy_Spline,...
                                            Smoothing_Accuracy_MovingAverage=Options.CalcPhase_Smoothing_Accuracy_MovingAverage);
    %if any(isnan(Theta(1,:)))
    %    Theta = rand(size(X_Target,1)*size(X_Target,2),size(X_Target,3))*2*pi;
    %end
    
    %% 4. Calculate orthogonal Subset
    [X_PsFast_Orth, X_PsSlow_Orth,X_Target_Orth,Theta_Orth, Indices_Orth] = QST.PostSelection.selectOrthogonal( X_PsFast,...
                                                                                                                X_PsSlow,...
                                                                                                                PiezoSign,...
                                                                                                                X_Target=X_Target,...
                                                                                                                Theta=Theta,...
                                                                                                                OrthWidth=Options.PostOrth_OrthWidth,...
                                                                                                                Shift=Options.PostOrth_Shift, ...
                                                                                                                Smoothing_Type=Options.PostOrth_Smoothing_Type,...
                                                                                                                Smoothing_Accuracy_Spline=Options.PostOrth_Smoothing_Accuracy_Spline,...
                                                                                                                Smoothing_Accuracy_MovingAverage=Options.PostOrth_Smoothing_Accuracy_MovingAverage);
    
    %% 5. Calculate the Photon Numbers of each channel
    N_PsFast_MesMean = QST.Analysis.PhotoNumbers.calcMeanPhotoNumber(X_PsFast);
    N_PsSlow_MesMean = QST.Analysis.PhotoNumbers.calcMeanPhotoNumber(X_PsFast);
    N_Target_MesMean = QST.Analysis.PhotoNumbers.calcMeanPhotoNumber(X_Target);
    N_Ps_MesMean = N_PsFast_MesMean + N_PsSlow_MesMean;


    %% 6. Remove Signal Modulation from the data
    if Options.ModFix_Done == true
        % maybe this code can be written cleaner
        N_PsFast_Vector = QST.Analysis.PhotoNumbers.calcPhotonNumberVector(X_PsFast);
        N_PsSlow_Vector = QST.Analysis.PhotoNumbers.calcPhotonNumberVector(X_PsSlow);
        N_Target_Vector = QST.Analysis.PhotoNumbers.calcPhotonNumberVector(X_Target);
        N_PsFast_Vector = N_PsFast_Vector(Indices_Orth);
        N_PsSlow_Vector = N_PsSlow_Vector(Indices_Orth);
        N_Target_Vector = N_Target_Vector(Indices_Orth);
        X_PsFast_Orth = X_PsFast_Orth * sqrt(Options.ModFix_N_PsFast_SeriesMean) ./ sqrt(N_PsFast_Vector);
        X_PsSlow_Orth = X_PsSlow_Orth * sqrt(Options.ModFix_N_PsSlow_SeriesMean) ./ sqrt(N_PsSlow_Vector);
        X_Target_Orth = X_Target_Orth * sqrt(Options.ModFix_N_Target_SeriesMean) ./ sqrt(N_Target_Vector);
        % Select now only the subset of Data which Photnumber lays in the by 'Range' defined range
        Indices_NInRange = find(N_PsFast_Vector >= min(Options.ModFix_N_Range) & N_PsFast_Vector <= max(Options.ModFix_N_Range));
        X_PsFast_Orth = X_PsFast_Orth(Indices_NInRange);
        X_PsSlow_Orth = X_PsSlow_Orth(Indices_NInRange);
        X_Target_Orth = X_Target_Orth(Indices_NInRange);
        Theta_Orth = Theta_Orth(Indices_NInRange);
        Indices_Orth = Indices_Orth(Indices_NInRange);
    end

    %% 7. Save all Calculated Quantities and used input Parameters in the Quantities Struct
    % Information about the Aquisition Properties like Power, Delay and so
    % on are right not saved in this function, because I think this is something
    % directly connected to the analysis of series and not relevant for
    % single measurements


    % 7.0 Save all Information from Data Preparation
    % has to be written yet, in future this part should be done during
    % the calculation of the Quadratures (but for old data it would be still necessary)
    Quantities.InputOptions.CalcQuad.CorrFixApplied = QST.File_Managment.getInformationFromFilePath(FilePath,'corrRemove-(yes|no)','(yes|no)',Type='String');   
    Quantities.InputOptions.CalcQuad.PiezoApplied = QST.File_Managment.getInformationFromFilePath(FilePath,'piezo-(yes|no)','(yes|no)',Type='String');
    Quantities.InputOptions.CalcQuad.OffSetType = QST.File_Managment.getInformationFromFilePath(FilePath,'offset-(local|global)','(local|global)',Type='String');
    

    % 7.1 Save all Input Parameter
    % 7.1.1 Data saved ?
    Quantities.InputOptions.PostOrth_3Ch.ThetaSaved = Options.SaveTheta;
    % 7.1.2 Modulation removed Input Parameter
    Quantities.InputOptions.PostOrth_3Ch.ModFix.Applied = Options.ModFix_Done;
    Quantities.InputOptions.PostOrth_3Ch.ModFix.N_PsFast_SeriesMean = Options.ModFix_N_PsFast_SeriesMean;
    Quantities.InputOptions.PostOrth_3Ch.ModFix.N_PsSlow_SeriesMean = Options.ModFix_N_PsSlow_SeriesMean;
    Quantities.InputOptions.PostOrth_3Ch.ModFix.N_Target_SeriesMean = Options.ModFix_N_Target_SeriesMean;
    Quantities.InputOptions.PostOrth_3Ch.ModFix.N_Range = Options.ModFix_N_Range;
    % 7.1.3 Phase Calculation Input Parameter
    Quantities.InputOptions.PostOrth_3Ch.CalcPhase.PeriodsPerSegment = Options.CalcPhase_PeriodsPerSegment;
    Quantities.InputOptions.PostOrth_3Ch.CalcPhase.PeakThreshold = Options.CalcPhase_PeakThreshold;
    Quantities.InputOptions.PostOrth_3Ch.CalcPhase.Smoothing_Type = Options.CalcPhase_Smoothing_Type;
    Quantities.InputOptions.PostOrth_3Ch.CalcPhase.Smoothing_Accuracy_Spline = Options.CalcPhase_Smoothing_Accuracy_Spline;
    Quantities.InputOptions.PostOrth_3Ch.CalcPhase.Smoothing_Accuracy_MovingAverage = Options.CalcPhase_Smoothing_Accuracy_MovingAverage;
    % 7.1.4 Postselection By Orthogonal Input Parameter
    Quantities.InputOptions.PostOrth_3Ch.PostOrth.OrthWidth = Options.PostOrth_OrthWidth;
    Quantities.InputOptions.PostOrth_3Ch.PostOrth.Shift = Options.PostOrth_Shift;
    Quantities.InputOptions.PostOrth_3Ch.PostOrth.Smoothing_Type = Options.PostOrth_Smoothing_Type;
    Quantities.InputOptions.PostOrth_3Ch.PostOrth.Smoothing_Accuracy_Spline = Options.PostOrth_Smoothing_Accuracy_Spline;
    Quantities.InputOptions.PostOrth_3Ch.PostOrth.Smoothing_Accuracy_MovingAverage = Options.PostOrth_Smoothing_Accuracy_MovingAverage;
    
    % 7.2 Save all wanted Calculated Quantities
    % 7.2.1 Save Calculated PhotoNumber Information
    Quantities.Analysis.PhotoNumbers.N_PsFast_MesMean = N_PsFast_MesMean;
    Quantities.Analysis.PhotoNumbers.N_PsSlow_MesMean = N_PsSlow_MesMean;
    Quantities.Analysis.PhotoNumbers.N_Target_MesMean = N_Target_MesMean;
    Quantities.Analysis.PhotoNumbers.N_Ps_MesMean = N_Ps_MesMean;



    %% 8. Save Everything which was calculated dependent on the given Input Commands
    % Set if Data needs to be appended to existing file or not
    if isequal(Options.SaveFilePath, FilePath)
        Append = '-append';
    else
        Append = '';
    end
    VariablesToSave = {};
    % It simply does not make sense to not save them. and if not it creates
    VariablesToSave = [VariablesToSave, {'X_PsFast_Orth','X_PsSlow_Orth', 'X_Target_Orth', 'Theta_Orth', 'Indices_Orth', 'Quantities'}];
    % If bare Theta should also be saved (bloats the file)
    if Options.SaveTheta == true
        VariablesToSave = [VariablesToSave, 'Theta'];
    end
    save(Options.SaveFilePath, VariablesToSave{:}, Append)
end

