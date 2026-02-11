function data = getCorrByCond(data, metricName)
% Requires data to have the following columns:
% Eyetrack, for the eyetracking data
% Category, to split by condition
% Motion, the total motion energy for that video
% We get the average eyetrack value per video (ie across subjects),
% then split by condition, and correlate with motion energy.

conds{1} = 'social';
conds{2} = 'mechanical';
inds{1} = strcmp(data.Category, conds{1});
inds{2} = strcmp(data.Category, conds{2});
fprintf(1, '\n');
for i = 1:length(inds)
    % One condition at a time
    subset = inds{i};
    dat = data(subset,:);
    vidList = unique(dat.StimName);
    avgE = zeros(length(vidList), 1);
    avgM = zeros(length(vidList), 1);
    % Get the average eyetrack value per video
    for v = 1:length(vidList)
        subset = strcmp(dat.StimName, vidList{v});
        avgE(v) = mean(dat.Eyetrack(subset));
        avgM(v) = mean(dat.Motion(subset)); % should all be equal tho
    end
    % Correlate gaze with motion within this category
    [r,p] = corr(avgM, avgE, 'Type', 'Spearman');
    var1 = getGraphLabel('motion');
    var2 = getGraphLabel(metricName);
    fprintf(1, 'Within %s condition, correlation between %s and average %s:\n', conds{i}, var1, var2);
    fprintf(1, '\tSpearman''s \x03C1 = %0.3f, p = %0.3f\n', r, p);
end