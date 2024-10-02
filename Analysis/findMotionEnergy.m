function [flow] = findMotionEnergy(vidPath)
% For a given video, estimate the amount of motion per frame
% Uses a Farneback optical flow algorithm

% Load the video
thisVid = VideoReader(vidPath);
numFrames = thisVid.NumFrames;

% Initialize motion tracker
opticFlow = opticalFlowFarneback;

globSize = ceil(thisVid.FrameRate) * 2; % read many frames at once to improve performance

flow = zeros([numFrames, 1]); % column
% output = flow;

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
        flow(i) = mean(x.Magnitude, 'all');
    end
end
% i = 1 will have some huge number from comparing frame 1 to frame "0"
% It's treating the onset of the first frame as motion relative to blank.
% This ought to instead be 0, to indicate "no change" since it's the first.
flow(1) = 0;
end