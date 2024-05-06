function plotItemwise(plotData, metricName, varargin)
% Generate boxplots showing variability of each stimulus

if nargin > 2
    mwflag = varargin{1};
else
    % Default assume TriCOPA
    mwflag = 0;
end
pths = specifyPaths('..');

% First get some axis labels etc
[axistxt, yl] = getGraphLabel(metricName);
stimList = unique(plotData.StimName); % Theoretically alphabetical order

% Let's try sorting by video duration instead of video name
for i = 1:length(stimList)
    stim = stimList{i};
    % Find video, accounting for different locations etc.
    if mwflag
        % This loop is pointless for MW since they're all 16 sec
        % But do it for compatibility
        fpath = fullfile(pths.MWstim, [stim '.mov']);
    else
        % TC vids are all variable duration
        fpath = fullfile(pths.TCstim, 'normal', stim);
    end
    dur = getVideoDuration(fpath);
    s{i} = stim;
    d(i) = dur;
    ind = strcmp(stim, plotData.StimName);
    durCol(ind) = d(i);
end
[~,o] = sort(d); % sort the durations and get the reordering indices
plotOrder = stimList(o); % use the new order to index from stim list
tit = 'Videos sorted by duration, variance is across subjects';

% plotOrder = stimList;
% tit = 'Videos sorted alphabetically, variance is across subjects';

% Also calculate a correlation between metric and video duration
c = corr(plotData.Eyetrack, durCol', 'rows', 'complete');

% Now make the plot
figure();
    boxplot(plotData.Eyetrack, plotData.StimName, 'GroupOrder', plotOrder);
    ylim(yl);
    ylabel(axistxt);
    title(sprintf([tit '\nPearson''s r = %0.2f'],c));
