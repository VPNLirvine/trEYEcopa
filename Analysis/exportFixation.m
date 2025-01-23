%% Extract fixation data and export to file, for use with fMRI analysis
% Get the fixation data
sfix = getTCData('scaledfixation');

% Get an output template with all the stimulus names in numerical order
intScore = importdata('interactData.mat');

% Write the new values in to the output variable
fixations = intScore;
for i = 1:length(fixations.StimName)
    stim = fixations.StimName{i};
    subset = strcmp(sfix.StimName, stim);
    fixations.ScaledFixation(i) = mean(sfix.Eyetrack(subset));
end
fixations = removevars(fixations, {'Interactivity'});

% Export to file
save('fixationData.mat', 'fixations');