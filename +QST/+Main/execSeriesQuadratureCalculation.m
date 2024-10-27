function [] = execSeriesQuadratureCalculation(Directory, Channels,Offset,ModulatedPhase,RemoveDetectorResponse,Options)
% Function to automatically calculate the quadratures of a whole recorded Series.
% It manages the File  ordering and saves the results while the main calculation 
% is done by the function 'QST.QuadratureCalculation.prepareData'.
% The Series has to be saved in one main directory with each each Dataset in its own subdirectory
% in each subdirectory the recorded six files (cfg, raw, stamp for both LOOnly and LOwithSIG)
% have to be again in another Subdirectory called 'rawdata'.

% Dependent of the type of signal two different analysis approaches have to be used
% (here shown if all channels behave equal, otherwise adjust the params accordingly)
% For measurements with undefined phase with reference to the LO use:
%        Offset = ['Local','Local','Local'];
%        ModulatedPhase = [false,false,false];
%        RemoveDetectorResponse = [true,true,true];
% For measurements with well defined  phase with reference to LO use:
%        Offset = ['Global','Global','Global'];
%        ModulatedPhase = [true,true,true];
%        RemoveDetectorResponse = [false,false,false];
   
    arguments
        % DirPath
        Directory;
        %Parameter:
        Channels;
        Offset = ['Local','Local','Local'];
        ModulatedPhase = [false,false,false];
        RemoveDetectorResponse = [true,true,true];
        Options.IntegrationDutyCycle = 1/3;
        Options.nMean_Min = 1000000;
        Options.Delta = 50;
        %Token
        Options.Token_LOOnly = "LOonly";
        Options.Token_LOAndSignal = "LOwithSIG";
        Options.UseLegacySyntax = false;
    end
    IntegrationDutyCycle = Options.IntegrationDutyCycle;
    nMean_Min = Options.nMean_Min;
    Delta = Options.Delta;
    Token_LOOnly = Options.Token_LOOnly;
    Token_LOAndSignal = Options.Token_LOAndSignal;
    UseLegacySyntax = Options.UseLegacySyntax;

%% 1. get all Subdirectories
SubDirectories = QST.File_Managment.getDirectoryPaths(Directory);

%% 2. calculate and save the quadratures for each recorded dataset
for Dir = SubDirectories.'
    FileName_LOOnly = "";
    FileName_LOAndSignal = "";

    % 2.1 skip if directory includes no valid files (checked by seachring for '.raw' files)
    if isempty(dir(fullfile(Dir,'*.raw')))
        continue
    end

    % 2.2 get the filepaths of a dataset
    [~,FileNames,~] = fileparts(QST.File_Managment.getFilePaths(Dir));
    
    % 2.3 get the filenames of LOOnly and LOwithSIG with the used tokens (THIS PART CAN BE IMPROVED)
    for Name = FileNames.'
        if contains(Name,Token_LOOnly)
            FileName_LOOnly = Name;
        end
        if contains(Name,Token_LOAndSignal)
            FileName_LOAndSignal = Name;
        end
    end
    assert(FileName_LOOnly ~= "" && FileName_LOAndSignal ~= "","Filenames are wrong: LOOnly and/or LOAndSignal Files could not be found")
    % 2.4 calculate the Quadratures
    [X1, X2, X3, PiezoInfos] = QST.QuadratureCalculation.prepareData(Dir,...
                                     char(FileName_LOOnly),...
                                     char(FileName_LOAndSignal),...
                                     Channels,...
                                     Offset,...
                                     ModulatedPhase,...
                                     RemoveDetectorResponse,...
                                     IntegrationDutyCycle,...
                                     nMean_Min,...
                                     Delta,...
                                     UseLegacySyntax=UseLegacySyntax);
    
    % 2.5 save the calculated quadratures
    % create Folder
    SaveDirectory = fullfile(Dir,'..');
    SaveDirectory = fullfile(SaveDirectory,'mat-data');
    if ~exist(SaveDirectory,"dir")
        mkdir(SaveDirectory)
    end

    % save the data
    QST.QuadratureCalculation.saveQuadratures(SaveDirectory, 'Matdata', X1, X2, X3, PiezoInfos);
    % create some extra Config to save the analysis parameter (to be implemented)
    %QST.QuadratureCalculation.saveAnalyseParameters([],QuadratureCalculation,Channels,)
end



