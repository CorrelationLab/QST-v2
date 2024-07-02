function [SubDirectories] = getSubDirectories(RootDirectory)
%Function that returns a list of all subdirectories of given rootdirectory

SubDirectories = dir(fullfile(RootDirectory, '**\*.*'));
SubDirectories = (SubDirectories.isdir);
end

