function plotItemwise(plotData, metricName)
% Generate boxplots showing variability of each stimulus
% First get some axis labels etc
[axistxt, yl] = getGraphLabel(metricName);
stimList = unique(plotData.StimName); % Theoretically alphabetical order

% % Let's try sorting by video duration instead of video name
% pths = specifyPaths('..');
% for i = 1:length(stimList)
%     stim = stimList{i};
%     dur = getVideoDuration(fullfile(pths.TCstim, 'normal',stim));
%     s{i} = stim;
%     d(i) = dur;
% end
% [~,o] = sort(d); % sort the durations and get the reordering indices
% plotOrder = stimList(o); % use the new order to index from stim list
% tit = 'Videos sorted by duration, variance is across subjects';

plotOrder = stimList;
tit = 'Videos sorted alphabetically, variance is across subjects';

% Now make the plot
figure();
    boxplot(plotData.Eyetrack, plotData.StimName, 'GroupOrder', plotOrder);
    ylim(yl);
    ylabel(axistxt);
    title(tit);