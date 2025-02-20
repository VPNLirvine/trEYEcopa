% Generate a histogram of ISC values per video (across subjects)
% Intended to help identify consistently-interpreted videos,
% as a more sophisticated check than merely the average ISC

allData = analysis('ISC');
close all;
subList = unique(allData.StimName);
numSubs = length(subList);
fitSize = ceil(sqrt(numSubs));

figure();
tiledlayout(fitSize, fitSize);
for i = 1:numSubs
    nexttile;
    subID = subList{i};
    subset = strcmp(allData.StimName, subID);
    val = mean(allData.Eyetrack(subset));

    histogram(allData.Eyetrack(subset), 5);
    newSubID = strrep(subID, '_', '\_');
    title(sprintf('%s: mean ISC = %0.2f', newSubID, val));
    xlabel('ISC');
    ylim([0 20]);
    xlim([0 1]);
end
