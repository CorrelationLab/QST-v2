function prepareSeries(FolderPath, Channels,Offset,ModulatedPhase,RemoveDetectorResponse,Options)
% Extrascript to prepare Data using Carolins PreaparationCodes (or the
% slight variations also included in this folder), to prepare data in
% arbitrary folder structures without special behavior
    arguments
        % DirPath
        FolderPath;
        %Parameter:
        Channels;
        Offset = ['Global','Global','Global'];
        ModulatedPhase = [false,false,false];
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

% get the Directories associated with the recorded Series (they have to be in the same main directory,all six files 
% associated to one recording have to be in a seperate subdirectory each, best in a subsub directory called rawdata)
% maindirectory series
    %subdirectory one recorded dataset
        %subdirectory rawdata    
FilePaths = QST.File_Managment.getFolderPathsFromFolder(FolderPath,EndFoldersOnly=true);

for FilePath = FilePaths

    %% Get FileNames
    FileNames_Raw = QST.File_Managment.getFilePathsFromFolder(FilePath,FileTypes="*.raw");
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



