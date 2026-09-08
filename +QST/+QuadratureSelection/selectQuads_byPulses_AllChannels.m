function [Results_N_G2_TimeResolved] = selectQuads_ByPulses_AllChannels(X1, X2, X3, X4, Results_N_G2_TimeResolved, Channels, RootDirectory, Options)
%% Description:
%   This function performs pulse-based quadrature selection for multiple measurement channels and stores the selected
%   signal and vacuum data in the Results_N_G2_TimeResolved structure.
%
%   For every channel specified by Channels, the function uses the time-resolved photon number N to identify
%   signal pulses with QST.QuadratureSelection.selectQuads_byPulses. The detected pulse regions are stored together
%   with the selected time, photon-number, g^{(2)}(0), and edge-index data.
%
%   The complementary samples, which are not classified as signal, are treated as vacuum data. The function further
%   determines indices for signal and vacuum quadratures that are common to all four channels.
%
%   Finally, the updated Results_N_G2_TimeResolved structure is appended to all MATLAB files found below
%   RootDirectory.
%
%% Syntax:
%   Results_N_G2_TimeResolved = selectQuads_ByPulses_AllChannels( ...
%       X1, X2, X3, X4, Results_N_G2_TimeResolved, Channels)
%
%   Results_N_G2_TimeResolved = selectQuads_ByPulses_AllChannels( ...
%       X1, X2, X3, X4, Results_N_G2_TimeResolved, Channels, ModulationFrequency=500, Threshold=0.05, Flank=0.15)
%
%% Input:
% required input values:
%   X1                                              - quadrature data of channel 1
%
%   X2                                              - quadrature data of channel 2
%
%   X3                                              - quadrature data of channel 3
%
%   X4                                              - quadrature data of channel 4
%
%   Results_N_G2_TimeResolved                      - structure containing time-resolved analysis results for the
%                                                     selected channels
%
%   Channels                                        - list of channel field names to be processed, for example
%                                                     ["Channel1", "Channel2", "Channel3", "Channel4"]
%
% optional input values:
%   ModulationFrequency                                               - expected pulse repetition frequency in hertz; passed to
%                                                     selectQuads_byPulses (default: 500)
%
%   Threshold                                       - photon-number threshold used to identify signal pulses; passed to
%                                                     selectQuads_byPulses (default: 0.05)
%
%   Flank                                           - fraction removed from both flanks of every detected pulse; passed
%                                                     to selectQuads_byPulses (default: 0.15)
%
%% Output:
%   Results_N_G2_TimeResolved                      - updated time-resolved analysis structure containing the following
%                                                     additional fields for every processed channel:
%
%       Time_Select                                 - time values belonging to the selected signal pulses
%       N_Select                                    - photon-number values belonging to the selected signal pulses
%       G2_Select                                   - g^{(2)}(0) values belonging to the selected signal pulses
%       EdgeIndices_Select                          - edge indices of the selected signal regions
%
%       Times_Vac                                   - time values classified as vacuum
%       N_Vac                                       - photon-number values classified as vacuum
%       G2_Vac                                      - g^{(2)}(0) values classified as vacuum
%       EdgeIndices_Vac                             - edge indices of contiguous vacuum regions
%
%   The function additionally creates the following structure fields:
%
%   Results_N_G2_TimeResolved.CommonQuadratures     - common signal quadratures of all four channels:
%
%       idx                                         - indices classified as signal in all four channels
%       X1, X2, X3, X4                              - common signal quadrature values of the four channels
%
%   Results_N_G2_TimeResolved.CommonVacuumQuadratures - common vacuum quadratures of all four channels:
%
%       idx_vac                                     - indices classified as vacuum in all four channels
%       X1_vac, X2_vac, X3_vac, X4_vac              - common vacuum quadrature values of the four channels
%
%% Required structure fields:
%   Each processed channel entry, for example Results_N_G2_TimeResolved.Channel1, must contain:
%
%   Time                                            - time vector
%   N                                               - time-resolved photon-number vector
%   G2                                              - time-resolved g^{(2)}(0) vector
%   EdgeIndices                                     - edge-index array associated with the time-resolved analysis
%
%% Notes:
%   Signal pulses are determined individually for every selected channel. Common signal quadratures are obtained by
%   calculating the intersection of the signal indices from Channel1 through Channel4.
%
%   Common vacuum quadratures are determined from the intersection of the complements of the four channel-specific
%   signal masks.
%
%   The function currently assumes that Results_N_G2_TimeResolved contains the fields Channel1, Channel2, Channel3,
%   and Channel4, irrespective of the Channels input.
%
%   The current implementation uses RootDirectory to locate MATLAB files, but RootDirectory is not an input argument
%   or a locally defined variable. The automatic file-saving section therefore requires RootDirectory to be added as
%   an input or otherwise defined before it can run.
%
%   The function calls QST.QuadratureSelection.selectQuads_byPulses. Ensure that this name matches the actual
%   function filename and MATLAB function declaration, including capitalization.
%
%   This function requires QST.QuadratureSelection.selectQuads_byPulses,
%   QST.QuadratureSelection.selectQuads_ByEdgeIndices, and QST.File_Managment.getFilePaths.
    
    
    
    arguments
        X1;
        X2;
        X3;
        X4;
        Results_N_G2_TimeResolved;
        Channels;
        RootDirectory;
        Options.ModulationFrequency (1,1) double = 500;
        Options.Threshold (1,1) double = 0.05;
        Options.Flank (1,1) double =0.15;
    end


    for ch = Channels
        chStr = char(ch);

        Time       = Results_N_G2_TimeResolved.(chStr).Time;
        N           = Results_N_G2_TimeResolved.(chStr).N;
        G2          = Results_N_G2_TimeResolved.(chStr).G2;
        EdgeIndices = Results_N_G2_TimeResolved.(chStr).EdgeIndices;


        [Time_Select, N_Select, G2_Select, EdgeIndices_Select,Times_Vac, N_Vac, G2_Vac, EdgeIndices_Vac] = ...
            QST.QuadratureSelection.selectQuads_byPulses(Time, N, Options.ModulationFrequency, Options.Threshold, Options.Flank, G2, EdgeIndices);

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

    %Common quadratures:
    X1_common = X1(idx_common);
    X2_common = X2(idx_common);
    X3_common = X3(idx_common);
    X4_common = X4(idx_common);

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
        SavePath = MatPaths(j);
        SaveDir = split(SavePath,filesep);
        SaveDir = SaveDir(1:end-2);
        SaveDir = join(SaveDir,filesep);
        SaveDir = strcat(SaveDir,filesep,'Results',filesep,'N_G2_TimeResolved');

        if ~exist(SaveDir,'dir')
            mkdir(SaveDir)
        end
        save(SavePath, 'Results_N_G2_TimeResolved', '-append')
    end
    
end
