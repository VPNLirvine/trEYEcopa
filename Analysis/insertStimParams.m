function data = insertStimParams(data, stype)
% Given a stack of data from e.g. getTCData,
% insert a column with the stimulus parameters,
% i.e. video duration, motion energy, "social interactivity"

% Determine which parameters to load: MW or TC
if nargin < 2
    stype = detectStimType(data); % should be either 'TC' or 'MW'
end
% Determine whether we need to split each trial into 'quadrants'
if ismember('Quadrant', data.Properties.VariableNames)
    splitFlag = true;
    numQuads = max(data.Quadrant);
    itype = 'vec';
else
    splitFlag = false;
    numQuads = 1;
    itype = 'val';
end
pths = specifyPaths('..');
% Get the motion data
motfname = fullfile(pths.mot, append(stype, '_motionData.mat'));
if ~exist(motfname, 'file')
    % This exports to file, which should match fname.
    getMotionEnergy('eng', stype);
end
motion = importdata(motfname);
% Get the interactivity data
intScore = getInteractivity(stype, itype);

numVids = height(motion);
numRows = height(data);

% init new cols with nans, as a failsafe
data.Motion = nan(numRows, 1);
data.Duration = nan(numRows, 1);
data.Interactivity = nan(numRows, 1);

% Insert the stimulus parameters into the table
for v = 1:numVids
    vidName = motion.StimName{v};
    if splitFlag
        % Split all three parameters by the specified number of windows
        % This requires using the long form of interactivity
        intSub = strcmp(intScore.StimName, vidName);
        quadrants = round(length(motion.MotionEnergy{v}) * (0:numQuads)/numQuads);
        duration = motion.Duration{v} / numQuads;
        for j = 1:numQuads
            % Identify the indices for this quadrant
            sttime = quadrants(j)+1;
            entime = quadrants(j+1);
            % Get the motion subset
            motVec = motion.MotionEnergy{v}(sttime:entime);
            % Get the interactivity subset
            % intVec = intScore.Interactivity{intSub}(intsttime:intentime);
            intVec = intScore.Interactivity{intSub}(sttime:entime);
            % Insert values
            subset = strcmp(data.StimName, vidName) & data.Quadrant == j;
            data.Interactivity(subset) = sum(intVec) / length(intVec);
            data.Motion(subset) = sum(motVec) / duration;
            data.Duration(subset) = duration;
        end
    else
        % Fill each row normally
        subset = strcmp(data.StimName, vidName);
        data.Motion(subset) = sum(motion.MotionEnergy{v}) / motion.Duration{v};
        data.Duration(subset) = motion.Duration{v};
        if ~ismember(vidName, intScore.StimName)
            % This is expected if we're filling Martin & Weisberg data,
            % as interactivity was only calculated for Social videos.
            % Anything we skip here falls back to NaN.
            continue
        else
            % Don't trust that interactivity is in the same order as motion
            intSub = strcmp(intScore.StimName, vidName);
            data.Interactivity(subset) = intScore.Interactivity(intSub);
        end
    end
end
