function [IdentifierSeries,N_1_Mean,N_2_Mean,N_Mean,N_1_Std,N_2_Std,N_Std,G2_1_Mean,G2_2_Mean,G2_Mean,G2_1_Std,G2_2_Std,G2_Std] = collectN_G2_ResultsFromSeries(DirPath, Identifier, Options)
    arguments
        DirPath;
        Identifier;
        Options.IdentifierSeries = []
        Options.Wanted = [];
        Options.Unwanted = [];
        Options.sortResults = true;
    end

    % collect N
    [N_1,IdentifierSeries] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,["Results_N_G2_TimeResolved.Channel1.N_High","Results_N_G2_TimeResolved.Channel1.N"],Identifier,Wanted=Options.Wanted,Unwanted=Options.Unwanted,SaveAsRegularArray=false);
    [N_2,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,["Results_N_G2_TimeResolved.Channel2.N_High","Results_N_G2_TimeResolved.Channel2.N"],Identifier,Wanted=Options.Wanted,Unwanted=Options.Unwanted,SaveAsRegularArray=false);

    % collect G2
    [G2_1,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,["Results_N_G2_TimeResolved.Channel1.G2_High","Results_N_G2_TimeResolved.Channel1.G2"],Identifier,Wanted=Options.Wanted,Unwanted=Options.Unwanted,SaveAsRegularArray=false);
    [G2_2,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,["Results_N_G2_TimeResolved.Channel2.G2_High","Results_N_G2_TimeResolved.Channel2.G2"],Identifier,Wanted=Options.Wanted,Unwanted=Options.Unwanted,SaveAsRegularArray=false);




    % calculate std and mean for photon number
    N_1_Mean = cellfun(@mean,N_1);
    N_2_Mean = cellfun(@mean,N_2);
    N_Mean = (N_1_Mean + N_2_Mean)/2;

    N_1_Std = cellfun(@std,N_1);
    N_2_Std = cellfun(@std,N_2);
    N_Std = (N_1_Std + N_2_Std)/2;


    % calculate std and mean for g2
    G2_1_Mean = cellfun(@mean,G2_1);
    G2_2_Mean = cellfun(@mean,G2_2);
    G2_Mean = (G2_1_Mean + G2_2_Mean)/2;

    G2_1_Std = cellfun(@std,G2_1);
    G2_2_Std = cellfun(@std,G2_2);
    G2_Std = (G2_1_Std + G2_2_Std)/2;



    % In case one want to use a specific Identifierseries (eg Diameter instead of the saved Axicon)
    if ~isempty(Options.IdentifierSeries)
        IdentifierSeries = Options.IdentifierSeries;
    end


    % sort the result by the IdentifierSeries if wanted
    if Options.sortResults == true
        [IdentifierSeries,Idx] = sort(IdentifierSeries);
        N_1_Mean = N_1_Mean(Idx);
        N_2_Mean = N_2_Mean(Idx);
        N_Mean = N_Mean(Idx);
        N_1_Std = N_1_Std(Idx);
        N_2_Std = N_2_Std(Idx);
        N_Std = N_Std(Idx);
    
        G2_1_Mean = G2_1_Mean(Idx);
        G2_2_Mean = G2_2_Mean(Idx);
        G2_Mean = G2_Mean(Idx);
        G2_1_Std = G2_1_Std(Idx);
        G2_2_Std = G2_2_Std(Idx);
        G2_Std = G2_Std(Idx);
    

    end

    % transpose them so its easier to copy them manually (for example into origin)
    IdentifierSeries = IdentifierSeries.';
    N_1_Mean = N_1_Mean.';
    N_2_Mean = N_2_Mean.';
    N_Mean = N_Mean.';
    N_1_Std = N_1_Std.';
    N_2_Std = N_2_Std.';
    N_Std = N_Std.';

    G2_1_Mean = G2_1_Mean.';
    G2_2_Mean = G2_2_Mean.';
    G2_Mean = G2_Mean.';
    G2_1_Std = G2_1_Std.';
    G2_2_Std = G2_2_Std.';
    G2_Std = G2_Std.';







