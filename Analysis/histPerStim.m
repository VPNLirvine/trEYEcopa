% Histograms of individual fixation durations per stimulus
outputPath = '/Users/vpnl/Documents/MATLAB/ExpOutputs/MWoutput';
edfList = dir(strcat(outputPath, '/*.edf'));
metricName = 'rawfix';
axistxt = getGraphLabel(metricName);
% Aggregate data
for subject = 1:length(edfList)
    Trials = osfImport(edfList(subject).name);
    if subject == 1
        plotData = initPlotData(Trials);
    end
    for trial = 1:length(Trials)
        % Determine which movie was actually presented
        stimName = getStimName(Trials(trial));
        % Find that movie in the struct, since each sub has dif order
        idx = find(strcmp({plotData(:).name}, stimName));
        % Get the data to use
        thisData = selectMetric(Trials(trial), metricName);
        % Append fixation vector to existing vector for this stimulus
        plotData(idx).data = [plotData(idx).data, thisData];
    end
end

close all
% Now plot separately per stimulus
for t = 1:length(plotData)
    stimName = plotData(t).name;
    figure();
    histogram(plotData(t).data);
    title(stimName);
%     xticklabels(stimList);
    ylim([0 25*length(edfList)]);
    xlabel(axistxt);
    xlim([0 5000]); % TWEAK
end

function plotData = initPlotData(Trials)
% Set up an empty struct to put data into per subject
    for trial = 1:length(Trials)
        plotData(trial).name = getStimName(Trials(trial));
        plotData(trial).data = [];
    end
end