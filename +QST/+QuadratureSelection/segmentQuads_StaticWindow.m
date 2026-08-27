function [X_Segmented, EdgeIndices] = segmentQuads_StaticWindow(X, SegmentSize)
%% Description:
%   This function takes a set of quadratures X and segmentises it into eqal sized segments using a static (blockwise moving) window. 
%   It returns the reshaped quadrature data as well as the EdgeIndices
%
%% Syntax:
%   [XSegments, EdgeIndices] = segmentQuads_StaticWindow(X, SegmentSize, StepSize)
%
%% Input:
% required input values;
%   X                                               - set of quadratures
%   SegmentSize                                     - number of quadratures per segment
%
%% Output:
%   X_Segmented                                     - 2d array of the segmented data [SegmentSize x NumberOfSegments]
%   EdgeIndices                                     - two-dimensional array which marks the segments in the quadrature array used to compute N and g2.
%                                                     The first row contains the indices of the first quadratures of the individual segment,
%                                                     the second row contains the indices of the respective final quadratures    


    arguments
        X;
        SegmentSize;
    end


    X = X(:);
    %% 1. Compute the exspected amount of segments
    nSegments = floor(length(X)/SegmentSize);
    
    %% 2. Cut the data recording to the segmentation
    X_Segmented = X(1:nSegments*SegmentSize);
    X_Segmented = reshape(X_Segmented,[SegmentSize, nSegments]);

    %% 4. Save the borders of the used segmentation to be able to recalculate the actual quadrature Indices from it
    EdgeIndices = [     1      : SegmentSize :  nSegments*SegmentSize;...
                   SegmentSize : SegmentSize :  nSegments*SegmentSize];

end