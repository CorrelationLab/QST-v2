function [] = execInSimpleSeries_NoReturns(FunctionAsString,Indices_1,Indices_2)

    arguments
        FunctionAsString
        Indices_1
        Indices_2 = [];
    end
% Quick and Dirty Solution
    for i = 1:length(Indices_1)
        if ~isempty(Indices_2) 
            for j = 1:length(Indices_2)
                FunctionAsString_Iteration = replace(replace(FunctionAsString,'IND1',string(Indices_1(i))),'IND2',string(Indices_2(j)));
                evalin('base',FunctionAsString_Iteration);
            end
        else
            FunctionAsString_Iteration = replace(FunctionAsString,'IND1',string(Indices_1(i)));
            evalin('base',FunctionAsString_Iteration);
        end
    end
end