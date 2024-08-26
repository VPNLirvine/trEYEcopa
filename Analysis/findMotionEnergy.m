function [flow] = findMotionEnergy(vidPath)
% For a given video, estimate the amount of motion per frame
% Uses a Farneback optical flow algorithm

% Load the video
thisVid = VideoReader(vidPath);
numFrames = thisVid.NumFrames;

% Initialize motion tracker
opticFlow = opticalFlowFarneback;

globSize = ceil(thisVid.FrameRate); % read many frames at once to improve performance

flow = zeros([numFrames, 1]); % column
% output = flow;

% Read in a glob of frames, then compare each j to j+1
for g = 1:globSize:numFrames-1
    fs = read(thisVid, [g, min([numFrames, g + globSize])]);
    for j = 1:size(fs,4)-1
        i = g + j - 1; % frame number
        img1 = fs(:,:,:,j);
        img2 = fs(:,:,:,j+1);
        
        % % Simple comparison
        % output(i+1) = mean(abs(img2 - img1), 'all');

        % More complicated comparison
        img3 = im2gray(img2);
        img3 = imcomplement(img3);
        x = estimateFlow(opticFlow, img3); % x is a struct with vectors etc
        flow(i+1) = mean(x.Magnitude, 'all');
    end
end
flow(2) = 0; % This is the difference between no video and first frame
end