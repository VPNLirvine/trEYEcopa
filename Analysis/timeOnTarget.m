% This is to be a case inside selectMetric,
% which means it should operate on a SINGLE ROW of an EDF file
% (i.e. one trial of one subject)
% So we DON'T want to load in frames or positions of anything extraneous

% ...so ask for them as input!
%% SCRATCHPAD - find out what the inputs should be

% The edf data that goes into a given call of selectMetric
trialNum = 5; % say
edf = osfImport('TC_19.edf');
edfDat = edf(trialNum);

    % We can extract the stim name from that
    % ...but it may have a path attached that we should remove
    stimName = getStimName(edfDat);

% The 'window' vector defining the location of the video on screen
pos = [xLeft xRight yTop yBottom];
% Get the position data while rescaling it to fit the display area
% Be mindful this imports all position data first, then subsets,
% so you're wasting compute if you do this inside a loop.
% ...which means I need to re-tool this function
posDat = resizePosition(stimName, pos);

% So now the position data follows the frames of the video,
% but the gaze data operates at its own sampling rate.
% Synchronize the two:

%% SYNCHRONIZE GAZE AND POSITION
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

% Search the Events struct to find messages defining frame changes
% Use those indices to extract the timestamps of frame updates
% Use those timestamps to compare to Sample timestamps
% Apply a label to each Sample describing which frame was displayed
% ...unless that's existing data??


%% COMPARE GAZE AND POSITION
% Define a radius around each character 