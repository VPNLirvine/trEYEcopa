function gaze = addframe2gaze(edfDat, i)
% Given a single row of EDF data (i.e. one trial),
% and the row index of the eye to use (determined by selectMetric),
% export the XY gaze path WITH the number of the video frame that was up

% First, extract gaze and interpolate over blinks
gx = censorBlinks(edfDat.Samples.gx(i,:), edfDat);
gy = censorBlinks(edfDat.Samples.gy(i,:), edfDat);

% Search the Events struct to find messages defining frame changes
list = edfDat.Events.message;
stxt = 'Frame to be displayed ';
y = cellfun(@(x) contains(x,stxt), list);
assert(sum(y) > 0, 'No message re frame timing found!');
% Get the frame numbers associated with each true element in y
frames = list(y);
frameNums = cellfun(@(x) str2double(erase(x,stxt)), frames);
% Use those indices to extract the timestamps of frame updates
frameTimes = edfDat.Events.sttime(y);
% Append the final frame's offset time, so you know when to stop
frameTimes(end+1) = findStimOffset(edfDat);
% Use those timestamps to compare to Sample timestamps
sampleTimes = edfDat.Samples.time;
stimOnset = findStimOnset(edfDat);
gaze = NaN([4,numel(edfDat.Samples.time)]); % init to a larger size than needed, then shrink later
c = 1;
for f = 1:numel(frameTimes) - 1
    % Which samples fit the bill?
    y3 = sampleTimes >= frameTimes(f) & sampleTimes < frameTimes(f+1);
    % How many are there?
    fend = sum(y3);
    npos = c+fend-1;
    % Get X
    gaze(1,c:npos) = gx(:,y3);
    % Get Y
    gaze(2,c:npos) = gy(:,y3);
    % Get timestamp
    gaze(3,c:npos) = sampleTimes(y3) - stimOnset;
    % Get frame number
    gaze(4, c:npos) = frameNums(f); % probably same as f
    % increment
    c = npos+1;
end
% Strip out the unused columns
gaze(:,isnan(gaze(1,:))) = [];
% Now we have every X and Y gaze coordinate during the video, plus frame #

end