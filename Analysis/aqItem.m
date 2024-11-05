function tbl = aqItem(data)
% Do an item analysis on the AQ data:
% Given a table of data with some Eyetracking metric, e.g. time on target,
% determine which items (i.e. videos) are discriminative of AQ.
% That is, correlate AQ with Eye, split by video, then see what's high.

vidList = unique(data.StimName);
numVids = height(vidList);

tbl = table('Size', [0,2], 'VariableNames', {'StimName', 'dFactor'}, 'VariableTypes', {'string', 'double'});

for v = 1:numVids
    vidName = vidList{v};
    subset = strcmp(data.StimName, vidName);
    dv = data.Eyetrack(subset);
    aq = data.AQ(subset);
    
    % Fill table
    tbl(v,:) = {vidName, corr(dv, aq, 'Type', 'Spearman')};
    
end