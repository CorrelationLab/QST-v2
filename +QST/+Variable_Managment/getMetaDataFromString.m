function [MetaData] = getMetaDataFromString(String, Regex_Main, Regex_Sub, Regex_Exchange, DataType)
%% Description:
%   This function reads in a string, for e.g. a file name, containing some
%   metadata and extracts the meta data using regular expressions. To be
%   able to differenciate between different similar sounding metadata
%   information in one string one can use two regular expression to
%   characterize the metadata properly.
%
%% Syntax:
%   [MetaData] = getMetaDataFromString(String, Regex_Main, Regex_Sub, Regex_Exchange, DataType)
%
%% Input:
% required input values;
%   String                                          - string, for example of a filename that includes the meta data
%   Regex_Main                                      - main regular expression used to identify the meta data inside the string e.g 'Power[0-9]+[i]?[0-9]*mw'
%   Regex_Sub                                       - underlying regular expression used to identify the meta data inside the
%                                                     previously found substring string e.g '[0-9]+[i]?[0-9]*'
%   Regex_Exchange                                  - array that includes two regular expression to exchange a component inside the metadata eg.[[0-9]+[i]?[0-9]*,[0-9]+[.]?[0-9]*]
%                                                     to replace an i by a .
%   DataType                                        - data type of the meta data
%
%% Output:
%   MetaData                                        - variable containg the meta data. the variable type is determined by DataType



    arguments
        String;
        Regex_Main;
        Regex_Sub;
        Regex_Exchange;
        DataType;
    end


    %% 1. Get the meta data substring
    String_Sub = regexp(String,Regex_Main,"match");
    if ~isempty(String_Sub)
        String_Sub = regexp(String_Sub,Regex_Sub,"match");
    end
    
    %% 2. Replace unfitting phrases (like 'i' for an '.')
    if ~isempty(Regex_Exchange)
        String_Sub = replace(String_Sub,Regex_Exchange(1),Regex_Exchange(2));
    end
    
    %% 3. Convert the meta data info the proper type
    try
        MetaData = DataType(String_Sub);
    catch
        warning('Conversion failed')
        MetaData = [];
    end
end

