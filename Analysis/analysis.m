function varargout = analysis(varargin)
% Perform statistical analysis on eyetracking data
% Optional input 1 should be a metric name listed in selectMetric()
close all;
if nargin > 0
    metricName = varargin{1};
else
    % By default, use percent time spent fixating
    metricName = 'scaledfixation';
end
dflag = false;
if nargin > 1
    data = varargin{2};
    dflag = true;
end

% The exact test depends on which stimulus set we're looking at
% So force a choice:
choice = menu('Which data do you want to analyze?','TriCOPA','Martin & Weisberg');

if choice == 1
    % TriCOPA
    fprintf(1, 'Using metric %s\n\n', metricName);
    if strcmp(metricName, 'ISC')
        if ~dflag; data = doISC(getTCData('heatmap')); end
        fprintf(1, 'Mean ISC = %0.2f%%\n', 100 * mean(data.Eyetrack));
        fprintf(1, 'Median ISC = %0.2f%%\n', 100 * median(data.Eyetrack));
    elseif strcmp(metricName, 'coherence')
        if ~dflag; [~, data] = doGazePath(getTCData('gaze')); end
        % Compress the timecourse down to a single number
        for i = 1:height(data)
            data.Eyetrack{i} = mean(data.Eyetrack{i}(1,:), 'omitnan');
        end
        % Now that they're not vectors, turn the column into a single mat
        data.Eyetrack = cell2mat(data.Eyetrack);
    else
        if ~dflag; data = getTCData(metricName); end
    end

    mwflag = 0;
elseif choice == 2
    % Martin & Weisberg
    if strcmp(metricName, 'ISC')
        if ~dflag; data = doISC(getMWData('heatmap')); end
        fprintf(1, 'Mean ISC = %0.2f%%\n', 100 * mean(data.Eyetrack));
        fprintf(1, 'Median ISC = %0.2f%%\n', 100 * median(data.Eyetrack));
    else
        if ~dflag; data = getMWData(metricName); end
    end
    mwflag = 1;
    choice = menu('Which analysis method do you want for this Martin & Weisberg data?','correlation', 't-test');
end

% Establish some common variables before diverging analysis paths
subList = unique(data.Subject);
numSubs = size(subList, 1);
aqTable = getAQ(specifyPaths('..')); % Get the AQ scores from Qualtrics
    % Ensure you have an AQ score for every subject
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

% Calculate and report any correlations between the AQ subscales
% They're supposed to be orthogonal, so all should be < 0.3
% Social Skills vs Communication
[c1, p1] = corr(aqTable.SocialSkills, aqTable.Communication);
% Social Skills vs Attention to Detail
[c2, p2] = corr(aqTable.SocialSkills, aqTable.AttentionDetail);
% Communication vs Attention to Detail
[c3, p3] = corr(aqTable.Communication, aqTable.AttentionDetail);
fprintf(1, '\n\nAQ Subscale validation:\n')
fprintf(1, 'Social Skills vs Communication: r = %0.2f, p = %0.4f\n', c1, p1);
fprintf(1, 'Social Skills vs Attention to Detail: r = %0.2f, p = %0.4f\n', c2, p2);
fprintf(1, 'Communication vs Attention to Detail: r = %0.2f, p = %0.4f\n', c3, p3);
fprintf(1, '\n');

