function [Variable] = getVariableFromFilePath(FilePath,VariableString)
    % Function that loads a variable from a given matfile based on the variablename as string. If 'VariableString' is an array it is used as a 
    % preference list (First check for variable A, if it does not exist check for variable B...)
    arguments
        FilePath;
        VariableString;
    end
    Variable = [];

    for i = 1:length(VariableString)
        % 1. Try to load the variable
        try
            VariableString_Components = split(VariableString(i),'.');
            Variable = load(FilePath,VariableString_Components{1});
            Variable = Variable.(VariableString_Components{1});
        catch 
            warning("Variable" + VariableString_Components{1} + " not found");
        end

        % 2. in case the variable is field of a struct search for this
        try
            if length(VariableString_Components) > 1   
                X = VariableString_Components(2:end);
                Variable = getfield(Variable,X{:});
            end
        catch
            warning("Searched component" + join(VariableString_Components(2:end),'.') + "not found in struct " + VariableString_Components(1));
            Variable = [];
        end
        % if the variable is found break the loop and return the found variable
        if ~isempty(Variable)
            break
        end
    end
    % give a warning if nothings was found at all
    if isempty(Variable)
        warning("No searched variable found");
    end

end

