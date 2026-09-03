function [] = plotHusimiQ_1DCut(Bins_Q,HusimiCut,HusimiCutTheory,PoissonErrorCut,Options)
%% Description:
%   This function creates a one-dimensional plot of a Husimi Q distribution cut along the P = 0 axis.
%
%   The measured Husimi Q cut is displayed with Poisson-based error bars and compared with the theoretical cut
%   calculated from a phase-averaged displaced thermal state model. The figure can optionally display fitted thermal
%   and coherent photon numbers in the legend and can be saved as a MATLAB .fig file.
%
%% Syntax:
%   QST.HusimiQ.Plot.plotHusimiQ_1DCut(Bins_Q, HusimiCut, HusimiCutTheory, PoissonErrorCut)
%   QST.HusimiQ.Plot.plotHusimiQ_1DCut(Bins_Q, HusimiCut, HusimiCutTheory, PoissonErrorCut, SaveFigure=true)
%   QST.HusimiQ.Plot.plotHusimiQ_1DCut(Bins_Q, HusimiCut, HusimiCutTheory, PoissonErrorCut, ShowLegend=true)
%
%% Input:
% required input values:
%   Bins_Q                                          - vector containing the quadrature-bin centers along the q axis
%
%   HusimiCut                                       - measured Husimi Q distribution along the Q axis at P = 0
%
%   HusimiCutTheory                                 - theoretical Husimi Q cut calculated from the fitted DTS model
%
%   PoissonErrorCut                                 - Poisson-based uncertainty estimate corresponding to HusimiCut
%
% optional input options:
% figure-saving options:
%   SaveFigure                                      - logical value specifying whether the generated figure is saved as
%                                                     a MATLAB .fig file (default: false)
%
%   SaveDir                                         - directory in which the figure is saved; it is created if necessary
%                                                     (default: '')
%
%   SaveName                                        - base name of the saved figure file (default: 'HusimiQ-1DCut')
%
%   FitMethod                                       - identifier of the applied fitting method; included in the saved
%                                                     filename and required when SaveFigure is true (default: '')
%
% plot-display options:
%   ShowLegend                                      - logical value specifying whether the fitted photon numbers are
%                                                     included in the theory-curve legend entry (default: false)
%
% PDTS-result options:
%   nTherm                                          - thermal photon number displayed in the legend when ShowLegend is
%                                                     true (default: [])
%
%   nCoherent                                       - coherent photon number displayed in the legend when ShowLegend is
%                                                     true (default: [])
%
%% Output:
%   This function does not return output arguments. It creates a plot of the Husimi Q cut in the current MATLAB
%   figure.
%
%   If SaveFigure is true, the figure is saved using the filename:
%
%   <SaveName>-Resolution<Resolution>-FitMethod-<FitMethod>-IncludesResults-<ShowLegend>.fig
%
%% Notes:
%   The measured Husimi Q cut is plotted with QST.Helper.shadedErrorBar using a black line with a line width of
%   3. The theoretical fit is plotted as a red line with the same line width.



    arguments
        Bins_Q;
        HusimiCut;
        HusimiCutTheory;
        PoissonErrorCut;
        Options.SaveFigure = false;
        Options.SaveDir = '';
        Options.SaveName='HusimiQ-1DCut';
        Options.ShowLegend = false;
        Options.FitMethod = '';
        Options.nTherm = [];
        Options.nCoherent = [];

    end

    clf
    cla
    %% 1. create 1D Graph for the Data
    Fig(1) = figure;
    Line = QST.Helper.shadedErrorBar(Bins_Q, HusimiCut, PoissonErrorCut, 'lineProps', {'k-','Linewidth',3});
    Line.DisplayName= 'Data';
    hold on;

    %% 2. create Graph for the optimal fit with a displaced thermal state
    if Options.ShowLegend
        plot(Bins_Q,HusimiCutTheory,'r',LineWidth=3, DisplayName=['Theory, n_{Th} = ', num2str(Options.nTherm,'%.2f'), ', n_{Coh} = ', num2str(Options.nCoherent,'%.2f')]);
    else
        plot(Bins_Q,HusimiCutTheory,'r',LineWidth=3)
    end

    %% 3. set the axis labels
    xlabel('q');
    ylabel('Q(q,p = 0)');
    legend('location','southwest');
    QST.Helper.graphicsSettings(Fontsize=50);
    Axes = gca;
    Resolution = abs(Bins_Q(2)-Bins_Q(1));
    Axes.XLim = [Bins_Q(1)-Resolution/2, Bins_Q(end)+Resolution/2];

    %% 4. Save the plot
    if Options.SaveFigure
        assert(~isequal(Options.FitMethod,''),'No Fitmethod given');
        SaveNameFull = strcat(Options.SaveName, '-Resolution', num2str(Resolution), '-FitMethod-', Options.FitMethod, '-IncludesResults-', string(Options.ShowLegend),'.fig');
        if ~exist(Options.SaveDir,'dir')
            mkdir(Options.SaveDir);
        end
        SavePath = fullfile(Options.SaveDir, SaveNameFull);
        savefig(Fig,SavePath);
    end
end

