function [Data8bit, Config, Timestamps] = load8BitBinary(Directory, Filename, StarHub, Options)
%% Description:
%   This function loads 8-bit binary data recorded with a Spectrum data acquisition card, its configuration file,
%   and optionally its timestamp file.
%
%   It supports both a standard single-ADC-card setup and a multi-ADC-card StarHub setup. For StarHub measurements,
%   the channels are reordered to match the channel order specified in the configuration file.
%
%% Syntax:
%   Data8bit = load8BitBinary(Directory, Filename)
%   [Data8bit, Config] = load8BitBinary(Directory, Filename)
%   [Data8bit, Config, Timestamps] = load8BitBinary(Directory, Filename)
%   [...] = load8BitBinary(Directory, Filename, StarHub)
%   [...] = load8BitBinary(Directory, Filename, StarHub, SaveData=true)
%
%% Input:
% required input values:
%   Directory                                       - folder containing the measurement files
%   Filename                                        - filename without the .raw extension
%
% optional input values:
%   StarHub                                         - false for a single ADC card (default); true for a multi-ADC
%                                                     StarHub setup
%
% name-value input options:
%   SaveData                                        - save Data8bit as 'Data8bit.mat' (default: false)
%
%% Output:
%   Data8bit                                        - int8 measurement data
%   Config                                          - configuration structure
%   Timestamps                                      - uint64 trigger timestamps, or [] if unavailable



    arguments
        Directory
        Filename
        StarHub (1,1) logical = false
        Options.SaveData (1,1) logical = false
    end
    
    
    
    %% 1. File paths and configuration
    Filepath_Raw = fullfile(Directory, strcat(Filename, '.raw'));
    Filepath_Config = fullfile(Directory, strcat(Filename, '.cfg'));
    Filepath_Timestamp = fullfile(Directory, strcat(Filename, '.stamp'));
    
    assert(exist(Filepath_Raw, 'file') == 2, ['There is no .raw file with filename ', Filename, '!']);
    assert(exist(Filepath_Config, 'file') == 2, ['There is no .cfg file with filename ', Filename, '!']);
    
    Config = QST.QuadratureCalculation.getConfig(Filepath_Config);
    Segmentsize = Config.SpectrumCard.ModeSetup.Segmentsize_I32;
    
    if isfield(Config.SpectrumCard.ModeSetup, 'Memory_I32')
        Memsize = Config.SpectrumCard.ModeSetup.Memory_I32;
    else
        Memsize = round(Config.SpectrumCard.ModeSetup.Memory_DBL);
    end
    
    assert(mod(Memsize, Segmentsize) == 0, 'Memory size must be an integer multiple of the segment size.');
    NumberOfRecordings = Memsize / Segmentsize;
    
    %% 2. Get active-channel information
    if StarHub
        ChannelNames = "Channel0" + (1:4);
    else
        ChannelNames = "Channel0" + (0:3);
    end
    
    ChannelInfo = Config.SpectrumCard.(ChannelNames(1));
    
    for iChannel = 2:numel(ChannelNames)
        ChannelInfo(iChannel) = Config.SpectrumCard.(ChannelNames(iChannel));
    end
    
    ChannelInfo = ChannelInfo([ChannelInfo.Enable_BOOL]);
    Channelnumber = numel(ChannelInfo);
    
    assert(Channelnumber > 0, 'No active channels found in the configuration.');
    
    %% 3. Read raw data
    DatafileID = fopen(Filepath_Raw, 'r');
    assert(DatafileID ~= -1, 'Could not open raw data file.');
    
    if StarHub
        CardIDs = [ChannelInfo.ADC_CardID_I32];
        InputIDs = [ChannelInfo.ADC_InputID_I32];
        ChannelsPerCard = arrayfun(@(iCard) sum(CardIDs == iCard), 0:max(CardIDs));
    else
        ChannelsPerCard = Channelnumber;
    end
    
    Data8bit = zeros(Segmentsize, NumberOfRecordings, Channelnumber, 'int8');
    StartChannel = 1;
    
    for iBlock = 1:numel(ChannelsPerCard)
        NumberOfChannels = ChannelsPerCard(iBlock);
    
        if NumberOfChannels == 0
            continue;
        end
    
        Data = fread(DatafileID, [Segmentsize * NumberOfChannels, NumberOfRecordings], 'int8=>int8');
    
        assert(numel(Data) == Segmentsize * NumberOfChannels * NumberOfRecordings, ...
            'Raw data file ended unexpectedly.');
    
        EndChannel = StartChannel + NumberOfChannels - 1;
        Data8bit(:, :, StartChannel:EndChannel) = ...
            permute(reshape(Data, NumberOfChannels, Segmentsize, NumberOfRecordings), [2, 3, 1]);
    
        StartChannel = EndChannel + 1;
    end
    fclose(DatafileID);
    
    % Convert StarHub data from physical card/input order to configuration channel order.
    if StarHub
        [~, ChannelOrder] = sort(CardIDs * 4 + InputIDs);
        Data8bit = Data8bit(:, :, ChannelOrder);
    end
    
    % Preserve the original two-dimensional output for a single non-StarHub channel.
    if ~StarHub && Channelnumber == 1
        Data8bit = Data8bit(:, :, 1);
    end
    
    %% 4. Read timestamps
    Timestamps = [];
    
    if exist(Filepath_Timestamp, 'file') == 2
        TimestampsfileID = fopen(Filepath_Timestamp, 'r');
        assert(TimestampsfileID ~= -1, 'Could not open timestamp file.');
    
        TimestampsRaw = fread(TimestampsfileID, [2 * NumberOfRecordings, 1], 'uint64=>uint64');
        fclose(TimestampsfileID);
        Timestamps = TimestampsRaw(1:2:end);
    else
        warning('No timestamps file detected.');
    end
    
    %% 5. Save data
    if Options.SaveData
        save('Data8bit.mat', '-v7.3', 'Data8bit');
    end
end