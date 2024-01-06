function output = selectMetric(edfDat, metricName)
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
        A = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        B = edfDat.Fixations.gavx(edfDat.Fixations.eye == i);
        C = edfDat.Fixations.gavy(edfDat.Fixations.eye == i);
        [~, colIdx] = max(A);
        valueInB = B(colIdx);
        valueInC = C(colIdx);
        output = [valueInB; valueInC];
    case 'positionMin'
        A = edfDat.Fixations.time(edfDat.Fixations.eye == i);
        B = edfDat.Fixations.gavx(edfDat.Fixations.eye == i);
        C = edfDat.Fixations.gavy(edfDat.Fixations.eye == i);
        [~, colIdx] = min(A);
        valueInB = B(colIdx);
        valueInC = C(colIdx);
        output = [valueInB; valueInC];
        
    otherwise
        error('Unknown metric name %s! aborting', metricName);
end