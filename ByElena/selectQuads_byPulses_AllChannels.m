function [Results_N_G2_TimeResolved] = selectQuads_byPulses_AllChannels(Results_N_G2_TimeResolved, Channels, f, Threshold, Flank)
    % Does selectQuads_byPulses() for all channels
    arguments
        Results_N_G2_TimeResolved;
        Channels;
        f (1,1) double = 500;
        Threshold (1,1) double = 0.05;
        Flank (1,1) double =0.15;
    end

    for ch = Channels
        chStr = char(ch);

        Time       = Results_N_G2_TimeResolved.(chStr).Time;
        N           = Results_N_G2_TimeResolved.(chStr).N;
        G2          = Results_N_G2_TimeResolved.(chStr).G2;
        EdgeIndices = Results_N_G2_TimeResolved.(chStr).EdgeIndices;


        [Time_Select, N_Select, G2_Select, EdgeIndices_Select,Times_Vac, N_Vac, G2_Vac, EdgeIndices_Vac] = ...
            QST.QuadratureSelection.selectQuads_byPulses(Time, N, f, Threshold, Flank, G2, EdgeIndices);

        %For signal
        Results_N_G2_TimeResolved.(chStr).Time_Select       = Time_Select;
        Results_N_G2_TimeResolved.(chStr).N_Select           = N_Select;
        Results_N_G2_TimeResolved.(chStr).G2_Select          = G2_Select;
        Results_N_G2_TimeResolved.(chStr).EdgeIndices_Select = EdgeIndices_Select;
        %For vacuum
        Results_N_G2_TimeResolved.(chStr).Times_Vac       = Times_Vac;
        Results_N_G2_TimeResolved.(chStr).N_Vac           = N_Vac;
        Results_N_G2_TimeResolved.(chStr).G2_Vac          = G2_Vac;
        Results_N_G2_TimeResolved.(chStr).EdgeIndices_Vac = EdgeIndices_Vac;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Common-Quadratures for signal:

    [~, idx1] = QST.QuadratureSelection.selectQuads_ByEdgeIndices([], Results_N_G2_TimeResolved.Channel1.EdgeIndices_Select);
    [~, idx2] = QST.QuadratureSelection.selectQuads_ByEdgeIndices([], Results_N_G2_TimeResolved.Channel2.EdgeIndices_Select);
    [~, idx3] = QST.QuadratureSelection.selectQuads_ByEdgeIndices([], Results_N_G2_TimeResolved.Channel3.EdgeIndices_Select);
    [~, idx4] = QST.QuadratureSelection.selectQuads_ByEdgeIndices([], Results_N_G2_TimeResolved.Channel4.EdgeIndices_Select);

    %Common indices for all channels 
    idx_common = intersect(intersect(idx1, idx2), intersect(idx3, idx4));

    %Taking the quadratures out of the workspace:
    
    X1_sel = evalin('base','X1');
    X2_sel = evalin('base','X2');
    X3_sel = evalin('base','X3');
    X4_sel = evalin('base','X4');

    %Common quadratures:
    X1_common = X1_sel(idx_common);
    X2_common = X2_sel(idx_common);
    X3_common = X3_sel(idx_common);
    X4_common = X4_sel(idx_common);

    %Saving the results in Results_N_G2_TimeResolved.CommonQuadratures:
    Results_N_G2_TimeResolved.CommonQuadratures.idx = idx_common;
    Results_N_G2_TimeResolved.CommonQuadratures.X1 = X1_common;
    Results_N_G2_TimeResolved.CommonQuadratures.X2 = X2_common;
    Results_N_G2_TimeResolved.CommonQuadratures.X3 = X3_common;
    Results_N_G2_TimeResolved.CommonQuadratures.X4 = X4_common;

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    % Common Quadratures for vacuum:
    %in this method a mask is initially designed as
    %vacuumMask=~signalMask;, so the data that is not classified as
    %signal is classified as vacuum and then the exact same treatment as
    %the signal is applied to the vacuum.

    % Load raw quadratures
    X1 = evalin('base','X1');
    X2 = evalin('base','X2');
    X3 = evalin('base','X3');
    X4 = evalin('base','X4');

    % Build full signal masks per channel (from stored Select data)
    mask1 = false(size(X1));
    mask2 = false(size(X2));
    mask3 = false(size(X3));
    mask4 = false(size(X4));

    % Reconstruct signal masks from EdgeIndices_Select
    for k = 1:size(Results_N_G2_TimeResolved.Channel1.EdgeIndices_Select,2)
        mask1(Results_N_G2_TimeResolved.Channel1.EdgeIndices_Select(1,k): ...
              Results_N_G2_TimeResolved.Channel1.EdgeIndices_Select(2,k)) = true;
    end
    
    for k = 1:size(Results_N_G2_TimeResolved.Channel2.EdgeIndices_Select,2)
        mask2(Results_N_G2_TimeResolved.Channel2.EdgeIndices_Select(1,k): ...
              Results_N_G2_TimeResolved.Channel2.EdgeIndices_Select(2,k)) = true;
    end

    for k = 1:size(Results_N_G2_TimeResolved.Channel3.EdgeIndices_Select,2)
        mask3(Results_N_G2_TimeResolved.Channel3.EdgeIndices_Select(1,k): ...
              Results_N_G2_TimeResolved.Channel3.EdgeIndices_Select(2,k)) = true;
    end
    
    for k = 1:size(Results_N_G2_TimeResolved.Channel4.EdgeIndices_Select,2)
        mask4(Results_N_G2_TimeResolved.Channel4.EdgeIndices_Select(1,k): ...
              Results_N_G2_TimeResolved.Channel4.EdgeIndices_Select(2,k)) = true;
    end
    
    % Determine vacuum in each channel
    vac1 = ~mask1;
    vac2 = ~mask2;
    vac3 = ~mask3;
    vac4 = ~mask4;
    
    % Common vacuum indices for all channels 
    idx_common_vac = find(vac1 & vac2 & vac3 & vac4);
    
    % Saving the results in Results_N_G2_TimeResolved.CommonVacuumQuadratures:
    Results_N_G2_TimeResolved.CommonVacuumQuadratures.idx_vac = idx_common_vac;
    
    Results_N_G2_TimeResolved.CommonVacuumQuadratures.X1_vac = X1(idx_common_vac);
    Results_N_G2_TimeResolved.CommonVacuumQuadratures.X2_vac = X2(idx_common_vac);
    Results_N_G2_TimeResolved.CommonVacuumQuadratures.X3_vac = X3(idx_common_vac);
    Results_N_G2_TimeResolved.CommonVacuumQuadratures.X4_vac = X4(idx_common_vac);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %Automatically saving the data in Matdata.mat
    MatPaths = QST.File_Managment.getFilePaths(RootDirectory);
    [~,~,Ext] = fileparts(MatPaths); 
    MatPaths = MatPaths(strcmp(Ext,".mat"));

    for j = 1:length(MatPaths)
        f = MatPaths(j);
    SavePath = split(f,filesep);
    SavePath = SavePath(1:end-2);
    SavePath = join(SavePath,filesep);
    SavePath = strcat(SavePath,filesep,'Results',filesep,'N_G2_TimeResolved');

        if ~exist(SavePath,'dir')
            mkdir(SavePath)
        end
    save(f, 'Results_N_G2_TimeResolved', '-append')
    end
    
end
