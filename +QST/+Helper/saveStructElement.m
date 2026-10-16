function saveStructElement(matfilePath, varName, newStruct)
% saveStructElement Save or append a struct element into a struct array in a MAT-file.
%   Creates the MAT-file if it doesn't exist. If varName does not exist in the
%   file it is created. If varName exists and is a struct array, the newStruct
%   is appended as a new element. Ensures target directory exists.
%
%   matfilePath               - path to mat file
%
%   varName                   - name of the variable (char)
%   newStruct                  - struct element to save or append
%
%   The existing variable must be a struct array.



% Ensure directory exists
[folder, ~, ~] = fileparts(matfilePath);
if ~isempty(folder) && ~exist(folder, 'dir')
    mkdir(folder);
end

% If file doesn't exist, create it with the variable
if ~isfile(matfilePath)
    S.(varName) = newStruct;
    save(matfilePath, '-struct', 'S', '-v7.3');
    return
end

% Check variable existence without loading
varsInFile = who('-file', matfilePath);
m = matfile(matfilePath, 'Writable', true);

if ~ismember(varName, varsInFile)
    % Variable does not exist -> create it
    m.(varName) = newStruct;
    return
end

% Variable exists -> verify type and append
info = whos(m, varName);
if ~strcmp(info.class, 'struct')
    error('Variable "%s" exists but is not a struct.', varName);
end

sz = info.size;
% If somehow empty, overwrite with new element
if any(sz == 0)
    m.(varName) = newStruct;
    return
end

% Append for common 2-D struct arrays: 1xN append as (1,N+1); otherwise append as (M+1,1)
if numel(sz) == 2
    if sz(1) == 1
        m.(varName)(1, sz(2) + 1) = newStruct;
    else
        m.(varName)(sz(1) + 1, 1) = newStruct;
    end
else
    % Append along last dimension for N-D arrays
    idx = repmat({':'}, 1, numel(sz));
    idx{end} = sz(end) + 1;
    m.(varName)(idx{:}) = newStruct;
end
end
