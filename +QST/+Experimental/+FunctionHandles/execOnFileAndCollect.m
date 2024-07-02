function [Output] = execOnFileAndCollect(Files,FunctionHandler,InputCell,OutputVariables)
% This wrapper execute a given function on a set of files. Needed variables
% which are stored in the file have to placed in InputCell by their string
% and the appendix 'VS_'

isValid = ~isequal(OutputVariables,'');


Outputs = cell([length(Files),sum(isValid)]);
for i = 1:length(Files)
    % 1. Load necessary variables
    InputCellData = InputCell;
    for j = 1:length(InputCellData)
        if ischar(InputCellData{j})
            if startsWith(InputCellData{j},'VS_')
                InputCellData{j} = getVariableFromMat(Files(i),InputCellData{j}(4:end));
            end
        end
    end


    % 2. execute the function
    OutputTuple  = FunctionHandler(InputCellData{:});
    % 3. Save the outputs into a struct
    OutputTuple = OutputTuple(isValid);
    Outputs{i,:} = OutputTuple;
    % clean the workspace
    clear OutputTuple OutputStruct  

end
% restruct the output
Output = cell([sum(isValid),1]);
for i = 1:sum(isValid)
    Output{i} = Outputs(:,i);
end
end