function motion = getMotionEnergy()
% Point this function at a stimulus folder
% Loop over every file in the folder
% Calculate motion energy vectors, then store them as a .mat

pths = specifyPaths('..');
stimDir = fullfile(pths.TCstim, 'normal');
stimList = dir(fullfile(stimDir, '*.mov')); % ignore any CSVs in there
numStims = length(stimList);

motion = table('Size', [numStims, 2], 'VariableTypes', {'string', 'cell'}, 'VariableNames', {'StimName', 'MotionEnergy'}); % init

fprintf(1, 'Getting motion data for %i videos.\n', numStims)
for s = 1:numStims
    fprintf(1, '\t%i\n', s);
    stimName = stimList(s).name;
    fname = fullfile(stimDir, stimName);
    motionVec = findMotionEnergy(fname);

    motion.StimName{s} = stimName;
    motion.MotionEnergy{s} = motionVec;
    motion.Duration{s} = getVideoDuration(fname);
end
fprintf(1, 'Done.\n');

% Save to disk, since this takes ~45 minutes to calculate
save('motionData.mat', 'motion');
