function [Theta, Theta_Absolute, Y_Smoothed] = computePhase(Xa,Xb, PiezoSign, Options)
% COMPUTEPHASE calculates the phase between two Quadraturesets Xa and Xb, which phaserelation is constantly changed by an piezo
% (which changes sligtly the beampath and therefore its length).
%
% INPUTS:
% Xa :                                Quadratures of Channel A
% Xb :                                Quadratures of Channel B
% PiezoSign :                         Sign of Piezomovement of first Segment (1: positive, way gets longer, -1: negative, way gets shorter)
%
%
% OPTIONS:
% PeriodsPerSegment :                 Guessed count of occuring phasepasses in
%                                     the Crosscorelation of X_PsFast and
%                                     X_Target. Default is 2.
% PeakThreshold :                     Relative Threshold (compared to Segments Maximum) for Detection of Peaks.
%                                     Default is 0.5
% IgnoredSegments:                    Array of Indices of in the calculation
%                                     ignored Segments. Default is []
% Smoothing_Type :                    Type of Crosscorrelationsmoothing used in
%                                     the Phasecalculationprocess. Default is 'Spline'.
% Smoothing_Accuracy_Spline :         Accuracy of the Spline Interpolation Method for the
%                                     CrossCorrelation Smoothing used in the Phasecalculationprocess. Default is 1e-14.
% Smoothing_Accuracy_MovingAverage :  Accuracy of the Moving Window Average Method for the
%                                               CrossCorrelation Smoothing used in the Phasecalculationprocess. Default is 20.
%
%
% OUTPUTS:
% Theta :                             Phase between A and B reduced to values between 0 and 2 pi
% Theta_Absolute :                    Total, non reduced Phase
% Y_Smoothed :                        Smoothed CrossCorrelation between A and B

    arguments(Input)
        Xa
        Xb
        PiezoSign {mustBeMember(PiezoSign,[-1, 1])}
        Options.PeriodsPerSegment {mustBeNonnegative} = 2
        Options.PeakThreshold {mustBeInRange(Options.PeakThreshold,0,1)} = 0.5
        Options.IgnoredSegments = []
        Options.Smoothing_Type {mustBeMember(Options.Smoothing_Type, ["Spline","MovingAverage"])} = "Spline"
        Options.Smoothing_Accuracy_Spline {mustBeInRange(Options.Smoothing_Accuracy_Spline,0,1)} = 1e-14;
        Options.Smoothing_Accuracy_MovingAverage {mustBeNonnegative} = 20;
    end

    % Calculate the smoothed Crosscorrelation between Xa and Xb
    Y_Smoothed = QST.Helper.calcSmoothedCrossCorr(Xa,Xb,Type=Options.Smoothing_Type,Accuracy_Spline=Options.Smoothing_Accuracy_Spline,Accuracy_MovingAverage=Options.Smoothing_Accuracy_MovingAverage);
    % Set Dimensions of used Data 
    [nPointsPerSegment,nSegments] = size(Y_Smoothed);
    nPointsPerPeriod = nPointsPerSegment / Options.PeriodsPerSegment;
    Theta = zeros(nPointsPerSegment,nSegments);
    % Do the following calculation for every Segment (can maybe be calculated parallel)
    for iSeg = [1:nSegments]
        %% Ignore segments listed in Options.IgnoredSegments
        if sum(Options.IgnoredSegments == iSeg)>0
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
            continue
        end
        %% Calculate the Deviation from the segmentmean
        Y = Y_Smoothed(:,iSeg);
        Y = Y - mean(Y,1);
        %% Set Parameter for '_findpeaks_'
        PeakOptsMax.MinPeakDistance = 0.6 * nPointsPerPeriod;
        PeakOptsMin.MinPeakDistance = 0.6 * nPointsPerPeriod;
        PeakOptsMax.MinPeakHeight = Options.PeakThreshold * max(Y);
        PeakOptsMin.MinPeakHeight = Options.PeakThreshold * max(-Y);
        %% Get the Peakposition of both local maxima and minima
        [~,MaxLocs] = findpeaks(Y,PeakOptsMax);
        [~,MinLocs] = findpeaks(-Y,PeakOptsMin);
        %% Check if the Count of local maxima and minima is theoretical possible
        if abs(length(MaxLocs)-length(MinLocs))>2 || (length(MaxLocs)+length(MinLocs))<2 
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
            continue
        end
        %% Sort the Peaks (assumption: we only see "global" maxima and minima)
        MaxPeaks = Y(MaxLocs); %ColumnVectors!!!
        MinPeaks = Y(MinLocs);
        [PeakLocs, PeakLocs_Indices] = sort([MaxLocs;MinLocs]);
        Peaks = [MaxPeaks;MinPeaks];
        Peaks = Peaks(PeakLocs_Indices); 
        %% Account for wrongly detected peaks close to the boundaries
        % Left boundary
        if length(Peaks)>=3
            if PeakLocs(1) < 0.02*nPointsPerPeriod
                if (Peaks(1)>0 && ((Peaks(3)-Peaks(1))/abs(Peaks(3)))>0.05) || (Peaks(1)<0 && (Peaks(1)-Peaks(3))/abs(Peaks(3))>0.05)
                    PeakLocs = PeakLocs(2:end);
                    Peaks = Peaks(2:end);
                end
            end
        end
        % Right Boundary
        if length(Peaks)>=3
            if (nPointsPerSegment-PeakLocs(end)) < 0.02*nPointsPerPeriod
                if (Peaks(end)>0 && (Peaks(end-2)-Peaks(end))/abs(Peaks(end-2))>0.05) || (Peaks(end)<0 && (Peaks(end)-Peaks(end-2))/abs(Peaks(end-2))>0.05)
                    PeakLocs = PeakLocs(1:end-1);
                    Peaks = Peaks(1:end-1);
                end
            end
        end
        %% Check if the amount of of TurningPoints (local extrema) stays at least up to 1
        if isempty(Peaks)
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
            continue
        end
        %% Account for extrema lying directly on the boundary which where not detected as peak
        % Left Boundary
        if (Peaks(1)<0 && Y(1)>Peaks(2)) || (Peaks(1)>0 && Y(1)<Peaks(2))
            PeakLocs = [1;PeakLocs];
            Peaks = [Y(1);Peaks];
        end
        % Right Boundary
        if (Peaks(end)<0 && Y(end)>Peaks(end-1)) || (Peaks(end)>0 && Y(end)<Peaks(end-1))
            PeakLocs = [PeakLocs;nPointsPerSegment];
            Peaks = [Peaks;Y(end)];
        end        
        %% Account for false detected peaks, which are next to a Boundary
        % Left Boundary
        if (Peaks(1)<0 && Y(1)<Peaks(1)) || (Peaks(1)>0 && Y(1)>Peaks(1))
            PeakLocs(1) = 1;
            Peaks(1) = Y(1);
        end
        % Right Boundary
        if (Peaks(end)<0 && Y(end)<Peaks(end)) || (Peaks(end)>0 && Y(end)>Peaks(end))
            PeakLocs(end) = nPointsPerSegment;
            Peaks(end) = Y(end);
        end
        %% Loop over all visible Flanks
        nTurningPoints = length(PeakLocs);
        PeakDiffs = -diff(Peaks); % minus is necessary due to the way is calculating the difference
        PhaseSignOfFirstFlank = sign(PeakDiffs(1))*PiezoSign;
        for iFlank = [0:nTurningPoints]
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
            %Normalize flank to the interval [-1,-1] (necessary for the arcsin)
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
            % add a phaseshift to Theta, dependent on the moving direction of the Piezo (positive) and the type of the first flank
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
        %% Check if all calculated Phases are realvalued
        if ~isreal(Theta(:,iSeg))
            Theta(:,iSeg) = NaN(nPointsPerSegment,1);
        end
    end
    %% Calculate the relative Phase (since e^(ix) = e^(ix+2*pi))
    Theta_Absolute = Theta;
    Theta = mod(Theta,2*pi);


end

