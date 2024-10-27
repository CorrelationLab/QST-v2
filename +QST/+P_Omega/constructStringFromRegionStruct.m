function [StringOfRegion] = constructStringFromRegionStruct(Region)
% CONSTRUCTSTRINGFROMREGIONSTRUCT returns a string containing all
% information of a before inserted Struct which defines a postselection region
%
% INPUT:
% Region :          Struct of a wanted postselection region. The has to
%                   have a field called 'Type' which defines the Type of the wanted region.
%                   The other fields are then type dependent
%
% OUTPUT:
% StringOfRegion :  Information of the Struct formatted into a String. All
%                   Name value pairs are divided by a '-'. The Type Information is written at
%                   the first position.

StringOfRegion = "-Type-" + Region.Type;
ParameterNames = fieldnames(Region);
ParameterNames(ParameterNames == "Type") = [];
for iParameter = 1:length(ParameterNames)
    Name = ParameterNames{iParameter};
    Value = num2str(getfield(Region,Name));
    StringOfRegion = StringOfRegion + "-" + Name + "-" + Value;
end

