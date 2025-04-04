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
opticFlow = opticalFlowHS;

% Define constants
globSize = ceil(thisVid.FrameRate) * 2; % read many frames at once to improve performance
thresh = .07; % noise threshold on motion magnitude

% Preallocate output
if strcmp(mtype, 'eng')
    flow = zeros([numFrames, 1]); % single column
elseif strcmp(mtype, 'loc')
    flow = zeros([2, numFrames]); % wide matrix
elseif strcmp(mtype, 'map')
    flow = zeros([1200,1920,numFrames]); % yowza that's big
    flow = single(flow); % reduce memory demands
    % Resize that map to be centered fullscreen in a 1920x1200 window
    newSc = resizeVideo(thisVid.Width, thisVid.Height, [0 0 1920 1200]);
    % avoid non-integers, since we will be indexing
    newSc = round(newSc);
    newW = newSc(3) - newSc(1);
    newH = newSc(4) - newSc(2);
end

% Read in a glob of frames, then compare each i to i-1
for g = 1:globSize:numFrames
    fs = read(thisVid, [g, min([numFrames, g + globSize - 1])]);
    for j = 1:size(fs,4)
        i = g + j - 1; % frame number
        img1 = fs(:,:,:,j);
        
        % More complicated comparison
        img2 = im2gray(img1);
        % Smooth out popcorn noise
        img2 = imgaussfilt(img2, 2);
        % img2 = imcomplement(img2); % not sure why this is here
        x = estimateFlow(opticFlow, img2); % x is a struct with vectors etc
        
        % Determine what to return
        if strcmp(mtype, 'eng')
            if i == 1
            % i = 1 will have some huge number from comparing frame 1 to frame "0"
            % It's treating the onset of the first frame as motion relative to blank.
            % This ought to instead be 0, to indicate "no change" since it's the first.
                flow(i) = 0;
            else
                % Return motion energy, a la filename
                flow(i) = sum(x.Magnitude, 'all');
            end
        elseif strcmp(mtype, 'map')
            tmp = x.Magnitude;
            tmp(tmp < thresh) = 0;
            % flow(:,:,i) = tmp;
            % Process the map
            tmp2 = imresize(tmp, [newH, newW], 'nearest');
            flow(1:1200, newSc(1)+1:newSc(1) + newW,i) = tmp2;
            if i == 1
                % Similar to above, the first frame is compared to blank,
                % So treat it as if there is no motion anywhere.
                flow(:,:,i) = 0;
            % else
            %     % Only return the top 5% of pixels?
            %     flow(flow < prctile(flow, 95, 'all')) = 0;
            end
        elseif strcmp(mtype, 'loc')
            if i == 1
                % Similar to above, the first frame is compared to blank.
                % Any "motion" it detects is meaningless, so
                % replace those coordinates with the center of the video.
                flow(1,1) = round(thisVid.Width/2);
                flow(2,1) = round(thisVid.Height/2);
            else
                % Return X,Y coordinates of highest energy
                % m = max(x.Magnitude, [], 'all');
                m = max(maxk(x.Magnitude, 5),[],2);
                [Y, X] = find(ismember(x.Magnitude, m));
                if m < thresh
                    % If no motion, expect to stay at the previous location
                    flow(1,i) = flow(1,i-1);
                    flow(2,i) = flow(2, i-1);
                else
                    % See if multiple options exist with the same magnitude
                    if isscalar(X)
                        s = 1;
                    else
                        % Pick the one closest to the previous location
                        testVal = flow(:,i-1)';
                        % distances = norm(testVal - [X, Y]);
                        distances = sqrt((X - testVal(1)).^2 + (Y - testVal(2)).^2);
                        s = find(min(distances) == distances, 1);
                    end
                    flow(1,i) = X(s); % in case multiple exist
                    flow(2,i) = Y(s); % in case multiple exist
                end
            end
        end % mtype
    end % for frame j
end % for glob

% Make final adjustments to output
if strcmp(mtype, 'loc')  
    % Rescale from video resolution to monitor resolution
    newSc = resizeVideo(thisVid.Width, thisVid.Height, [1 1 1920 1200]);
    newW = newSc(3) - newSc(1);
    xrs = newW / thisVid.Width;
    yrs = 1200 / thisVid.Height;
    flow(1,:) = flow(1,:) .* xrs + newSc(1);
    flow(2,:) = flow(2,:) .* yrs;

    % Prepend some values before smoothing, which will be dropped after.
    % This helps ensure the first point remains the center of the screen,
    % so in case there is an immediate discontinuity, it gets discounted.
    nPrepend = 10;
    flow = [repmat(flow(:,1), 1, nPrepend), flow];

    % Lowpass filter the timeseries
    filtCutoff = 3; % Hz
    sr = 60; % sampling rate, also in Hz
    flow = lowpass(flow', filtCutoff, sr)';

    % Drop the prepended values so that we're back to the original size
    flow = flow(:, nPrepend+1:end);

    % Also add a time vector?
    flow(3,:) = round(1:1000/thisVid.FrameRate:1000*(width(flow))/thisVid.FrameRate);
end
clear thisVid % explicitly clear to ensure no memory leaks