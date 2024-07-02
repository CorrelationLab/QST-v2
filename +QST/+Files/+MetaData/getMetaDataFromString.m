function [MetaData] = getMetaDataFromString(String,Regex_Main,Regex_Sub,Regex_Exchange,InfoType)

% 1. Get substring from Regex_Main
String_Sub = regexp(String,Regex_Main,"match");
% 2. Get SubString by applying Regex_Sub
if ~isempty(String_Sub)
    String_Sub = regexp(String_Sub,Regex_Sub,"match");
end
% 3. Replace unfitting phrases (like 'i' for an '.')
if ~isempty(Regex_Exchange)
    String_Sub = replace(String_Sub,Regex_Exchange(1),Regex_Exchange(2));
end
% 4. convert info to proper type
try
    MetaData = InfoType(String_Sub);
catch
    warning('Conversion failed')
    MetaData = [];
end
end

