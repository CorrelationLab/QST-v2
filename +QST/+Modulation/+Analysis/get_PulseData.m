function [PulseData, N_Pulse, G2_Pulse, Times_Pulse, EdgeIndices_Pulse, X_Correctionfactor,N,G2] = get_PulseData(Frequency, Dutycycle, minNForPulse, N, Times, G2,EdgeIndices,Options)
    arguments
        Frequency;
        Dutycycle;
        minNForPulse;
        N = [];
        Times = [];
        G2 = [];
        EdgeIndices = [];
        % Options for fitting the pulses
        Options.Accuracy = 100;
        % Options for the Zerolevel correction
        Options.applyZerolevelCorrection = false
        % Options for saving the controlplots
        Options.ControlPlotsSavePath = '';
        Options.ChannelNumber = NaN;
    end

    Accuracy = Options.Accuracy;
    applyZerolevelCorrection = Options.applyZerolevelCorrection;
    ControlPlotsSavePath = Options.ControlPlotsSavePath;
    if isnan(Options.ChannelNumber)
        S = inputname(1);
        ChannelNumber = uint16(str2double(S(3)));
    else
        ChannelNumber = Options.ChannelNumber;
    end

    
    %% 1. Estimate the best phase offset for the given photo number dat set (using least squares and based , due to the function, on bruteforce)
    [N_SquareFit,~,~] = QST.Modulated.Statistics.fit_SquareWave_PhaseBruteForce(N,...
                                                                                Times,...
                                                                                Frequency,...
                                                                                Dutycycle,...
                                                                                minNForPulse,...
                                                                                Accuracy=Accuracy,...
                                                                                showControlPlot=false);

    %% 1.5 Plot the result of the fit
    ControlFig(1) = figure;
    tiledlayout(2,2)

    nexttile
    plot(Times,N);
    hold on
    plot(Times,N_SquareFit)
    hold off
    title('Rectangle-pulse-fit of timeresolved photon number')
    xlabel('Time in s')
    ylabel('N')


    %% 2. Extract the position of the pulses from the fit
    [PulseIndicesStruct,PulseIndicesTotal,ZerolevelIndices] = QST.Modulated.Statistics.get_PulseIndices(N_SquareFit);

    %% 2.5 Plot the Pulsedata and the ZerolevelData
    nexttile
    
    plot(Times,N);
    hold on
    plot(Times(PulseIndicesTotal),N(PulseIndicesTotal));
    hold on
    plot(Times(ZerolevelIndices),N(ZerolevelIndices));
    hold off
    title('PulseData and ZerolevelData')
    xlabel('Time in s')
    ylabel('N')


    %% 3. Select data based on the indices
    PulseData(length(PulseIndicesStruct)) = struct();
    for i = 1:length(PulseIndicesStruct)
        PulseData(i).N = N(PulseIndicesStruct(i).Idx);
        PulseData(i).Times = Times(PulseIndicesStruct(i).Idx);
    end
    if ~isempty(G2)
        PulseData(i).G2 = G2(PulseIndicesStruct(i).Idx);
    else
        PulseData(i).G2 = [];
    end

    if ~isempty(G2)
        PulseData(i).EdgeIndices = EdgeIndices(:,PulseIndicesStruct(i).Idx);
    else
        PulseData(i).EdgeIndices = [];
    end


    %% 4. Calculate the data as Single Array
    N_Pulse = N(PulseIndicesTotal);
    Times_Pulse = Times(PulseIndicesTotal);
    if ~isempty(G2)
        G2_Pulse = G2(PulseIndicesTotal);
    else
        G2_Pulse = [];
    end

    if ~isempty(EdgeIndices)
        EdgeIndices_Pulse = EdgeIndices(:,PulseIndicesTotal);
    else
        EdgeIndices_Pulse = [];
    end


    %% 5. In case one can do a Zerolevel correction
    if applyZerolevelCorrection == true && ~isempty(G2)
        N_Zerolevel = mean(N(ZerolevelIndices));
        [X_Correctionfactor,PulseData,N_Pulse,G2_Pulse,N,G2] = QST.Modulated.Statistics.calc_ZerolevelCorrecture(N_Zerolevel, PulseData, N_Pulse, G2_Pulse, N=N,G2=G2);

        %% 5. Plot the result of the Zerolevel correction
        if ControlPlotSavePath == true
           nexttile
           plot(Times,N);
           hold on
           plot(Times,N_Pulse)
           hold off
           title('N after Quadrature Correction')
           xlabel('Time in s')
           ylabel('N')
           
           nexttile
            plot(Times,G2_Pulse)
            xlabel('Time in s')
            ylabel('g^2(0)')
            title('g^2(0) after Quadrature Correction')
        end
    else
        X_Correctionfactor = 1;
    end


    %% 6. If wanted: save the controlplot
    if ~isequal(ControlPlotsSavePath,'')
        if ~exist(ControlPlotsSavePath,'dir')
            mkdir(ControlPlotsSavePath);
        end
        FilePath = strjoin([ControlPlotsSavePath, filesep, 'ModulationFiltering Controlfig Channel ', string(ChannelNumber)],'');
        savefig(ControlFig,FilePath);
    end


        



end
%% Further Optimizations: the Zerolevel is most probably overkill (especially because the zerolevel is right now more acurate corrected by the pulse condensate finding function)
%% Update: the zerolevel correction is not working properly if its only based on the fit
