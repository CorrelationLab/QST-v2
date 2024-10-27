function [DirPaths] = getDirectoryPaths(RootDirectory)
%Function that returns a list of all subdirectories of given rootdirectory.
arguments
    RootDirectory;
end

DirPaths = dir(fullfile(RootDirectory, '**\*.*')); 
DirPaths = DirPaths([DirPaths.isdir]);
DirPaths = {DirPaths.folder};
DirPaths = unique(DirPaths);
DirPaths = string(DirPaths.');
end
