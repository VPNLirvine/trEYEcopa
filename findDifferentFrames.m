function output = findDifferentFrames()

pths = specifyPaths();
output = [];
vlist = dir(pths.frames);
vlist(1:3) = [];

v = 1;
folderName = vlist(v).name;

flist = dir(fullfile(pths.frames, folderName, '*.jpg')); % get list of frames
numFrames = length(flist);
% Account for jank sorting
for j = 1:numFrames
    inOrder{j} = [num2str(j) '.jpg'];
end

% Find first frame with motion
for i = 1:numFrames-1
    fname1 = fullfile(pths.frames, folderName, inOrder{i});
    fname2 = fullfile(pths.frames, folderName, inOrder{i+1});

    img1 = imread(fname1);
    img2 = imread(fname2);
    
    % Filter somehow
    img1 = im2bw(img1);
    img2 = im2bw(img2);

    if ~isequal(img1, img2)
        output(v, 1) = i+1;
        break
    end
end

% Final frame with motion
for i = numFrames:-1:2
    fname1 = fullfile(pths.frames, folderName, inOrder{i});
    fname2 = fullfile(pths.frames, folderName, inOrder{i-1});

    img1 = imread(fname1);
    img2 = imread(fname2);
    
    % Filter somehow
    img1 = im2bw(img1);
    img2 = im2bw(img2);

    if ~isequal(img1, img2)
        output(v, 2) = i-1;
        break
    end
end

end