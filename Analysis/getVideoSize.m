function [x,y] = getVideoSize(vidname)
% Given the name of a video, not necessarily a path, return its dimensions.

fpath = findVidPath(vidname);
vid = VideoReader(fpath);
x = vid.Width;
y = vid.Height;
end