function [isValid,Files] = validateFiles_ByRegex(Files,RegularExpression)
%Function that returns a list of all files that match a given regular
%expression. In case of an array of regular expression any of the regular
%expressions has to match.

isValid = contains(Files,RegularExpression);
Files = Files(isValid);
end

