function predGaze = motionDeviation(gaze, stimName)
% This follows the same basic concept as "time on target",
% in that we're comparing a subject's gaze path to a stimulus-derived path,
% but here we're comparing to a single predicted scanpath, not many.

%% EXTRACT DATA TO BE COMPARED
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
% Row 4 of gaze is the frame number. Use that to index out of posDat.
predGaze(1,:) = posDat(1,gaze(4,:));
predGaze(2,:) = posDat(2,gaze(4,:));

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