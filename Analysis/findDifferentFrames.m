function [output, varargout] = findDifferentFrames(fpath)
% Given the filename of a stimulus video, do motion detection:
% Assuming the video has some amount of dead air on either end,
% report back the first and final frames of the video that cut that out.
% e.g. if frames 1 to 10 are all identical, and frame 11 changes,
% then frame 10 is the first frame needed to capture all motion.

% VALIDATE INPUT
% See if the input has a path attached to it or not
[f0,f1, f2] = fileparts(fpath);
fname = [f1 f2]; % file name and extension, no path
if ~isempty(f0)
    % Validate path if provided
    if exist(fpath, 'file')
        % If it DOES exist, then just use it.
        movName = fpath;
    else
        % If NOT, strip out the bogus path and fish for a new one.
        % Errors out if file not found in known stim dirs.
        movName = findVidPath(fname);
    end
else
    % If no path provided, then find a valid one.
    % Errors out if file not found in known stim dirs.
    movName = findVidPath(fpath);
end

% START OPERATING
fprintf(1, 'Finding first and last frames of motion for video:\n');
fprintf(1, '\t%s...',fname);

% Load the video
thisVid = VideoReader(movName);
numFrames = thisVid.NumFrames;

frange = []; % init output
flag = false; % to break out of two fors at once
globSize = ceil(thisVid.FrameRate); % read many frames at once to improve performance

% Find first frame with motion
for g = 1:globSize:numFrames-1
    fs = read(thisVid, [g, min([numFrames, g + globSize])]);
    for j = 1:size(fs,4)-1
        i = g + j - 1; % frame number
        img1 = fs(:,:,:,j);
        img2 = fs(:,:,:,j+1);
    
        % Attempt to filter the jpg noise
    
        % Shrink image by half
        sz = size(img1);
        img1e = imresize(img1, [round(sz(1)/2), round(sz(2)/2)]);
        img2e = imresize(img2, [round(sz(1)/2), round(sz(2)/2)]);
        
        % Do edge detection and compare
        img1e = edge(double(im2gray(img1e)));
        img2e = edge(double(im2gray(img2e)));
        
        if sum(img1e ~= img2e, 'all') > 100
            frange(1) = i;
            flag = true;
        end
        if flag
            break
        end
    end
    if flag
        break
    end
end
flag = false;

% Final frame with motion
for g = numFrames-globSize:-globSize:2
    fs = read(thisVid, [g, min([numFrames, g + globSize])]);
    for j = size(fs,4):-1:2
        i = g + j - 1; % frame number
        img1 = fs(:,:,:,j);
        img2 = fs(:,:,:,j-1);
        
        % Attempt to filter the jpg noise
        
        % Shrink image by half
        sz = size(img1);
        img1e = imresize(img1, [round(sz(1)/2), round(sz(2)/2)]);
        img2e = imresize(img2, [round(sz(1)/2), round(sz(2)/2)]);
        
        % Do edge detection and compare
        img1e = edge(double(im2gray(img1e)));
        img2e = edge(double(im2gray(img2e)));
        % Compare
        if sum(img1e ~= img2e, 'all') > 10
            frange(2) = i;
            flag = true;
        end
        if flag
            break
        end
    end
    if flag
        break
    end
end

% Clear video object just in case
clear thisVid img1 img2 img1e img2e

% Set outputs
output.StimName = movName;
output.FrameRange = frange;

fprintf(1, 'Done.\n')

if nargout > 1
    varargout{1} = numFrames;
end

end