function output = motionDeviation(edfDat, i, flipFlag)
% This follows the same basic concept as "time on target",
% in that we're comparing a subject's gaze path to a stimulus-derived path,
% but here we're comparing to a single predicted scanpath, not many.

%% EXTRACT DATA TO BE COMPARED
% We can extract the stim name from edfDat
% ...but it may have a path attached that we should remove
stimName = getStimName(edfDat);
[~,stimName] = fileparts(stimName);
if flipFlag
    % stimName = erase(stimName, 'f_');
    stimName = stimName(3:end); % erase leading 'f_', but keep later ones
end

if ~strcmp(stimName(4:end), '.mov')
    stimName = [stimName '.mov'];
end

% Find the 'window' vector defining the location of the video on screen
% Get from the screen dimensions and video size given in the EDF file:
% pos = [xLeft yTop xRight yBottom];
[~,wRect] = findStimSize(edfDat);

% Load the motion-predicted timecourses and pick the one for this video.
if ~exist("motionLocation.mat", 'file')
    motion = getMotionEnergy('loc');
else
    motion = importdata("motionLocation.mat");
end
subset = strcmp(motion.StimName, stimName);
posDat = motion.MotionEnergy{subset};
% This data has already been rescaled to the stim monitor size,
% and gaze was inherently sampled at the stim monitor size,
% so the two are spatially aligned, but still need to be temporally aligned.

%% SYNCHRONIZE GAZE AND POSITION
% Resample up to the frame rate of the eyetracking data
% e.g. if the video is at 60 fps but the eyetracker is at 250 Hz,
% then there are 250/60 gaze samples per video frame,
% which is non-integer 4.167
% so it's not as simple as just e.g. playing each frame twice
% Need to know what frame was up for each gaze sample,
% then resample the position data to follow that pattern.
gaze = addframe2gaze(edfDat, i);
% We also need to un-flip the gaze for flipped videos
if flipFlag
    gaze(1,:) = mirrorX(gaze(1,:), wRect(3));
end
% Row 4 is the frame number. Use that to index out of posDat.
newPos(1,:) = posDat(1,gaze(4,:));
newPos(2,:) = posDat(2,gaze(4,:));

%% COMPARE GAZE AND PREDICTION
deviance(1,:) = gaze(1,:) - newPos(1,:);
deviance(2,:) = gaze(2,:) - newPos(2,:);
deviance(3,:) = gaze(3,:);

% deviance is a matrix of XY coordinates. Reduce it to 1D distance:
% Use the Pythagorean theorem to calculate the length of each hypotenuse.
output = sqrt(deviance(1,:).^2 + deviance(2,:).^2);

%% TO VISUALIZE:
% figure();
% subplot(1,3,1)
% plotGaze(gaze, 'Gaze');
% subplot(1,3,2)
% plotGaze(posDat, 'Predicted');
% subplot(1,3,3)
% plotGaze(deviance, 'Deviance');
% xlim([-1920/2, 1920/2]);
% zlim([-1200/2, 1200/2]);

end