% Pick which kind of analysis to run
if choice == 1 % Correlation analysis

    %
    % Compare the eyetracking data to the behavioral data
    %

    % Do not run a linear regression for predicting gaze from response
    % because the response measure is technically a DV, not an IV.
    % Do a correlation instead.
    % Calculate individually per subject to make it RFX.
    % mdl = fitlm(data, 'Eyetrack ~ Response');

    % Subset data to the videos most impacted by AQ
    if ~exist('sigVids.mat')
        % This function ought to generate this file
        rankAQperVid(insertAQ(data));
    end
    sigVidNames = importdata('sigVids.mat');
    data = data(ismember(data.StimName, sigVidNames), :);
 
    
    % Get axis labels for later
    [var1, yl, distTxt] = getGraphLabel(metricName);
    [var2, yl2, distTxt2] = getGraphLabel('response');
    
    % Get the average gaze metric per subject, to correlate with AQ
    % (since there's only one AQ score per subject)
    eyeCol = zeros([numSubs, 1]); % preallocate as column
    for s = 1:numSubs
        subID = subList{s};
        subset = strcmp(subID, data.Subject);
        eyeCol(s) = mean(data.Eyetrack(subset), 'all', 'omitmissing');
    end
        

    if ~mwflag
        % Calculate correlations and generate some visualizations
        % None of these involve AQ, so do them before the upcoming loop
        eye2rating = getCorrelations(data, metricName); % gaze vs rating
        data = getCorrelation2(data, metricName); % gaze vs motion
        data = getCorrelation3(data, metricName); % gaze vs interactivity

        % Get the average video rating per subject (not collected for MW)
        respCol = zeros([numSubs, 1]); % preallocate as column
        for s = 1:numSubs
            subID = subList{s};
            subset = strcmp(subID, data.Subject);
            respCol(s) = mean(data.Response(subset), 'all', 'omitmissing');
        end

    end
    for a = 1:3 % AQ subscales
        % Loop over the three AQ subscales
        % Ensure they're sorted the same as the other data
        aq = zeros([numSubs, 1]); % preallocate as column
        for s = 1:numSubs
            subID = subList{s};
            if a == 1
                aq(s) = aqTable.SocialSkills(strcmp(subID, aqTable.SubID));
                aqt = 'AQ1';
            elseif a == 2
                aq(s) = aqTable.Communication(strcmp(subID, aqTable.SubID));
                aqt = 'AQ2';
            elseif a == 3
                aq(s) = aqTable.AttentionDetail(strcmp(subID, aqTable.SubID));
                aqt = 'AQ3';
            end
        end
    
        % First, directly correlate the metric with AQ
        % i.e. do not correlate with the clarity rating
        % Reduce data to an average value per subject,
        % since there's only 1 AQ value per person
        [var3, yl3, distTxt3] = getGraphLabel(aqt);

        % Calculate correlations
        aq2eye = zeros([2,2]); % clear on each loop
        [aq2eye(1,1), aq2eye(1,2) ]= corr(aq, eyeCol, 'Type', 'Pearson', 'rows', 'complete');
        [aq2eye(2,1), aq2eye(2,2)] = corr(aq, eyeCol, 'Type', 'Spearman', 'rows', 'complete');
            
            % Plot
            figure();
            scatter(aq, eyeCol);
                title(sprintf('Across %i subjects, strength of relationship \x03C1 = %0.2f, p = %0.4f', numSubs, aq2eye(2,1), aq2eye(2,2)));
                xlabel(var3);
                ylabel(var1);
                ylim(yl);
                xlim(yl3);
                
            % Report the correlation score
            fprintf(1, '\n\nCorrelation between %s and average %s within subject:\n', var3, var1)
            fprintf(1, '\tSpearman''s \x03C1 = %0.2f, p = %0.4f\n', aq2eye(2,1), aq2eye(2,2));
            fprintf(1, '\tPearson''s r = %0.2f, p = %0.4f\n', aq2eye(1,1), aq2eye(1,2));
    
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
                xlim(yl3);
                % Add lines indicating the expected distribution(s)
                % overlayAQ(gca); % skip this 
        if ~mwflag
            % Report secondary correlation
            [aq2rating(1,1), aq2rating(1,2)] = corr(aq, respCol, 'Type', 'Spearman', 'rows', 'complete');
            [aq2rating(2,1), aq2rating(2,2)] = corr(aq, respCol, 'Type', 'Pearson', 'rows', 'complete');
            fprintf(1, '\n\nCorrelation between %s and average %s within subject:\n', var3, var2);
            fprintf(1, '\tSpearman''s \x03C1 = %0.2f, p = %0.4f\n', aq2rating(1,1), aq2rating(1,2));
            fprintf(1, '\tPearson''s r = %0.2f, p = %0.4f\n', aq2rating(2,1), aq2rating(2,2));

            % Plot that
            figure();
                scatter(aq, respCol);
                xlim(yl3);
                ylim(yl2);
                xlabel(var3);
                ylabel(['Average ', var2]);
                title(sprintf('Across %i subjects, \x03C1 = %0.2f, p = %0.4f', numSubs, aq2rating(1,1), aq2rating(1,2)));

            % Now Fischer z-transform your main correlation coefficients
            zCorr = zscore(eye2rating(:,2));
        
            % Plot and analyze relationship between AQ and current metric
            [secondCorr, secondP] = corr(aq, zCorr, 'Type', 'Spearman', 'rows', 'complete');
            figure();
                scatter(aq, zCorr, 'filled');
                xlabel(var3);
                ylabel('Z-Transformed Spearman correlation');
                title(sprintf('Impact of %s on %s''s relation with %s\n\x03C1 = %0.2f', var3, var1, var2, secondCorr));
                xlim(yl3);
        
            fprintf(1, 'Correlation between %s and (within-subject correlation between %s and %s):\n', var3, var1, var2)
            fprintf(1, '\t\x03C1 = %0.2f, p = %0.4f\n', secondCorr, secondP);
            
        end % if not MW data
    end % for each AQ subscale

    if ~mwflag % avoid doing this inside the loop over AQ subscales
        % Plot correlation of gaze and clarity, i.e. not considering AQ
        plotCorrelation(data, eye2rating, metricName);
        % Histograms of gaze and clarity
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
elseif choice == 2 % Do a mean comparison across groups
    
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
        F = tbl{ci+1,strcmp(tbl(1,:),'F')}; % +1 due to header
        df = tbl{ci+1,strcmp(tbl(1,:),'d.f.')};
        sse = tbl{ci+1,strcmp(tbl(1,:),'Sum Sq.')};
        fprintf('\tF(%i) = %0.2f\n', df, F)
        fprintf("\tp = %f\n",p1(ci))
        fprintf('\tSSE = %0.2f\n', sse)
        fprintf('\n')

    % Also see if AQ may be suppressing a difference in marginal means
    mwAQ(data, aqTable);
end
plotItemwise(data, metricName, mwflag);

% Export data matrix on request
if nargout > 0
    % Prepare for regression:
    % 1. Reset AQ to be Social Skills specifically,
    % since the other two subscales have a low effect
    for i = 1:height(aqTable)
        subID = aqTable.SubID{i};
        subset = strcmp(data.Subject, subID);
        data.AQ(subset) = aqTable.SocialSkills(i);
    end
    % 2. Convert strings to 'categorical' variables
    % data.Subject = categorical(data.Subject);
    % data.StimName = categorical(data.StimName);
    % if mwflag
    %     data.Category = categorical(data.Category);
    % end
    varargout{1} = data;
end