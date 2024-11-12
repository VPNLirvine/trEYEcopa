function tbl = aqItem(data)
% Do an item analysis on the AQ data:
% Given a table of data with some Eyetracking metric, e.g. time on target,
% determine which items (i.e. videos) are discriminative of AQ.
% That is, correlate AQ with Eye, split by video, then see what's high.

vidList = unique(data.StimName);
numVids = height(vidList);

tbl = table('Size', [0,3], 'VariableNames', {'StimName', 'dFactor', 'pValue'}, 'VariableTypes', {'string', 'double', 'double'});

for v = 1:numVids
    vidName = vidList{v};
    subset = strcmp(data.StimName, vidName);
    dv = data.Eyetrack(subset);
    aq = data.AQ(subset);
    [r, p] = corr(dv, aq, 'Type', 'Spearman');
    % Fill the entire table row at once
    tbl(v,:) = {vidName, r, p};
    
end

% Calculate significance
FDR = fdr_bh(tbl.pValue);
% Add to table
tbl.Sig = FDR(:);