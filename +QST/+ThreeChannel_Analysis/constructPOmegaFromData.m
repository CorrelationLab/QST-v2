function [] = constructPOmegaFromData(FilePath, POmega_PatternInfo, Options)
% CONSTRUCTPOMEGAFROMDATA constructs the POmegaFunction from either all, or
% a specific region postselected set of Data. PostSelection by
% Orthogonality and Postselection by Region have to been executed already
% on a 3-Channel Measurement. The PatternGenerator has to be already
% calculated using this package and loaded to the Matlab Memory as
% 'POmega_PatternInfo'
%
% INPUTS:
% FilePath :            FilePath to the File with the already Postselected
%                       Data. The File has to include a CellArray variable
%                       called 'SelectedRegionData'
%POmega_PatternInfo :   StructVariable which contains the Information about
%                       the pattern generating Function.
%
% OPTIONS:
% Identifier :          In case only specific Regions should be analysized
%                       these can be chosen using identifiers, given in a cellarray of Strings. The identifier has the form of a
%                       string and corresponds to the string which are
%                       created bythe Function
%                       'constructStringFromRegionStruct'. By default the
%                       Identifier is {} and all Regions are evaluated.
%
% OUTPUTS:
% None 
%
% SAVES TO FILE :
% POmega :              Matrix of the calculated POmega Function
% POmega_Sigma :        Standard Deviation of the calculated POmega Function
% POmega_Quadvals :     Values of the used Quadrature Binning
% -> FilePath -> SelectionRegionData{Identifier}.SelectedData


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

        [POmega,POmega_Sigma,POmega_QuadVals] = QST.POmega_Reconstruction.calcPOmegaFromData(X_Target_Selected, Theta_Selected, POmega_PatternInfo);
        SelectedData.POmega = POmega;
        SelectedData.POmega_Sigma = POmega_Sigma;
        SelectedData.POmega_QuadVals = POmega_QuadVals;
        SelectedRegionData{Position} = SelectedData;
    end
    save(FilePath,'SelectedRegionData','-append');






end

