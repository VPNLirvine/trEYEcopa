function output = timeOnTarget(edfDat, metricName, varargin)
% This is to be a case inside selectMetric,
% which means it should operate on a SINGLE ROW of an EDF file
% (i.e. one trial of one subject)
% So we DON'T want to load in frames or positions of anything extraneous

% Parse opts
split = false;
if nargin > 2 && ~isempty(varargin{:})
    opts = varargin{1};
    flipFlag = opts.flip;
    numWindows = opts.numWindows;
    if numWindows > 1, split = true; end
end

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
posDat = rescalePosition(posDat(1).Data, pos);
numChars = length(posDat);

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
gaze = selectMetric(edfDat, 'gaze', opts);

% Above will un-flip the gaze for flipped videos

% Row 4 is the frame number. Use that to index out of posDat.
p = struct;
for i = 1:numChars
    p(i).C = [ posDat(i).X(gaze(4,:)) ; posDat(i).Y(gaze(4,:)); gaze(3,:) ];
end

%% COMPARE GAZE AND POSITION
% Define a radius around each character
rad = 150; % 200 too big, 100 too small

% Define logicals to indicate whether gaze is near each character
for i = 1:numChars
    p(i).gazeOn = gaze(1,:) >= p(i).C(1,:) - rad & gaze(1,:) <= p(i).C(1,:) + rad & gaze(2,:) >= p(i).C(2,:) - rad & gaze(2,:) <= p(i).C(2,:) + rad;
end

% From here, you can do multiple things,
% like calculate the time spent on one specific character,
% or tally the total number of alternations between any characters,
% or 'triangle time' i.e. proportion of time on characters vs not,
% etc.

if strcmp(metricName, 'tot')
    % Triangle time: PERCENTAGE of time spent on the characters (but not door)
    % Stack all those gazeOn vectors into a matrix, then sum characters
    % Any non-zero element means gaze near at least one character then
    % Convert to a percentage
    gazeOn = zeros(numChars, length(p(1).gazeOn));
    for i = 1:numChars
        gazeOn(i,:) = p(i).gazeOn;
    end
    gazeOn(strcmp({posDat.Name}, 'door'),:) = []; % exclude the TriCOPA door
    onTarget = sum(gazeOn,1);
    % onTarget = gazeOnC1 + gazeOnC2 + gazeOnC4; % C3 is the door, so ignore

    if split
        output = zeros(numWindows, 2);
        quadrants = round(length(onTarget) * (0:numWindows)/numWindows);
        for i = 1:numWindows
            st = quadrants(i)+1;
            en = quadrants(i+1);
            output(i,1) = nnz(onTarget(st:en)) / length(onTarget(st:en));
            output(i,2) = i;
        end
    else
        output = nnz(onTarget) / length(onTarget);
    end
% elseif strcmp(metricName, 'track')
%     % Percentage of time on individual characters (including door)
%     % These may sum to >100% if gaze is near two characters at once
%     % ...not sure what all to do with this yet.
%     % Could compare to percentage of time each character is in motion?
%     timeOnC1 = nnz(gazeOnC1) / length(gazeOnC1); % big triangle
%     timeOnC2 = nnz(gazeOnC2) / length(gazeOnC2); % circle
%     timeOnC3 = nnz(gazeOnC3) / length(gazeOnC3); % door
%     timeOnC4 = nnz(gazeOnC4) / length(gazeOnC4); % small triangle
%     output = [timeOnC1, timeOnC2, timeOnC3, timeOnC4];
elseif strcmp(metricName, 'movert')
    % reaction time to first movement
    % Find the first character that moves,
    % compare gaze to the path of that character, 
    % find the first time they intersect AFTER the character has moved,
    % then report the latency.

    p(strcmp({posDat.Name}, 'door')) = []; % exclude the TriCOPA door
    % p(i).C(3,:) is timestamps
    % p(i).gazeOn(:) is boolean
    firstMotionInd = zeros(length(p), 1);
    
    for i = 1:length(p)
        % Find out when the character first moves
        initX = p(i).C(1,1);
        initY = p(i).C(2,1);
        motionX = find(p(i).C(1,:) ~= initX, 1);
        motionY = find(p(i).C(2,:) ~= initY, 1);
        temp = min([motionX, motionY]);
        % If the character never moved, this will be empty
        % Grab the maximum index instead
        if isempty(temp)
            firstMotionInd(i) = length(p(i).gazeOn);
        else
            firstMotionInd(i) = temp;
        end
    end
    % Which character moved first?
    firstCharInd = find(firstMotionInd == min(firstMotionInd), 1);
    firstMotionInd = firstMotionInd(firstCharInd);
    p = p(firstCharInd); % drop the other characters
    firstMotionTime = p.C(3, firstMotionInd);
    % Set all gazeOn values before that equal to 0
    p.gazeOn(1:firstMotionInd-1) = false;
    % extract the time gaze first meets the character
    earliestFixation = p.C(3, find(p.gazeOn, 1));
    % time between character motion and gaze meeting character
    % If character was never fixated, earliestFixation will be empty
    if isempty(earliestFixation) earliestFixation = inf; end
    output = earliestFixation - firstMotionTime;

else
    output = p; % output position data struct, i.e. NOT a summary metric.
end

% To visualize gaze against position, do this:
% plotGazeChars(p, gaze, gaze(4,:));
% title(replace(stimName, '_', '\_'));

end