function ConfigStruct = getConfig(FilePath)
% Parses .cfg file
% Returns a structure with section names, subsection names and keys as fields.
% 
% Based on:
% freeb (2014). ini2struct
% (http://www.mathworks.com/matlabcentral/fileexchange/45725-ini2struct/content/ini2struct.m),
% MATLAB Central File Exchange. Retrieved June 15, 2016.
% 
% Modified by:
% Johannes Thewes
% June 15, 2016
%
% Updated by:
% Yannik Brune
% December 18, 2023

arguments
    FilePath {mustBeFile}
end

File = fopen(FilePath,'r');

Section = '';
SubSection = '';
while ~feof(File)
    NextLine = strtrim(fgetl(File));                                            % Load next line from the File and removes leading and trailing whitespaces
    if isempty(NextLine) || NextLine(1) == ';' || NextLine(1) == '#'            % Skip empty and comment lines
        continue
    end
    if NextLine(1) == '['                                                       % NextLine is a Section Header
        if contains(NextLine,'.')                                               % There is Section and Subsection Header
            Headers = strsplit(NextLine(2:end-1),'.');
            Section = Headers{1};
            SubSection = Headers{2};
            ConfigStruct.(Section).(SubSection) = [];                           % create Field 
        else
            Section = NextLine(2:end-1);
            SubSection = '';
            ConfigStruct.(Section) = [];                                        % create Field 
        end
        continue
    end
    KeyValuePair = strsplit(NextLine,'=');
    Key = strtrim(KeyValuePair{1});
    Key = strrep(Key,'/','_');
    Key = strrep(Key,'(','_');
    Key = strrep(Key,')','_');                                                  % replace invalid char '/', ')','('
    Value = strtrim(KeyValuePair{2});
    if isempty(Value) || Value(1) == ';' || Value(1) == '#'                     % empty entry
        Value = [];
    elseif Value(1) == '"'
        Value = strtok(Value,'"');                                              % its a double quoted string
    elseif Value(1) == ''''
        Value = strtok(Value,'''');                                             % its single quoted string
    else
        Value = strtok(Value,';');                                              % its a number or bool! remove inline comments and comments before spaces
        Value = strtok(Value,'#');
        Value = strtrim(Value);
            
        Value = strrep(Value,',','.');                                          % replace comma by dot

        [Val, IsNumber] = str2num(lower(Value));                                % check if Value is number and converts it in this case
        if IsNumber == true
            Value = Val;
        end
    end
    
    if isequal(Section,'')                                                 % add 
        ConfigStruct.(Key) = Value;
    elseif isequal(SubSection,'')
        ConfigStruct.(Section).(Key) = Value;
    else
        ConfigStruct.(Section).(SubSection).(Key) = Value;
    end
end
fclose(File);