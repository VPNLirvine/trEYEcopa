function frameGenerator(movieName)
videoPath = '/Users/vpnl/Documents/MATLAB/Martin Weisberg stims'
% videoPAth = '/Users/vpnl/Documents/MATLAB/TCconverted'


% adding file extension if necessary 
% if ~contains(movieName,'(Converted)')
%     movieName= [movieName ' (Converted)'];
% end

% if (isempty(regexp(movieName, '.mov$','once')))
%     movieName= [movieName '.mov'];
% end

% import the video file
cd(videoPath)
obj = VideoReader(movieName);
  
% read the total number of frames
frameNum = 0;
  
% file format of the frames to be saved in
format ='.jpg';

% creat directory
dest = strcat('/Users/vpnl/Documents/MATLAB/frames', '/', erase(movieName,[' (Converted).mov', '.mov', '.MOV']));
mkdir(dest)

% reading and writing the frames
cd(dest)
while hasFrame(obj) 
    % converting integer to string
    frameNum = frameNum + 1;
    %frameNumStr = num2str(frameNum);

    % concatenating 2 strings
    Strc = strcat(num2str(frameNum), format);

    % reading in frame
    frame = readFrame(obj);

    % exporting the frames
    imwrite(frame, Strc);   
end

fprintf("frames generated for %s and stored in %s\n",erase(movieName,' (Converted).mov'),pwd)
cd /Users/vpnl/Documents/MATLAB/ExpAnalyze
clear

end