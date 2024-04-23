function output = findDifferentFrames()

pths = specifyPaths();
vlist = dir(pths.frames);
vlist(1:3) = [];
numVids = length(vlist);

fprintf(1, 'Operating over %i videos\n', numVids);
for v = 1:numVids
    folderName = vlist(v).name;
    movName = erase(folderName, '.MOV');
    movName = erase(movName, '.mov'); % either case
    flist = dir(fullfile(pths.frames, folderName, '*.jpg')); % get list of frames
    numFrames = length(flist);
    % Account for jank sorting
    for j = 1:numFrames
        inOrder{j} = [num2str(j) '.jpg'];
    end
    
    frange = []; % init per vid
    fprintf(1, '\tVideo %i/%i...', v, numVids);
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
            frange(1) = i+1;
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
            frange(2) = i-1;
            break
        end
    end
    output(v).StimName = movName;
    output(v).FrameRange = frange;
    fprintf(1, 'Done.\n')
end