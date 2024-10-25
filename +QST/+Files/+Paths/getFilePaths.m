function [FilePaths] = getFilePaths(RootDirectory)
%Function that returns a list of all filepaths to all files in a given rootdirectory and its subdirectories
arguments
    RootDirectory;
end

FilePaths = dir(fullfile(RootDirectory, '**\*.*')); 
FilePaths = FilePaths(~[FilePaths.isdir]);
FilePaths = fullfile({FilePaths.folder},{FilePaths.name});
FilePaths = string(FilePaths.');
end