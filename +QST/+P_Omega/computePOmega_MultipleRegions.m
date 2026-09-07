function [] = computePOmega_MultipleRegions(FilePath, POmega_PatternInfo, Options)
%% Description:
%   This function reconstructs the P_Omega nonclassicality quasiprobability function from postselected
%   quadrature data stored in a MATLAB file.
%
%   The input file must contain a cell array named SelectedRegionData. Each cell entry represents one selected
%   phase-space region and contains the target quadratures, phase angles, and an associated region identifier.
%
%   The function can reconstruct P_Omega for all available selected regions or only for regions specified by
%   their identifiers. The calculated P_Omega function, its standard deviation, and its quadrature-axis values
%   are appended to the corresponding entries of SelectedRegionData and saved back to the input file.
%
%   Orthogonality and region-based postselection must be performed before this function is called. The required
%   P_Omega pattern information must also have been generated beforehand.
%
%% Syntax:
%   constructPOmegaFromData(FilePath, POmega_PatternInfo)
%   constructPOmegaFromData(FilePath, POmega_PatternInfo, Identifier={"RegionIdentifier"})
%
%% Input:
% required input values:
%   FilePath                                        - path to the MATLAB file containing the SelectedRegionData cell
%                                                     array
%
%   POmega_PatternInfo                              - structure containing the information required by the
%                                                     P_Omega pattern-generating function
%
% optional input options:
%   Identifier                                      - cell array containing the identifiers of the selected regions to
%                                                     be analysed; use {} to analyse all available regions
%                                                     (default: {})
%
%% Output:
%   This function does not return output arguments.
%
%   The function appends or updates the following fields in the respective entries of SelectedRegionData and saves
%   the updated cell array to FilePath:
%
%   POmega                                          - reconstructed P_Omega quasiprobability function
%
%   POmega_Sigma                                    - standard deviation of the reconstructed P_Omega function
%
%   POmega_QuadVals                                 - quadrature values corresponding to the P_Omega function
%
%% Required file contents:
%   FilePath must contain a variable named SelectedRegionData. Every selected entry is expected to contain:
%
%   Identifier                                      - identifier of the selected phase-space region
%
%   X_Target_Selected                               - selected target-channel quadrature values
%
%   Theta_Selected                                  - selected phase values corresponding to X_Target_Selected
%
%% Notes:
%   Before reconstruction, X_Target_Selected is multiplied by sqrt{2} to rescale the quadrature values.
%
%   The function verifies that POmega_PatternInfo exists in the local workspace and that SelectedRegionData exists
%   in the specified MATLAB file.
%
%   The updated SelectedRegionData variable is saved with the '-append' option and therefore preserves other
%   variables already stored in FilePath.



    arguments(Input)
        FilePath
        POmega_PatternInfo
        Options.Identifier = {}
    end


    %% 1. Load Selected Data
    % Check that PatternFunction has been loaded
    Variables = {whos().name};
    assert(all(ismember('POmega_PatternInfo',Variables)))

    % Data
    Variables = {whos('-file',FilePath).name};
    NeededVariables = {'SelectedRegionData'};
    assert(all(ismember(NeededVariables,Variables)))
    load(FilePath, NeededVariables{:})
    
    %% 2. Get Identifier of selected Data (if wanted and or necessary)
    AvaibleIdentifier = {};
    for Position = 1:length(SelectedRegionData)
        RegionData = SelectedRegionData{Position};
        AvaibleIdentifier = [AvaibleIdentifier, RegionData.Identifier];
    end

    if isequal(Options.Identifier, {})
        Identifier = AvaibleIdentifier;
    else
        assert(all(ismember(Options.Identifier,AvaibleIdentifier)))
        Identifier = Options.Identifier;
    end

    for ID = Identifier
        Position = find(strcmp(Identifier, ID));
        SelectedData = SelectedRegionData{Position};
        
        X_Target_Selected = SelectedData.X_Target_Selected;
        Theta_Selected = SelectedData.Theta_Selected;
        X_Target_Selected = sqrt(2)*X_Target_Selected;

        [POmega,POmega_Sigma,POmega_QuadVals] = QST.P_Omega.computePOmegaFromQuadratures(X_Target_Selected, Theta_Selected, POmega_PatternInfo);
        SelectedData.POmega = POmega;
        SelectedData.POmega_Sigma = POmega_Sigma;
        SelectedData.POmega_QuadVals = POmega_QuadVals;
        SelectedRegionData{Position} = SelectedData;
    end
    save(FilePath,'SelectedRegionData','-append');
end

