function [Variable] = getVariableFromMat(File,VariableString)
% Get a variable from a given matfile



% 1. check the given variable string if it is a struct or not
Components = split(VariableString,'.');
Variable = Components(1);

% 2. check for the variable
if isempty(who('-file',File,Variable))
    warning('Variable not found')
    Variable = [];
else
    Variable = load(File,Variable);
    % 3. If it is a struct
        if length(Components) > 1
            FieldName = join(Components(2:end),'.');
            if ~isfield(Variable,FieldName)
                warning('Field not found')
                Variable = [];
            else
                Variable = Variable(FieldName);
            end
        end
end


end

