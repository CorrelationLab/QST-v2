function [FilePaths] = getFilePaths(RootDirectory, Options)
%% Description:
%   This function reads in a directory and returns an array of the absolute paths of all files in all subdirectories
%
%% Syntax:
%   [FilePaths] = getFilePaths(RootDirectory,IncludeSubDirs=true)
%
%% Input:
% required input values;
%   RootDirectory                                   - root directory of the serach
%
% optional input values;
%   IncludeSubDirs                                  - bool if subsubdirectories should also be included

%
%% Output:
%   FilePaths                                       - string array of the absolute paths of the sub directories



    arguments
        RootDirectory;
        Options.IncludeSubDirs=true;
    end


    % Extract the absolute paths of all files
    if Options.IncludeSubDirs == false
        FilePaths = dir(fullfile(RootDirectory, '*'));
    else
        FilePaths = dir(fullfile(RootDirectory, '**\*.*'));
    end 
    FilePaths = FilePaths(~[FilePaths.isdir]);
    FilePaths = fullfile({FilePaths.folder},{FilePaths.name});
    FilePaths = string(FilePaths.');
end