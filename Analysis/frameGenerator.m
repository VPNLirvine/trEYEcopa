function frameGenerator(movieName)
% Deconstructs a .mov file into a folder of .jpgs for each frame
% Takes an isolated filename as input and searches for it
% e.g. input is simply 'movie.mov' and we check the stimulus folder

% Define paths
addpath('..'); % to allow specifyPaths to run
pths = specifyPaths('..');
mwPath = fullfile(pths.MWstim);
tcPath = fullfile(pths.TCstim);

% Determine where the file exists, if at all
if exist(fullfile(mwPath, movieName), 'file')
    videoPath = mwPath;
elseif exist(fullfile(tcPath, 'normal', movieName), 'file')
    videoPath = fullfile(tcPath, 'normal');
else
    error('No such video file found! Check frameGenerator() for paths searched');
end

% adding file extension if necessary 
% if ~contains(movieName,'(Converted)')
%     movieName= [movieName ' (Converted)'];
% end

% if (isempty(regexp(movieName, '.mov$','once')))
%     movieName= [movieName '.mov'];
% end

% import the video file
movPath = fullfile(videoPath, movieName);
obj = VideoReader(movPath);
  
% read the total number of frames
frameNum = 0;
  
% file format of the frames to be saved in
format ='.jpg';

% define output directory
dest = fullfile(pths.frames, erase(movieName,[' (Converted).mov', '.mov', '.MOV']));

if exist(dest, 'dir')
    % Assume frames exist as well
    fprintf(1, 'Frames already exist! Skipping\n');
else
    % create output directory and proceed with extraction
    mkdir(dest)
    
    % reading and writing the frames
    while hasFrame(obj) 
        % get index for this frame
        frameNum = frameNum + 1;
    
        % this frame's filename
        fname = strcat(num2str(frameNum), format);
    
        % destination
        outPath = fullfile(dest, fname);
    
        % reading in frame
        frame = readFrame(obj);
    
        % export as image
        imwrite(frame, outPath);   
    end
    
    fprintf("Frames generated for %s and stored in %s\n",erase(movieName,' (Converted).mov'),dest)
end % if folder exists
end % function