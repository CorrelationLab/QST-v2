function prepareSeries(Directory, Channels,Offset,ModulatedPhase,RemoveDetectorResponse,Options)
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
        Offset = ['Global','Global','Global'];
        ModulatedPhase = [true,true,true];
        RemoveDetectorResponse = [false,false,false];
        Options.IntegrationDutyCycle = 1/3;
        Options.nMean_Min = 1000000;
        Options.Delta = 50;
        %Token
        Options.Token_LOOnly = "LOonly";
        Options.Token_LOAndSignal = "LOwithSIG";
    end
    IntegrationDutyCycle = Options.IntegrationDutyCycle;
    nMean_Min = Options.nMean_Min;
    Delta = Options.Delta;
    Token_LOOnly = Options.Token_LOOnly;
    Token_LOAndSignal = Options.Token_LOAndSignal;

 
SubDirectories = QST.Files.Paths.getSubDirectories(Directory,LeafDirsOnly=true);

for Dir = SubDirectories

    %% Get FileNames
    FileNames_Raw = QST.Files.Paths.getFilePathsFromFolder(Dir,FileTypes="*.raw");
    if isempty(FileNames_Raw)
        continue
    end
    
    FileName_LOOnly = "";
    FileName_LOAndSignal = "";

    for FileName_Raw = FileNames_Raw
        if contains(FileName_Raw,Token_LOOnly)
            FileName_LOOnly = FileName_Raw;
        end
        if contains(FileName_Raw,Token_LOAndSignal)
            FileName_LOAndSignal = FileName_Raw;
        end
    end
    assert(FileName_LOOnly ~= "" && FileName_LOAndSignal ~= "","Filenames are wrong: LOOnly and/or LOAndSignal Files could not be found")
    %% calculate the Quadratures
    [X1, X2, X3] = QST.QuadratureCalculation.prepareData(char(FileName_LOOnly),...
                                     char(FileName_LOAndSignal),...
                                     Channels,...
                                     Offset,...
                                     ModulatedPhase,...
                                     RemoveDetectorResponse,...
                                     IntegrationDutyCycle,...
                                     nMean_Min,...
                                     Delta);
    
    %% save the results
    % create Folder
    SaveFolderPath = fullfile(FilePath,'..');
    SaveFolderPath = fullfile(SaveFolderPath,'mat-data');
    if ~exist(SaveFolderPath,"dir")
        mkdir(SaveFolderPath)
    end
    % get parts of the filename right
    SIGFileNameOnly = split(FileName_LOAndSignal,'\');
    SIGFileNameOnly = char(SIGFileNameOnly(end));
    % save the data
    QST.QuadratureCalculation.saveQuadratures(SaveFolderPath,SIGFileNameOnly,X1,X2,X3);
    % create some extra Config to save the analysis parameter (to be implemented)
    %QST.QuadratureCalculation.saveAnalyseParameters([],QuadratureCalculation,Channels,)
end



