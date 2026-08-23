function [Variables] = getVariables(Files,VariableStrings)
% Get Variable from a list of files. One can place an array of
% VariableStrings to to use an preferencelist


Variables = cell([length(Files),1]);
% go through all files
for i = 1:length(Files)
    % go through all VariableStrings
    for v = VariableStrings
        Variable = getVariableFromMat(Files(i),v);
        if ~isempty(Variable)
            Variables{i} = Variable;
            break
        end
    end
    % last check if variable was found
    if isempty(Variables{i})
        warning('Variable could not be found')
    end
end

