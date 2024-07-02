function [PulseData,X_High,Indices_X_High,N_High,G2_High,Times_High,X_Raw,N_Raw,G2_Raw,Times_Raw,ControlFig] = postSelectQuadraturesForModulatedSignal(X,N,G2,Times,EdgeIndices,Options)
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
        % Give the function already calculates values to reduce computation time
        N = [];
        G2 = [];
        Times = [];
        EdgeIndices = [];
        % Options for the necessary calculation of the photonnumber
        Options.AverageMethod {mustBeMember(Options.AverageMethod,['static','moving'])} = 'moving';
        Options.AverageSize {mustBeInteger,mustBePositive} = 10000;
        Options.StepSize {mustBeInteger,mustBePositive} = 1000;
        Options.Samplerate {mustBeNumeric, mustBePositive} = 74.3864
        % Options for the postselection of the pulses in the modulated data
        Options.MinPhotoNumberForPulse {mustBeNumeric,mustBePositive} = 0.2;
        Options.MaxPhotoNumberForZeroLevel {mustBeNumeric} = 0.2
        Options.RemoveFirstAndLast {mustBeInteger,mustBePositive} = 15;
        Options.AllowedOutlierDeviation {mustBeNumeric,mustBePositive} = 0.15
        Options.ZeroLevelCorrection {mustBeMember(Options.ZeroLevelCorrection,[0,1])} = 1; % This should be correct true or false
        Options.ReturnAsStruct {mustBeMember(Options.ReturnAsStruct,[0,1])} = 1;
        Options.SaveControlPlots{mustBeMember(Options.SaveControlPlots,[0,1])} = 1;
       
    end
    %% 0. Make X data one dimensional
    X = X(:);


    %% 1. calculate Photonumber (has to be a time resolved method and return also the Information which quadratures has been used to calculate which N value)
    if isempty(Options.N) && isempty(Options.G) && isempty(Options.Times) && isempty(Options.EdgeIndices)
        [N,G2,Times,EdgeIndices] = QST.Analysis.G2.calc_N_G2_TimeResolved(X,...
                                                                    AverageMethod = Options.AverageMethod,...
                                                                    AverageSize = Options.AverageSize,...
                                                                    StepSize = Options.StepSize,...
                                                                    Samplerate = Options.Samplerate);
    end


    EdgeIndices = EdgeIndices';

    %% 1.5 Check that there are Areas Below the Minimum level for Condensate otherwise set values accordingly
    if min(N) >= Options.MinPhotoNumberForPulse
        PulseData = struct([]);
        X_High = X;
        Indices_X_High = 1:length(X_High);
        N_High = N;
        G2_High = G2;
        Times_High = Times;
        X_Raw = X;
        N_Raw = N;
        Times_Raw = Times;
        ControlFig = figure;
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
    Indices_High = [];

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
            Indices_High(end+1) = i;
        end
        if N_Current < Options.MinPhotoNumberForPulse && N_Next > Options.MinPhotoNumberForPulse
            AddToPulse = true;
        elseif N_Current > Options.MinPhotoNumberForPulse && N_Next < Options.MinPhotoNumberForPulse
            % Add PulseData to the struct
            PulseData(PulseIndex).N = N_High;
            PulseData(PulseIndex).G2 = G2_High;
            PulseData(PulseIndex).Times = Times_High;
            PulseData(PulseIndex).Indices_N = Indices_High;
            % reset temporary data variables to reload
            N_High = [];
            G2_High = [];
            Times_High = [];
            Indices_High = [];
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
    Indices_Zero = [];

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
            Indices_Zero(end+1) = i;
        end
        if N_Current > Options.MaxPhotoNumberForZeroLevel && N_Next < Options.MaxPhotoNumberForZeroLevel
            AddToZeroLevel = true;
        elseif N_Current < Options.MaxPhotoNumberForZeroLevel && N_Next > Options.MaxPhotoNumberForZeroLevel
            % Add PulseData to the struct
            ZeroLevelData(ZeroLevelIndex).N = N_Zero;
            ZeroLevelData(ZeroLevelIndex).Times = Times_Zero;
            ZeroLevelData(ZeroLevelIndex).Indices_N = Indices_Zero;
            % reset temporary data variables to reload
            N_Zero = [];
            Times_Zero = [];
            Indices_Zero = [];
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



    %% 2.3 Remove incomplete Pulses
    if N(1) > Options.MinPhotoNumberForPulse
        PulseData = PulseData(2:end);
    end
    if N(end) > Options.MinPhotoNumberForPulse
        PulseData = PulseData(1:end-1);
    end


    %% 2.4 Remove Outliers inside of the Data as well as the first n points at the beginning and the end of each pulse (to correct for shady pulse edges)
    for i = 1:length(PulseData)
        % Remove first and last n points
        PulseData(i).N = PulseData(i).N(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);
        PulseData(i).G2 = PulseData(i).G2(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);
        PulseData(i).Times = PulseData(i).Times(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);
        PulseData(i).Indices_N = PulseData(i).Indices_N(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);
        % Remove outliers
        N_Mean = mean(PulseData(i).N);
        Deviation = Options.AllowedOutlierDeviation*N_Mean; 
        ValidIndices = abs((PulseData(i).N/N_Mean)-1) <= Deviation;
        PulseData(i).N = PulseData(i).N(ValidIndices);
        PulseData(i).G2 = PulseData(i).G2(ValidIndices);
        PulseData(i).Times = PulseData(i).Times(ValidIndices);
        PulseData(i).Indices_N = PulseData(i).Indices_N(ValidIndices);
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
        ZeroLevelData(i).N = ZeroLevelData(i).N(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);
        ZeroLevelData(i).Times = ZeroLevelData(i).Times(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);
        ZeroLevelData(i).Indices_N = ZeroLevelData(i).Indices_N(Options.RemoveFirstAndLast+1:end-Options.RemoveFirstAndLast);        
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
        title('Low Level Cleaning')
        xlabel('Time in s')
        ylabel('N')
    end


    

    %% 3. Restore the Original Quadratures which belong to the high level
    % Regain Indices of the Original Quadratures
    for i = 1:length(PulseData)
        LastQuad = 1;
        Indices_X = [];
        for j = PulseData(i).Indices_N
            NewIndices_X = max(LastQuad+1,EdgeIndices(j,1)):EdgeIndices(j,2);
            Indices_X = cat(2,Indices_X,NewIndices_X);
            LastQuad = EdgeIndices(j,2);
        end
        PulseData(i).Indices_X = Indices_X;
        PulseData(i).X = X(Indices_X)';
    end





    %% 5. Quadrature Scale Correction based on the Zero Level
    if Options.ZeroLevelCorrection == 1
        % get Correctionfactor for the quadratures
        ZeroLevel = [arrayfun(@(X) X.N, ZeroLevelData, UniformOutput=false)];
        ZeroLevel = mean([ZeroLevel{:}]);
        X_Correctionfactor = sqrt(0.5/(0.5+ZeroLevel));
        % correct Quadratures if given
        for i = 1:length(PulseData)
            % correct X
            PulseData(i).X = PulseData(i).X*X_Correctionfactor;
            % correct N and G2
            X2 = X_Correctionfactor^2*(PulseData(i).N+0.5);
            X4 = X_Correctionfactor^4*(3/2)*(PulseData(i).G2.*PulseData(i).N.^2+2*PulseData(i).N+0.5);
            
            PulseData(i).N = X2-0.5;
            PulseData(i).G2 = (2/3*X4-2*X2+0.5)./(X2-0.5).^2;  
        end

        
        % correct the raw data
        X2 = X_Correctionfactor^2*(N+0.5);
        X4 = X_Correctionfactor^4*(3/2)*(G2.*N.^2+2*N+0.5);

        X_Raw = X*X_Correctionfactor;
        N_Raw = X2-0.5;
        G2_Raw = (2/3*X4-2*X2+0.5)./(X2-0.5).^2;
        Times_Raw = Times;



    else
        X_Raw = X;
        N_Raw = N;
        G2_Raw = G2;
        Times_Raw = Times;
        shg
    end
    X_High = cell2mat([arrayfun(@(B) B.X, PulseData, UniformOutput=false)]);
    Indices_X_High = cell2mat([arrayfun(@(B) B.Indices_X, PulseData, UniformOutput=false)]);
    N_High = cell2mat([arrayfun(@(B) B.N, PulseData, UniformOutput=false)]);
    G2_High = cell2mat([arrayfun(@(B) B.G2, PulseData, UniformOutput=false)]);
    Times_High = cell2mat([arrayfun(@(B) B.Times, PulseData, UniformOutput=false)]);



    if Options.SaveControlPlots == 1
        %% Fifth Checkup Plot: Zero Level is successfully corrected
        nexttile
        plot(Times_Raw,N_Raw)
        hold on
        plot(Times_High,N_High)
        hold off

        nexttile
        plot(Times_High,G2_High)
    end
    

end

