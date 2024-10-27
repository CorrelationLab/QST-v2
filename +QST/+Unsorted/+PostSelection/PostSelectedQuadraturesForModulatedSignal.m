function [XN, Indices_X_High_Total] = PostSelectedQuadraturesForModulatedSignal(XN,Options)
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
        XN
        % Options for the necessary calculation of the photonnumber
        Options.AverageMethod {mustBeMember(Options.AverageMethod,['static','moving'])} = 'moving';
        Options.AverageSize {mustBeInteger,mustBePositive} = 10000;
        Options.StepSize {mustBeInteger,mustBePositive} = 1000;
        Options.Samplerate {mustBeNumeric, mustBePositive} = 74.3864
        % Options for the postselection of the pulses in the modulated data
        Options.MinPhotoNumberForPulse {mustBeNumeric,mustBePositive} = 0.2;
        Options.MaxPhotoNumberForZeroLevel {mustBeNumeric} = 0.1
        Options.RemoveFirstAndLast {mustBeInteger,mustBePositive} = 15;
        Options.AllowedOutlierDeviation {mustBeNumeric,mustBePositive} = 0.15
        Options.ZeroLevelCorrection {mustBeMember(Options.ZeroLevelCorrection,[0,1])} = 1;
        Options.ReturnAsStruct {mustBeMember(Options.ReturnAsStruct,[0,1])} = 1;
    end
    NChannels = length(XN,dim=2);
    Indices = {NChannels};
    parfor i = 1:NChannels
        [PulseData,~,Indices_X_High,~,~,~,~,~,~,~] = QST.mainCalculations.postSelectQuadraturesForModulatedSignal(XN(:,i),Options)
        Indices{i} = Indices_X_High;
    end
    Indices_X_High_Total = prod(Indices);
    XN = XN(:,Indices_X_High_Total);
end

