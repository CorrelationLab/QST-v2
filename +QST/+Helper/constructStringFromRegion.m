function [StringOfRegion] = constructStringFromRegion(Region)
%% Description:
%   This function converts a postselection-region structure into a descriptive string identifier.
%
%   The returned identifier contains the region type followed by all remaining structure fields and their values.
%   Field names and values are separated by hyphens, allowing the resulting string to be used to identify or store
%   region-specific analysis results.
%
%% Syntax:
%   StringOfRegion = constructStringFromRegionStruct(Region)
%
%% Input:
% required input values:
%   Region                                          - structure defining a postselection region; it must contain a
%                                                     field named Type, while all additional fields define
%                                                     type-dependent region parameters
%
%% Output:
%   StringOfRegion                                  - string identifier containing the region type and all additional
%                                                     region parameters in the form:
%
%                                                     -Type-<Type>-<FieldName1>-<Value1>-<FieldName2>-<Value2>-...
%
%% Notes:
%   The Type field is always written first in the returned string.
%
%   All other fields are processed in the order returned by fieldnames.
%
%   For example, the structure
%
%   Region.Type = "Circle";
%   Region.Radius = 2;
%   Region.CenterQ = 1;
%
%   produces an identifier similar to:
%
%   "-Type-Circle-Radius-2-CenterQ-1".



    arguments
        Region;
    end


    StringOfRegion = "-Type-" + Region.Type;
    ParameterNames = fieldnames(Region);
    ParameterNames(ParameterNames == "Type") = [];
    for iParameter = 1:length(ParameterNames)
        Name = ParameterNames{iParameter};
        Value = num2str(getfield(Region,Name));
        StringOfRegion = StringOfRegion + "-" + Name + "-" + Value;
    end
end

