function newRect = resizeVideo(vidH, vidW, screenRect)
% Inputs 1 and 2 are the height and width of the video
% Input 3 is a 4-element vector, the 2nd output of Screen('OpenWindow')
% Determine how best to expand the video to fill the screen
% i.e. avoid bleeding over either dimension while keeping aspect ratio
% Output is a 4-element vector describing the rectangle to draw into,
% Which serves as input to Screen('DrawTexture', [], [], [], output)

% Get parameters of screen
scnH = screenRect(4);
scnW = screenRect(3);

% Get the ratios the image has to rescale to fit
hScale = vidH/scnH;
wScale = vidW/scnW;

% The above could be either >1 or <1
% If they're both < 1, image is smaller than window. Grow by the min val
% If either val is > 1, image is larger than window. Shrink by the max val
if hScale > 1 || wScale > 1
    % Shrink by inverting the max value
    rescale = 1 / max([hScale, wScale]);
else
    % Grow by the min value
    rescale = min([hScale wScale]);
end

% Calculate the coordinates of the drawing area
imgRect = [0 0 rescale*vidW rescale*vidH]; % box of final size
newRect = CenterRectOnPointd(imgRect, scnW / 2, scnH / 2); % centered
end