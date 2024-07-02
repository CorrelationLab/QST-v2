function [isValid,Files] = validateFiles_ByFileExtension(Files,Extension)
%Function that returns a list of all files that have a matching file
%extension

[~, ~, Ext] = fileparts(Files);
isValid = contains(Ext,Extension);
Files = Files(isValid);
end

