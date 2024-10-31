function [newGaze, posDat] = motionDeviation2(edfDat, i, flipFlag)
% MotionDeviation1 upsamples video frame data to the eyetracker's speed.
% This function downsamples eyetracking data to the video's speed.
% The output is then an edited gaze timecourse, and the predicted position.
% You're expected to compare the two outside this function.

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
% Resample the eyetracking data down to the video frame rate
% e.g. if the video is at 60 fps but the eyetracker is at 250 Hz,
% then there are 250/60 gaze samples per video frame,
% which is non-integer 4.167
% so it's not as simple as just e.g. averaging every other sample.
% Need to know what frame was up for each gaze sample,
% then only combine gaze data that shares a frame.
gaze = addframe2gaze(edfDat, i);
% We also need to un-flip the gaze for flipped videos
if flipFlag
    gaze(1,:) = mirrorX(gaze(1,:), wRect(3));
end
% Row 4 of gaze is the frame number. Use that to combine position values.
% maxFrame = max(gaze(:,4));
% for f = 1:maxFrame
%     x = gaze(4,:) == f; % which data uses this frame?
%     newGaze(1,f) = mean(gaze(1,x));
%     newGaze(2,f) = mean(gaze(2,x));
% end
% Try using fancy matrix-based function instead of a slow for loop
newGaze(1,:) = accumarray(gaze(4,:)', gaze(1,:)', [], @mean);
newGaze(2,:) = accumarray(gaze(4,:)', gaze(2,:)', [], @mean);

% Catch potential error (I guess if gaze cut off early?)
% Just fill to the end with the final know gaze position
if width(newGaze) < width(posDat)
    newGaze(1, width(newGaze):width(posDat)) = newGaze(1,end);
    newGaze(2, width(newGaze):width(posDat)) = newGaze(2,end);
end