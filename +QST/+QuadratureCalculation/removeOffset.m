function [Data] = removeOffset(Data,OffsetType)
%REMOVEOFFSET removes the Offset of a given Quadratureset
switch OffsetType
    case 'None'
        % does nothing
    case 'Global'
        % removes the global offset of the whole dataset
        Data = Data - mean(Data,"all");
    case 'Local'
        Data = bsxfun(@minus, Data, mean(Data,1));
    otherwise
end

