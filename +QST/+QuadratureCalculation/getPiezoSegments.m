function [Data, DataPiezoShape, PiezoStartDirection,PiezoEdgeIndices] = getPiezoSegments(Data, Timestamps, SegmentSelectionMode)
% This function reshapes the data into segments of the same piezo-movement
% (eg. first segment forwards movement, second segment backwards movement, third segment forward moevement,...)
% The direction is given by either +1 (piezo moves from 0µm to 2µm) or -1 (piezo moves from 2µm to 0µm)
% The Segmentlength can either be set as the maximum length (the longest piezomove), or the smallest length (the shortest complete piezomove).
% In the first case shorter segments are padded by NaN's in the second part of Data is discarded.
% The associated Information is then returned in 'PiezoEdgeIndices'
arguments
    Data;
    Timestamps;
    SegmentSelectionMode = 'MinLength';
end



%% 1. get the different segments from the timestamps
DeltaTime = diff(Timestamps);
ThresholdDeltaTime = (max(DeltaTime)-min(DeltaTime))/2; % some sort of Threshold
GapPositions = find(DeltaTime > ThresholdDeltaTime); % Positions of the Gaps
NSegments = length(GapPositions)-1; % Number of Segments


% calculate the Length of a Segment
switch SegmentSelectionMode
    case 'MaxLength' % Length by the longest Piezosegment
        SegmentLength = int32(max(diff(GapPositions)));
    case 'MinLength' % Length by the shortest Piezosegment
        SegmentLength = int32(min(diff(GapPositions)));
    otherwise
        error("Invalid Input for 'SegmentSelectionMode': Allowed values are 'MaxLength' and 'MinLength'. ");
end


%% 2. get the direction the first segment has moved
Gaps = DeltaTime(GapPositions);
Threshold = (max(Gaps)+min(Gaps))/2;
if Gaps(1) < Threshold
    PiezoStartDirection = +1;
else
    PiezoStartDirection = -1;
end

%% 3. reshape the data
PiezoEdgeIndices = zeros([2,NSegments]);
switch SegmentSelectionMode
    case 'MaxLength'
        Data_PiezoShaped = NaN(SegmentLength,NSegments);
        for iGap = 1:NSegments
            Start = GapPositions(iGap)+1;
            End = GapPositions(iGap+1);
            Seg = Data(Start:End);
            Data_PiezoShaped(:,iGap) = [Seg , NaN(SegmentLength-length(Seg))];
            PiezoEdgeIndices(:,iGap) = [Start,End];
        end
    case 'MinLength'
        Data_PiezoShaped = zeros(SegmentLength,NSegments);
        for iGap = 1:NSegments
            Start = GapPositions(iGap);
            End = GapPositions(iGap)+SegmentLength;
            Data_PiezoShaped(:,iGap) = Data(Start:End);
            PiezoEdgeIndices(:,iGap) = [Start, End];
        end
end

%% 4. reshape the data back to 1D since all other functions will use 1D
DataPiezoShape = size(Data_PiezoShaped);
Data = Data_PiezoShaped(:);

end