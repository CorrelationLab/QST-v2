function [X1,X2,X3] = prepareData_All(filenameLO,filenameSIG,Channels,IntegrationDutyCycle,nMean_Min,Delta)

arguments
    filenameLO;
    filenameSIG;
    Channels;
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
[data8bitLO,configLO,~]=load8BitBinary_FromArbPath(filenameLO,'dontsave');
% 2.2 load LO + Signal
dispstat('Load LO + Signal data','timestamp','keepthis',0);
[data8bitSIG,configSIG,~]=load8BitBinary_FromArbPath(filenameSIG,'dontsave');


%% 3. compute Number of LO Photons
dispstat('calculate laser amplification','timestamp','keepthis',0);
Alpha = zeros(length(Channels),1); %The Magnification created by the LO % This is better replaced by a dictionary (new since Matlab 2022b)
XLO = computeQuadratures(data8bitLO(:,:,Channels),configLO, CALIBRATION_CH1,DutyCycle=IntegrationDutyCycle);
for i = Channels
    Data = XLO(:,:,i);
    Data = bsxfun(@minus, Data, mean(Data)); % remove local Offsets [for testing purpose only local Offsetremoval is implemented]
    DataCleaned = CorrRemove_All(Data,nMean_Min,Delta);
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
        % 4.3 remove local Offsets [for testing purpose only local Offsetremoval is implemented]
        Data = bsxfun(@minus, Data, mean(Data));
        % calculate the Detectorresponse
        Data = Data(:);
        DataCleaned = CorrRemove_All(Data,nMean_Min,Delta);
        %% asign the cleaned Data to the Channels
        switch iCh
            case 1
                X1 = DataCleaned;
            case 2
                X2 = DataCleaned;
            case 3
                X3 = DataCleaned;
        end
    end
end



