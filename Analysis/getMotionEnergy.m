function output = getMotionEnergy(vidPath)
% For a given video, estimate the amount of motion per frame
% Rather than using complicated methods with e.g. banks of Gabor filters,
% here we just report the average intensity difference per frame.

% Load the video
thisVid = VideoReader(vidPath);
numFrames = thisVid.NumFrames;

globSize = ceil(thisVid.FrameRate); % read many frames at once to improve performance

output = zeros([numFrames, 1]); % column

% Read in a glob of frames, then compare each j to j+1
for g = 1:globSize:numFrames-1
    fs = read(thisVid, [g, min([numFrames, g + globSize])]);
    for j = 1:size(fs,4)-1
        i = g + j - 1; % frame number
        img1 = fs(:,:,:,j);
        img2 = fs(:,:,:,j+1);
        
        % Simple comparison
        output(i+1) = mean(abs(img2 - img1), 'all');
    end
end
end