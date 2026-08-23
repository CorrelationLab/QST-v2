% load data %% I will do this later
Dir = "D:\Data\Artifical DTS\8.11.2024\Mira\rawdata";

FilePath_LO_Raw = strcat(Dir,filesep,"LOOnly.raw");
FilePath_SIG_Raw = strcat(Dir,filesep,"LOwithSIG.raw");
FilePath_LO_Cfg = strcat(Dir,filesep,"LOOnly.cfg");
FilePath_SIG_Cfg = strcat(Dir,filesep,"LOwithSIG.cfg");
FilePath_SIG_Stamp = strcat(Dir,filesep,"LOwithSIG.stamp");

% load Configdata
Config_LO = QST.QuadratureCalculation.getConfig(FilePath_LO_Cfg);
Config_SIG = QST.QuadratureCalculation.getConfig(FilePath_SIG_Cfg);
% get the params
Segmentsize = Config_LO.SpectrumCard.ModeSetup.Segmentsize_I32;
Memsize_LO = round(Config_LO.SpectrumCard.ModeSetup.Memory_DBL);
Memsize_SIG = round(Config_SIG.SpectrumCard.ModeSetup.Memory_DBL);
NumberOfRecordings_LO = Memsize_LO/Segmentsize;
NumberOfRecordings_SIG = Memsize_SIG/Segmentsize;
Range_LO = Config_LO.SpectrumCard.Channel00.Range_I32;
Range_SIG = Config_SIG.SpectrumCard.Channel00.Range_I32;


Window = 3;
% load raw data
Data8Bit_LO = gpuArray(fread(fopen(FilePath_LO_Raw),[Segmentsize*2, NumberOfRecordings_LO], 'int8=>int8'));
Data8Bit_LO = permute(reshape(Data8Bit_LO,2,Segmentsize,NumberOfRecordings_LO),[2,3,1]);
Data8Bit_LO = Data8Bit_LO(:,:,1);
Data8Bit_SIG = gpuArray(fread(fopen(FilePath_SIG_Raw),[Segmentsize*2, NumberOfRecordings_SIG], 'int8=>int8'));
Data8Bit_SIG = permute(reshape(Data8Bit_SIG,2,Segmentsize,NumberOfRecordings_SIG),[2,3,1]);
Data8Bit_SIG = Data8Bit_SIG(:,:,1);

% get timestamps for the signal (ideally one would also dismiss this point)
Timestamps = zeros([NumberOfRecordings_SIG, 1], 'uint64');
TimestampsfileID = fopen(FilePath_SIG_Stamp);
TimestampsRaw = fread(TimestampsfileID,[2*NumberOfRecordings_SIG, 1],'uint64=>uint64');
% 4.3.2 remove the empty values (every second value is empty)
for i = 1:length(Timestamps)
    Timestamps(i) = TimestampsRaw((i-1)*2+1);
end
fclose(TimestampsfileID);

%% the real code:
% data is 1 channel therefore its easier
% % calculate the quadratures
tic
Data_LO = computeQuads(Data8Bit_LO,Window); % still bugged
Data_LO = Data_LO-mean(Data_LO);
Data_SIG = computeQuads(Data8Bit_SIG,Window);
Data_SIG = Data_SIG-mean(Data_SIG);
Data_SIG = Data_SIG * RangeToVoltage(Range_SIG)/(RangeToVoltage(Range_LO)*sqrt(2)*std(Data_LO));
toc
% piezo cant be skipped unfortunately




% ignore the piezo start movement direwction for now
% compute the phase
% execute the fast density reconstruction






function Data = computeQuads(Data8Bit,Window)
    D = single(Data8Bit(:,1:100));
    D = D-mean(D,2);
    pvar = var(D,0,2);
    [~,Locs] = findpeaks(pvar,MinPeakHeight=0.5*mean(pvar),MinPeakDistance=10);
    plot(pvar)
    hold on
    scatter(Locs,pvar(Locs))
    Locs = Locs(2:end-1);
    WindowT = [-Window:Window];
    Locs = (Locs+WindowT).';
    Locs = Locs(:);
    Data8Bit = Data8Bit(Locs,:);
    G = single(reshape(Data8Bit,2*Window+1,[]));
    Data = sum(G,1);
end

function INT8_TO_VOLTAGE = RangeToVoltage(Range_I32)
    switch Range_I32
        case 0
            INT8_TO_VOLTAGE = 0.200/128;
        case 1
            INT8_TO_VOLTAGE = 0.500/128;
        case 2
            INT8_TO_VOLTAGE = 1.0/128;
        case 3
            INT8_TO_VOLTAGE = 2.5/128;
    end
end