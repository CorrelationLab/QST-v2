function [DirPaths] = getDirectoryPaths(RootDirectory,IncludeSubDirs)
%Function that returns a list of all subdirectories of given rootdirectory.
arguments
    RootDirectory;
    IncludeSubDirs=true;
end
if IncludeSubDirs == false
    DirPaths = dir(fullfile(RootDirectory, '*'));
else
    DirPaths = dir(fullfile(RootDirectory, '**\*.*'));
end
DirPaths = DirPaths([DirPaths.isdir]);
DirPaths = {DirPaths.folder};
DirPaths = unique(DirPaths);
DirPaths = string(DirPaths.');
end
