function [X1,X2,X3,PiezoInfos] = prepareData(Directory, FilenameLO, FilenameSIG, Channels, OffsetType, ModulatedPhase, RemoveDetectorResponse, IntegrationDutyCycle, nMean_Min, Delta, Options)

arguments
    Directory;
    FilenameLO;
    FilenameSIG;
    Channels;
    OffsetType = ['Global','Global','Global'];
    ModulatedPhase = [true,true,true];
    RemoveDetectorResponse = [false,false,false];
    IntegrationDutyCycle = 1/3;
    nMean_Min = 10000000;
    Delta = 50;
    Options.UseLegacySyntax = false;
end

%% 1. set Constants
NORM = 1/sqrt(2);
CALIBRATION_CH1 = 4.596047840078126e-05;

%% 2. load Data
QST.Helper.dispstat('','init','timestamp','keepthis',0);
% 2.1 load LO only
QST.Helper.dispstat('Load LO data','timestamp','keepthis',0);
[Data8bitLO,ConfigLO,~]= QST.QuadratureCalculation.load8BitBinary(Directory, FilenameLO, SaveData=false, UseLegacySyntax=Options.UseLegacySyntax);
% 2.2 load LO + Signal
QST.Helper.dispstat('Load LO + Signal data','timestamp','keepthis',0);
[Data8bitSIG,ConfigSIG,TimestampSIG]= QST.QuadratureCalculation.load8BitBinary(Directory, FilenameSIG, SaveData=false,UseLegacySyntax=Options.UseLegacySyntax);


%% 3. compute Number of LO Photons
QST.Helper.dispstat('calculate laser amplification','timestamp','keepthis',0);
Alpha = zeros(length(Channels),1); %The Magnification created by the LO % This is better replaced by a dictionary (new since Matlab 2022b)

%3.1 calculate the not regulized quadratures for the LO
XLO = QST.QuadratureCalculation.computeQuadratures(Data8bitLO(:,:,Channels),ConfigLO, CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);
for i = Channels
    Data = XLO(:,:,i);
    % 3.2 remove the Offsets
    Data = QST.QuadratureCalculation.removeOffset(Data,'Local'); % remove Offsets (for LOOnly this can be a local offset)
    % 3.3 remove the detectorresponse
    DataCleaned = QST.QuadratureCalculation.removeDetectorResponse(Data,nMean_Min,Delta); % since vacuum has not phaserelation with LO the removal of the detectorresponse can always be applied
    % 3.4 calculate the regularisation based on the LO's distribution width
    Alpha(i) = (1/NORM)*std(DataCleaned(:));% It takes here now the width of all points (one could maybe change this but it should not matter)
end


%% 4. calculate Quadratures with Signal and rescale regarding LO power
% 4.1 calculate the Quadratures
QST.Helper.dispstat('compute Lo + Signal quadratures','timestamp','keepthis',0);
X = QST.QuadratureCalculation.computeQuadratures(Data8bitSIG(:,:,Channels),ConfigSIG,CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);


[X1, X2, X3] = deal(0);
%% from now on each Channel individually
    for iCh = Channels
        Data = X(:,:,iCh);
        % 4.2 rescale the Quadratures
        Data = Data / Alpha(iCh);
        % 4.3 remove the offset
        Data = QST.QuadratureCalculation.removeOffset(Data,OffsetType(iCh));
        % 4.4 remove the Detectorresponse
        Data = Data(:);
        if RemoveDetectorResponse(iCh)
            QST.Helper.dispstat(['Remove Detectorresponse from Channel ',num2str(iCh),'...'],'timestamp','keepthis',0);
            Data = QST.QuadratureCalculation.removeDetectorResponse(Data,nMean_Min,Delta);
        end
        % 4.5 cut the data in piezos according to the observed piezo movement if piezo was active on this channel
        if ModulatedPhase(iCh)
            [Data, PiezoShape, PiezoStartDirection,PiezoEdgeIndices] = QST.QuadratureCalculation.getPiezoSegments(Data,TimestampSIG);
        else
            PiezoShape = [1,length(Data)];
            PiezoStartDirection = 0;
            PiezoEdgeIndices = [1, length(Data)];
        end
        %% asign the cleaned Data to the Channels
        switch iCh
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
        end
    end
end



