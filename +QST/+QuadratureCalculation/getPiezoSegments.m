function [Data, DataPiezoShape, PiezoStartDirection,PiezoEdgeIndices] = getPiezoSegments(Data, Timestamps)
%% Description:
%   This function separates measurement data into segments corresponding to individual piezo movements.
%
%   Segments are identified from gaps in the trigger timestamps. The direction of the first piezo movement is
%   determined from the duration of the first timestamp gap and is returned as either +1 or -1.
%
%   All segments are reshaped to a common length equal to the longest detected segment. Shorter segments are padded
%   with NaN values at their end. The original start and end indices of every segment are returned in PiezoEdgeIndices.
%
%% Syntax:
%   [Data, PiezoStartDirection, PiezoEdgeIndices] = reshapePiezoData(Data, Timestamps)
%
%% Input:
% required input values:
%   Data                                            - measurement data array with samples stored along the second
%                                                     dimension

%   Timestamps                                      - timestamp vector associated with the recorded samples
%
%% Output:
%   Data                                            - reshaped measurement data containing consecutive piezo segments;
%                                                     shorter segments are padded with NaN values
%
%   PiezoStartDirection                             - direction of the first piezo movement:
%                                                     +1: piezo moves from 0 µm to 2 µm$
%                                                     -1: piezo moves from 2 µm to 0 µm
%
%   PiezoEdgeIndices                                - $2 \times N$ array containing the start and end sample indices
%                                                     of each detected piezo segment
%
%% Notes:
%   The output data are temporarily arranged as an array with dimensions
%   [NumberOfDataRows, SegmentLength, NumberOfSegments] and are subsequently converted into a one-dimensional array.
%
%   The segment length is set to the maximum length of all detected segments.



    arguments
        Data;
        Timestamps;
    end


    %% 1. get the different segments from the timestamps
    DeltaTime = diff(Timestamps);
    ThresholdDeltaTime = (max(DeltaTime)-min(DeltaTime))/2; % some sort of Threshold
    GapPositions = find(DeltaTime > ThresholdDeltaTime); % Positions of the Gaps
    NSegments = length(GapPositions)-1; % Number of Segments
    
    % calculate the Length of a Segment
    SegmentLength = int32(max(diff(GapPositions)));
    
    
    
    %% 2. get the direction the first segment has moved
    Gaps = DeltaTime(GapPositions);
    Threshold = (max(Gaps)+min(Gaps))/2;
    if Gaps(1) < Threshold
        PiezoStartDirection = +1;
    else
        PiezoStartDirection = -1;
    end
    
    %% 3. reshape the data
    % this can optimized further allowing 1D arrays as inputs, but for now it seems fine
    PiezoEdgeIndices = zeros([2,NSegments]);
    Data_PiezoShaped = NaN(size(Data,1), SegmentLength, NSegments);
    for iGap = 1:NSegments
        Start = GapPositions(iGap)+1;
        End = GapPositions(iGap+1);
        Seg = Data(:,Start:End);
        SegTotal = [Seg , NaN([size(Data,1),SegmentLength-size(Seg,2)])];
        Data_PiezoShaped(:,:,iGap) = SegTotal;
        PiezoEdgeIndices(:,iGap) = [Start,End];
    end
    
    %% 4. reshape the data back to 1D since all other functions will use 1D
    DataPiezoShape = size(Data_PiezoShaped);
    Data = Data_PiezoShaped(:);
end