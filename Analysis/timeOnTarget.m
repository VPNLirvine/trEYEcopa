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

% A flag for whether the video was flipped on this trial or not
% Comes as a varargin to selectMetric
flipFlag = true;

% selectMetric determines which eye to use
i = 2; % for now

    % We can extract the stim name from that
    % ...but it may have a path attached that we should remove
    stimName = getStimName(edfDat);

% The 'window' vector defining the location of the video on screen
% pos = [xLeft xRight yTop yBottom];
wRect = [0 0 1920 1200]; % the shape of the stim monitor
Movx = 674;
Movy = 504;
% Be aware that the videos we use in the experiment
% are a slightly different size than the ones I have locally:
% exp is 674 x 504, new is 676 x 506
% But since we USED the smaller ones, let's use those values here:
pos = resizeVideo(Movx, Movy, wRect);
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
% so it's not as simple as just e.g. playing each frame twice
% Need to know what frame was up for each gaze sample,
% then resample the position data to follow that pattern.
gaze = addframe2gaze(edfDat, i);
% We also need to un-flip the gaze for flipped videos
if flipFlag
    gaze(1,:) = mirrorX(gaze(1,:), wRect(3));
end
% Row 3 is the frame number. Use that to index out of posDat.
C1pos = [ posDat(1).X(gaze(3,:)) ; posDat(1).Y(gaze(3,:)) ];
C2pos = [ posDat(2).X(gaze(3,:)) ; posDat(2).Y(gaze(3,:)) ];
C3pos = [ posDat(3).X(gaze(3,:)) ; posDat(3).Y(gaze(3,:)) ];
C4pos = [ posDat(4).X(gaze(3,:)) ; posDat(4).Y(gaze(3,:)) ];

%% COMPARE GAZE AND POSITION
% Define a radius around each character
rad = 200; % for now - need to know character size on screen

% Define logicals to indicate whether gaze is near each character
gazeOnC1 = gaze(1,:) >= C1pos(1,:) - rad & gaze(1,:) <= C1pos(1,:) + rad & gaze(2,:) >= C1pos(2,:) - rad & gaze(2,:) <= C1pos(2,:) + rad;
gazeOnC2 = gaze(1,:) >= C2pos(1,:) - rad & gaze(1,:) <= C2pos(1,:) + rad & gaze(2,:) >= C2pos(2,:) - rad & gaze(2,:) <= C2pos(2,:) + rad;
gazeOnC3 = gaze(1,:) >= C3pos(1,:) - rad & gaze(1,:) <= C3pos(1,:) + rad & gaze(2,:) >= C3pos(2,:) - rad & gaze(2,:) <= C3pos(2,:) + rad;
gazeOnC4 = gaze(1,:) >= C4pos(1,:) - rad & gaze(1,:) <= C4pos(1,:) + rad & gaze(2,:) >= C4pos(2,:) - rad & gaze(2,:) <= C4pos(2,:) + rad;

% From here, you can do multiple things,
% like calculate the time spent on one specific character,
% or tally the total number of alternations between any characters,
% or 'triangle time' i.e. proportion of time on any character,
% etc.