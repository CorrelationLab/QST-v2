function [XSegments, EdgeIndices] = segmentQuads_RollingWindow(X, SegmentSize, StepSize)
%% Description:
%   This function takes a set of quadratures X and segmentises it into eqal sized segments using a rolling window. It returns the reshaped quadrature data
%   as well as the EdgeIndices
%
%% Syntax:
%   [XSegments, EdgeIndices] = segmentQuads_RollingWindow(X, SegmentSize, StepSize)
%
%% Input:
% required input values;
%   X                                               - set of quadratures
%   SegmentSize                                     - number of quadratures per segment
%   StepSize                                        - stepsize of the rolling window
%
%% Output:
%   X_Segmented                                     - 2d array of the segmented data [SegmentSize x NumberOfSegments]
%   EdgeIndices                                     - two-dimensional array which marks the segments in the quadrature array used to compute N and g2.
%                                                     The first row contains the indices of the first quadratures of the individual segment,
%                                                     the second row contains the indices of the respective final quadratures



    arguments
        X;
        SegmentSize;
        StepSize;
    end


    
    %% 1. calculate the exspected amount of segments
    X = X(:);
    NumberOfSegments = floor((length(X)-SegmentSize+StepSize)/StepSize);

    %% 2. cut the data acording to the segmentation
    X = X(1:SegmentSize+(NumberOfSegments-1)*StepSize);
    
    %% 3. Place the data is the segments
    XSegments = zeros(SegmentSize,NumberOfSegments);
    for i = 1:NumberOfSegments
        XSegments(:,i) = X((i-1)*StepSize+1:(i-1)*StepSize+SegmentSize); 
    end

    %% 4. Save the borders of the used segmentation to be later able to recalculate the actual quadrature indices from it
    EdgeIndices = [     1      : StepSize : (NumberOfSegments-1)*StepSize+1;...
                   SegmentSize : StepSize:  (NumberOfSegments-1)*StepSize+SegmentSize];
end