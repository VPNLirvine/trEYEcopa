function output = findDifferentFrames(fpath)
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

% Find first frame with motion
for i = 1:numFrames-1
    img1 = read(thisVid, i);
    img2 = read(thisVid, i+1);

    % Filter somehow
    img1 = imbinarize(img1(:,:,3), 0.5);
    img2 = imbinarize(img2(:,:,3), 0.5);

    if sum(img1 ~= img2, 'all') > 6
        frange(1) = i;
        break
    end
end

% Final frame with motion
for i = numFrames:-1:2
    img1 = read(thisVid, i);
    img2 = read(thisVid, i-1);

    % Filter somehow
    img1 = imbinarize(img1(:,:,3), 0.5);
    img2 = imbinarize(img2(:,:,3), 0.5);

    if sum(img1 ~= img2, 'all') > 6
        frange(2) = i;
        break
    end
end

% Clear video object just in case
clear thisVid

% Set outputs
output.StimName = movName;
output.FrameRange = frange;

fprintf(1, 'Done.\n')
end