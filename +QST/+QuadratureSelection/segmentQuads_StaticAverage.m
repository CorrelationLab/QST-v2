function [X, EdgeIndices] = segmentQuads_StaticAverage(X,AverageSize,Options)
    arguments
        X;
        AverageSize;
        Options.CenterData = true;
    end


    X = X(:);
    %% 1. calculate the exspected amount of Segments
    nSegments = floor(length(X)/AverageSize);
    
    %% 2. cut the Data recording to the Segmentation
    X = X(1:nSegments*AverageSize);
    X = reshape(X,[AverageSize, nSegments]);

    %% 3. If wanted Center the Data around Zero
    if Options.CenterData == true
        X = X - mean(X,'all');
    end

    %% 4. Save the Borders of the used Segmentation to be able to recalculate the actual Quadrature Indicees from it
    EdgeIndices = [     1      : AverageSize :  NSegments*AverageSize;...
                   AverageSize : AverageSize :  NSegments*AverageSize];

end