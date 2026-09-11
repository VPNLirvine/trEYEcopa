function data = insertStimParams(data, stype, metricName)
% Given a stack of data from e.g. getTCData,
% insert a column with the stimulus parameters,
% i.e. video duration, motion energy, "social interactivity"

% Parse inputs
if nargin > 2
    splitFlag = strcmp(metricName, 'fixddt');
else
    splitFlag = false;
end

% Determine which parameters to load: MW or TC
if nargin < 2
    stype = detectStimType(data); % should be either 'TC' or 'MW'
end
pths = specifyPaths('..');
motfname = fullfile(pths.mot, append(stype, '_motionData.mat'));
intfname = fullfile(pths.int, append(stype, '_interactData.mat'));
% Get the motion data
if ~exist(motfname, 'file')
    % This exports to file, which should match fname.
    getMotionEnergy('eng', stype);
end
motion = importdata(motfname);
% Get the interactivity score data
if ~exist(intfname, 'file')
    intScore = interactivity(stype);
    save(intfname, 'intScore');
else
    intScore = importdata(intfname);
end

numVids = height(motion);
numIntVids = height(intScore);
numRows = height(data);

% init new cols with nans, as a failsafe
data.Motion = nan(numRows, 1);
data.Duration = nan(numRows, 1);
data.Interactivity = nan(numRows, 1);

% Insert the stimulus parameters into the table
for v = 1:numVids
    % Insert motion energy and duration from the same table
    vidName = motion.StimName{v};
    subset = strcmp(data.StimName, vidName);
    data.Motion(subset) = sum(motion.MotionEnergy{v}) / motion.Duration{v};
    data.Duration(subset) = motion.Duration{v};

    % Don't trust that interactivity is in the same order as motion
    if v > numIntVids
        % Interactivity table for MW dropped the mechanical videos.
        % (since we couldn't identify characters to calculate it from)
        % Since v is just a number, and vidName depends on the variable,
        % and we initialized each column with NaNs,
        % then any vids not in intScore will fall back to NaN if we skip.
        continue;
    else
        vidName = intScore.StimName{v};
        subset = strcmp(data.StimName, vidName);
        data.Interactivity(subset) = intScore.Interactivity(v);
    end
end

end