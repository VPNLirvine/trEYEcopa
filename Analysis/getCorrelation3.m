function data = getCorrelation3(data, metricName)
% Given a stack of data from e.g. getTCData,
% insert the interactivity score of each video, and get a correlation.

% A correlation is only appropriate for getting a main effect
% because many subjects watch each video,
% but there is only one interactivity value per video.
% If you want to see whether individual subjects are more sensitive to interactivity than others,
% you may be better off doing a regression that stratifies by subject,
% or maybe correlating the average correlation per subject with AQ.
% But the point of this function is just to see if interactivity is 
% interfering with the DV at all.

subList = unique(data.Subject);
numSubs = length(subList);

stype = detectStimType(data); % should be either 'TC' or 'MW'
pths = specifyPaths('..');
if strcmp(stype, 'TC')
    fname = fullfile(pths.int, 'TC_interactData.mat');
elseif strcmp(stype, 'MW')
    fname = fullfile(pths.int, 'MW_interactData.mat');
end

% Get the interactivity score data
if ~exist(fname, 'file')
    intScore = interactivity(stype);
    save(fname, 'intScore');
else
    intScore = importdata(fname);
end
numVids = height(intScore);

% Insert the interactivity scores into the main data table
for v = 1:numVids
    vidName = intScore.StimName{v};
    subset = strcmp(data.StimName, vidName);
    data.Interactivity(subset) = intScore.Interactivity(v);

    % Also extract the average Eyetrack value for this video, for later
    avgE(v,1) = mean(data.Eyetrack(subset));
    intr(v,1) = intScore.Interactivity(v);
    if ~strcmp(stype, 'MW')
        rat(v,1) = mean(data.Response(subset));
    end
end

% Loop over subject to calculate independent correlation coefficients
output = [];
% p = [];
% for s = 1:numSubs
%     subID = subList{s};
%     subset = strcmp(data.Subject, subID);
%     [output(s,1), p(s,1)] = corr(data.Eyetrack(subset), data.Interactivity(subset), 'Type', 'Pearson', 'rows', 'complete');
%     [output(s,2), p(s,2)] = corr(data.Eyetrack(subset), data.Interactivity(subset), 'Type', 'Spearman', 'rows', 'complete');
% end

% Get the names of what you're correlating
var1 = getGraphLabel(metricName);
var2 = 'Social Interactivity Level';
var3 = getGraphLabel('response');

% Analyze the distribution of correlation scores
% mu = mean(output(:,2));
% sigma = std(output(:,2));
[output(1,1), pval1] = corr(avgE, intr, 'type', 'Pearson');
[output(1,2), pval2] = corr(avgE, intr, 'type', 'Spearman');
if ~strcmp(stype, 'MW')
    [output(1,3), pval3] = corr(rat, intr, 'type', 'Spearman');
end

% Calculate p values by performing a t-test against 0
% Use atanh() as a Fischer r-to-z transform 
% [~,pval1] = ttest(atanh(output(:,1))); % Pearson
% [~,pval2] = ttest(atanh(output(:,2))); % Spearman

fprintf(1, '\n\nRESULTS:\n');
fprintf(1, 'Correlation between average %s and %s:\n', var1, var2);
fprintf(1, '\tSpearman''s \x03C1 = %0.2f , p = %0.3f\n', output(1,2), pval2);
fprintf(1, '\tPearson''s r = %0.2f , p = %0.3f\n', output(1,1), pval1);
fprintf(1, 'Percent variance explained by this relationship:\n');
fprintf(1, '\tr%c = %0.2f%%\n', 178, 100*(output(:,2) .^2));
if ~strcmp(stype, 'MW')
    fprintf(1, 'Correlation between average %s and %s:\n', var3, var2);
    fprintf(1, '\tSpearman''s \x03C1 = %0.2f , p = %0.3f\n', output(1,3), pval3);
end
fprintf(1, '\n');

% Plots
figure();
    % Raw scatterplot
    % Correlation is expected to be low due to between-subject variance
    [c1, p1] = corr(data.Eyetrack, data.Interactivity);
    scatter(data.Interactivity, data.Eyetrack);
    xlabel(var2); ylabel(var1);
    title(sprintf('Correlation = %0.2f, p = %0.4f', c1, p1));

figure();
    % Scatterplot of averaged data
    % Throws away subject-level variance to evaluate by stimulus
    [c2, p2] = corr(intr, avgE);
    scatter(intr, avgE);
    xlabel(var2);
    ylabel(sprintf('%s, averaged across subjects', var1));
    title(sprintf('Correlation = %0.2f, p = %0.4f', c2, p2));

if ~strcmp(stype, 'MW')
    figure();
        % Scatterplot of rating data
        scatter(intr, rat);
        xlabel(var2);
        ylabel(sprintf('%s, averaged across subjects', var3));
        title(sprintf('\x03C1 = %0.2f, p = %0.4f', output(1,3), pval3));
end
