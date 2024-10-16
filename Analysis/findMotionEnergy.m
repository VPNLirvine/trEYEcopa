function [flow] = findMotionEnergy(vidPath, varargin)
% For a given video, estimate the amount of motion per frame
% Uses a Farneback optical flow algorithm

if nargin > 1
    mtype = varargin{1};
else
    mtype = 'eng';
end

% Load the video
thisVid = VideoReader(vidPath);
numFrames = thisVid.NumFrames;

% Initialize motion tracker
opticFlow = opticalFlowFarneback;

globSize = ceil(thisVid.FrameRate) * 2; % read many frames at once to improve performance

% Preallocate output
if strcmp(mtype, 'eng')
    flow = zeros([numFrames, 1]); % single column
elseif strcmp(mtype, 'loc')
    flow = zeros([2, numFrames]); % wide matrix
end

% Read in a glob of frames, then compare each i to i-1
for g = 1:globSize:numFrames
    fs = read(thisVid, [g, min([numFrames, g + globSize - 1])]);
    for j = 1:size(fs,4)
        i = g + j - 1; % frame number
        img1 = fs(:,:,:,j);
        
        % More complicated comparison
        img2 = im2gray(img1);
        % img3 = imcomplement(img3); % not sure why this is here
        x = estimateFlow(opticFlow, img2); % x is a struct with vectors etc

        % Determine what to return
        if strcmp(mtype, 'eng')
            % Return motion energy, a la filename
            flow(i) = mean(x.Magnitude, 'all');
        elseif strcmp(mtype, 'loc')
            % Return X,Y coordinates of highest energy
            m = max(x.Magnitude, [], 'all');
            [Y, X] = find(ismember(x.Magnitude, m));
            if m < .1 && i > 1
                % If no motion, expect to stay at the previous location
                flow(1,i) = flow(1,i-1);
                flow(2,i) = flow(2, i-1);
            else
                flow(1,i) = X(1); % in case multiple exist
                flow(2,i) = Y(1); % in case multiple exist
            end
        end
    end
end
% Fix output re first frame
if strcmp(mtype, 'eng')
    % i = 1 will have some huge number from comparing frame 1 to frame "0"
    % It's treating the onset of the first frame as motion relative to blank.
    % This ought to instead be 0, to indicate "no change" since it's the first.
    flow(1) = 0;
elseif strcmp(mtype, 'loc')
    % Similar to above, since the first frame should have no motion,
    % replace whatever is detected with the center of the video.
    flow(1,1) = round(thisVid.Width/2);
    flow(2,1) = round(thisVid.Height/2);
    
    % Rescale from video resolution to monitor resolution
    newSc = resizeVideo(thisVid.Width, thisVid.Height, [1 1 1920 1200]);
    newW = newSc(3) - newSc(1);
    xrs = newW / thisVid.Width;
    yrs = 1200 / thisVid.Height;
    flow(1,:) = flow(1,:) .* xrs + newSc(1);
    flow(2,:) = flow(2,:) .* yrs;

    % Also add a time vector?
    flow(3,:) = round(1:1000/thisVid.FrameRate:1000*(width(flow))/thisVid.FrameRate);
end