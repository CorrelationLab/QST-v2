function [PulseData,N_High,G2_High,Times_High,EdgeIndices_High,X_Correctionfactor,N,G2,Times,EdgeIndices] = postSelectQuadraturesForModulatedSignal_OptimizedForHusimiQ(X,Options)
    % POSTSELECTQUADRATURESFORMODULATEDSIGNAL takes a set of quadratures of data with signal modulation and finds the high level areas inside of
    % the data (photonnumber not around zero) and returns the data as well as g2 and times. it also allows a quadrature correction based on the
    % zero level
    %
    % INPUTS:
    % X:                Set of Quadratures of modulated data
    %
    % OPTIONS:
    % AverageMethod :   Averagemethod for the calculation of the photonumber
    % 
    
    arguments
        X
        %Channelinformation
        Options.ChannelNumber = NaN;
        % Give the function already calculates values to reduce computation time
        Options.N = [];
        Options.G2 = [];
        Options.Times = [];
        Options.EdgeIndices = [];
        % Options for the necessary calculation of the photonnumber
        Options.AverageMethod {mustBeMember(Options.AverageMethod,['static','moving'])} = 'moving';
        Options.AverageSize {mustBeInteger,mustBePositive} = 10000;
        Options.StepSize {mustBeInteger,mustBePositive} = 1000;
        Options.Samplerate {mustBeNumeric, mustBePositive} = 74.3864
        % Options for the postselection of the pulses in the modulated data
        Options.MinPhotoNumberForPulse {mustBeNumeric,mustBePositive} = 0.2;
        Options.MaxPhotoNumberForZeroLevel {mustBeNumeric} = 0.2
        Options.RemoveFirstAndLastPulse {mustBeInteger,mustBePositive} = 15;
        Options.RemoveFirstAndLastZeroLevel {mustBeInteger,mustBePositive} = 5;
        Options.AllowedOutlierDeviation {mustBeNumeric,mustBePositive} = 0.15
        Options.ZeroLevelCorrection {mustBeMember(Options.ZeroLevelCorrection,[0,1])} = 1; % This should be correct true or false
        % Options for the Controlplots
        Options.SaveControlPlots{mustBeMember(Options.SaveControlPlots,[0,1])} = 1;
        Options.ControlPlotsSavePath = '';
       
    end
    %% 0. Make X data one dimensional
    X = X(:);

    %% 0.5 Set Channelnumber if not given
        if isnan(Options.ChannelNumber)
            S = inputname(1);
            Options.ChannelNumber = uint16(str2double(S(2:end)));
        end




    %% 1. calculate Photonumber (has to be a time resolved method and return also the Information which quadratures has been used to calculate which N value)
    if isempty(Options.N) && isempty(Options.G2) && isempty(Options.Times) && isempty(Options.EdgeIndices)
        [N,G2,Times,EdgeIndices] = QST.Analysis.G2.calc_N_G2_TimeResolved(X,...
                                                                    AverageMethod = Options.AverageMethod,...
                                                                    AverageSize = Options.AverageSize,...
                                                                    StepSize = Options.StepSize,...
                                                                    Samplerate = Options.Samplerate);
    end



    %% 1.1 Check that there are Areas Below the Minimum level for Condensate otherwise set values accordingly
    if min(N) >= Options.MinPhotoNumberForPulse
        PulseData = struct([]);
        N_High = N;
        G2_High = G2;
        Times_High = Times;
        EdgeIndices_High = EdgeIndices;
        X_Correctionfactor = NaN;
        return
    end

    %% 1.2 Check that there are Areas Above the Minimum Level for Condensate otherwise set values accordingly
    if max(N) < Options.MinPhotoNumberForPulse
        PulseData = struct([]);
        N_High = [];
        G2_High = [];
        Times_High = [];
        EdgeIndices_High = [];
        X_Correctionfactor = NaN;
        return
    end
    

    %% 2. Find the Pulses and Zerolevelsinside of the modulated data
    % Set variables to save the results
    DataLength = length(N);
    PulseData = struct([]);
    ZeroLevelData = struct([]);

    %% 2.1 Find the Pulses

    PulseIndex = 1;
    AddToPulse = false;
    G2_High = [];
    N_High = [];
    Times_High = [];
    EdgeIndices_High = [[],[]];

    for i = 1:DataLength
        N_Current = N(i);
        if (i < DataLength)
            N_Next = N(i+1);
        else
            N_Next = 0;
        end
        if AddToPulse == true
            N_High(end+1) = N(i);
            G2_High(end+1) = G2(i);
            Times_High(end+1) = Times(i);
            EdgeIndices_High(:,end+1) = EdgeIndices(:,i);
        end
        if N_Current < Options.MinPhotoNumberForPulse && N_Next >= Options.MinPhotoNumberForPulse
            AddToPulse = true;
        elseif N_Current >= Options.MinPhotoNumberForPulse && N_Next < Options.MinPhotoNumberForPulse
            % Add PulseData to the struct
            PulseData(PulseIndex).N = N_High;
            PulseData(PulseIndex).G2 = G2_High;
            PulseData(PulseIndex).Times = Times_High;
            PulseData(PulseIndex).EdgeIndices = EdgeIndices_High;
            % reset temporary data variables to reload
            N_High = [];
            G2_High = [];
            Times_High = [];
            EdgeIndices_High = [];
            % reset pulsefinder and change pulseindex
            AddToPulse = false;
            PulseIndex = PulseIndex + 1;  
        end
    end

    if Options.SaveControlPlots == 1
        %% First Checkup Plot: High Value Areas have been recognized properly
        clf
        ControlFig(1) = figure;
        tiledlayout(3,2)

        N_High = cell2mat([arrayfun(@(B) B.N, PulseData, UniformOutput=false)]);
        Times_High = cell2mat([arrayfun(@(B) B.Times, PulseData, UniformOutput=false)]);

        nexttile
        plot(Times,N);
        hold on
        plot(Times_High,N_High)
        hold off
        title('High Value Recognition')
        xlabel('Time in s')
        ylabel('N')
    end



 %% 2.2 Find the ZeroLevels

    ZeroLevelIndex = 1;
    AddToZeroLevel = false;
    PhotoNumbers = [];
    Position = [];
    N_Zero = [];
    Times_Zero = [];

    for i = 1:DataLength
        N_Current = N(i);
        if (i < DataLength)
            N_Next = N(i+1);
        else
            N_Next = 0;
        end
        if AddToZeroLevel == true
            N_Zero(end+1) = N(i);
            Times_Zero(end+1) = Times(i);
        end
        if N_Current > Options.MaxPhotoNumberForZeroLevel && N_Next < Options.MaxPhotoNumberForZeroLevel
            AddToZeroLevel = true;
        elseif N_Current < Options.MaxPhotoNumberForZeroLevel && N_Next > Options.MaxPhotoNumberForZeroLevel
            % Add PulseData to the struct
            ZeroLevelData(ZeroLevelIndex).N = N_Zero;
            ZeroLevelData(ZeroLevelIndex).Times = Times_Zero;
            % reset temporary data variables to reload
            N_Zero = [];
            Times_Zero = [];
            % reset pulsefinder and change pulseindex
            AddToZeroLevel = false;
            ZeroLevelIndex = ZeroLevelIndex + 1; 
        end
    end

    if Options.SaveControlPlots == 1
        %% Second Checkup Plot: Areas of the Zerolevel have been recognized properly
        N_Zero = cell2mat([arrayfun(@(B) B.N, ZeroLevelData, UniformOutput=false)]);
        Times_Zero = cell2mat([arrayfun(@(B) B.Times, ZeroLevelData, UniformOutput=false)]);

        nexttile
        plot(Times,N);
        hold on
        plot(Times_Zero,N_Zero)
        hold off
        title('Zero Level Recognition')
        xlabel('Time in s')
        ylabel('N')
    end



    %% 2.3 Remove incomplete Pulses at the beginning and the end
    if N(1) > Options.MinPhotoNumberForPulse
        PulseData = PulseData(2:end);
    end
    if N(end) > Options.MinPhotoNumberForPulse
        PulseData = PulseData(1:end-1);
    end


    %% 2.4 Remove Outliers inside of the Data as well as the first n points at the beginning and the end of each pulse (to correct for shady pulse edges)
    for i = 1:length(PulseData)
        % Remove first and last n points
        PulseData(i).N = PulseData(i).N(Options.RemoveFirstAndLastPulse+1:end-Options.RemoveFirstAndLastPulse);
        PulseData(i).G2 = PulseData(i).G2(Options.RemoveFirstAndLastPulse+1:end-Options.RemoveFirstAndLastPulse);
        PulseData(i).Times = PulseData(i).Times(Options.RemoveFirstAndLastPulse+1:end-Options.RemoveFirstAndLastPulse);
        PulseData(i).EdgeIndices = PulseData(i).EdgeIndices(:,Options.RemoveFirstAndLastPulse+1:end-Options.RemoveFirstAndLastPulse);
        % Remove outliers
        N_Mean = mean(PulseData(i).N);
        Deviation = Options.AllowedOutlierDeviation*N_Mean; 
        ValidIndices = abs((PulseData(i).N/N_Mean)-1) <= Deviation;
        PulseData(i).N = PulseData(i).N(ValidIndices);
        PulseData(i).G2 = PulseData(i).G2(ValidIndices);
        PulseData(i).Times = PulseData(i).Times(ValidIndices);
        PulseData(i).EdgeIndices = PulseData(i).EdgeIndices(:,ValidIndices);
    end

    if Options.SaveControlPlots == 1
        %% Third Checkup Plot: Incomplete Pulses have been removed correctly and high areas have been cut properly
        N_High = cell2mat([arrayfun(@(B) B.N, PulseData, UniformOutput=false)]);
        Times_High = cell2mat([arrayfun(@(B) B.Times, PulseData, UniformOutput=false)]);

        nexttile
        plot(Times,N);
        hold on
        plot(Times_High,N_High)
        hold off
        title('High Level Cleaning')
        xlabel('Time in s')
        ylabel('N')
    end



    % Remove first and last n points also for the zero level to remove
    % effects of the flanks
    for i = 1:length(ZeroLevelData)
        ZeroLevelData(i).N = ZeroLevelData(i).N(Options.RemoveFirstAndLastZeroLevel+1:end-Options.RemoveFirstAndLastZeroLevel);
        ZeroLevelData(i).Times = ZeroLevelData(i).Times(Options.RemoveFirstAndLastZeroLevel+1:end-Options.RemoveFirstAndLastZeroLevel);       
    end

    if Options.SaveControlPlots == 1
        %% Fourth Checkup Plot: Sides of the low areas have been cut properly
        N_Zero = cell2mat([arrayfun(@(B) B.N, ZeroLevelData, UniformOutput=false)]);
        Times_Zero = cell2mat([arrayfun(@(B) B.Times, ZeroLevelData, UniformOutput=false)]);

        nexttile
        plot(Times,N);
        hold on
        plot(Times_Zero,N_Zero)
        hold off
        title('Zero Level Cleaning')
        xlabel('Time in s')
        ylabel('N')
    end


    

    %% 3. Quadrature Scale Correction based on the Zero Level
    if Options.ZeroLevelCorrection == 1
        %get Correctionfactor for the quadratures
        ZeroLevel = [arrayfun(@(X) X.N, ZeroLevelData, UniformOutput=false)];
        ZeroLevel = mean([ZeroLevel{:}]);
        X_Correctionfactor = sqrt(0.5/(0.5+ZeroLevel));

    
        % recalculate the N and g^2(0) values inside of Pulsedata
        for i = 1:length(PulseData)
            % calculate <X^2> and <X^4> arrays from n and g^2(0)
            X2 = (PulseData(i).N+0.5);
            X4 = (3/2)*(PulseData(i).G2.*PulseData(i).N.^2+2*PulseData(i).N+0.5);
            % rescale them with the correction factor
            X2 = X2*X_Correctionfactor^2;
            X4 = X4*X_Correctionfactor^4;
            % recalculate N and g^2(0) with the rescaled <X^2> and <X^4> arrays
            PulseData(i).N = X2-0.5;
            PulseData(i).G2 = (2/3*X4-2*X2+0.5)./(X2-0.5).^2;
        end




        % for the purpose of checking that everything went correct one also has to check the correction on the whole dataset
        % calculate <X^2> and <X^4> arrays from n and g^2(0)
        X2 = N+0.5;
        X4 = (3/2)*(G2.*N.^2+2*N+0.5);
        % rescale them with the correction factor
        X2 = X2*X_Correctionfactor^2;
        X4 = X4*X_Correctionfactor^4;
        % recalculate N and g^2(0) with the rescaled <X^2> and <X^4> arrays
        N = X2-0.5;
        G2 = (2/3*X4-2*X2+0.5)./(X2-0.5).^2;

        

    else
        X_Correctionfactor = 1;
    end

    N_High = cell2mat([arrayfun(@(B) B.N, PulseData, UniformOutput=false)]);
    G2_High = cell2mat([arrayfun(@(B) B.G2, PulseData, UniformOutput=false)]);
    Times_High = cell2mat([arrayfun(@(B) B.Times, PulseData, UniformOutput=false)]);
    EdgeIndices_High = cell2mat([arrayfun(@(B) B.EdgeIndices, PulseData, UniformOutput=false)]);

    if Options.SaveControlPlots == 1
        %% Fifth Checkup Plot: Zero Level is successfully corrected
        nexttile
        plot(Times,N)
        hold on
        plot(Times_High,N_High)
        hold off
        xlabel('Time in s')
        ylabel('N')
        title('N after Quadrature Correction')

        nexttile
        plot(Times_High,G2_High)
        xlabel('Time in s')
        ylabel('g^2(0)')
        title('g^2(0) after Quadrature Correction')
    end
    % save the the Controlfigures if wanted
    if Options.SaveControlPlots == 1 && ~isequal(Options.ControlPlotsSavePath,'')
        if ~exist(Options.ControlPlotsSavePath,'dir')
            mkdir(Options.ControlPlotsSavePath);
        end
        savefig(ControlFig,strcat(Options.ControlPlotsSavePath,filesep,'ModulationFiltering Controlfig Channel ',string(Options.ChannelNumber)));
    end
   
end
%% Comment for future Optimisation:
