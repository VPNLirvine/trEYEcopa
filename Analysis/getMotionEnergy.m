function motion = getMotionEnergy(varargin)
% Point this function at a stimulus folder
% Loop over every file in the folder
% Calculate motion energy vectors, then store them as a .mat

if nargin > 0
    mtype = varargin{1};
    assert(ischar(mtype), 'Input must be either ''loc'', ''map'', or ''eng''');
    assert(any(strcmp(mtype, {'loc', 'eng', 'map'})), 'Input must be either ''loc'', ''map'', or ''eng''');
else
    mtype = 'eng';
end

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
    motionVec = findMotionEnergy(fname, mtype);
    if strcmp(mtype, 'map')
        % Save each map as an individual file,
        % since they are each several GB uncompressed
        % Requires an argument specifying a newer format (c. R2006b)
        fout = strrep(stimName, '.mov', '.mat');
        save(fullfile(pths.map, fout), 'motionVec', '-v7.3');
    else
        motion.StimName{s} = stimName;
        motion.MotionEnergy{s} = motionVec;
        motion.Duration{s} = getVideoDuration(fname);
    end

end
fprintf(1, 'Done.\n');

% Save to disk, since this takes ~45 minutes to calculate
if strcmp(mtype, 'eng')
    save('motionData.mat', 'motion');
elseif strcmp(mtype, 'loc')
    save('motionLocation.mat', 'motion'); 
end
