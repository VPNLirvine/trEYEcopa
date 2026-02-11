function motionMap = motionDeviation(stimName)
% This follows the same basic concept as "time on target",
% in that we're comparing a subject's gaze path to stimulus-derived data,
% but here we're comparing to a heatmap of motion, which will:
% 1. include the door swinging open, and 
% 2. ignore times when no character is in motion.
% This is most closely equivalent to the "pursuit duration" metric 
% given by Roux, Passerieux, & Ramus (2013).

pths = specifyPaths('..');
[~,fname,~] = fileparts(stimName); % strip extension and replace with .mat
fname = [fname, '.mat'];
fpath = fullfile(pths.map, fname);

%% EXTRACT DATA TO BE COMPARED
if exist(fpath, 'file')
    % Load the motion-predicted timecourses and pick the one for this video.
    motionMap = importdata(fpath);
    % subset = strcmp(motion.StimName, stimName);
    % motionMap = motion.MotionEnergy{subset};
else
    % Detect the motion energy for this video
    fprintf(1, '\nDetecting motion energy for %s\n', stimName);
    fprintf(1, 'This data will not be saved; please run getMotionEnergy(''map'') to do so.\n\n')
    motionMap = findMotionEnergy(findVidPath(stimName), 'map');
end
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
% motionMap = posDat(:,:,gaze(4,:));

end