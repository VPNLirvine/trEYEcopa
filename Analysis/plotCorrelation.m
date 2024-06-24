function plotCorrelation(data, output, metricName)
% Given a stack of data from e.g. getTCData,
% and the pre-calculated correlation coefficients (for labeling),
% Plot the gaze metric against the clarity ratings.

%% Setup
warning('off','stats:boxplot:BadObjectType'); % it's fine

% See if you can use fancy new formatting
chk = which('tiledlayout');
ok = ~isempty(chk); % ok if not empty, not ok if empty

%% Execution
% Open figures
fig1 = figure();
    if ok
        tiledlayout('horizontal');
    end
fig2 = figure();
    if ok
        tiledlayout('horizontal');
    end
% Get axis titles
[var1, yl] = getGraphLabel(metricName);
[var2, yl2] = getGraphLabel('response');

% Count subjects to loop over
subList = unique(data.Subject);
numSubs = length(subList);

for s = 1:numSubs
    subID = subList{s};
    subset = strcmp(subID, data.Subject);
    set(0,'CurrentFigure',fig1);
    if ok
        nexttile;
    else
        subplot(1,numSubs, s)
    end
    % Plot the eyetracking data against the understanding score
    % Use boxplots instead of a scatterplot because Response is ordinal
    % (i.e. it's an integer of 1-5, not a ratio/continuous variable)
        % Handle cases where subjects don't use all the buttons:
        % init an empty, oversize matrix
        x = nan([length(data.Eyetrack), 5]);
        dat = []; % tmp
        for i = 1:5
            % Get the values for each response choice
            dat = data.Eyetrack(data.Response == i & subset);
            datl = length(dat);
            if ~isempty(dat)
                % If no responses with this button, leave nans
                x(1:datl,i) = dat;
            end
        end
        boxplot(x, 1:5); % which ignores nans thankfully
        xlabel(var2);
        ylabel(var1);
        title([strrep(subID, '_', '\_'), sprintf(', \x03C1 = %0.2f', output(s,2))]);
        ylim(yl); % ylimit varies by metric
    % subplot(2,numSubs, s+numSubs)
    set(0,'CurrentFigure',fig2);
    if ok
        nexttile;
    else
        subplot(1,numSubs, s)
    end
    % But also add some scatterplots so you can see ALL your data
    % Helps give a better sense of where numbers are coming from
        scatter(data.Response(subset), data.Eyetrack(subset));
        xlabel(var2);
        ylabel(var1);
        title([strrep(subID, '_', '\_'), sprintf(', \x03C1 = %0.2f', output(s,2))]);
        ylim(yl); % varies by metric
        xlim(yl2); % fixed bc it's response 1-5
        xticks([1 2 3 4 5])
        % lsline
end

% Also generate an overall plot (i.e. not by subject)
figure();
x = nan([length(data.Eyetrack), 5]);
dat = []; % tmp
for i = 1:5
    % Get the values for each response choice
    dat = data.Eyetrack(data.Response == i);
    datl = length(dat);
    if ~isempty(dat)
        % If no responses with this button, leave nans
        x(1:datl,i) = dat;
    end
end
boxplot(x, 1:5); % which ignores nans thankfully
xlabel(var2);
ylabel(var1);
title(sprintf('Across %i subjects, \x03C1 = %0.2f', numSubs, output(s,2)));
ylim(yl); % ylimit varies by metric

warning('on','stats:boxplot:BadObjectType'); % toggle
end