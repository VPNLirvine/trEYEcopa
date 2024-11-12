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

% Generate report
tally = sum(tbl.Sig);
if tally > 0
    fprintf(1, '\n%i videos meet significance after FDR adjustment:\n\n', tally)
    results = tbl(tbl.Sig, :);
    disp(results);
else
    fprintf(1, '\nNo videos survive FDR thresholding at q = 0.05\n\n');
end

end % function