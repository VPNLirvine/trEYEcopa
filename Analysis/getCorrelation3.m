function data = getCorrelation3(data, metricName)
% Given a stack of data from e.g. getTCData,
% insert the interactivity score of each video, and get a correlation.

% A correlation is inappropriate because many subjects watch each video,
% but there is only one interactivity value per video.
% You may be better off doing a regression that stratifies by subject,
% or maybe reporting the average correlation per subject like before.

subList = unique(data.Subject);
numSubs = length(subList);
% Get the interactivity score data
fname = 'interactData.mat';
if ~exist(fname, 'file')
    intScore = interactivity();
    save('interactData.mat', 'intScore');
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
end

% Loop over subject to calculate independent correlation coefficients
output = [];
p = [];
for s = 1:numSubs
    subID = subList{s};
    subset = strcmp(data.Subject, subID);
    [output(s,1), p(s,1)] = corr(data.Eyetrack(subset), data.Interactivity(subset), 'Type', 'Pearson', 'rows', 'complete');
    [output(s,2), p(s,2)] = corr(data.Eyetrack(subset), data.Interactivity(subset), 'Type', 'Spearman', 'rows', 'complete');
end

% Get the names of what you're correlating
var1 = getGraphLabel(metricName);
var2 = 'Social Interactivity Level';

% Analyze the distribution of correlation scores
mu = mean(output(:,2));
sigma = std(output(:,2));

fprintf(1, '\n\nRESULTS:\n');
fprintf(1, 'Average correlation between %s and %s:\n', var1, var2);
fprintf(1, '\tSpearman''s \x0304\x03C1 = %0.2f (SD = %0.2f)\n', mu, sigma);
fprintf(1, '\tPearson''s \x0304r = %0.2f (SD = %0.2f)\n', mean(output(:,1)), std(output(:,1)));
fprintf(1, 'Average subject-level percent variance explained by this relationship:\n');
fprintf(1, '\tr%c = %0.2f%%\n', 178, 100*mean(output(:,2) .^2));
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

% Try regression instead?
% mdl = fitlme(data, 'Eyetrack ~ Interactivity + (1 | Subject)')