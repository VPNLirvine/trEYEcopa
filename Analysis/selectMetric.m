function output = selectMetric(edfDat, metricName, varargin)
% Takes in a single row of an edf file (ie already indexed by trial number)
% e.g. input should be edfFile(trialNum), not edfFile itself
% Given a metric name like 'totfixation', calculate and return that metric
% Options are as follows:
%   'fixation' - Total fixation time per trial
%   'scaledfixation' - Percentage of video time spent fixating
%   'meanfix' - Average fixation duration within a trial
%   'medianfix' - Median fixation duration within a trial
%   'maxfixOnset' - Onset time of the longest fixation
%   'minfixOnset' - Onset time of the shortest fixation
%   'meansacdist' - Average distance of all saccades within a trial
%   'heatmap' - a 2D heatmap summarizing the scanpath

% Determine how many eyes were used
% If more than one, pick one at random and discard the other
n = unique(edfDat.Saccades.eye);
if length(n) == 2
    i = round(rand());
else
    i = n;
end

switch metricName
    case 'fixation'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        data = fixOutliers(data);
        output = sum(data);
    case 'scaledfixation'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        data = fixOutliers(data); 
        data = sum(data);
        duration = double(edfDat.Header.duration);
        
        if duration == 0
            % This does actually happen for some reason
            duration = double(edfDat.Header.endtime - edfDat.Header.starttime);
        end

        output = data / duration;
    case 'meanfix'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        data = fixOutliers(data);
        output = mean(data);
    case 'medianfix'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        data = fixOutliers(data);
        output = median(data);
    case 'maxfixOnset'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        data = fixOutliers(data);
        [~, position] = max(data);
        output = edfDat.Fixations.sttime(:,position);
    case 'minfixOnset'
        data = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        data = fixOutliers(data);
        [~, position] = min(data);
        output = edfDat.Fixations.sttime(:,position);
    case 'meansacdist'
        data = edfDat.Saccades.ampl(edfDat.Saccades.eye == i);
        data = fixOutliers(data);
        output = mean(data);
        % ampl = amplitude of saccade (ie distance)
        % there is also phi, which is direction in degrees (ie not rads)
    case 'positionMax'
        % This is probably useless
        A = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        B = edfDat.Fixations.gavx(edfDat.Fixations.eye == i);
        C = edfDat.Fixations.gavy(edfDat.Fixations.eye == i);
        [~, colIdx] = max(A);
        valueInB = B(colIdx);
        valueInC = C(colIdx);
        output = [valueInB; valueInC];
    case 'positionMin'
        % This also seems useless
        A = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        B = edfDat.Fixations.gavx(edfDat.Fixations.eye == i);
        C = edfDat.Fixations.gavy(edfDat.Fixations.eye == i);
        [~, colIdx] = min(A);
        valueInB = B(colIdx);
        valueInC = C(colIdx);
        output = [valueInB; valueInC];
    case 'heatmap'
        % This is a 2D matrix, not a single value! Be careful.

        % Extract x and y timeseries
        xdat = pickCoordData(edfDat.Samples.gx);
        ydat = pickCoordData(edfDat.Samples.gy);

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
        if nargin > 2
            flipFlag = varargin{1};
            assert(islogical(flipFlag), '3rd input must be a boolean indicating whether the stimulus was flipped or not');
            if flipFlag
                xdat = mirrorX(xdat, scDim(1));
            end
        end
        % A number >= 1 of pixels to average over
        % 1 = full-resolution, 10 is what Isik used.
        binRes = 1;

        % Get the data
        output = getHeatmap(xdat, ydat, scDim, binRes);
        
    otherwise
        error('Unknown metric name %s! aborting', metricName);
end