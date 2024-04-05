function [txt, varargout] = getGraphLabel(metricName)
% Define the axis labels used by boxPlot2
% Also export the xlim and ylim vectors
switch metricName
    case 'rawfix'
        txt = 'Fixation durations in ms';
    case 'fixation'
        txt = 'Total fixation time in ms';
        hy = [0 25];
        yl = [1.5e4 2.1e4];
    case 'scaledfixation'
        txt = 'Percent time spent fixating';
        hy = [0 100];
        yl = [0 1.1];
    case 'meanfix'
        txt = 'Average fixation time in ms';
        hy = [0 60];
        % yl = [220 1000];
        yl = [0 1000];
    case 'medianfix'
        txt = 'Median fixation time in ms';
        hy = [0 60];
        yl = [175 800];
    case 'maxfixOnset'
        txt = 'Onset time of longest fixation';
        hy = [0 45];
        yl = [0 2e4];
    case 'minfixOnset'
        txt = 'Onset time of shortest fixation';
        hy = [0 45];
        yl = [0 2.2e4];
    case 'meansacdist'
        txt = 'Average saccade distance in degrees';
        hy = [0 45];
        yl = [0 9];
    case 'ISC'
        txt = 'Intersubject correlation with group mean';
        hy = [0 1];
        % no idea what yl is...
    otherwise
        error('Unknown metric name %s! aborting', metricName);
end % switch
if nargout > 1
    varargout{1} = hy;
end
if nargout > 2
    varargout{2} = yl;
end
end % function