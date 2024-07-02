function [Files] = getFilesFromSubDirectories(RootDirectory)
%Function that returns a list of all files of all subdirectories of a given rootdirectory

Files = dir(fullfile(RootDirectory, '**\*.*'));
Files = Files(~[Files.isdir]);
end

