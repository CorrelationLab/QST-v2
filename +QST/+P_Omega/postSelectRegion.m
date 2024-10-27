function [] = postSelectRegion(FilePath, Regions, Options)
% POSTSELECTREGION Postselect Subsets of Data from TargetChannel and from Theta, which counterpart data
% in the postselection channels lays in a beforehand specified region (e.g. a circle ring)
%
% INPUTS:
% FilePath :                FilePath to a set of already by Orthogonality postselected Quadratures, measured with 3 Channels.
% Regions:                  Struct of Predefined Regions, which are used for PostSelection
%                           Possible Structs can be found in the Documentation of QST.PostSelection.selectRegion
%
%
% OPTIONS:
% VaryAPS :                 Modifies the Photonumber, so its dependent on the Photonumbers found in the Data. Default is false.
% SaveFilePath :            FilePath to the place where the PostSelected Data should be saved. Default is the Original File. In case of a seperate
%                           File the Region is described in the filename by its Identifier and 'Quantities' is saved tohgether with it to ensure 
%                           transparency regarding the analysis process.
%
%
% OUTPUTS:
% None
%
%
% SAVE TO FILE:
% Regionparameter :         Parameter of the Region
% Identifier :              Identifer of the Region (String of all Region Parameters combined)       
% VaryAPS :                 Used Parameter of VaryAPS
% X_Target_Selected :       Selected Data Subset from Targetchannel        
% Theta_Selected :          Selected Data Subset from Theta
% -> SaveFilePath -> SelectedRegionData.RegionData

    arguments(Input)
        FilePath
        Regions
        Options.VaryAPS = false
        Options.SaveFilePath = FilePath
    end
    %% Load Variables (and check in the first place that they exists)
    Variables = {whos('-file',FilePath).name};
    NeededVariables = {'X_PsFast_Orth', 'X_PsSlow_Orth', 'X_Target_Orth', 'Theta_Orth', 'Quantities'};
    assert(all(ismember(NeededVariables, Variables)))
    load(FilePath, NeededVariables{:})
    
    %% 2. If 'VaryAPS' is true connect the chosen region with the photonnumber
    if Options.VaryAPS == true
        for iRegion=1:length(Regions)
            Region = Regions{iRegion};
            if isequal(Region.Type,'FullCircle')
               N_Ps = Quantities.PhotoNumbers.N_Ps_MesMean;
               Region.Radius = sqrt(abs(Region.Radius)) * (1+N_Ps)/sqrt(2*N_Ps)*sign(Region.Radius);
               Regions{iRegion} = Region;
            end
        end
    end






    %% 3. Calculate postselected Data Subset based on the Region and save it to a new File
    if isequal(Options.SaveFilePath,FilePath)
        if all(ismember('SelectedRegionData', Variables))
            load(FilePath,'SelectedRegionData')
        else
            SelectedRegionData = {};
        end
        for iRegion=1:length(Regions)
            Region = Regions{iRegion};
            [X_Target_Selected, Theta_Selected] = QST.PostSelection.selectRegion(X_PsFast_Orth, X_PsSlow_Orth, X_Target_Orth,Theta_Orth,Region);
            RegionData = Region;
            RegionData.Identifier = QST.Helper_Other.constructStringFromRegionStruct(Region);
            RegionData.VaryAPS = Options.VaryAPS; 
            RegionData.X_Target_Selected = X_Target_Selected;
            RegionData.Theta_Selected = Theta_Selected;
            SelectedRegionData = [SelectedRegionData, RegionData];
        end
        save(FilePath, 'SelectedRegionData', '-append');
    else
        for iRegion=1:length(Regions)
            Region = Regions{iRegion};
            [X_Target_Selected, Theta_Selected] = QST.PostSelection.selectRegion(X_PsFast_Orth, X_PsSlow_Orth, X_Target_Orth,Theta_Orth,Region);
            RegionData = Region;
            RegionData.Identifier = QST.Helper_Other.constructStringFromRegionStruct(Region);
            RegionData.VaryAPS = Options.VaryAPS; 
            RegionData.X_Target_Selected = X_Target_Selected;
            RegionData.Theta_Selected = Theta_Selected;
            SelectedRegionData = RegionData;
            % create Filename of new file
            RegionAsString = QST.Helper_Other.constructStringFromRegionStruct(Region);
            [~, FileName, ~] = fileparts(FilePath);
            PostFileName = PostFilePath + "\" + FileName + "-" + RegionAsString' + '.mat';
            save(PostFileName, 'SelectedRegionData', 'Quantities')
        end
    end


end

