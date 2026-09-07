function [] = plotPOmega(POmega,POmega_Quadvals, Options)
%% Description:
%   This function creates a three-dimensional mesh plot of a P_Omega quasiprobability distribution.
%
%   The same quadrature-axis values are used for both phase-space axes. Optionally, the generated MATLAB figure can
%   be saved to a specified file path.
%
%% Syntax:
%   plotPOmega(POmega, POmega_Quadvals)
%   plotPOmega(POmega, POmega_Quadvals, SaveFigure=true, SavePath="POmega.fig")
%
%% Input:
% required input values:
%   POmega                                          - two-dimensional matrix containing the reconstructed
%                                                     P_Omega quasiprobability distribution
%
%   POmega_Quadvals                                 - vector containing the quadrature-axis values used for both
%                                                     phase-space dimensions of POmega
%
% name-value input options:
%   SaveFigure                                      - logical value specifying whether the generated figure is saved
%                                                     (default: false)
%
%   SavePath                                        - path and filename used to save the MATLAB figure; required when
%                                                     SaveFigure is true (default: '')
%
%% Output:
%   This function does not return output arguments. It creates a three-dimensional mesh plot in the current MATLAB
%   figure.



    arguments(Input)
        POmega
        POmega_Quadvals
        Options.SaveFigure = false
        Options.SavePath = ''
    end
    

    % pplot the figure
    mesh(POmega_Quadvals, POmega_Quadvals, POmega);

    % save the result
    if Options.SaveFigure == true
        savefig(Options.SavePath)
    end
end