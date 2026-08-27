function [Times_Select,N_Select,G2_Select,EdgeIndices_Select,XIndices_Select,X_Select,StartTime,EndTime,Index_StartTime,Index_EndTime] = selectQuads_ByTimeInterval(Times, StartTime, EndTime, Options)
%% Description:
%   This function takes an array of Times and a Start and Endtime and returns the subset of Times that lies in the given time interval.
%   Optional with Times associated N, g2, Edgeindices or X data can be given to also return the respective subsets.
%
%% Syntax:
%   [Times_Select, N_Select, G2_Select, EdgeIndices_Select, XIndices_Select, X_Select, StartTime,EndTime,Index_StartTime,Index_EndTime] = selectQuads_ByTimeInterval(Times, StartTime, EndTime, Options)
%
%% Input:
% required input values;
%   Times                                               - 1D array of Times
%   StartTime                                           - the start time
%   EndTime                                             - the end time
%
% optional input arguments;
%   Options.N = []                                      - array of with the time array associated photon numbers
%   Options.G2 = []                                     - array of with the time array associated g2 values
%   Options.EdgeIndices = []                            - array of with the time array associated edge indices
%   Options.X = []                                      - array of with the time array associated quadratures
%
%% Output:
%   Times_Select                                        - 1D array of the postselected times.
%   N_Select                                            - 1D array of the postselected N. It returns [] when N is [].
%   G2_Select                                           - 1D array of the postselected G2. It returns [] when G2 is [].
%   EdgeIndices_Select                                  - 1D array of the postselected edge indices. It returns [] when EdgeIndices is [].
%   XIndices_Select                                     - 1D array of the postselected quadrature indices. It returns [] when X is [].
%   X_Select                                            - 1D array of the postselected quadratures. It returns [] when X is [].
%   StartTime                                           - closest start time excisting in the Times array
%   EndTime                                             - closest end time excisting in the Times array
%   Index_StartTime                                     - index of the found start time
%   Index_EndTime                                       - index of the found end time



    arguments
        Times
        StartTime;
        EndTime;
        Options.N = [];
        Options.G2 = [];
        Options.EdgeIndices = [];
        Options.X = [];
    end


    %% 1. Find the clostest start and end times in the times array and the associated indices
    [~,Index_StartTime] = min(abs(Times-StartTime));
    [~,Index_EndTime] = min(abs(Times-EndTime));
    StartTime = Times(Index_StartTime);
    EndTime = Times(Index_EndTime);

    %% 2. extract the associated data subsets for the different quantities
    % Times
    Times_Select = Times(Index_StartTime:Index_EndTime);

    % N
    if ~isempty(Options.N)
        N_Select = Options.N(Index_StartTime:Index_EndTime);
    else
        N_Select = [];
    end

    % G2
    if ~isempty(Options.G2)
        G2_Select = Options.G2(Index_StartTime:Index_EndTime);
    else
        G2_Select = [];
    end

    % EdgeIndices and X
    if ~isempty(Options.EdgeIndices)
        EdgeIndices_Select = Options.EdgeIndices(:,Index_StartTime:Index_EndTime);
        if ~isempty(Options.X)
            [X_Select,XIndices_Select] = QST.QuadratureSelection.selectQuads_ByEdgeIndices(Options.X,EdgeIndices_Select);
        else
            [~,XIndices_Select] = QST.QuadratureSelection.selectQuads_ByEdgeIndices([],EdgeIndices_Select);
            X_Select = [];
        end
    else
        EdgeIndices_Select = [];
        X_Select = [];
    end
end

