function [] = parSaveQuantities(FilePath,Quantities,Options)
% PARSAVEQUANTITIES saves the Variable 'Quantities' in an extra function to allow the use
% of parfor loop. In Future this should be expanded to enable this procedure to arbitrary variables.
%
% INPUTS:
% FilePath :        SaveFilepath for the Quantities Variable
% Quantities :      The Quantities Variable
%
% OPTIONS:
% Append :          Bool which defines if Quantities should be appended to old file, or if the file should be overwritten.
%                   Default is true and should not be changed for the most situations

    arguments(Input)
        FilePath
        Quantities
        Options.Append = true
    end
    if Options.Append == true
        Append = '-append';
    else
        Append = '';
    end
    save(FilePath,'Quantities', Append);
end

