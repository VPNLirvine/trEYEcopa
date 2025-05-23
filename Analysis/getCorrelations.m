function output = getCorrelations(data, metricName)
% Given a stack of data from e.g. getTCData,
% calculate the correlation with the clarity rating.

subList = unique(data.Subject);
numSubs = length(subList);
for s = 1:numSubs
    subID = subList{s};
    subset = strcmp(subID, data.Subject);
    output(s, 1) = corr(data.Response(subset), data.Eyetrack(subset), 'Type', 'Pearson', 'rows', 'complete');
    output(s,2) = corr(data.Response(subset), data.Eyetrack(subset), 'Type', 'Spearman', 'rows', 'complete');
end

% Also look at the overall correlation, since these are both DVs
[c1, p1] = corr(data.Response, data.Eyetrack, 'type', 'Spearman', 'rows', 'complete');

% Get the names of what you're correlating
var1 = getGraphLabel(metricName);
var2 = 'Understandability rating';

% Analyze the distribution of correlation scores
mu = mean(output(:,2));
sigma = std(output(:,2));

% Calculate p values by performing a t-test against 0
% Use atanh() as a Fischer r-to-z transform 
[~,pval1] = ttest(atanh(output(:,1))); % Pearson
[~,pval2] = ttest(atanh(output(:,2))); % Spearman

fprintf(1, '\n\nRESULTS:\n');
fprintf(1, 'Overall correlation between %s and %s:\n', var1, var2);
fprintf(1, '\tSpearman''s \x03C1 = %0.2f , p = %0.3f\n', c1, p1);
fprintf(1, 'Average correlation between %s and %s:\n', var1, var2);
fprintf(1, '\tSpearman''s \x0304\x03C1 = %0.2f (SD = %0.2f), p = %0.3f\n', mu, sigma, pval2);
fprintf(1, '\tPearson''s \x0304r = %0.2f (SD = %0.2f), p = %0.3f\n', mean(output(:,1)), std(output(:,1)), pval1);
fprintf(1, 'Average subject-level percent variance explained by this relationship:\n');
fprintf(1, '\tr%c = %0.2f%%\n', 178, 100*mean(output(:,2) .^2));
fprintf(1, '\n');

% Give the distribution of coefficients
figure();
histogram(output(:,2), -1:.1:1); % plot the Spearman ones by default
xlabel(sprintf('Spearman''s \x03C1'));
xlim([-1 1]);
title(sprintf('Coefficients for %s : %s', var1, var2));