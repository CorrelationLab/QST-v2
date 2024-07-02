function [HusimiQ,Bins1,Bins2, Radius,nTherm,nThermErr,nCoherent,nCoherentErr,meanN,meanR,nRatio,g2,Coherence,CoherenceErr,poissonErrors,poissonErrorsCut,HusimiCut, HusimiCut_Theory,HusimiCut_DataForFit_alpha,HusimiCut_DataForFit_H ] = calcHusimiAfterCarolin(X1,X2,Resolution,Limits,Options)
%UNTITLED Summary of this function goes here
%   Detailed explanation goes here
    arguments
        X1;
        X2;
        Resolution = 0.1;
        Limits=[-8,8];
        Options.Edges1 = [];
        Options.Edges2 = [];
        Options.CalcStatistics = true;
        Options.FitMethod = 'NLSQ-LAR';
        Options.FitFunction = '';
    end
    Edges1 = Options.Edges1;
    Edges2 = Options.Edges2;

%% 5. create Husimi Distribution
if isempty(Options.Edges1) || isempty(Options.Edges2)
    Edges1 = [Limits(1)-Resolution/2:Resolution:Limits(2)+Resolution/2];% ensures one central bin around zero
    Edges2 = Edges1;
end

[HusimiQ] = histcounts2(X1,X2,Edges1,Edges2,Normalization="probability");
Bins1 = (Edges1(1:end-1) + Edges1(2:end))/2;
Bins2 = (Edges2(1:end-1) + Edges2(2:end))/2;

if Options.CalcStatistics == true
    %% 3. calc Poissonerrors
    poissonErrors = sqrt(HusimiQ.*(1-HusimiQ)/length(X1));
    poissonErrorsCut = poissonErrors((length(Bins1)+1)/2,:);
    
    %% 4. get base Values from the raw data
    [X1Axis,X2Axis] = meshgrid(Bins1,Bins2);
    alphaspace = 1/sqrt(2)*sqrt(X1Axis.^2+X2Axis.^2);
    
    meanN = 0.5*sum((X1Axis.^2+X2Axis.^2).*HusimiQ,"all")-1;
    meanR = sum(sqrt(X1Axis.^2+X2Axis.^2).*HusimiQ,"all");
    
    
    %% 5. The Horizontal Cut
    HusimiCut = HusimiQ((length(Bins1)+1)/2,:);
    if ~isempty(Edges1) && ~isempty(Edges2)
        Resolution = (Edges1(end)-Edges1(1))/(length(Edges1)-1);
    end
    % Calc Start Parameter for the Fit
    HusimiCut_Soft = transpose(csaps(Bins1,HusimiCut,0.6,Bins1));
    [~,I] = max(HusimiCut_Soft);
    Radius = abs(Bins1(I));
    nCoherent = 0.5*Radius^2; % the factor of 0.5 comes bcause its calculated from the q-p space
    nTherm = meanN-nCoherent;
    
    % Set Up Data for Fit in alpha space (data only bases on radial value)
    alphaFit = alphaspace(:);
    HusimiFit = HusimiQ(:); 
    
    % the actual fit
    if strcmp(Options.FitMethod,'NLSQ-LAR')
        if isempty(Options.FitFunction)
            %Options.FitFunction = fittype('0.5*Resolution^2*(pi*(a1+1))^-1 *exp(-(x.^2 + b1)/(a1+1)) .* besseli(0,2*x*sqrt(b1)/(a1+1))','problem','Resolution');
            Options.FitFunction = fittype('(pi*(a1+1))^-1 *exp(-(x.^2 + b1)/(a1+1)) .* besseli(0,2*x*sqrt(b1)/(a1+1))');
        end
    end
    %The Fit
    %[Params,gof,~] = fit(alphaFit,HusimiFit,Options.FitFunction,'problem',Resolution,'StartPoint', [nTherm,nCoherent],'Lower',[0,0],'Robust','LAR' );
    [Params,gof,~] = fit(alphaFit,HusimiFit/(0.5*Resolution^2),Options.FitFunction,'StartPoint', [nTherm,nCoherent],'Lower',[0,0],'Robust','LAR' );% improve the fit by rescaling all probabilities to bigger values (here from probability to prob. density)
    %The two basic Result Parameters
    nTherm = Params.a1;
    nCoherent = Params.b1;
    % and their standard Errors
    StandardErrors = getStandardErrorsFromFit(Params,gof,'method1');
    nThermErr = StandardErrors(1);
    nCoherentErr = StandardErrors(2);
    % and derived Quantities
    nRatio = nCoherent/nTherm;
    g2 = 2 - (nCoherent/(nCoherent+nTherm))^2;
    % And Quantum Coherence
    Coherence = coherencePDTS(nTherm,nCoherent);
    [~, CoherenceErr,~, ~] = error_propagation( @(nTherm,nCoherent) coherencePDTS(nTherm,nCoherent),...
                                                                    nTherm, ...
                                                                    nCoherent, ...
                                                                    nThermErr, ...
                                                                    nCoherentErr);
    CoherenceErr(isnan(CoherenceErr)) = 0;
    
    % Theory Plot Data
    HusimiCutFunction = 0.5*Resolution^2*(pi*(nTherm+1))^-1 *exp(-(alphaspace.^2 + nCoherent)/(nTherm+1)) .* besseli(0,2*alphaspace*sqrt(nCoherent)/(nTherm+1));
    HusimiCut_Theory = HusimiCutFunction((length(Bins1)+1)/2,:);
    HusimiCut_DataForFit_alpha = alphaFit*sqrt(2);
    HusimiCut_DataForFit_H = HusimiFit;



else
    nTherm = NaN;
    nThermErr = NaN;
    nCoherent = NaN;
    nCoherentErr = NaN;
    meanN = NaN;
    nRatio = NaN;
    Radius = NaN;
    g2 = NaN;
    Coherence = NaN;
    CoherenceErr = NaN;
    HusimiCut = NaN;
    HusimiCut_Theory = NaN;
    poissonErrors = NaN;
end

end

