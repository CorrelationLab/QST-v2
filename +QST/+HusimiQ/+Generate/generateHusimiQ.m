function [HusimiQ, Bins_Q, Bins_P, Edges_Q,Edges_P] = generateHusimiQ(X1, X2,Options)
%% Description:
%   This function generates a two-dimensional Husimi Q distribution from two to each other orthogonal quadrature datasets.
%   The first quadrature X1 defines the Q-axis, and the second quadrature X2 defines the P-axis.
%
%   The Husimi Q distribution is calculated as a two-dimensional histogram within a rectangular phase-space
%   region. The histogram range and bin width can be defined independently for the Q- and P-quadrature axes.
%
%% Syntax:
%   [HusimiQ, Bins_Q, Bins_P, Edges_Q, Edges_P] = generateHusimiQ(X1, X2)
%   [HusimiQ, Bins_Q, Bins_P, Edges_Q, Edges_P] = generateHusimiQ(X1, X2, Limits_Q=[-10, 10])
%   [HusimiQ, Bins_Q, Bins_P, Edges_Q, Edges_P] = generateHusimiQ(X1, X2, Limits_P=[-10, 10])
%   [HusimiQ, Bins_Q, Bins_P, Edges_Q, Edges_P] = generateHusimiQ(X1, X2, Resolution=0.05)
%
%% Input:
% required input values:
%   X1                                              - first quadrature dataset defining the Q-axis values
%
%   X2                                              - second quadrature dataset defining the P-axis values
%
% name-value input options:
%   Limits_Q                                        - two-element vector containing the lower and upper limits of the
%                                                     Q-quadrature axis (default: [-10, 10])
%
%   Limits_P                                        - two-element vector containing the lower and upper limits of the
%                                                     P-quadrature axis (default: [-10, 10])
%
%   Resolution                                      - histogram bin width for both quadrature axes (default: 0.05)
%
%   Normalization                                   - normalization method passed to histcounts2, for example
%                                                     "probability", "pdf", "count", or "countdensity"
%                                                     (default: "probability")
%
%% Output:
%   HusimiQ                                         - two-dimensional histogram representing the Husimi Q
%                                                     distribution; rows correspond to Q-axis bins and columns
%                                                     correspond to P-axis bins
%
%   Bins_Q                                          - vector containing the center value of every Q-axis histogram bin
%
%   Bins_P                                          - vector containing the center value of every P-axis histogram bin
%
%   Edges_Q                                         - vector containing the edges of the Q-axis histogram bins
%
%   Edges_P                                         - vector containing the edges of the P-axis histogram bins
%
%% Notes:
%   The bin edges are constructed symmetrically around zero using the selected Resolution. The resulting edge vectors
%   may extend by up to half a bin width beyond the specified axis limits.
%
%   Values outside the specified histogram ranges are not included in HusimiQ.



    arguments
        X1;
        X2;
        Options.Limits_Q = [-10,10];
        Options.Limits_P = [-10,10];
        Options.Resolution=0.05;
        Options.Normalization = "probability";
    end



    Limits_Q = Options.Limits_Q;
    Limits_P = Options.Limits_P;
    Resolution = Options.Resolution;
    
    %% 1. create Husimi Distribution
    BinsLeft_Q = flip([-Resolution/2:-Resolution:Limits_Q(1)-Resolution/2]);
    BinsRight_Q = [Resolution/2:Resolution:Limits_Q(2)+Resolution/2];
    Edges_Q = cat(2,BinsLeft_Q,BinsRight_Q);
    
    BinsLeft_P = flip([-Resolution/2:-Resolution:Limits_P(1)-Resolution/2]);
    BinsRight_P = [Resolution/2:Resolution:Limits_P(2)+Resolution/2];
    Edges_P = cat(2,BinsLeft_P,BinsRight_P);
    
    
    [HusimiQ] = histcounts2(X1,X2,Edges_Q,Edges_P,Normalization=Options.Normalization);
    Bins_Q = (Edges_Q(1:end-1) + Edges_Q(2:end))/2;
    Bins_P = (Edges_P(1:end-1) + Edges_P(2:end))/2;
end