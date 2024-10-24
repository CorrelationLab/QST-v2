function [X1,X2,X3] = prepareData(filenameLO,filenameSIG,Channels,OffsetType,ModulatedPhase,RemoveDetectorResponse,IntegrationDutyCycle,nMean_Min,Delta)

arguments
    filenameLO;
    filenameSIG;
    Channels;
    OffsetType = ['Global','Global','Global'];
    ModulatedPhase = [true,true,true];
    RemoveDetectorResponse = [false,false,false];
    IntegrationDutyCycle = 1/3;
    nMean_Min = 10000000;
    Delta = 50;
end

%% 1. set Constants
NORM = 1/sqrt(2);
CALIBRATION_CH1 = 4.596047840078126e-05;

%% 2. load Data
dispstat('','init','timestamp','keepthis',0);
% 2.1 load LO only
dispstat('Load LO data','timestamp','keepthis',0);
[data8bitLO,configLO,~]= QST.QuadratureCalculation.load8BitBinary_FromArbPath(filenameLO,'dontsave');
% 2.2 load LO + Signal
dispstat('Load LO + Signal data','timestamp','keepthis',0);
[data8bitSIG,configSIG,~]= QST.QuadratureCalculation.load8BitBinary_FromArbPath(filenameSIG,'dontsave');


%% 3. compute Number of LO Photons
dispstat('calculate laser amplification','timestamp','keepthis',0);
Alpha = zeros(length(Channels),1); %The Magnification created by the LO % This is better replaced by a dictionary (new since Matlab 2022b)

%3.1 calculate the not regulized quadratures for the LO
XLO = computeQuadratures(data8bitLO(:,:,Channels),configLO, CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);
for i = Channels
    Data = XLO(:,:,i);
    % 3.2 remove the Offsets
    Data = QST.QuadratureCalculation.removeOffset(Data,'Local'); % remove Offsets (for LOOnly this can be a local offset)
    % 3.3 remove the detectorresponse
    DataCleaned = QST.QuadratureCalculation.RemoveDetectorResponse(Data,nMean_Min,Delta); % since vacuum has not phaserelation with LO the removal of the detectorresponse can always be applied
    % 3.4 calculate the regularisation based on the LO's distribution width
    Alpha(i) = (1/NORM)*std(DataCleaned(:));% It takes here now the width of all points (one could maybe change this but it should not matter)
end


%% 4. calculate Quadratures with Signal and rescale regarding LO power
% 4.1 calculate the Quadratures
dispstat('compute Lo + Signal quadratures','timestamp','keepthis',0);
X = computeQuadratures(data8bitSIG(:,:,Channels),configSIG,CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);


[X1, X2, X3] = deal(0);
%% from now on each Channel individually
    for iCh = Channels
        dispstat(['Remove Detectorresponse from Channel ',num2str(iCh),'...'],'timestamp','keepthis',0);
        Data = X(:,:,iCh);
        % 4.2 rescale the Quadratures
        Data = Data / Alpha(iCh);
        % 4.3 remove the offset
        Data = QST.QuadratureCalculation.removeOffset(Data,OffsetType(iCh));
        % 4.4 remove the Detectorresponse
        Data = Data(:);
        if RemoveDetectorResponse(iCh)
            Data = QST.QuadratureCalculation.RemoveDetectorResponse(Data,nMean_Min,Delta);
        end
        %% asign the cleaned Data to the Channels
        switch iCh
            case 1
                X1 = Data;
            case 2
                X2 = Data;
            case 3
                X3 = Data;
        end
    end
end



