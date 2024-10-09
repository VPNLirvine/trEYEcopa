function [output]= getSaliency(vidname)
thisVid = VideoReader(vidname); 
numFrames = thisVid.NumFrames; 
for i = 1:numFrames
    img= read(thisVid, i);
    
    %1.how to apply runSaliency
    %2. figure out how to get the xy position of the most salient thing and
    %store it 
    x(i) = [];
    y(i) = [];
end


