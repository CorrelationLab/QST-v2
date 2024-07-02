function [Identifier,nTherm,nThermErr,nCoherent,nCoherentErr,nMean,Coherence,CoherenceErr,nRatio,g2] = collectHusimiResultsFromSeries(DirPath, Identifier, Options)
    arguments
        DirPath;
        Identifier;
        Options.createPlots = false;
        Options.IdentifierLabel = '';
        Options.IdentifierTitle = '';
        Options.SavePath = '';
    end

    [nTherm,IdentifierSeries] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.nTherm',Identifier,SaveAsRegularArray=true);
    [nThermErr,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.nThermErr',Identifier,SaveAsRegularArray=true);
    [nCoherent,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.nCoherent',Identifier,SaveAsRegularArray=true);
    [nCoherentErr,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.nCoherentErr',Identifier,SaveAsRegularArray=true);
    [nMean,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.nMean',Identifier,SaveAsRegularArray=true);
    [Coherence,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.Coherence',Identifier,SaveAsRegularArray=true);
    [CoherenceErr,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.CoherenceErr',Identifier,SaveAsRegularArray=true);
    [nRatio,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.nRatio',Identifier,SaveAsRegularArray=true);
    [g2,~] = QST.Data_Managment.Series.CollectVariablesFromSeries(DirPath,'Results_HusimiQ.g2',Identifier,SaveAsRegularArray=true);

    IdentifierSeries = IdentifierSeries';
    nTherm = nTherm';
    nThermErr = nThermErr';
    nCoherent = nCoherent';
    nCoherentErr = nCoherentErr';
    nMean = nMean';
    Coherence = Coherence';
    CoherenceErr = CoherenceErr';
    nRatio = nRatio';
    g2 = g2';

    if Options.createPlots == true
        clf
        Fig(1) = figure;
        errorbar(IdentifierSeries,nTherm,nThermErr);
        xlabel(Options.IdentifierLabel)
        %ylabel('$N_\text{Therm}$',Interpreter='latex')
        %title(strcat('$N_\text{Therm}$ in Dependence of ', Options.IdentifierTitle),Interpreter='latex')
        ylabel('N Therm')
        title(strcat('N Therm in Dependence of ', Options.IdentifierTitle))
        if ~isequal(Options.SavePath,'')
            savefig(Fig,strcat(Options.SavePath,filesep,'nTherm in Dependence of ',Options.IdentifierTitle,'.fig'));
        end

        clf
        Fig(1) = figure;
        errorbar(IdentifierSeries,nCoherent,nCoherentErr);
        xlabel(Options.IdentifierLabel)
        ylabel('N Coherent')
        title(strcat('N Coherent in Dependence of ', Options.IdentifierTitle))
        if ~isequal(Options.SavePath,'')
            savefig(Fig,strcat(Options.SavePath,filesep,'nCoherent in Dependence of ',Options.IdentifierTitle,'.fig'));
        end

        clf
        Fig(1) = figure;
        errorbar(IdentifierSeries,Coherence,CoherenceErr);
        xlabel(Options.IdentifierLabel)
        ylabel('Quantum Coherence')
        title(strcat('Quantum Coherence in Dependence of ', Options.IdentifierTitle))
        if ~isequal(Options.SavePath,'')
            savefig(Fig,strcat(Options.SavePath,filesep,'Quantum Coherence in Dependence of ',Options.IdentifierTitle,'.fig'));
        end

        clf
        Fig(1) = figure;
        plot(IdentifierSeries,nRatio);
        xlabel(Options.IdentifierLabel)
        ylabel('Ratio N Therm / N Coherent')
        title(strcat('Ratio N Therm / N Coherent in Dependence of ', Options.IdentifierTitle))
        if ~isequal(Options.SavePath,'')
            savefig(Fig,strcat(Options.SavePath,filesep,'nRatio in Dependence of ',Options.IdentifierTitle,'.fig'));
        end

        clf
        Fig(1) = figure;
        plot(IdentifierSeries,g2);
        xlabel(Options.IdentifierLabel)
        ylabel('g^2(0)')
        title(strcat('g^2(0) in Dependence of ', Options.IdentifierTitle))
        if ~isequal(Options.SavePath,'')
            savefig(Fig,strcat(Options.SavePath,filesep,'g2 in Dependence of ',Options.IdentifierTitle,'.fig'));
        end
    end
end

