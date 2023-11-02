function frameGenerator(movieName, varargin)
% Breaks a video file down into a folder full of individual frames
% Used by frame2movie to plot fixation data on top of the video file
% Input movieName is just the filename of the video
% By default, outputs to a folder called 'frames' in root directory
% Optional second input specifies the output folder

pths = specifyPaths;
if nargin > 1
    outdir = varargin{1};
    assert(ischar(outdir), 'Second input must be a string/char');
    assert(exist(outdir, 'folder'), 'Provided output path %s does not exist!', outdir);
else
    outdir = pths.frames;
end

if ~exist(movieName, 'file')
    % If full path not specified, try looking here:
    videoPath = pths.MW;
    movieName = fullfile(videoPath, movieName);
end

% import the video file
obj = VideoReader(movieName);
  
% read the total number of frames
frameNum = 0;
  
format ='.jpg'; % output format

% create directory
[~, infname, inext] = fileparts(movieName); % assume movieName has a path
dest = fullfile(outdir, erase([infname inext],[' (Converted).mov', '.mov', '.MOV']));
mkdir(dest)

% reading and writing the frames
while hasFrame(obj) 
    % converting integer to string
    frameNum = frameNum + 1;
    %frameNumStr = num2str(frameNum);

    % Filename is just the frame number, e.g. 1.jpg
    fname = strcat(num2str(frameNum), format);

    % reading in frame
    frame = readFrame(obj);
    fpath = fullfile(dest, fname);
    % exporting the frames
    imwrite(frame, fpath);   
end

fprintf("%i frames generated for %s and stored in %s\n",frameNum, erase(movieName,' (Converted).mov'),dest)

end