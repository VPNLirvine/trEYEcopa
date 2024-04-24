function plotItemwise(plotData, metricName)
% Generate boxplots showing variability of each stimulus
% First get some axis labels etc
[axistxt, ~, yl] = getGraphLabel(metricName);
plotOrder = unique(plotData.StimName); % Theoretically alphabetical order
% Now make the plot
figure();
    boxplot(plotData.Eyetrack, plotData.StimName, 'GroupOrder', plotOrder);
    ylim(yl);
    ylabel(axistxt);