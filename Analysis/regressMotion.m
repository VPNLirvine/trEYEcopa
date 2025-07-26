function gazeDat = regressMotion(gazeDat, motion)
% OBJECTIVE:
% Regress out video motion from gaze timeseries
% Compare residuals across subjects to verify similarity
% Export as a predictor for fMRI analysis

% JUSTIFICATION:
% These are visually-simple videos with strong bottom-up effects on gaze.
% If you eliminate the stimulus-driven effects,
% you ought to be left with just the top-down cognitive influence.
% Now, whether the AMOUNT of motion alone is the ideal predictor...

pths = specifyPaths('..');
% Load data to compare, if not provided
if nargin < 1
    gazeDat = getTCData('gaze');
    stype = 'TC';
else
    % Determine which kind of gaze data was sent
    stype = gazeDat.Subject{1}(1:2);
end
if nargin < 2
    % If 2nd input (motion) not provided, load from disk
    % or calculate if not on disk already
    fin = fullfile(pths.mot, [stype, '_motionData.mat']);
    if exist(fin, 'file')
        motion = importdata(fin);
    else
        motion = getMotionEnergy('eng', stype);
    end
end

% Extract parameters
vidList = motion.StimName;
subList = unique(gazeDat.Subject);
numSubs = height(subList);
numVids = height(vidList);
% Loop through every row of the gaze data
for v = 1:numVids
    vidName = vidList{v};
    vidMotion = motion.MotionEnergy{strcmp(motion.StimName, vidName)};
    fprintf(1, 'Removing effect of motion from video %s...', vidName)
    for s = 1:numSubs
        subID = subList{s};
        % If this sub did not see this video, skip
        subset = strcmp(gazeDat.Subject, subID) & strcmp(gazeDat.StimName, vidName);
        if sum(subset) == 0
            continue
        end
        % otherwise:
        subgaze = gazeDat.Eyetrack{subset};
        X = subgaze(1,:)';
        Y = subgaze(2,:)';
        X = double(X); % convert from uint32
        Y = double(Y); % convert from uint32
        % Use frame numbers added by addframe2gaze to index motion data
        submotion = vidMotion(subgaze(4,:));
        % Regress out video motion from gaze
        t = table(X, Y, submotion); % make a table with the below variables
        mdl1 = fitlme(t, 'X ~ submotion');
        mdl2 = fitlme(t, 'Y ~ submotion');
        xresid = residuals(mdl1);
        yresid = residuals(mdl2);
        gazeDat.Eyetrack{subset} = [xresid'; yresid'; subgaze(4,:)]; % overwrite actual gaze
    end
    fprintf(1, 'Done.\n')
end
% Validate data across subjects
    % doISC(gazeDat)? or doGazePath(gazeDat)?

end % function