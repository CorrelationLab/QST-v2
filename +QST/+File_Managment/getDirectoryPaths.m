function [DirPaths] = getDirectoryPaths(RootDirectory,Options)
%% Description:
%   This function reads in a directory and returns an array of the absolute paths of all subdirectories
%
%% Syntax:
%   [DirPaths] = getDirectoryPaths(RootDirectory, IncludeSubDirs=false)
%
%% Input:
% required input values;
%   RootDirectory                                   - root directory of the serach
%
% optional input values;
%   IncludeSubDirs                                  - bool if subsubdirectories should also be included

%
%% Output:
%   DirPaths                                        - string array of the absolute paths of the sub directories



    arguments(Input)
        RootDirectory;
        Options.IncludeSubDirs=false;
    end
    
    
    % Extract the absolute paths of all subdirectories
    if Options.IncludeSubDirs == false
        DirPaths = dir(fullfile(RootDirectory, '*'));
    else
        DirPaths = dir(fullfile(RootDirectory, '**\*.*'));
    end
    DirPaths = DirPaths([DirPaths.isdir]);
    DirPaths = {DirPaths.folder};
    DirPaths = unique(DirPaths);
    DirPaths = string(DirPaths.');
end
