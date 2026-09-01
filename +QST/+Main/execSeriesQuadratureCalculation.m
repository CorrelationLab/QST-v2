function [] = execSeriesQuadratureCalculation(Directory, Channels, OffsetType, ModulatedPhase, RemoveDetectorResponse, Options)
%% Description:
%   This function reads in a main directory of a series of measurements and computes the quadratures out of each measurement.
%   To this end each measurement has to consist six files (1 vacuum measurement for calibration, 1 measurement with signal, each measurement saves 3 
%   files, a .cfg config file, a timestamp .stamp file and a .raw binary data file). The file tree should have the following structure:
%   -Dir
%       -Measurement_1
%           -raw-data
%               -LOonly.cfg
%               -LOonly.stamp
%               -LOonly.raw
%               -LOwithSIG.cfg
%               -LOwithSIG.stamp
%               -LOwithSIG.raw
%       -Measurement_2
%       ...
% 
%   The final quadratures are then saved in a .mat file that is saved in an extra sub directory 'mat-data' which is placed on the same level as 'raw-data'
% 
%% Syntax:
%   execSeriesQuadratureCalculation(Directory, Channels, OffsetType, ModulatedPhase, RemoveDetectorResponse, Options)
%
%% Input:
% required input values;
%   Directory                                   - main directory of the measurement series
%   Channels                                    - array of the detection channels of the homodyne setup that were active in the measurement 
%   OffsetType                                  - array of options to indicate wether the offset correction should be applied using a global or a local varying offset.
%                                                 An example would be "OffsetType = ["Global", "Global", "Global", "Global"]" or "OffsetType = ["Local", "Local", "Local", "Local"]"
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
% 



    arguments
        % Directory
        Directory;
        %Parameter:
        Channels;
        OffsetType = ["Local", "Local", "Local", "Local"];
        ModulatedPhase = [false, false, false, false];
        RemoveDetectorResponse = [true, true, true, true];
        Options.Preset = '';
        % quadrature integration
        Options.IntegrationDutyCycle = 1/3;
        % detector response removal
        Options.nMean_Min = 1000000;
        Options.Delta = 50;
        %Token
        Options.Token_LOOnly = "LOOnly";
        Options.Token_LOAndSignal = "LOwithSIG";
        Options.UseLegacySyntax = false;
        Options.StarHubIncluded = true;
    end


    %% 0. Set OffsetType, ModulatedPhase and RemoveDetectorResponse according to a preset to save time
    switch Options.Preset
        case 'FixedPhase'
            OffsetType = ["Global","Global", "Global", "Global"];
            ModulatedPhase = [true,true,true,true];
            RemoveDetectorResponse = [false, false, false, false];
        case ''
            OffsetType = ["Local", "Local", "Local", "Local"];
            ModulatedPhase = [false, false, false, false];
            RemoveDetectorResponse = [true, true, true, true];
    end
    
    
    %% 1. Get all Subdirectories
    SubDirectories = QST.File_Managment.getDirectoryPaths(Directory);
    
    %% 2. Compute and save the quadratures for each recorded dataset
    parfor i = 1:length(SubDirectories)
        Dir = SubDirectories(i);
        FileName_LOOnly = "";
        FileName_LOAndSignal = "";
    
        % 2.1 skip if directory includes no valid files (checked by seachring for '.raw' files)
        if isempty(dir(fullfile(Dir,'*.raw')))
            continue
        end
    
        % 2.2 get the filepaths of a dataset
        [~,FileNames,~] = fileparts(QST.File_Managment.getFilePaths(Dir));
    
        % 2.3 get the filenames of LOOnly and LOwithSIG with the used tokens
        for Name = FileNames.'
            if contains(Name, Options.Token_LOonly)
                FileName_LOOnly = Name;
            end
            if contains(Name, Options.Token_LOAndSignal)
                FileName_LOAndSignal = Name;
            end
        end
        assert(FileName_LOOnly ~= "" && FileName_LOAndSignal ~= "","Filenames are wrong: LOOnly and/or LOAndSignal Files could not be found")

        % 2.4 calculate the Quadratures
        [X1, X2, X3, X4, PiezoInfos] = QST.QuadratureCalculation.computeQuadratures(Dir,...
                                                                                    char(FileName_LOOnly),...
                                                                                    char(FileName_LOAndSignal),...
                                                                                    Channels,...
                                                                                    OffsetType,...
                                                                                    ModulatedPhase,...
                                                                                    RemoveDetectorResponse,...
                                                                                    Options.IntegrationDutyCycle,...
                                                                                    Options.nMean_Min,...
                                                                                    Options.Delta,...
                                                                                    StarHubIncluded=Options.StarHubIncluded);
    
        % 2.5 save the calculated quadratures
        SaveDirectory = fullfile(Dir,'..');
        SaveDirectory = fullfile(SaveDirectory,'mat-data');
        if ~exist(SaveDirectory,"dir")
            mkdir(SaveDirectory)
        end
        QST.QuadratureCalculation.saveQuadratures(SaveDirectory, 'Matdata', X1, X2, X3,X4, PiezoInfos);
    end
end



