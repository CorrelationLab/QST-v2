function [] = parSaveQuantities(FilePath, Quantities, Options)
%% Description:
%   This function saves the variable Quantities to a MATLAB file. It is intended to be called from within a parfor
%   loop, where saving is delegated to a separate function.
%
%   By default, Quantities is appended to an existing MATLAB file. Optionally, the target file can be overwritten.
%
%% Syntax:
%   parSaveQuantities(FilePath, Quantities)
%   parSaveQuantities(FilePath, Quantities, Append=true)
%   parSaveQuantities(FilePath, Quantities, Append=false)
%
%% Input:
% required input values:
%   FilePath                                        - path and filename of the MATLAB file in which Quantities is saved
%
%   Quantities                                      - variable or structure containing the quantities to be saved
%
% optional input options:
%   Append                                          - logical value specifying the saving behavior:
%                                                     true:  append Quantities to an existing file (default)
%                                                     false: overwrite the target file
%
%% Output:
%   This function does not return output arguments. It saves a variable named Quantities in FilePath.
%
%% Notes:
%   This function always saves the input under the variable name Quantities, independent of the variable name used by
%   the caller.
%
%   The function is intended to support file saving from parfor loops. Concurrent writes by multiple workers to the
%   same file can still lead to file-access conflicts and should be avoided.



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

