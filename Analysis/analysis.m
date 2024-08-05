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
        data = doISC(getTCData('heatmap'));
        fprintf(1, 'Mean ISC = %0.2f%%\n', 100 * mean(data.Eyetrack));
        fprintf(1, 'Median ISC = %0.2f%%\n', 100 * median(data.Eyetrack));
    elseif strcmp(metricName, 'coherence')
        [~, data] = doGazePath(getTCData('gaze'));
        % Compress the timecourse down to a single number
        for i = 1:height(data)
            data.Eyetrack{i} = mean(data.Eyetrack{i}(1,:), 'omitnan');
        end
        % Now that they're not vectors, turn the column into a single mat
        data.Eyetrack = cell2mat(data.Eyetrack);
    else
        data = getTCData(metricName);
    end
    mwflag = 0;
elseif choice == 2
    % Martin & Weisberg
    if strcmp(metricName, 'ISC')
        data = doISC(getMWData('heatmap'));
        fprintf(1, 'Mean ISC = %0.2f%%\n', 100 * mean(data.Eyetrack));
        fprintf(1, 'Median ISC = %0.2f%%\n', 100 * median(data.Eyetrack));
    else
        data = getMWData(metricName);
    end
    mwflag = 1;
    choice = menu('Which analysis method do you want for this Martin & Weisberg data?','correlation', 't-test');
end

if choice == 1
    % Correlation analysis
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
    
    % Get axis labels for later
    [var1, yl, distTxt] = getGraphLabel(metricName);
    [var2, yl2, distTxt2] = getGraphLabel('response');
    
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
    if mwflag
        % SubIDs indicate which experiment was run,
        % But the AQ table only says 'TC'.
        % TC_01 == MW_01. Compensate.
        aqTable.SubID = replace(aqTable.SubID, 'TC','MW');
    end
    % Ensure they're sorted the same as the other data
    for s = 1:numSubs
        subID = subList{s};
        aq(s) = aqTable.AQ(strcmp(subID, aqTable.SubID));
    end
    aq = aq'; % Rotate 90 deg so it's a column vector like zCorr below
    

    % First, directly correlate the metric with AQ
    % i.e. do not correlate with the clarity rating
    % Reduce data to an average value per subject,
    % since there's only 1 AQ value per person
    [var3, yl3, distTxt3] = getGraphLabel('AQ');

    aqCol = [];
    for s = 1:numSubs
        subID = subList{s};
        subset = strcmp(subID, data.Subject);
        nrows = sum(subset);
        aqCol = [aqCol; aq(s) * ones(nrows,1)];
    end
    output(1,1) = corr(aqCol, data.Eyetrack, 'Type', 'Pearson', 'rows', 'complete');
    output(1,2) = corr(aqCol, data.Eyetrack, 'Type', 'Spearman', 'rows', 'complete');
        
        % Plot
        figure();
        scatter(aqCol, data.Eyetrack);
            title(sprintf('Across %i subjects, strength of relationship \x03C1 = %0.2f', numSubs, output(1,2)));
            xlabel(var3);
            ylabel(var1);
            ylim(yl);
            xlim(yl3);
            
        % Report the correlation score
        fprintf(1, '\n\nCorrelation between AQ and %s:\n', var1)
        fprintf(1, '\tSpearman''s \x03C1 = %0.2f\n', output(1,2));
        fprintf(1, '\tPearson''s r = %0.2f\n', output(1,1));

        % Report secondary correlation
        aq2rating(1) = corr(aqCol, data.Response, 'Type', 'Spearman', 'rows', 'complete');
        aq2rating(2) = corr(aqCol, data.Response, 'Type', 'Pearson', 'rows', 'complete');
        fprintf(1, '\n\nCorrelation between AQ and %s:\n', var2);
        fprintf(1, '\tSpearman''s \x03C1 = %0.2f\n', aq2rating(1));
        fprintf(1, '\tPearson''s r = %0.2f\n', aq2rating(2));

        % Histograms
        figure();
        subplot(1,2,1);
            histogram(data.Eyetrack);
            xlabel(var1);
            title(distTxt);
            xlim(yl);
        subplot(1,2,2)
            histogram(aq, 'BinEdges', 0:5:50);
            xlabel(var3);
            title(distTxt3);
            xlim([0 50]);
            % Add lines indicating the expected distribution(s)
            overlayAQ(gca);
    if ~mwflag
        % Calculate correlations and generate some visualizations
        output = getCorrelations(data, metricName);
        plotCorrelation(data, output, metricName);
    
        % Now Fischer z-transform your correlation coefficients
        zCorr = zscore(output(:,2));
    
        % Plot and analyze relationship between AQ and current metric
        secondCorr = corr(aq, zCorr, 'Type', 'Spearman', 'rows', 'complete');
        figure();
            scatter(aq, zCorr, 'filled');
            xlabel(var3);
            ylabel('Z-Transformed Spearman correlation');
            title(sprintf('Impact of AQ on %s''s relation with %s\n\x03C1 = %0.2f', var1, var2, secondCorr));
    
        fprintf(1, 'Correlation between AQ and above correlation:\n')
        fprintf(1, '\t\x03C1 = %0.2f\n', secondCorr);
        
        % Histograms of the variables at play
        figure();
        subplot(1,2,1);
            histogram(data.Eyetrack);
            xlabel(var1);
            title(distTxt);
            xlim(yl);
        subplot(1,2,2)
            histogram(data.Response);
            xlabel(var2);
            title(distTxt2);
    end
    
elseif choice == 2
    % Do a mean comparison across groups
    subList = unique(data.Subject);
    numSubs = size(subList, 1);

    % RFX ANOVA accounting for subject-level variance
    % Generates a figure window with statistical table
    ivs = {data.Category, data.Subject};
    rfx = [2]; % which IV(s) is a random effect? (e.g. subject ID)
    ci = 1; % condition of interest
    [p1, tbl, stats1] = anovan(data.Eyetrack, ivs, 'varnames', {'Condition', 'SubID'}, 'random', rfx);
    
    h = p1(ci) <= .05;
    % Generate figures
    BoxplotMW(data, metricName);
    
    % % Plain t-test ignoring subject-level variance
    % socDat = data.Eyetrack(strcmp(data.Category,'social'));
    % mecDat = data.Eyetrack(strcmp(data.Category, 'mechanical'));
    % [h,p,~,stats] = ttest2(socDat,mecDat);

    % Print results to screen
        hlist = {'Fail to reject', 'Reject'};
        fprintf("\n\n\n")
        fprintf("%d subjects were considered.\n", numSubs)
        fprintf("%s the null hypothesis.\n",hlist{h+1})
        F = tbl{ci+1,strcmp(tbl(1,:),'F')};
        df = tbl{ci+1,strcmp(tbl(1,:),'d.f.')};
        sse = tbl{ci+1,strcmp(tbl(1,:),'Sum Sq.')};
        fprintf('\tF(%i) = %0.2f\n', df, F)
        fprintf("\tp = %f\n",p1(ci))
        fprintf('\tSSE = %0.2f\n', sse)
        fprintf('\n')
end
plotItemwise(data, metricName, mwflag);