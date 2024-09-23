function output = timeOnTarget(edfDat, i, flipFlag, metricName)
% This is to be a case inside selectMetric,
% which means it should operate on a SINGLE ROW of an EDF file
% (i.e. one trial of one subject)
% So we DON'T want to load in frames or positions of anything extraneous
pths = specifyPaths('..');

% We can extract the stim name from edfDat
% ...but it may have a path attached that we should remove
stimName = getStimName(edfDat);
[~,stimName] = fileparts(stimName);
if flipFlag
    % stimName = erase(stimName, 'f_');
    stimName = stimName(3:end); % erase leading 'f_', but keep later ones
end

% Find the 'window' vector defining the location of the video on screen
% Get from the screen dimensions and video size given in the EDF file:
% pos = [xLeft yTop xRight yBottom];
[pos,wRect] = findStimSize(edfDat);

% Get the position data, then rescale it to fit the display area
posDat = getPosition(stimName);
posDat = interpPosition(posDat);
posDat = rescalePosition(posDat, pos);
posDat = postab2struct(posDat);

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
p.C1 = [ posDat(1).X(gaze(3,:)) ; posDat(1).Y(gaze(3,:)) ];
p.C2 = [ posDat(2).X(gaze(3,:)) ; posDat(2).Y(gaze(3,:)) ];
p.C3 = [ posDat(3).X(gaze(3,:)) ; posDat(3).Y(gaze(3,:)) ];
p.C4 = [ posDat(4).X(gaze(3,:)) ; posDat(4).Y(gaze(3,:)) ];

%% COMPARE GAZE AND POSITION
% Define a radius around each character
rad = 150; % 200 too big, 100 too small

% Define logicals to indicate whether gaze is near each character
gazeOnC1 = gaze(1,:) >= p.C1(1,:) - rad & gaze(1,:) <= p.C1(1,:) + rad & gaze(2,:) >= p.C1(2,:) - rad & gaze(2,:) <= p.C1(2,:) + rad;
gazeOnC2 = gaze(1,:) >= p.C2(1,:) - rad & gaze(1,:) <= p.C2(1,:) + rad & gaze(2,:) >= p.C2(2,:) - rad & gaze(2,:) <= p.C2(2,:) + rad;
gazeOnC3 = gaze(1,:) >= p.C3(1,:) - rad & gaze(1,:) <= p.C3(1,:) + rad & gaze(2,:) >= p.C3(2,:) - rad & gaze(2,:) <= p.C3(2,:) + rad;
gazeOnC4 = gaze(1,:) >= p.C4(1,:) - rad & gaze(1,:) <= p.C4(1,:) + rad & gaze(2,:) >= p.C4(2,:) - rad & gaze(2,:) <= p.C4(2,:) + rad;

% From here, you can do multiple things,
% like calculate the time spent on one specific character,
% or tally the total number of alternations between any characters,
% or 'triangle time' i.e. proportion of time on characters vs not,
% etc.

if strcmp(metricName, 'tot')
    % Triangle time: PERCENTAGE of time spent on the characters (but not door)
    onTarget = gazeOnC1 + gazeOnC2 + gazeOnC4; % C3 is the door, so ignore
    output = nnz(onTarget) / length(onTarget);
elseif strcmp(metricName, 'track')
    % Percentage of time on individual characters (including door)
    % These may sum to >100% if gaze is near two characters at once
    % ...not sure what all to do with this yet.
    % Could compare to percentage of time each character is in motion?
    timeOnC1 = nnz(gazeOnC1) / length(gazeOnC1); % big triangle
    timeOnC2 = nnz(gazeOnC2) / length(gazeOnC2); % circle
    timeOnC3 = nnz(gazeOnC3) / length(gazeOnC3); % door
    timeOnC4 = nnz(gazeOnC4) / length(gazeOnC4); % small triangle
    output = [timeOnC1, timeOnC2, timeOnC3, timeOnC4];
else
    output = p; % output position data struct, i.e. NOT a summary metric.
end

% To visualize gaze against position, do this:
% plotGazeChars(p, gaze, gaze(4,:));
% title(replace(stimName, '_', '\_'));

end