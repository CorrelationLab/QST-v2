function [DataCell,SeriesParams] = getVariablesFromSeries(DirPath,VariableString,Identifier,Options)
%% Description:
%   This function collects a specified variable from all MATLAB .mat files found in a directory and associates every
%   loaded variable with a series parameter extracted from its file path or filename.
%
%   The series parameter is identified using a regular expression. Predefined identifiers for common experimental
%   series parameters, such as laser power, axicon position, and DC voltage, are available.
%
%   The collected variables are returned as a cell array by default. Optionally, the cell array can be converted into
%   a regular MATLAB array if all loaded variables have compatible dimensions.
%
%   VariableString can be an array of different variables. In this case the program searches through the variables for one that exists in the file, 
%   whereby the the position inside the array gives the priority.
%
%% Syntax:
%   [DataCell, SeriesParams] = getVariablesFromSeries(DirPath, VariableString, Identifier)
%
%   [DataCell, SeriesParams] = getVariablesFromSeries(DirPath, VariableString, Identifier, Options)
%
%   [DataCell, SeriesParams] = getVariablesFromSeries(DirPath, VariableString, "Power")
%
%   [DataCell, SeriesParams] = getVariablesFromSeries(DirPath, VariableString, Identifier, ...
%       Wanted=[1, 2, 3], SaveAsRegularArray=true)
%
%% Input:
% required input values:
%   DirPath                                         - root directory searched recursively for MATLAB .mat data files
%
%   VariableString                                  - variable name or variable path of the data to be loaded from
%                                                     every MATLAB file. It can also be an array to be used as priority list
%
%   Identifier                                      - regular expression used to identify the series parameter in each
%                                                     file path or filename; predefined identifiers are "Power",
%                                                     "Axicon", and "DC"
%
% name-value input options:
%   SubIdentifier                                   - regular expression used to extract the numeric parameter value
%                                                     from the identifier match (default: "[0-9]+[i\\.]?[0-9]*")
%
%   DotExchange                                     - two-element string array defining character replacements applied
%                                                     while extracting the parameter value; intended, for example, to
%                                                     replace "i" by "." (default: ["i", "."])
%
%   DataType                                        - function handle intended to define the data type of extracted
%                                                     series parameters (default: @float)
%
%   Unwanted                                        - vector of series-parameter values to exclude from the returned
%                                                     data (default: [])
%
%   Wanted                                          - vector of series-parameter values to include; all other values
%                                                     are excluded when this option is specified (default: [])
%
%   AppendixDataCell                                - cell array appended before the collected DataCell entries
%                                                     (default: [])
%
%   AppendixSeriesParams                            - vector appended before the collected SeriesParams entries
%                                                     (default: [])
%
%   SaveAsRegularArray                              - logical value specifying whether DataCell is converted to a
%                                                     regular array using cell2mat (default: false)
%
%% Output:
%   DataCell                                        - cell array containing the variable specified by VariableString
%                                                     from every selected MATLAB file; optionally converted to a
%                                                     regular array if SaveAsRegularArray is true
%
%   SeriesParams                                    - vector containing the extracted series parameter corresponding
%                                                     to every entry of DataCell
%
%% Predefined identifiers:
%   "Power"                                         - searches for values with optional mW or $\mu\mathrm{W}$ units
%
%   "Axicon"                                        - searches for identifiers beginning with "Ax"
%
%   "DC"                                            - searches for identifiers beginning with "DC"
%



    arguments
        DirPath;
        VariableString;
        Identifier;
        Options.SubIdentifier = "[0-9]+[i\\.]?[0-9]*";
        Options.DotExchange = ["i","."];
        Options.DataType = @double;
        Options.Unwanted = [];
        Options.Wanted = [];
        Options.AppendixDataCell = [];
        Options.AppendixSeriesParams = [];
        Options.SaveAsRegularArray = false;
    end


    %% 1. Set the Identifier to simplify standard cases
    switch Identifier
        case 'Power'
                Identifier = "[0-9]+[i\.]?[0-9]*[mW]?[µW]";
                Options.SubIdentifier = "[0-9]+[i\.]?[0-9]*";
                Options.DotExchange = ["i","."];
                Options.DataType = @double;
        case 'Axicon'
                Identifier = "Ax[0-9]+[i\.]?[0-9]*";
                Options.SubIdentifier = "[0-9]+[i\.]?[0-9]*";
                Options.DotExchange = ["i","."];
                Options.DataType = @double;
        case 'DC'
                Identifier = "DC[0-9]+[i\.]?[0-9]*";
                Options.SubIdentifier = "[0-9]+[i\.]?[0-9]*";
                Options.DotExchange = ["i","."];
                Options.DataType = @double;
    end

    %% 2. Get The Paths to all the Data
    DataFilePaths = QST.File_Managment.getFilePaths(DirPath, FileTypes='*.mat', IncludeSubDirs=true);
    
    %% 3. Remove valid but unwanted files from the lookthrough (but how)

    %% 4. Go through the Files
    DataCell = {};
    SeriesParams = [];
    for f = DataFilePaths
        % get the infomation of the series 
        Param = QST.Variable_Managment.getMetaDataFromString(f,Identifier,Options.SubIdentifier,Exchange=Options.DotExchange);
        if ~isempty(Options.Wanted)
            if ~ismember(Param,Options.Wanted)
                continue
            end
        end
        if ~isempty(Options.Unwanted)
            if ismember(Param,Options.Unwanted) 
                continue
            end
        end

        % get the variable
        Variable = QST.Variable_Managment.getVariableFromFilePath(f, VariableString);
        DataCell{end+1} = Variable;
        SeriesParams(end+1) = Param;
    end

    if ~isempty(Options.AppendixDataCell) && ~isempty(Options.AppendixSeriesParams)
        DataCell = [Options.AppendixDataCell,DataCell];
        SeriesParams = [Options.AppendixSeriesParams,SeriesParams];
    end

    if Options.SaveAsRegularArray == true
        DataCell = cell2mat(DataCell);
    end
end

