function output = addframe2gaze(gaze, edfDat, stimParams)
% Given a 3*n matrix of gaze data (X, Y, time)
% and a single row of EDF data (i.e. one trial),
% find the video frame indices associated with each gaze sample,
% and append them as a fourth row to the input gaze matrix.
tdat = gaze(3,:);
stimStart = findStimOnset(edfDat);
stimEnd = findStimOffset(edfDat);
% Search for frame change messages in Events struct
list = edfDat.Events.message;
stxt = 'Frame to be displayed ';
frameMsgs = cellfun(@(x) contains(x, stxt), list);

% Read the known stimulus parameters to aid synchronization
duration = getStimDuration(edfDat);
numFrames = stimParams.NumFrames;
FR = stimParams.FR;

if any(frameMsgs)
    % Extract frame numbers and times
    frames = list(frameMsgs);
    frameNums = cellfun(@(x) str2double(erase(x, stxt)), frames);
    frameTimes = double(edfDat.Events.sttime(frameMsgs));
    frameTimes(end + 1) = stimEnd;  % Append end of stimulus

    % Estimate the ideal frame timing based on sample rate
    % SR = 60/1000; % frames/msec
    fr = 1000/FR; % msec/frame
    ideal = floor(stimStart:fr:frameTimes(end-1));

    % Synchronize the expected frame timing to the measured frame updates
    likelyIdx = zeros(size(frameTimes));
    for i = 1:length(frameTimes)
        % The last frame in ideal whose time is before the current update
        % We're not going to draw a frame that isn't supposed to be up yet
        likelyIdx(i) = find(frameTimes(i) >= ideal, 1, 'last');
    end

    % Sometimes the video takes a second to stop running, even though it
    % already hit the final frame. PTB will keep flipping that final frame
    % until it realizes it's time to stop now. Account for that here.
    likelyIdx(likelyIdx > numFrames) = numFrames;

    % Initialize frame output
    frameCol = NaN(size(tdat));
    for f = 1:numel(frameNums)
        % Get indices for samples within the current frame period
        frameIdx = tdat >= (frameTimes(f) - stimStart) & tdat < (frameTimes(f + 1) - stimStart);
        frameCol(frameIdx) = likelyIdx(f);
    end

    % Account for situations where the first gaze sample is at time 0,
    % meaning it recorded EXACTLY at the moment the stimulus came on.
    % In that case, we'll say the first frame was on (not 'frame 0').
    if tdat(1) == 0
        frameCol(1) = 1;
    end

    % Append frame numbers to output
    output = [gaze; frameCol];
else
    error('No frame timing messages found in Events struct.');
end
end