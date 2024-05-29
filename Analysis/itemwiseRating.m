function itemwiseRating(data)
% Analyze distribution of ratings per video
% See if some videos are mostly 5s, mostly 1s, etc.
% SD is just as important as mean here.
% Input 1 is full data stack from e.g. getTCData()

stimList = unique(data.StimName);
numVids = length(stimList);
numSubs = length(unique(data.Subject));

% Orient column-wise
vidMeanRat = NaN([numSubs, numVids]);

for s = 1:numVids
    thisStim = stimList{s};
    thisDat = data.Response(strcmp(data.StimName, thisStim));
    vidMeanRat(1:length(thisDat), s) = thisDat;
end

% Plot

figure();
boxplot(vidMeanRat);
xticklabels(stimList);

ylim([0.9 5.1]);

% Get some descriptives
vidMeans = mean(vidMeanRat, 1, 'omitmissing');
vidSDs = std(vidMeanRat, 0, 1, 'omitmissing');

[vMaxMean, vMaxMeanI] = max(vidMeans);
[vMaxSD, vMaxSDI] = max(vidSDs);
[vMinMean, vMinMeanI] = min(vidMeans);
[vMinSD, vMinSDI] = min(vidSDs);

fprintf(1, '%s has the highest mean rating of %0.2f\n', stimList{vMaxMeanI}, vMaxMean);
fprintf(1, '%s has the highest rating SD of %0.2f\n', stimList{vMaxSDI}, vMaxSD);
fprintf(1, '%s has the lowest mean rating of %0.2f\n', stimList{vMinMeanI}, vMinMean);
fprintf(1, '%s has the lowest rating SD of %0.2f\n', stimList{vMinSDI}, vMinSD);

