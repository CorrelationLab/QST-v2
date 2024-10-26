function [ Data8bit, Config, Timestamps ] = load8BitBinary(Directory, Filename,Options)
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
assert(exist(Filepath_Raw,'file')==2,['There is no *raw-file with filename', Filename, '!' ]);
assert(exist(Filepath_Config,'file')==2,['There is no *.cfg-file with filename', Filename, '!']);
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
% 4.1.1 Channelnumber
Channelnumber = Config.SpectrumCard.Channel00.Enable_BOOL + ...
                Config.SpectrumCard.Channel01.Enable_BOOL + ...
                Config.SpectrumCard.Channel02.Enable_BOOL + ...
                Config.SpectrumCard.Channel03.Enable_BOOL;
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
Data = fread(DatafileID,[Segmentsize*Channelnumber, NumberOfRecordings], 'int8=>int8');
% 4.2.2 distribute the recorded data into the different channels
if Channelnumber>1
    Data8bit = zeros(Segmentsize, NumberOfRecordings, Channelnumber,'int8');
    for iBlock = 1:NumberOfRecordings
        for iChannel = 1:Channelnumber
            Data8bit(:,iBlock,iChannel) = Data(iChannel:Channelnumber:Segmentsize*Channelnumber, iBlock);
        end
    end
else
    Data8bit = Data; % one has to check if this works, since the code afterwards is based on 3d arrays
end
% 4.2.3 close the file again
fclose(DatafileID);



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

