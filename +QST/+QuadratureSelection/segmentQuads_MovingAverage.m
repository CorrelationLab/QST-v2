function [X, EdgeIndices] = segmentQuads_MovingAverage(X, AverageSize, StepSize, Options)

    arguments
        X;
        AverageSize;
        StepSize;
        Options.CenterData = true;
    end

    X = X(:);
    %% 1. calculate the exspected amount of Segments
    nSegments = floor((length(X)-AverageSize+StepSize)/StepSize);

    %% 2. If wanted Center the Data around Zero
    if Options.CenterData == true
        X = X - mean(X,'all');
    end

    %% 3. cut the Data recording to the Segmentation
    X = X(1:AverageSize+(nSegments-1)*StepSize);
    
    %% 4. Place the Data is the Segments
    XSegments = zeros(AverageSize,nSegments);
    for i = 1:nSegments
        XSegments(:,i) = X((i-1)*StepSize+1:(i-1)*StepSize+AverageSize); 
    end
    X = XSegments;

    %% 4. Save the Borders of the used Segmentation to be able to recalculate the actual Quadrature Indicees from it
    EdgeIndices = [     1      : StepSize : (nSegments-1)*StepSize+1;...
                   AverageSize : StepSize:  (nSegments-1)*StepSize+AverageSize];
end