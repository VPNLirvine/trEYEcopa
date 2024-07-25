function lum = estLuminance(movName)
% Given the path to a video file,
% estimate the luminance of each frame

movFName = findVidPath(movName);
thisVid = VideoReader(movFName);

numFrames = thisVid.NumFrames;
lum = zeros([numFrames, 1]);

globSize = ceil(thisVid.FrameRate); % read many frames at once to improve performance
for g = 1:globSize:numFrames
    fs = read(thisVid, [g, min([numFrames, g + globSize])]);
    for j = 1:size(fs,4)
        i = g + j - 1; % frame number
        img = fs(:,:,:,j);
        img = rgb2hsv(img);
        lum(i) = mean(img(:,:,3), 'all'); % take the average luminance
    end
end
end