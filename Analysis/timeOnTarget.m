% This is to be a case inside selectMetric,
% which means it should operate on a SINGLE ROW of an EDF file
% (i.e. one trial of one subject)
% So we DON'T want to load in frames or positions of anything extraneous

% ...so ask for them as input!
%% Comment this part out later
trialNum = 5; % say
edf = osfImport('TC_19.edf');
edfDat = edf(trialNum);




% Do the data import you do for frame3video
% Export the rescaling to a file somewhere
% Index out the data for THIS VIDEO, 

%% GET THE DATA YOU WANT
% Resample up to the frame rate of the eyetracking data
% e.g. if the video is at 60 fps but the eyetracker is at 250 Hz,
% then there are 250/60 gaze samples per video frame,
% which is non-integer 4.167
% AH EXCEPT the EDF file SHOULD have messages for frame number!

% edfDat.Events.message has the data
% 0 !V VFRAME fnum leftXPos topYPos filename
% this has the XY coordinates of the top left corner
% or just look for 'Frame to be displayed X' which comes immediately before
% Both are displayed immediately after the frame goes up


%% OPERATION
% So once you have gaze path and position data,

% segment the gaze based on frame number,

% then compare to the video-frame-rescaled position data