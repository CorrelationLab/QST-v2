function [] = plotPOmega(POmega,POmega_Quadvals, Options)
% PLOTPOMEGA plots a given POmega Distribution and saves it if wanted. IN CONSTRUCTION
%
% INPUTS:
% POmega :          Matrix of HusimiQ Distribution
% POmega_Quadvals : Array of the Binning Positions along both axis. For POmega the Binnings for both axis are the same. 
%
% OPTIONS:
% SaveFigure :      Bool if the Figure of the plot will be saved or not. Default is false
% SavePath :        Path where the figure should be saved if wanted

    arguments(Input)
        POmega
        POmega_Quadvals
        Options.SaveFigure = false
        Options.SavePath = ''
    end
    if Options.SaveFigure == true
        mesh(POmega_Quadvals, POmega_Quadvals, POmega);
        savefig(Options.SavePath)
    else
        mesh(POmega_Quadvals, POmega_Quadvals, POmega)
    end
end