function plotItemwise(plotData, metricName, varargin)
% Generate boxplots showing variability of each stimulus

if nargin > 2
    mwflag = varargin{1};
else
    % Default assume TriCOPA
    mwflag = 0;
end

% First get some axis labels etc
[axistxt, yl] = getGraphLabel(metricName);
stimList = unique(plotData.StimName); % Theoretically alphabetical order
numStims = length(stimList);
var2 = getGraphLabel('duration');
var3 = getGraphLabel('response');

% Let's try sorting by video duration instead of video name
for i = 1:numStims
    stim = stimList{i};
    % Find video, accounting for different locations etc.
    fpath = findVidPath(stim);
    dur = getVideoDuration(fpath);
    s{i} = stim;
    d(i) = dur;
    ind = strcmp(stim, plotData.StimName);
    durCol(ind) = d(i);
    if ~mwflag
        ratCol(i) = mean(plotData.Response(ind));
    end
    eyeCol(i) = mean(plotData.Eyetrack(ind));
end
[~,o] = sort(d); % sort the durations and get the reordering indices
plotOrder = stimList(o); % use the new order to index from stim list
tit = 'Videos sorted by duration, variance is across subjects';

% plotOrder = stimList;
% tit = 'Videos sorted alphabetically, variance is across subjects';

% Also calculate a correlation between metric and video duration
% c = corr(plotData.Eyetrack, durCol', 'rows', 'complete');
[c,p1] = corr(eyeCol', d', 'rows', 'complete', 'Type', 'Spearman');
% c2 = corr(plotData.Response, durCol', 'rows', 'complete');
fprintf(1, '\nCorrelation between average %s and %s:\n', axistxt, var2);
fprintf(1, '\tSpearman''s \x03C1 = %0.2f , p = %0.3f\n', c, p1);
if ~mwflag
    [c2,p2] = corr(ratCol', d', 'rows', 'complete', 'Type', 'Spearman');
    % Report p values
    fprintf(1, 'Correlation between average %s and %s:\n', axistxt, var3);
    fprintf(1, '\tSpearman''s \x03C1 = %0.2f , p = %0.3f\n', c2, p2);
end

% Now make the plot
figure();
    plt = boxplot(plotData.Eyetrack, plotData.StimName, 'GroupOrder', plotOrder);
    ylim(yl);
    ylabel(axistxt);
    title(sprintf([tit '\nSpearman''s \x03C1 = %0.2f, p = %0.4f'],c, p1));
    hold on
        scatter(1:numStims, eyeCol(o), "filled", "MarkerFaceColor", "#D95319");
    hold off
    ax = gca;
    set(ax, 'Box', 'off');
    set(ax, 'FontSize', 13);
    set(ax, 'LineWidth', 1.5);
    set(plt, 'LineWidth', 1.5);
    
if ~mwflag
    % Do it again as a scatterplot, so the x axis isn't artificially spaced
    % Skip if MW bc all those videos are the same length
    figure();
        scatter(d(o), eyeCol(o), "filled", 'LineWidth', 2);
        ylim(yl);
        ylabel(axistxt);
        title(sprintf('Spearman''s \x03C1 = %0.2f',c));
        xlabel('Video Duration (sec)');
        xlim([0 30]);
        ax = gca;
        set(ax, 'Box', 'off');
        set(ax, 'FontSize', 13);
        set(ax, 'LineWidth', 1.5);

    % Make another for ratings
    [ax2, yl2] = getGraphLabel('response');
    figure();
        plt = boxplot(plotData.Response, plotData.StimName, 'GroupOrder', plotOrder);
        ylim(yl2);
        yticks(yl2(1)+1 : yl2(2) - 1); % 1:5
        ylabel(ax2);
        title(sprintf([tit '\nSpearman''s \x03C1 = %0.2f'],c2));
        hold on
        scatter(1:length(stimList), ratCol(o), "filled", "MarkerFaceColor", "#D95319");
        hold off
        ax = gca;
        set(ax, 'Box', 'off');
        set(ax, 'FontSize', 13);
        set(ax, 'LineWidth', 1.5);
        set(plt, 'LineWidth', 1.5);
    % And again as a scatterplot, so the x axis isn't artificially spaced
    figure();
        scatter(d(o), ratCol(o), "filled", 'LineWidth', 2);
        ylim(yl2);
        ylabel(['Average', ax2]);
        title(sprintf('Spearman''s \x03C1 = %0.2f, p = %0.4f',c2,p2));
        xlabel('Video Duration (sec)');
        xlim([0 30]);
        ax = gca;
        set(ax, 'Box', 'off');
        set(ax, 'FontSize', 13);
        set(ax, 'LineWidth', 1.5);
end