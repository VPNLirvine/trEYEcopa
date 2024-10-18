function output = selectMetric(edfDat, metricName, varargin)
% Takes in a single row of an edf file (ie already indexed by trial number)
% e.g. input should be edfFile(trialNum), not edfFile itself
% Given a metric name like 'totfixation', calculate and return that metric
% Options are as follows:
%   'fixation' - Total fixation time per trial
%   'scaledfixation' - Percentage of video time spent fixating
%   'firstfix' - Duration of the initial fixation - like an RT to the video
%   'duration' - Duration of the video  in sec (a QC metric)
%   'meanfix' - Average fixation duration within a trial
%   'medianfix' - Median fixation duration within a trial
%   'maxfixOnset' - Onset time of the longest fixation
%   'minfixOnset' - Onset time of the shortest fixation
%   'meansacdist' - Average distance of all saccades within a trial
%   'heatmap' - a 2D heatmap summarizing the scanpath
%   'gaze' - gives the scanpath as coords over time. Rows are X, Y, and T.
%   'blinkrate' - number of blinks / duration of video. 
%   'deviance' - deviation of gaze from a predicted timecourse

% Determine how many eyes were used
% values of n: 0 = left, 1 = right.
% Length of n should be the number of eyes tracked.
% If more than one, pick one eye at random and ignore the other
n = unique(edfDat.Saccades.eye);
if length(n) == 2
    i = round(rand());
else
    i = n;
end

% See if the optional screen dimensions were included
if nargin > 3
    % Expecting screen dimensions: [xsize ysize]
    % e.g. a typical HD screen is [1920 1080]
    scDim = varargin{2};
    assert(length(scDim) == 2, '4th input must be a 2-element array of screen dimensions: [xwidth yheight]');
else
    % Use defaults
    scDim = [1920 1200];
end

% See if the data needs to be flipped or not
if nargin > 2 && ~isempty(varargin{1})
    flipFlag = varargin{1};
    assert(islogical(flipFlag), '3rd input must be a boolean indicating whether the stimulus was flipped or not');
else
    flipFlag = false;
end

% Account for differences between TRIAL duration and STIMULUS duration
% (the full stream of samples per trial includes drift checking etc)

% Find timepoints bounding stimulus presentation
stimStart = findStimOnset(edfDat);
stimEnd = findStimOffset(edfDat);
recStart = edfDat.Header.rec.time; % time eyetracker starts recording

% The EDF file's 'duration' field is unreliable:
% sometimes it's 0, sometimes it's far less than the event durations,
% so just calculate it from start and end time instead.
duration = stimEnd - stimStart;

% There is a short delay b/w the eyetracker starting and stimulus onset.
% All the "Fixation" onset times are relative to the former, not the latter.
% e.g. a fixation with sttime == 100 began 100ms after recording,
% which may be before the stimulus actually started.
% Filter out any events that begin before this delay has passed.
recOffset = stimStart - recStart; % delay b/w eyetracker and stim, ~140ms

% Look for end times that happen before this interval.
recDur = stimEnd - recStart;


