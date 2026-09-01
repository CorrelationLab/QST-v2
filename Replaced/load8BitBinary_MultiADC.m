function [ Data8bit, Config, Timestamps ] = load8BitBinary_MultiADC(Directory, Filename,Options)
%LOAD8BITBINARY Loads 8bit binary datafiles, the configuration file and the
%timestamp file for a single multiple recording measurement with a Spectrum
%data acquisition card.
%
%   DATA8BIT = LOAD8BITBINARY(Filename) Depending on the number of
%   channels, DATA8BIT is a 2D- or 3D- array with dimensions [columns,
%   rows, channels] that contains a single measured segment of one channel
%   in a column. To extract the number of channels, a configuration file
%   Filename.cfg is necessary. The file 'Filename' has to be located in the
%   folder 'raw-data'.
%
%   [DATA8BIT, CONFIG, TIMESTAMPS] = LOAD8BITBINARY(Filename) Additionally
%   to the previously discussed array DATA8BIT, the structure CONFIG
%   consists of the configuration data and TIMESTAMPS is a 1D-array
%   containing the timestamps of the trigger events. 

arguments
    Directory;
    Filename;
    Options.SaveData = false;
    Options.UseLegacySyntax = false;
end


% 1. create the paths to the raw the config and the timestamp file
Filepath_Raw = fullfile(Directory, strcat([Filename, '.raw']));
if Options.UseLegacySyntax
    Filepath_Config = fullfile(Directory, strcat([Filename, '.raw.cfg']));
    Filepath_Timestamp = fullfile(Directory, strcat([Filename, '.raw.stamp']));
else
    Filepath_Config = fullfile(Directory, strcat([Filename, '.cfg']));
    Filepath_Timestamp = fullfile(Directory, strcat([Filename, '.stamp']));
end

% 2. check that all files exists (timestamps are optional)
assert(exist(Filepath_Raw,'file')==2,['There is no *raw-file with filename ', Filename, '!' ]);
assert(exist(Filepath_Config,'file')==2,['There is no *.cfg-file with filename ', Filename, '!']);
if exist(Filepath_Timestamp,'file')==2
    TimestampsExists = true;
else
    disp('Warning: No timestamps file detected!');
    TimestampsExists = false;
end

% 3. generate the config struct from the config file
Config = QST.QuadratureCalculation.getConfig(Filepath_Config);



% 4. generate the 8bit data from the raw-file
% 4.1 get the necessary infos from the config files
% Channel information
nChannels = 4;
nChannelsPerADCCard = 4;
for i = 1:nChannels
    ChannelInfo(i) = getfield(Config.SpectrumCard,'Channel0'+string(i));
end
% 4.1.1.1 Channel enabled
ChannelEnabled = [ChannelInfo(:).Enable_BOOL];
% 4.1.1.2
% # ADC cards
nADCcards = max([ChannelInfo(:).ADC_CardID_I32])+1;
% get the matrix of active ADC inputs and the channel-saveorder lookup
% table
Channel_Input_LookupTable = zeros(4,1);
ActiveCardInputs = zeros(nChannelsPerADCCard,nADCcards);
for i = 1:length(ChannelInfo)
    ActiveCardInputs(ChannelInfo(i).ADC_InputID_I32+1,ChannelInfo(i).ADC_CardID_I32+1) = 1;
    Channel_Input_LookupTable(i) = ChannelInfo(i).ADC_CardID_I32 *nChannelsPerADCCard + ChannelInfo(i).ADC_InputID_I32;
end
% get the order on how the channels where saved
[~,Channel_SaveOrder_LookupTable] = sort(Channel_Input_LookupTable(ChannelEnabled == 1)); 

% 4.1.2 Segmentsize
Segmentsize = Config.SpectrumCard.ModeSetup.Segmentsize_I32;

% 4.1.3 Memsize; The field could be called "Memory_I32" or "Memory_DBL"
if isfield(Config.SpectrumCard.ModeSetup,'Memory_I32')
    Memsize = Config.SpectrumCard.ModeSetup.Memory_I32;
else
    Memsize = round(Config.SpectrumCard.ModeSetup.Memory_DBL);
end
% 4.1.4 Number of recordings
NumberOfRecordings = Memsize/Segmentsize;


% 4.2 generate the 8 bit data

% 4.2.1 read in data
DatafileID = fopen(Filepath_Raw);

% 4.2.2 distribute the recorded data into the different channels
StartCH = 1;
for i = 1:size(ActiveCardInputs,2)
    ActiveInputsOnCard = sum(ActiveCardInputs(:,i));
    if ActiveInputsOnCard > 0
        Data = fread(DatafileID,[Segmentsize*ActiveInputsOnCard, NumberOfRecordings], 'int8=>int8');
        Data8bit(:,:,StartCH:StartCH+ActiveInputsOnCard-1) = permute(reshape(Data,ActiveInputsOnCard,Segmentsize,NumberOfRecordings),[2,3,1]);
        StartCH = StartCH+ActiveInputsOnCard;
    end
end
Data8bit = Data8bit(:,:,Channel_SaveOrder_LookupTable);
% 4.2.3 close the file again
fclose(DatafileID);


%X1 = Data8bit(:,:,1);
%X2 = Data8bit(:,:,2);
%X3 = Data8bit(:,:,3);
%X4 = Data8bit(:,:,4);
%subplot(1,4,1)
%plot(X1(:));
%subplot(1,4,2)
%plot(X2(:));
%subplot(1,4,3)
%plot(X3(:));
%subplot(1,4,4)
%plot(X4(:));

% 4.3 if timestamps exists also get them
if TimestampsExists
    % 4.3.1 open the timestamp file and get the raw data
    Timestamps = zeros([NumberOfRecordings, 1], 'uint64');
    TimestampsfileID = fopen(Filepath_Timestamp);
    TimestampsRaw = fread(TimestampsfileID,[2*NumberOfRecordings, 1],'uint64=>uint64');
    % 4.3.2 remove the empty values (every second value is empty)
    for i = 1:length(Timestamps)
        Timestamps(i) = TimestampsRaw((i-1)*2+1);
    end
    fclose(TimestampsfileID);
end



% 5. save the data as 8bit 3D-array
if Options.SaveData
    save('Data8bit.mat','-v7.3','Data8bit');
end



end
% READ TIMESTAMPS
% 1. When using VI dwTimestampsRead_64.vi (64bit) in LabView and big-endian ordering:
% fseek(timestampsfileID,4,'bof');
% timestamps = fread(timestampsfileID,[2*memsize/segmentsize 1],'uint64=>uint64',0,'s');
% 2. For Debugging:
% timestamps_raw = fread(timestampsfileID,[16 2*memsize/segmentsize],'uint8=>uint8');
% 3. When using VI dwTimestampsRead.vi (32bit) in LabView and big-endian ordering:
% timestamps_raw = fread(timestampsfileID,[2*memsize/segmentsize 1],'uint64=>uint64',0,'s');
% timestamps_raw(1) = mod(timestamps_raw(1),2^24); %Removing filesize bytes in the first timestamp when using 32bit timestamp reading operation in LabView

