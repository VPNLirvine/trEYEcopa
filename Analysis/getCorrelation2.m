function data = getCorrelation2(data, metricName)
% Given a stack of data from e.g. getTCData,
% calculate the correlation with the motion energy of each video.

% A correlation is inappropriate because many subjects watch each video,
% but there is only one motion value per video.
% You're better off doing some sort of regression that factors in subject,
% or maybe reporting the average correlation per subject like before.

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
end

% Loop over subject to calculate independent correlation coefficients
output = [];
for s = 1:numSubs
    subID = subList{s};
    subset = strcmp(data.Subject, subID);
    output(s,1) = corr(data.Eyetrack(subset), data.Motion(subset), 'Type', 'Pearson', 'rows', 'complete');
    output(s,2) = corr(data.Eyetrack(subset), data.Motion(subset), 'Type', 'Spearman', 'rows', 'complete');
end

% Get the names of what you're correlating
var1 = getGraphLabel(metricName);
var2 = 'Video motion energy';

% Analyze the distribution of correlation scores
mu = mean(output(:,2));
sigma = std(output(:,2));

% Calculate p values by performing a t-test against 0
% Use atanh() as a Fischer r-to-z transform 
[~,pval1] = ttest(atanh(output(:,1))); % Pearson
[~,pval2] = ttest(atanh(output(:,2))); % Spearman

fprintf(1, '\n\nRESULTS:\n');
fprintf(1, 'Average correlation between %s and %s:\n', var1, var2);
fprintf(1, '\tSpearman''s \x0304\x03C1 = %0.2f (SD = %0.2f), p = %0.3f\n', mu, sigma, pval2);
fprintf(1, '\tPearson''s \x0304r = %0.2f (SD = %0.2f), p = %0.3f\n', mean(output(:,1)), std(output(:,1)), pval1);
fprintf(1, 'Average subject-level percent variance explained by this relationship:\n');
fprintf(1, '\tr%c = %0.2f%%\n', 178, 100*mean(output(:,2) .^2));
fprintf(1, '\n');

% Plots
figure();
    % Grouped scatterplot - separates by subject
    % Admittedly hard to read when there's 30 subjects
    gscatter(data.Motion, data.Eyetrack, data.Subject);
    xlabel(var2); ylabel(var1);
    title(sprintf('Average correlation = %0.2f', mu));

figure();
    % Raw scatterplot
    % Correlation is expected to be low due to between-subject variance
    [c1, p1] = corr(data.Eyetrack, data.Motion);
    scatter(data.Motion, data.Eyetrack);
    xlabel(var2); ylabel(var1);
    title(sprintf('Correlation = %0.2f, p = %0.4f', c1, p1));

figure();
    % Scatterplot of averaged data
    % Artificially increases correlation by throwing away variance
    [c2, p2] = corr(mot, avgE);
    scatter(mot, avgE);
    xlabel(var2);
    ylabel(sprintf('%s, averaged across subjects', var1));
    title(sprintf('Correlation = %0.2f, p = %0.4f', c2, p2));

% Try regression instead?
% mdl = fitlme(data, 'Eyetrack ~ Motion + (1 | Subject)')