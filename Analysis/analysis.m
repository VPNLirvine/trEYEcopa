function analysis(varargin)
% Perform statistical analysis on eyetracking data

% Optional input 1 should be a metric name listed in selectMetric()
if nargin > 0
    metricName = varargin{1};
else
    % By default, use percent time spent fixating
    metricName = 'scaledfixation';
end

% The exact test depends on which stimulus set we're looking at
% So force a choice:
choice = menu('Which data do you want to analyze?','TriCOPA','Martin & Weisberg');

if choice == 1
    % TriCOPA
    fprintf(1, 'Using metric %s\n\n', metricName);
    if strcmp(metricName, 'ISC')
        data = doISC;
    else
        data = getTCData(metricName);
    end
    numSubs = size(unique(data.Subject), 1);
    numTrials = height(data);

    %
    % Compare the eyetracking data to the behavioral data
    %

    % Do not run a linear regression for predicting gaze from response
    % because the response measure is technically a DV, not an IV.
    % Do a correlation instead.
    % Calculate individually per subject to make it RFX.
    % mdl = fitlm(data, 'Eyetrack ~ Response');
    
    % Histograms of the input variables
    figure();
    subplot(1,2,1);
        histogram(data.Eyetrack);
        xlabel(getGraphLabel(metricName));
    subplot(1,2,2)
        histogram(data.Response);
        xlabel('Intentionality score');

    % Calculate correlations and generate some visualizations
    subList = unique(data.Subject);
    figure();
    for s = 1:numSubs
        subID = subList{s};
        subset = strcmp(subID, data.Subject);
        output(s, 1) = corr(data.Response(subset), data.Eyetrack(subset), 'Type', 'Pearson');
        output(s,2) = corr(data.Response(subset), data.Eyetrack(subset), 'Type', 'Spearman');
        subplot(2, numSubs, s)
        % Plot the eyetracking data against the understanding score
        % Use boxplots instead of a scatterplot because Response is ordinal
        % (i.e. it's an integer of 1-5, not a ratio/continuous variable)
            boxplot(data.Eyetrack(subset), data.Response(subset));
            xlabel('Intentionality Score');
            ylabel(getGraphLabel(metricName));
            title([strrep(subID, '_', '\_'), sprintf(', Spearman''s rho = %0.2f', output(s,2))]);
            ylim([0, 1]); % fixation proportions are bounded from 0 to 100%
        subplot(2,numSubs, s+numSubs)
        % But also add some scatterplots so you can see ALL your data
        % Helps give a better sense of where numbers are coming from
            scatter(data.Response(subset), data.Eyetrack(subset));
            xlabel('Intentionality Score');
            ylabel(getGraphLabel(metricName));
            title([strrep(subID, '_', '\_'), sprintf(', Spearman''s rho = %0.2f', output(s,2))]);
            ylim([0, 1]); % fixation proportions are bounded from 0 to 100%
            xlim([0 6]);
            xticks([1 2 3 4 5])
            % lsline
    end
    
    % Analyze the distribution of correlation scores
    mu = mean(output(:,2));
    sigma = std(output(:,2));

    fprintf(1, '\n\nRESULTS:\n\n');
    fprintf(1, 'Average correlation between %s and ')
elseif choice == 2
    % Martin & Weisberg
    % Pipeline was already built, just call here:
    Ttest(metricName);
end