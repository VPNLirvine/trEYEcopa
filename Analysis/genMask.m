function genMask(fpath, varargin)
% Given a filename, extract the first frame and save to file
% Optionally specify something other than the first frame

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
% See if frameNum was provided
if nargin > 1
    frameNum = varargin{1};
    assert(isnumeric(frameNum), 'Second input must be an integer frame number');
    assert(round(frameNum) == frameNum, 'Second input must be an integer frame number');
else
    frameNum = 1; % by default
end

thisVid = VideoReader(movName);
frame = read(thisVid, frameNum); % read first frame
frame = imcomplement(frame); % invert image to black bkgd, white figures

% Export to file
% Save in a new subdirectory of Analysis, not to the stim folder.
p = specifyPaths('..');
outPath = fullfile(p.analysis, 'masks');
if ~exist(outPath, 'dir')
    mkdir(outPath)
end
outName = [f1 '.png']; % give it the same name as the video
fout = fullfile(outPath, outName);
imwrite(frame, fout); % write to file

% Clean up
clear thisVid

end % function