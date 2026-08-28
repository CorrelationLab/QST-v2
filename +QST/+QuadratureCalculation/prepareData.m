function [X1, X2, X3, X4, PiezoInfos] = prepareData(Directory, FilenameLO, FilenameSIG, Channels, OffsetType, ModulatedPhase, RemoveDetectorResponse, IntegrationDutyCycle, nMean_Min, Delta, Options)
%% Description:
%   This function reads in a main directory of a series of measurements and computes the quadratures out of each measurement.
%   To this end each measurement has to consist six files (1 vacuum measurement for calibration, 1 measurement with signal, each measurement saves 3 
%   files, a .cfg config file, a timestamp .stamp file and a .raw binary data file). The file tree should have the following structure:
%   -Directory
%       -LOonly.cfg
%       -LOonly.stamp
%       -LOonly.raw
%       -LOwithSIG.cfg
%       -LOwithSIG.stamp
%       -LOwithSIG.raw
% 
%   The final quadratures are then saved in a .mat file that is saved in an extra sub directory 'mat-data' which is placed on the same level as 'raw-data'
% 
%% Syntax:
%   execSeriesQuadratureCalculation(Directory, Channels, Offset, ModulatedPhase, RemoveDetectorResponse, Options)
%
%% Input:
% required input values;
%   Directory                                   - raw-data directory of a single measurement
%   FilenameLO                                  - filename token of the vacuum measurement
%   FilenameLO                                  - filename token of the signal measurement
%   Channels                                    - array of the detection channels of the homodyne setup that were active in the measurement 
%   Offset                                      - array of options to indicate wether the offset correction should be applied using a global or a local varying offset.
%                                                 An example would be "Offset = ["Global", "Global", "Global", "Global"]" or "Offset = ["Local", "Local", "Local", "Local"]"
%   ModulatedPhase                              - array of options to indicate wether the relative phase between local oscillator and signal was actively modulated or not 
%                                                 An example would be "ModulatedPhase = [true, true, true, true]" or "ModulatedPhase = [false, false, false, false]"
%   RemoveDetectorResponse                      - array of options to indicate wether the detector response of the balanced detectors should be removed.
%                                                 This is only possible when the relative phase between local oscillator and signal is not only random but that
%                                                 the phase information decays within the time between two consecutive pulses such that the quadratures of consecutive pulses
%                                                 theoretically should be uncorrelated
%
% optional input values;                        
%   Options.Token_LOOnly = "LOOnly"             - indication token for the vacuum measurement files
%   Options.Token_LOAndSignal = "LOwithSIG"     - indication token for the signal measurement files            
%   Options.StarHubIncluded = true              - check if the Spectrum instruments ADC card uses the Starhub module 
%   Options.Preset = ''                         - activate predefined preset to shorten the function call. Use 'FixedPhase' when the phase relation between
%                                                 local oscillator and signal was intrinsically stabel and modulated by a piezo (LO acts as source of the signal).
%                                               - Use RandomPhase when the phase relation was random and consecutive quadratures should be uncorrelated
%                                                 (polariton condensate emission)
%   Options.IntegrationDutyCycle = 1/3          - width of the integration window used to convert the digitalized values from the adc card via integration to a quadrature value.
%                                                 The integration window size is given in relation to the time interval between two pulses. 
%                                                 If this time is for e.g. equivalent to 33 voltage values the integration interval includes 11 points 
%                                                 centered around the pulse maximum
%   Options.nMean_Min = 1000000                 - number of consective quadratures used to compute the detector response
%   Options.Delta = 50                          - order up to which correlations between consecutive quadratures should be removed
%   
%% Output:
%   X1                                            - constructed quadratures of channel 1
%   X2                                            - constructed quadratures of channel 2
%   X3                                            - constructed quadratures of channel 3
%   X4                                            - constructed quadratures of channel 4
%   PiezoInfos                                    - struct that contains information about the piezo movement reconstructed from the timestamp data



    arguments
        Directory;
        FilenameLO;
        FilenameSIG;
        Channels;
        OffsetType = ["Global", "Global", "Global", "Global"]; % this has to be strings!!!
        ModulatedPhase = [true,true,true,true];
        RemoveDetectorResponse = [false,false,false,false];
        IntegrationDutyCycle = 1/3;
        nMean_Min = 10000000;
        Delta = 50;
        Options.UseLegacySyntax = false;
        Options.StarHubIncluded = true;
    end
    
    
    %% 1. set Constants
    NORM = 1/sqrt(2);
    CALIBRATION_CH1 = 4.596047840078126e-05;
    
    %% 2. load Data
    QST.Helper.dispstat('','init','timestamp','keepthis',0);
    % 2.1 load LO only
    QST.Helper.dispstat('Load LO data','timestamp','keepthis',0);
    if Options.StarHubIncluded == true
        [Data8bitLO,ConfigLO,~]= QST.QuadratureCalculation.load8BitBinary_MultiADC(Directory, FilenameLO, SaveData=false, UseLegacySyntax=Options.UseLegacySyntax);
    else
        [Data8bitLO,ConfigLO,~]= QST.QuadratureCalculation.load8BitBinary(Directory, FilenameLO, SaveData=false, UseLegacySyntax=Options.UseLegacySyntax);
    end
    % 2.2 load LO + Signal
    QST.Helper.dispstat('Load LO + Signal data','timestamp','keepthis',0);
    if Options.StarHubIncluded == true
        [Data8bitSIG,ConfigSIG,TimestampSIG]= QST.QuadratureCalculation.load8BitBinary_MultiADC(Directory, FilenameSIG, SaveData=false,UseLegacySyntax=Options.UseLegacySyntax);
    else
        [Data8bitSIG,ConfigSIG,TimestampSIG]= QST.QuadratureCalculation.load8BitBinary(Directory, FilenameSIG, SaveData=false,UseLegacySyntax=Options.UseLegacySyntax);
    end
    
    
    %% 3. compute Number of LO Photons
    QST.Helper.dispstat('calculate laser amplification','timestamp','keepthis',0);
    Alpha = zeros(length(Channels),1); %The Magnification created by the LO % This is better replaced by a dictionary (new since Matlab 2022b)
    
    %3.1 calculate the not regulized quadratures for the LO
    XLO = QST.QuadratureCalculation.computeQuadratures(Data8bitLO(:,:,Channels),Channels,ConfigLO, CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);
    nChannels = length(Channels);
    for i = 1:nChannels
        Data = XLO(:,:,i);
        % 3.2 remove the Offsets
        Data = QST.QuadratureCalculation.removeOffset(Data,OffsetType(Channels(i)));
        % 3.3 remove the detectorresponse
        if RemoveDetectorResponse(Channels(i))
            DataCleaned = QST.QuadratureCalculation.removeDetectorResponse(Data,nMean_Min,Delta);
        else
            DataCleaned = Data;
        end
        % 3.4 calculate the regularisation based on the LO's distribution width
        Alpha(i) = (1/NORM)*std(DataCleaned(:));% It takes here now the width of all points (one could maybe change this but it should not matter)
    end
    
    
    %% 4. calculate Quadratures with Signal and rescale regarding LO power
    % 4.1 calculate the Quadratures
    QST.Helper.dispstat('compute Lo + Signal quadratures','timestamp','keepthis',0);
    X = QST.QuadratureCalculation.computeQuadratures(Data8bitSIG(:,:,Channels),Channels,ConfigSIG,CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);
    
    
    [X1, X2, X3, X4] = deal(0);
    %% from now on each Channel individually
        for iCh = 1:nChannels
            Data = X(:,:,iCh);
            DataShape = size(Data);
            % 4.2 rescale the Quadratures
            Data = Data / Alpha(iCh);
            % 4.3 remove the offset
            Data = QST.QuadratureCalculation.removeOffset(Data,OffsetType(Channels(iCh)));
            % 4.4 remove the Detectorresponse
            Data = Data(:);
            if RemoveDetectorResponse(Channels(iCh))
                QST.Helper.dispstat(['Remove Detectorresponse from Channel ',num2str(Channels(iCh)),'...'],'timestamp','keepthis',0);
                Data = QST.QuadratureCalculation.removeDetectorResponse(Data,nMean_Min,Delta);
            end
            % 4.5 cut the data in piezos according to the observed piezo movement if piezo was active on this channel
            if ModulatedPhase(Channels(iCh))
                Data = reshape(Data,DataShape);% reshape Data back into the segments
                [Data, PiezoShape, PiezoStartDirection,PiezoEdgeIndices] = QST.QuadratureCalculation.getPiezoSegments(Data,TimestampSIG,SegmentSelectionMode='MaxLength');
            else
                PiezoShape = [1,length(Data)];
                PiezoStartDirection = 0;
                PiezoEdgeIndices = [1, length(Data)];
            end
            %% asign the cleaned Data to the Channels
            switch Channels(iCh)
                case 1 
                    X1 = Data;
                    PiezoInfos.X1.Shape = PiezoShape;
                    PiezoInfos.X1.StartDirection = PiezoStartDirection;
                    PiezoInfos.X1.EdgeIndices = PiezoEdgeIndices;
                case 2
                    X2 = Data;
                    PiezoInfos.X2.Shape = PiezoShape;
                    PiezoInfos.X2.StartDirection = PiezoStartDirection;
                    PiezoInfos.X2.EdgeIndices = PiezoEdgeIndices;
                case 3
                    X3 = Data;
                    PiezoInfos.X3.Shape = PiezoShape;
                    PiezoInfos.X3.StartDirection = PiezoStartDirection;
                    PiezoInfos.X3.EdgeIndices = PiezoEdgeIndices;
                case 4
                    X4 = Data;
                    PiezoInfos.X4.Shape = PiezoShape;
                    PiezoInfos.X4.StartDirection = PiezoStartDirection;
                    PiezoInfos.X4.EdgeIndices = PiezoEdgeIndices;
            end
        end
end



