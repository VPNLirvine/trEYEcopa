function output = getAvgDeviance()
% Deviance is a measure of how far any subject deviates from prediction.
% Here, we're averaging across subjects, preserving the time dimension,
% in order to get a group-average (or "expected") deviance vector.
% (...which is sort of ironic: you've got a stimulus-derived prediction,
% but then also a behavior-derived predicted deviance from the prediction)

% Get all subs all trials, downsampled from 250Hz to 60Hz
dat = getTCData('deviance2');

% Get a template for the output format
template = importdata('rateData.mat');
numStims = height(template);

% For each stim, average each timepoint across subjects
for i = 1:numStims
    stimName = template.StimName{i};
    subset = strcmp(stimName, dat.StimName);
    tmp1 = dat.Eyetrack(subset);
    tmpDat = cell2mat(tmp1);
    Deviance{i} = mean(tmpDat, 1);
end

% Write to output file
output.StimName = template.StimName;
output.Deviance = Deviance';