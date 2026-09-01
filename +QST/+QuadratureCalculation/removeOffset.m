function [Data] = removeOffset(Data, OffsetType)
%% Description:
%   This function removes an offset from a given quadrature dataset.
%
%   The offset-removal method is selected by OffsetType. A global offset is calculated over all elements of Data,
%   whereas a local offset is calculated separately for each column of Data.
%
%% Syntax:
%   Data = removeOffset(Data, OffsetType)
%
%% Input:
% required input values:
%   Data                                            - quadrature data array from which the offset is removed
%
%   OffsetType                                      - offset-removal method:
%                                                     'None':   do not modify Data
%                                                     'Global': subtract the mean of all elements in Data
%                                                     'Local':  subtract the mean of each column from the corresponding
%                                                               column of Data
%
%% Output:
%   Data                                            - offset-corrected quadrature data array



    arguments(Input)
        Data;
        OffsetType;
    end


    switch OffsetType
        case 'None'
            
        case 'Global'
            Data = Data - mean(Data,"all");
        case 'Local'
            Data = bsxfun(@minus, Data, mean(Data,1));
        otherwise
            error('Invalid OffsetType. Choose ''None'', ''Global'', or ''Local''.');
    end
end

