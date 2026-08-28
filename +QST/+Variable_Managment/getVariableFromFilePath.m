function [Variable] = getVariableFromFilePath(FilePath, VariableString)
%% Description:
%   This function reads in a file path to a .mat file and loads a specific given by VariableString. If this function is applied in a series and the
%   variable name may change between iterations (an example would for e.g. a search for g2 inside the condensate state which can be saved either in a 
%   variable ending to _high if the separation function was applied or without if the function was not applied or the system was constant inside the condensate state).
%   In this case one can insert a priority listof decsending order of variable names which then returns the first found variable. 
%   The function can also extract fields from a struct. In its current form this function cannot return all fields of a struct array at once but has to be called in a loop.
%
%% Syntax:
%   [Variable] = getVariableFromFilePath(FilePath, VariableString)
%
%% Input:
% required input values;
%   FilePath                                        - absolute file path to the .mat file
%   VariableString                                  - string or array of strings containing the variable that should be extracted from the matfile.
%                                                     In case of an array this acts as a priority list and the function returns the first variable found
%   
%
%% Output:
%   Variable                                        - first fitting variable found in the .mat file



    arguments
        FilePath;
        VariableString;
    end


    Variable = [];
    %% 1. Iterate through the array of variables
    for i = 1:length(VariableString)

        %% 2. Try to load the main variable
        try
            VariableString_Components = split(VariableString(i),'.');
            Variable = load(FilePath,VariableString_Components{1});
            Variable = Variable.(VariableString_Components{1});
        catch 
            warning("Variable" + VariableString_Components{1} + " not found");
        end

        %% 3. Try to load the exact variable field in case a struct is given
        try
            if length(VariableString_Components) > 1   
                X = VariableString_Components(2:end);
                Variable = getfield(Variable,X{:});
            end
        catch
            warning("Searched component" + join(VariableString_Components(2:end),'.') + "not found in struct " + VariableString_Components(1));
            Variable = [];
        end

        %% 4. return the found variable
        if ~isempty(Variable)
            break
        end
    end

    %% 5. Return a warning if no variable could be found
    if isempty(Variable)
        warning("No searched variable found");
    end
end

