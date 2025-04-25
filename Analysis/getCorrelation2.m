function data = getCorrelation2(data, metricName)
% Given a stack of data from e.g. getTCData,
% calculate the correlation with the motion energy of each video.

% Since there's one motion value per video, but multiple subjects,
% you need to average the data somewhere.
% The most appropriate method is to get the average DV per VIDEO,
% then correlate that with motion.
% We don't care about within-subject correlations:
% why would we care if sub1 has r = .9 but sub2 has r = .2?
% It's not about how sensitive each sub is to motion, but rather
% whether the DV is sensitive to motion. Is motion a confound?

subList = unique(data.Subject);
numSubs = length(subList);
% Get the motion data
fname = 'motionData.mat';
if ~exist(fname, 'file')
    getMotionEnergy();
end
motion = importdata(fname);
numVids = height(motion);

% Insert the motion energy values into the table
for v = 1:numVids
    vidName = motion.StimName{v};
    subset = strcmp(data.StimName, vidName);
    data.Motion(subset) = sum(motion.MotionEnergy{v});
    data.Duration(subset) = motion.Duration{v};

    % Also extract the average Eyetrack value for this video, for later
    avgE(v,1) = mean(data.Eyetrack(subset));
    mot(v,1) = sum(motion.MotionEnergy{v});
    rat(v,1) = mean(data.Response(subset));
end

% Loop over subject to calculate independent correlation coefficients
output = [];
% for s = 1:numSubs
%     subID = subList{s};
%     subset = strcmp(data.Subject, subID);
%     output(s,1) = corr(data.Eyetrack(subset), data.Motion(subset), 'Type', 'Pearson', 'rows', 'complete');
%     output(s,2) = corr(data.Eyetrack(subset), data.Motion(subset), 'Type', 'Spearman', 'rows', 'complete');
% end

% Get the names of what you're correlating
var1 = getGraphLabel(metricName);
var2 = 'Video motion energy';
var3 = getGraphLabel('response');

[output(1,1), pval1] = corr(avgE, mot, 'type', 'Pearson');
[output(1,2), pval2] = corr(avgE, mot, 'type', 'Spearman');
[output(1,3), pval3] = corr(rat, mot, 'type', 'Spearman');

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
fprintf(1, 'Correlation between average %s and %s:\n', var3, var2);
fprintf(1, '\tSpearman''s \x03C1 = %0.2f , p = %0.3f\n', output(1,3), pval3);
fprintf(1, '\n');

% Plots
% figure();
%     % Grouped scatterplot - separates by subject
%     % Admittedly hard to read when there's 30 subjects
%     gscatter(data.Motion, data.Eyetrack, data.Subject);
%     xlabel(var2); ylabel(var1);
%     title(sprintf('Average correlation = %0.2f', mu));

figure();
    % Raw scatterplot
    % Correlation is expected to be low due to between-subject variance
    [c1, p1] = corr(data.Eyetrack, data.Motion);
    scatter(data.Motion, data.Eyetrack);
    xlabel(var2); ylabel(var1);
    title(sprintf('r = %0.2f, p = %0.4f', c1, p1));

figure();
    % Scatterplot of averaged data
    % [c2, p2] = corr(mot, avgE); % already done
    scatter(mot, avgE);
    xlabel(var2);
    ylabel(sprintf('%s, averaged across subjects', var1));
    title(sprintf('r = %0.2f, p = %0.4f', output(1,1), pval1));

figure();
    % Scatterplot of rating data
    scatter(mot, rat);
    xlabel(var2);
    ylabel(sprintf('%s, averaged across subjects', var3));
    title(sprintf('\x03C1 = %0.2f, p = %0.4f', output(1,3), pval3));
