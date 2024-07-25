function output = findFrameNums(edfDat)
% Report the video frame number associated with each gaze sample
% Why this wasn't a built-in function...

% Step 1: get the timestamp associated with each frame onset
list1 = edfDat.Events.message;
list2 = edfDat.Events.sttime;
chktxt = 'Frame to be displayed ';
y = cellfun(@(x) contains(x, chktxt), list1);
assert(sum(y) > 0, 'No messages re frame numbers found!');
fMsgs = list1(y);
fTimes = list2(y);
for i = 1:sum(y)
    fnums(i,1) = str2double(erase(fMsgs{i}, chktxt));
    fnums(i,2) = double(fTimes(i));
end

% Step 2: get the timestamp associated with each gaze sample
gazeTimes = edfDat.Samples.time;

% Step 3: decide which frame number was active during each gaze sample
output = zeros(size(gazeTimes));
for i = 1:length(output)
    t = gazeTimes(i);
    if t < fnums(1,2)
        % The eyetracker definitely starts recording before the video is up
        output(i) = 0;
    else
        activeFrame = find(t >= fnums(:,2), 1,'last');
        assert(~isempty(activeFrame), 'Could not find a frame with this timestamp!');
        output(i) = fnums(activeFrame, 1);
    end

end
