function [txt, varargout] = getGraphLabel(metricName)
% Define the axis labels used by boxPlot2
%
% Optional output 2 is the ylim vector
% yl = y limit, i.e. the max expected value
% Note that on a histogram, yl should be used on the x axis
%
% Optional output 3 describes the expected shape of a histogram
% This should typically be used as the histogram's title

switch metricName
    case 'response'
        txt = 'Understandability rating';
        yl = [0 6]; % fixed response limit 1-5
        dist = 'Uniform distribution is ideal';
    case 'coherence'
        txt = 'Average scanpath similarity to group';
        yl = [0 1.1];
        dist = 'Expect an RT-like distribution';
    case 'AQ1'
        txt = 'Social Skills score';
        yl = [13 52]; % 13 questions scored 1-4
        dist = 'Expect a bimodal distribution';
    case 'AQ2'
        txt = 'Communication Skills score';
        yl = [8 32]; % 8 questions scored 1-4
        dist = 'Expect a bimodal distribution';
    case 'AQ3'
        txt = 'Attention to Detail score';
        yl = [7 28]; % 7 questions scored 1-4
        dist = 'Expect a bimodal distribution';
    case 'rawfix'
        txt = 'Fixation durations in ms';
        yl = 'tight';
        dist = 'Expect an RT-like distribution';
    case 'fixation'
        txt = 'Total fixation time in ms';
        yl = [1.5e4 2.1e4];
        dist = 'Expect an RT-like distribution';
    case 'scaledfixation'
        txt = 'Percent time spent fixating';
        yl = [0 1.1];
        dist = 'Expect an RT-like distribution';
    case 'gap'
        txt = 'Delay between recording and video onset';
        yl = [0 200];
        dist = 'Expect a normal distribution';
    case 'firstfix'
        txt = 'Duration of first fixation in ms';
        yl = [0 1000]; % though there are MANY outliers beyond this
        dist = 'Expect an RT-like distribution';
    case 'duration'
        txt = 'Duration of stimulus in sec';
        yl = [0 30];
        dist = 'Expect a normal distribution';
    case 'meanfix'
        txt = 'Average fixation time in ms';
        yl = [0 2000];
        dist = 'Expect an RT-like distribution';
    case 'medianfix'
        txt = 'Median fixation time in ms';
        yl = [0 1000];
        dist = 'Expect an RT-like distribution';
    case 'maxfixOnset'
        txt = 'Onset time of longest fixation';
        yl = [0 2e4];
        dist = 'Expect a normal distribution';
    case 'minfixOnset'
        txt = 'Onset time of shortest fixation';
        yl = [0 2.2e4];
        dist = 'Expect a normal distribution';
    case 'meansacdist'
        txt = 'Average saccade distance in degrees';
        yl = [0 10];
        dist = 'Expect a normal distribution';
    case 'blinkrate'
        txt = 'Number of blinks per second';
        yl = [0 2]; % Usually < 1, avg 0.3, but sub15 was WILD
        dist = 'Expect an RT-like distribution';
    case 'ISC'
        txt = 'Intersubject correlation with group mean';
        yl = [0 1.1]; % correlation bounded 0:1
        dist = 'Expect a normal distribution';
    case 'tot'
        txt = 'Percent time gaze was on any character';
        yl = [0 1]; % percentage is bounded 0 to 1
        dist = 'Expect an RT-like distribution';
    otherwise
        error('Unknown metric name %s! aborting', metricName);
end % switch
if nargout > 1
    varargout{1} = yl;
end
if nargout > 2
    varargout{2} = dist;
end
end % function