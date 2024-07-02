function [] = execOnFileAndSave(Files,FunctionHandler,InputCell,OutputVariables)
% This wrapper execute a given function on a set of files. Needed variables
% which are stored in the file have to placed in InputCell by their string
% and the appendix 'VS_'

isValid = ~isequal(OutputVariables,'');
OutputVariables = OutputVariables(isValid);

for f = Files
    % 1. Load necessary variables
    InputCellData = InputCell;
    for i = 1:length(InputCellData)
        if ischar(InputCellData{i})
            if startsWith(InputCellData{i},'VS_')
                InputCellData{i} = getVariableFromMat(f,InputCellData{i}(4:end));
            end
        end
    end


    % 2. execute the function
    OutputTuple  = FunctionHandler(InputCellData{:});
    % 3. Save the outputs into a struct
    OutputTuple = OutputTuple(isValid);

    for i = 1:length(OutputVariables)
        OutputStruct.(OutputVariables(i)) = OutputTuple(i);
    end
    % save the outputs placed in the struct
    save(f,'-struct',"OutputStruct",'-append');
    % clean the workspace
    clear OutputTuple OutputStruct  

end
end

