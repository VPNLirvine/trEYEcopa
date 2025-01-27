function QC_PlotPrediction(stimID, eyeData)
% DEBUG findMotionEnergy
% Get a prediction for ONE video, then compare to actual subjects.
% From there, fine-tune parameters like low-pass cutoff.

if nargin < 2
    eyeData = getTCData('gaze');
end
stimList = unique(eyeData.StimName);

if nargin < 1
    stimID = 5; % pick a video to analyze
end
stimName = stimList{stimID};

subset = strcmp(eyeData.StimName, stimName);
datSubset = eyeData(subset, :);
numSubs = height(datSubset);

tic;
fprintf(1, 'Calculating predicted scanpath...');
prediction = findMotionEnergy(findVidPath(stimName), 'loc');
fprintf(1, 'Done.');
toc

figSize = ceil(sqrt(numSubs+1));
figure();
tl = tiledlayout(figSize, figSize);
nexttile;
plotGaze(prediction, 'Predicted scanpath');

tic;
fprintf(1, 'Plotting scanpath for %i subjects...', numSubs);
for i = 1:numSubs
    nexttile;
    subName = datSubset.Subject{i};
    gaze = datSubset.Eyetrack{i};
    plotGaze(gaze, strrep(subName, '_', '\_'));
end
fprintf(1, 'Done.');
toc

title(tl, strrep(stimName, '_', '\_'));