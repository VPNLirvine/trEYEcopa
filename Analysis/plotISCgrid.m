function plotISCgrid(isc)
% Visualize ISC values in a grid (subject by stimulus)
% Requires preallocating since not every subj did every video
% Expected input is the standard data table for ISC values
% Will fetch that data if no input is given

% Get data and dimensions
if nargin < 1
    isc = analysis('ISC'); close all;
end

subList = unique(isc.Subject);
stimList = unique(isc.StimName);
numSubs = length(subList);
numStims = length(stimList);

% Organize into a matrix
output = nan(numSubs, numStims);
for sub = 1:numSubs
    subID = subList{sub};
    for stim = 1:numStims
        stimID = stimList{stim};
        c = strcmp(isc.Subject, subID) & strcmp(isc.StimName, stimID);
        if ~c
            continue
        else
            output(sub, stim) = isc.Eyetrack(c);
        end
    end
end

% Sort two different ways
subMean = mean(output, 2, 'omitnan');
stimMean = mean(output, 1, 'omitnan');
[~, subInds] = sort(subMean);
[~, stimInds] = sort(stimMean);

% Plot both ways
subVec = 1:numSubs;
stimVec = 1:numStims;

figure();
imagesc(output(subInds, :));
xlabel('Stimulus');
ylabel('Subject, sorted by mean ISC');
colorbar;
title('Intersubject correlations');
yticklabels(subVec(subInds));

figure();
imagesc(output(:, stimInds));
xlabel('Stimulus, sorted by mean ISC');
ylabel('Subject');
colorbar;
title('Intersubject correlations');
xticklabels(stimVec(stimInds));