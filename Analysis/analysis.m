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
        fprintf(1, 'Mean ISC = %0.2f%%\n', 100 * mean(data.Eyetrack));
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
    [var1, ~, yl] = getGraphLabel(metricName);
    var2 = 'Understandability rating';

    figure();
    subplot(1,2,1);
        histogram(data.Eyetrack);
        xlabel(var1);
        title('Expect an RT-like distribution');
    subplot(1,2,2)
        histogram(data.Response);
        xlabel(var2);
        title('Uniform distribution is ideal');

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
            title([strrep(subID, '_', '\_'), sprintf(', rho = %0.2f', output(s,2))]);
            ylim(yl); % ylimit varies by metric
        subplot(2,numSubs, s+numSubs)
        % But also add some scatterplots so you can see ALL your data
        % Helps give a better sense of where numbers are coming from
            scatter(data.Response(subset), data.Eyetrack(subset));
            xlabel(var2);
            ylabel(var1);
            title([strrep(subID, '_', '\_'), sprintf(', rho = %0.2f', output(s,2))]);
            ylim(yl); % varies by metric
            xlim([0 6]); % fixed bc it's response 1-5
            xticks([1 2 3 4 5])
            % lsline
    end
    
    % Analyze the distribution of correlation scores
    mu = mean(output(:,2));
    sigma = std(output(:,2));

    fprintf(1, '\n\nRESULTS:\n');
    fprintf(1, 'Average correlation between %s and %s:\n', var1, var2);
    fprintf(1, '\t\x03C1 = %0.2f (SD = %0.2f)\n', mu, sigma);
    fprintf(1, 'Average subject-level percent variance explained by this relationship:\n');
    fprintf(1, '\tr%c = %0.2f%%\n', 178, 100*mean(output(:,2) .^2));
    fprintf(1, '\n');
    
    %
    % Now correlate those correlations with the AQ scores
    %
    
    % First get the AQ scores from the Qualtrics output
    aqTable = getAQ(specifyPaths('..'));
            % validate
        numAQ = height(aqTable);
        if numSubs > numAQ
            txt = sprintf(['There are %i EDF files, '...
                'but Qualtrics data had only %i subjects. '...
                'Please resolve and try again.\n'...
                'You likely just need to re-download the Qualtrics data.'] ...
                , numSubs, numAQ);
            error(txt)
        end
    % Ensure they're sorted the same as the other data
    for s = 1:numSubs
        subID = subList{s};
        aq(s) = aqTable.AQ(strcmp(subID, aqTable.SubID));
    end
    aq = aq'; % Rotate 90 deg so it's a column vector like zCorr below
    
    % Now Fischer z-transform your previous data
    zCorr = zscore(output(:,2));

    % Plot and analyze
    figure();
        scatter(aq, zCorr, 'filled');
        xlabel('Autism Quotient');
        ylabel('Z-Transformed Spearman correlation');
        title(sprintf('Impact of AQ on %s''s relation with %s', var1, var2));
    secondCorr = corr(aq, zCorr, 'Type', 'Spearman');

    fprintf(1, 'Correlation between AQ and above correlation:\n')
    fprintf(1, '\t\x03C1 = %0.2f\n', secondCorr);

elseif choice == 2
    % Martin & Weisberg
    % Pipeline was already built, just call here:
    Ttest(metricName);
end