function analysis(varargin)
% Perform statistical analysis on eyetracking data
% Optional input 1 should be a metric name listed in selectMetric()
close all;
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
        fprintf(1, 'Median ISC = %0.2f%%\n', 100 * median(data.Eyetrack));
    else
        data = getTCData(metricName);
    end
    subList = unique(data.Subject);
    numSubs = size(subList, 1);

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
    
    % Get the AQ scores from the Qualtrics output
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
    

    if strcmp(metricName, 'ISC')
        % Directly correlate ISC with AQ
        % Compress to average ISC per subject since there's only 1 AQ
        metric = zeros([numSubs,1]);
        for s = 1:numSubs
            subID = subList{s};
            subset = strcmp(subID, data.Subject);
            metric(s) = mean(data.Eyetrack(subset));
        end
        output(1,1) = corr(aq, metric, 'Type', 'Pearson');
        output(1,2) = corr(aq, metric, 'Type', 'Spearman');
        
        % Plot
        figure();
        scatter(aq, metric);
            title(sprintf('Strength of relationship: \x03C1 = %0.2f', output(1,2)));
            xlabel('Autism Quotient');
            ylabel(var1);
            ylim(yl);
            
        % Report the correlation score
        fprintf(1, 'Correlation between AQ and %s:\n', var1)
        fprintf(1, '\t\x03C1 = %0.2f\n', output(1,2));
    else
        % Calculate correlations and generate some visualizations
        output = getCorrelations(data);
        plotCorrelation(data,output,metricName);
    
        % Now Fischer z-transform your correlation coefficients
        zCorr = zscore(output(:,2));
    
        % Plot and analyze relationship between AQ and current metric
        figure();
            scatter(aq, zCorr, 'filled');
            xlabel('Autism Quotient');
            ylabel('Z-Transformed Spearman correlation');
            title(sprintf('Impact of AQ on %s''s relation with %s', var1, var2));
        secondCorr = corr(aq, zCorr, 'Type', 'Spearman');
    
        fprintf(1, 'Correlation between AQ and above correlation:\n')
        fprintf(1, '\t\x03C1 = %0.2f\n', secondCorr);
    end
    
elseif choice == 2
    % Martin & Weisberg
    % Pipeline was already built, just call here:
    Ttest(metricName);
end