switch metricName
    case 'fixation'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        data = fixOutliers(data);
        output = sum(data);
    case 'gap'
        % This is ultimately meaningless
        % so if it correlates strongly with anything,
        % you've likely got a bug in your pipeline.
        output = recOffset;
    case 'scaledfixation'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        % data = [selectMetric(edfDat, 'firstfix', varargin) data]; % re-insert first fixation as well??
        data = [data selectMetric(edfDat, 'lastfix', varargin{:})]; % include the cut-off final fixation
        data = fixOutliers(data);
        data = sum(data);
        output = data / duration;
    case 'firstfix'
        data = edfDat.Fixations.entime(edfDat.Fixations.eye == i & edfDat.Fixations.sttime <= recOffset & edfDat.Fixations.entime >= recOffset);
        if isempty(data)
            output = NaN;
        else
            % I selected the END TIME of the fixation, not the duration.
            % The start time could be ANY time b/w recStart and stimStart,
            % But the end time is always relative to recStart.
            % Subtracting recOffset gives you the duration from video on,
            % so that this becomes a sort of reaction time to the video.
            output = data - recOffset;
        end
    case 'lastfix'
        % Please don't analyze this by itself
        data = edfDat.Fixations.sttime(edfDat.Fixations.eye == i & edfDat.Fixations.sttime <= recDur & edfDat.Fixations.entime >= recDur);
        if isempty(data)
            output = [];
        else
            % I selected the START TIME of the fixation, not the duration.
            % The end time could be ANY time after the stim ends,
            % but we need to ignore that part,
            % and just get the portion from its start to the video end.
            % Since Fixations.sttime is relative to recording onset,
            % we need to subtract recOffset as well.
            % The result is the duration of the final fixation,
            % minus any time it lasted after the video ended.
            output = (stimEnd - stimStart) - data(end) - recOffset;
        end
    case 'duration'
        output = getStimDuration(edfDat);
    case 'meanfix'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        data = fixOutliers(data);
        output = mean(data);
    case 'medianfix'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        data = fixOutliers(data);
        output = median(data);
    case 'maxfixOnset'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        data = fixOutliers(data);
        [~, position] = max(data);
        output = edfDat.Fixations.sttime(:,position);
    case 'minfixOnset'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        data = fixOutliers(data);
        [~, position] = min(data);
        output = edfDat.Fixations.sttime(:,position);
    case 'meansacdist'
        data = edfDat.Saccades.ampl(edfDat.Saccades.eye == i & edfDat.Saccades.entime <= recDur & edfDat.Saccades.sttime >= recOffset);
        % ampl = amplitude of saccade (ie distance)
        % there is also phi, which is direction in degrees (ie not rads)
        data = fixOutliers(data);
        % This metric has a theoretical limit.
        % fixOutliers is sometimes too conservative to catch it,
        % so enforce the hard limit post-hoc.
        % Examples of distance > 360 deg would be blinks (may go to inf)
        data(data > 360) = [];
        output = mean(data);
    case 'positionMax'
        % This is probably useless
        A = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        B = edfDat.Fixations.gavx(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        C = edfDat.Fixations.gavy(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        [~, colIdx] = max(A);
        valueInB = B(colIdx);
        valueInC = C(colIdx);
        output = [valueInB; valueInC];
    case 'positionMin'
        % This also seems useless
        A = edfDat.Fixations.time(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        B = edfDat.Fixations.gavx(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        C = edfDat.Fixations.gavy(edfDat.Fixations.eye == i & edfDat.Fixations.entime <= recDur & edfDat.Fixations.sttime >= recOffset);
        [~, colIdx] = min(A);
        valueInB = B(colIdx);
        valueInC = C(colIdx);
        output = [valueInB; valueInC];
    case 'heatmap'
        % This is a 2D matrix, not a single value! Be careful.
        
        % First get the full gaze trajectory for this trial
        dat = selectMetric(edfDat, 'gaze', varargin{:});
        
        % Separate x and y timeseries
        xdat = dat(1,:);
        ydat = dat(2,:);
        clear dat

        % A number >= 1 of pixels to average over
        % 1 = full-resolution, 10 is what Isik used.
        % Another Isik paper averaged 900x900 videos into 20 bins per side,
        % Which is about 2 deg of visual angle.
        binRes = round(deg2pix(2)); % calculate bin size using trig
        % binRes = 80;
        
        % We need to un-flip the gaze for flipped videos
        if flipFlag
            xdat = mirrorX(xdat, scDim(1));
        end

        % Get the data
        output = getHeatmap(xdat, ydat, scDim, binRes);
        
    case 'gaze'
        % This is a 2-row matrix of X-Y coordinate pairs
        % that represents gaze position on screen over time,
        % plus a 3rd row giving the time in ms from onset.
        % Not intended as its own 'metric' per se.

        % First get the XY timeseries, filtering blinks
        xdat = censorBlinks(edfDat.Samples.gx(i+1,:), edfDat);
        ydat = censorBlinks(edfDat.Samples.gy(i+1,:), edfDat);

        % Only consider timepoints where the stimulus was visible
        stimPeriod = edfDat.Samples.time >= stimStart & edfDat.Samples.time <= stimEnd;
        
        % i is 0 or 1 for left or right eye, so i+1 is 1st or 2nd row.
        % xdat = pickCoordData(edfDat.Samples.gx(:, stimPeriod));
        % ydat = pickCoordData(edfDat.Samples.gy(:, stimPeriod));
        xdat = xdat(stimPeriod);
        ydat = ydat(stimPeriod);
        tdat = edfDat.Samples.time(stimPeriod) - stimStart;

        % We need to un-flip the gaze for flipped videos
        if flipFlag
            xdat = mirrorX(xdat, scDim(1));
        end
        output = [xdat;ydat; tdat];
    case 'gazeF'
        % HIDDEN METRIC
        % This is just like 'gaze' above,
        % except then we also insert the video frame numbers.
        output = addframe2gaze(edfDat, i+1);
        if flipFlag
            output(1,:) = mirrorX(output(1,:), scDim(1));
        end
    case 'tot'
        % Time on Target, aka "triangle time"
        % Percentage of video time spent looking at characters
        output = timeOnTarget(edfDat, i+1, flipFlag, metricName);

    case 'blinkrate'
        % Pretty straightforward.
        % Duration is in msec, so 1000x gives you the rate in Hz
        if isempty(edfDat.Blinks)
            numBlinks = 0;
        else
            % Length of edfDat.Blinks will just be 1, so count this way.
            numBlinks = length(edfDat.Blinks.sttime);
        end
        output = 1000 * numBlinks / duration;
    case 'deviance'
        % Deviation of actual scanpath from a predicted scanpath,
        % based on the location of highest motion in each video frame.
        % Built out a separate function to calculate this.
        [gaze, newPos] = motionDeviation(edfDat, i+1, flipFlag);
        % Subtract prediction from measurement to get 'error' timeseries:
        deviance(1,:) = gaze(1,:) - newPos(1,:);
        deviance(2,:) = gaze(2,:) - newPos(2,:);
        deviance(3,:) = gaze(3,:);
        
        % This is a matrix of coordinate pairs. Reduce it to 1D distances:
        % XY coordinates form a right triangle with the origin, so use the
        % Pythagorean theorem to calculate the length of each hypotenuse.
        output = sqrt(deviance(1,:).^2 + deviance(2,:).^2);
    case 'similarity'
        % Correlation of scanpath with predicted scanpath,
        % based on the location of highest motion in each video frame.
        % Similar to 'deviance', but this is a correlation, not a vector.
        [gaze, newPos] = motionDeviation(edfDat, i+1, flipFlag);
        output = corr2(gaze(1:2,:), newPos);

    otherwise
        error('Unknown metric name %s! aborting', metricName);
end