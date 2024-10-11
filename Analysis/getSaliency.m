function output = getSaliency(vidname)
thisVid = VideoReader(vidname); 
numFrames = thisVid.NumFrames; 
for i = 1:numFrames
    img= read(thisVid, i);
    
    %1. Extract each frame separately, since it expects images not video
    IMG{i} = img;
end

% 2. Calculate the #1 most salient pixel location of each frame
[~, fixations] = batchSaliency(IMG, 1);

% 3. Extract those locations into separate X and Y vectors
for i = 1:numFrames
    x(i) = fixations{i}(2);
    y(i) = fixations{i}(1);
end

% 4. Rescale from the image dimensions to the experiment display dimensions
newSc = resizeVideo(thisVid.Width, thisVid.Height, [1 1 1920 1200]);
newW = newSc(3) - newSc(1);
xrs = newW / thisVid.Width;
yrs = 1200 / thisVid.Height;
x = x .* xrs + newSc(1);
y = y .* yrs;

% 5. Create a time vector to go along with the XY data
fr = thisVid.FrameRate;
z = 1:1000/fr:(length(x))*(1000/fr);

output = [x; y; z];
