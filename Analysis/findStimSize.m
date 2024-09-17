function [stimWindow, screenDims] = findStimSize(edfRow)
% Somehow I managed to never directly specify the video dimensions
% So this function calculates it based on screen size and top-left pixel
% We stretched the videos to be fullscreen in at least one dimension,
% and since they're 4:3 on a 16:9 monitor, they cap out the vertical space.
% So assume the Y coord is maxed,
% and calculate the X width based on the fact that the video is centered.

list = edfRow.Events.message;
% Find display dimensions first
chktxt1 = 'GAZE_COORDS ';
y = cellfun(@(x) contains(x, chktxt1), list);
assert(sum(y) > 0, 'No message re screen resolution found!');
gtext = list{y};
    gtext = erase(gtext, chktxt1);
    screenDims = str2num(gtext); %#ok<ST2NM>
    % res should be a 4-element vector e.g. [0, 0, 1920-1, 1200-1]
    scnWidth = screenDims(3) - screenDims(1);
    scnHeight = screenDims(4) - screenDims(2);

chktxt = '0 !V VFRAME ';
y = cellfun(@(x) contains(x, chktxt), list);
assert(sum(y) > 0, 'No message re video display found!');
dtxt = list{find(y, 1)}; % just grab the first example
    z = sscanf(dtxt, '0 !V VFRAME %i %i %i %s'); % do reverse sprintf
    X = z(2); Y = z(3); % extract integers 2 and 3, and ignore the string
    % X and Y should be coordinates in the domain set by res
    % Y is likely 0, X somewhere around 80.

% Now put the two together to define the 4-element window the video was in.
% If X defines the video's left side, 0:X are empty, and will be mirrored.
% So double X to get the total black space, and subtract from screen size.
vidWidth = scnWidth - (X * 2);
% We can safely assume that the video height is always the screen height,
% but I'll calculate it anyway just to be safe.
vidHeight = scnHeight - (Y * 2);
stimWindow = [X, Y, X+vidWidth, Y+vidHeight];

end