function newRect = resizeVideo(vidW, vidH, screenRect)
% Inputs 1 and 2 are the height and width of the video
% Input 3 is a 4-element vector, the 2nd output of Screen('OpenWindow')
% Determine how best to expand the video to fill the screen
% i.e. avoid bleeding over either dimension while keeping aspect ratio
% Output is a 4-element vector describing the rectangle to draw into,
% Which serves as input to Screen('DrawTexture', [], [], [], output)

% Get parameters of screen
scnH = screenRect(4);
scnW = screenRect(3);

% Get the ratios the image must change by to fit the screen
hGrow = scnH/vidH;
wGrow = scnW/vidW;

% No matter shrink or expand, this picks the right amount:
rescale = min([hGrow wGrow]);

% Calculate the coordinates of the drawing area
imgRect = [0 0 rescale*vidW rescale*vidH]; % box of final size
newRect = CenterRectOnPointd(imgRect, scnW / 2, scnH / 2); % centered
end