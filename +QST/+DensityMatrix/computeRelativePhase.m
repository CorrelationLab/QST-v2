function [Theta, Theta_Absolute, Y_Smoothed] = computeRelativePhase(Xa,Xb, PiezoSign, Options)
%% Description:
%   This function reads in two quadrature matrices, whose phase relation has been constantly changed by a piezo actuator
%   and computes the relative phase between both.
%
%% Syntax:
%   [Theta, Theta_Absolute, Y_Smoothed] = computeRelativeTheta(Xa, Xb, PeriodsPerSegment=2, PeakThreshold=0.5, IgnoredSegments=[], Acurracy_Spline=1e-15)
%
%% Input:
% required input values;
%   Xa                                  - quadratures of Channel A
%   Xb                                  - quadratures of Channel B
%   PiezoSign                           - sign of piezo movement of the first Segment (1: positive, way gets longer, -1: negative, way gets shorter)
%
% optional input values;
%   Options.PeriodsPerSegment=2         - initial guess of occuring phasecycles in one segment of nearly linear piezo movement
%   Options.PeakThreshold=0.5           - relative threshold in comparison to the segments extreme values for the detection of peaks
%   Options.IgnoredSegments=[]          - array of segments that should be excluded from the analysis. The segments are identified by their segment index 
%   Options.Accuracy_Spline=1e-14       - spline interpolation accuracy. The value is between 0 and 1. The interpolation accuracy 
%                                         increases nonlinear with increasing value (see documentation of csaps())
%
%% Output:
%   Theta                               - relative phase between A and B reduced to the value range [0,2*pi)
%   Theta_Absolute                      - relative phase between A and B    
%   Y_Smoothed                          - smoothed cross correlations



    arguments(Input)
        Xa
        Xb
        PiezoSign {mustBeMember(PiezoSign,[-1, 1])}
        Options.PeriodsPerSegment {mustBeNonnegative} = 2
        Options.PeakThreshold {mustBeInRange(Options.PeakThreshold,0,1)} = 0.5
        Options.IgnoredSegments = []
        Options.Smoothing_Accuracy_Spline {mustBeInRange(Options.Smoothing_Accuracy_Spline,0,1)} = 1e-14;
    end

    % Calculate the smoothed cross correlation between Xa and Xb
    Y_Smoothed = QST.DensityMatrix.computeSmoothedCrossCorr(Xa,Xb,Accuracy_Spline=Options.Smoothing_Accuracy_Spline);

    % Set dimensions of the used data 
    [nPointsPerSegment,nSegments] = size(Y_Smoothed);
    nPointsPerPeriod = nPointsPerSegment / Options.PeriodsPerSegment;
    Theta = zeros(nPointsPerSegment,nSegments);

    % execute the phase computation on every piezo segment individually (This step could be paralized in a future update)
    for iSeg = [1:nSegments]

        % Ignore the current piezo segment if it is listed in Options.IgnoredSegments
        if sum(Options.IgnoredSegments == iSeg)>0
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
            continue
        end
        
        %% Distribute the data inside the current segment in subsegments dependent on if the curve is rising phi:(-pi,0] or falling phi:(0,pi].
        %% To this end find the extrema inside the functiongraph of the slow moving cross correlation associated with the piezo movement
        % Consider the quadratures in relation to the segmentwise mean
        Y = Y_Smoothed(:,iSeg);
        Y = Y - mean(Y,1);

        % Set parameter for '_findpeaks_'
        PeakOptsMax.MinPeakDistance = 0.6 * nPointsPerPeriod;
        PeakOptsMin.MinPeakDistance = 0.6 * nPointsPerPeriod;
        PeakOptsMax.MinPeakHeight = Options.PeakThreshold * max(Y);
        PeakOptsMin.MinPeakHeight = Options.PeakThreshold * max(-Y);

        % Get the peakposition of both local maxima and minima
        [~,MaxLocs] = findpeaks(Y,MinPeakDistance=PeakOptsMax.MinPeakDistance,MinPeakHeight=PeakOptsMax.MinPeakHeight);
        [~,MinLocs] = findpeaks(-Y,MinPeakDistance=PeakOptsMin.MinPeakDistance,MinPeakHeight=PeakOptsMin.MinPeakHeight);

        % Check if the count of local maxima and minima is theoretical possible
        if abs(length(MaxLocs)-length(MinLocs))>2 || (length(MaxLocs)+length(MinLocs))<2 
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
            continue
        end

        % Sort the peaks (assumption: we only see "global" maxima and minima)
        MaxPeaks = Y(MaxLocs);
        MinPeaks = Y(MinLocs);
        [PeakLocs, PeakLocs_Indices] = sort([MaxLocs;MinLocs]);
        Peaks = [MaxPeaks;MinPeaks];
        Peaks = Peaks(PeakLocs_Indices);

        % Account for wrongly detected peaks close to the boundaries
        % Left boundary
        if length(Peaks)>=3
            if PeakLocs(1) < 0.02*nPointsPerPeriod
                if (Peaks(1)>0 && ((Peaks(3)-Peaks(1))/abs(Peaks(3)))>0.05) || (Peaks(1)<0 && (Peaks(1)-Peaks(3))/abs(Peaks(3))>0.05)
                    PeakLocs = PeakLocs(2:end);
                    Peaks = Peaks(2:end);
                end
            end
        end
        % Right boundary
        if length(Peaks)>=3
            if (nPointsPerSegment-PeakLocs(end)) < 0.02*nPointsPerPeriod
                if (Peaks(end)>0 && (Peaks(end-2)-Peaks(end))/abs(Peaks(end-2))>0.05) || (Peaks(end)<0 && (Peaks(end)-Peaks(end-2))/abs(Peaks(end-2))>0.05)
                    PeakLocs = PeakLocs(1:end-1);
                    Peaks = Peaks(1:end-1);
                end
            end
        end

        % Check if the amount of of TurningPoints (local extrema) stays at least up to 1
        if isempty(Peaks)
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
            continue
        end

        % Account for extrema lying directly on the boundary which where not detected as peak
        % Left boundary
        if (Peaks(1)<0 && Y(1)>Peaks(2)) || (Peaks(1)>0 && Y(1)<Peaks(2))
            PeakLocs = [1;PeakLocs];
            Peaks = [Y(1);Peaks];
        end
        % Right boundary
        if (Peaks(end)<0 && Y(end)>Peaks(end-1)) || (Peaks(end)>0 && Y(end)<Peaks(end-1))
            PeakLocs = [PeakLocs;nPointsPerSegment];
            Peaks = [Peaks;Y(end)];
        end

        % Account for false detected peaks, which are next to a Boundary
        % Left boundary
        if (Peaks(1)<0 && Y(1)<Peaks(1)) || (Peaks(1)>0 && Y(1)>Peaks(1))
            PeakLocs(1) = 1;
            Peaks(1) = Y(1);
        end
        % Right boundary
        if (Peaks(end)<0 && Y(end)<Peaks(end)) || (Peaks(end)>0 && Y(end)>Peaks(end))
            PeakLocs(end) = nPointsPerSegment;
            Peaks(end) = Y(end);
        end

        %% Loop over all visible flanks and calculate the associated phases
        nTurningPoints = length(PeakLocs);
        PeakDiffs = -diff(Peaks); % minus is necessary due to the way is calculating the difference
        PhaseSignOfFirstFlank = sign(PeakDiffs(1))*PiezoSign;
        for iFlank = [0:nTurningPoints]
            % Get the signof the current flank
            PhaseSignOfFlank = PhaseSignOfFirstFlank * (-1)^(iFlank);

            % Get the Information about the ranges of the flank in x and y
            if iFlank == 0
                IntervalX = 1:PeakLocs(1);
                IntervalYRange = abs(PeakDiffs(1));
                MaxValue = max([Peaks(1), Peaks(2)]);
            elseif iFlank == nTurningPoints
                IntervalX = PeakLocs(end):nPointsPerSegment;
                IntervalYRange = abs(PeakDiffs(end));
                MaxValue = max([Peaks(end),Peaks(end-1)]);
            else
                IntervalX = (PeakLocs(iFlank)):(PeakLocs(iFlank+1));
                IntervalYRange = abs(PeakDiffs(iFlank));
                MaxValue = max(Peaks(iFlank),Peaks(iFlank+1));
            end

            % Normalize flank to the interval [-1,-1] (necessary for the arcsin)
            IntervalY = Y(IntervalX);
            IntervalYNormed = 2*(IntervalY-MaxValue)/IntervalYRange + 1;

            % Do correction to handle Problems with the maschine precision of matlab
            [~,iMax] = max(IntervalYNormed);
            IntervalYNormed(iMax) = IntervalYNormed(iMax) - 2*eps;
            [~,iMin] = min(IntervalYNormed);
            IntervalYNormed(iMin) = IntervalYNormed(iMin) + 2*eps;

            % Calculate the relative phase in the flank
            if PhaseSignOfFlank == 1
                Theta(IntervalX,iSeg) = asin(IntervalYNormed); % increasing flank with a relative phase between [-pi/2,pi/2] 
            else
                Theta(IntervalX,iSeg) = pi - asin(IntervalYNormed); % decreasing flank with a relative phase between [pi/2,3*pi/2]
            end

            % Add a phaseshift to Theta, dependent on the moving direction of the piezo (positive) and the type of the first flank
            if PiezoSign == 1 % Piezo is increasing the pathlength to detector, Theta increases
                if PhaseSignOfFirstFlank == 1
                    Theta(IntervalX,iSeg) = Theta(IntervalX,iSeg) + 2*pi*floor(iFlank/2); % Segment starts with a positive flank
                else
                    Theta(IntervalX,iSeg) = Theta(IntervalX,iSeg) + 2*pi*floor((iFlank+1)/2); % Segment starts with a negative flank
                end
            else % Piezo is decreasing the pathlength to detector, Theta decreases
                if PhaseSignOfFirstFlank == 1
                    Theta(IntervalX,iSeg) = Theta(IntervalX,iSeg) - 2*pi*floor((iFlank+1)/2); % Segment starts with a negative flank
                else
                    Theta(IntervalX,iSeg) = Theta(IntervalX,iSeg) - 2*pi*floor(iFlank/2); % Segment starts with a positive flank
                end
            end
        end

        % Check if all calculated phases are realvalued
        if ~isreal(Theta(:,iSeg))
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
        end
    end

    %% Calculate the relative phase (since e^(ix) = e^(ix+2*pi))
    Theta_Absolute = Theta;
    Theta = mod(Theta,2*pi);
end

