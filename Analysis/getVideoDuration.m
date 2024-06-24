function duration = getVideoDuration(fname)
% Given the name+location of a video file, find its duration

assert(exist(fname,'file') ~= 0, 'Could not find file: %s', fname)
if ismac
    % Use a Mac shell function to find the video's duration
    % I do this instead of mmfileinfo() bc I get a codec error on my laptop
    
    exe = sprintf("mdls %s | grep Duration | awk '{ print $3 }'", fname);
    [~,duration] = system(exe);
    duration = str2double(duration);
else
    % Try the below Matlab-based function
    vidHeader = mmfileinfo(fname);
    duration = vidHeader.Duration;
end
