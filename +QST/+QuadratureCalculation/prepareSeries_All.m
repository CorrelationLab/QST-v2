function prepareSeries_All(Options)
% Extrascript to prepare Data using Carolins PreaparationCodes (or the
% slight variations also included in this folder), to prepare data in
% arbitrary folder structures without special behavior
    arguments
        % DirPath
        Options.FolderPath;
        %Parameter:
        Options.Channels;
        Options.IntegrationDutyCycle = 1/3;
        Options.nMean_Min = 1000000;
        Options.Delta = 50;
        %Token
        Options.Token_LOOnly = "LOonly";
        Options.Token_LOAndSignal = "LOwithSIG";
    end
    FolderPath = Options.FolderPath;
    Channels = Options.Channels;
    IntegrationDutyCycle = Options.IntegrationDutyCycle;
    nMean_Min = Options.nMean_Min;
    Delta = Options.Delta;
    Token_LOOnly = Options.Token_LOOnly;
    Token_LOAndSignal = Options.Token_LOAndSignal;

FilePaths = QST.File_Managment.getFolderPathsFromFolder(FolderPath,EndFoldersOnly=true);

for FilePath = FilePaths

    % Get FileNames
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
    % Start the code to prepare the quadratures
    [X1, X2, X3] = prepareData_All(char(FileName_LOOnly),...
                                     char(FileName_LOAndSignal),...
                                     Channels,...
                                     IntegrationDutyCycle,...
                                     nMean_Min,...
                                     Delta);
    % save the results


    % create Folder
    SaveFolderPath = fullfile(FilePath,'..');
    SaveFolderPath = fullfile(SaveFolderPath,'mat-data');
    if ~exist(SaveFolderPath)
        mkdir(SaveFolderPath)
    end
    % get parts of the filename right
    SIGFileNameOnly = split(FileName_LOAndSignal,'\');
    SIGFileNameOnly = char(SIGFileNameOnly(end));
    

    save(strcat(char(SaveFolderPath),'\',SIGFileNameOnly,'.mat'),'X1','X2','X3');
end



