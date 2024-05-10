function output = findDifferentFrames(varargin)

pths = specifyPaths('..');
vlist = dir(pths.frames);
vlist(startsWith({vlist(:).name}, '.')) = []; % drop system folders
numVids = length(vlist);

if nargin > 0
    % Input should be a video name
    % "loop" over just that one video
    loopRange = find(strcmpi(varargin{1}, {vlist(:).name}));
    assert(~isempty(loopRange), 'Provided movie name %s not found!', varargin{1});
    numVids = 1;
else
    loopRange = 1:numVids;
end

fprintf(1, 'Finding first and last frames of motion in videos\n');
fprintf(1, 'Operating over %i videos\n', numVids);
for v = loopRange
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
    fprintf(1, '\tVideo %i/%i: %s...', v, numVids, movName);
    % Find first frame with motion
    for i = 1:numFrames-1
        fname1 = fullfile(pths.frames, folderName, inOrder{i});
        fname2 = fullfile(pths.frames, folderName, inOrder{i+1});

        img1 = imread(fname1);
        img2 = imread(fname2);

        % Filter somehow
        img1 = imbinarize(img1(:,:,3), 0.5);
        img2 = imbinarize(img2(:,:,3), 0.5);

        if sum(img1 ~= img2, 'all') > 6
            frange(1) = i;
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
        img1 = imbinarize(img1(:,:,3), 0.5);
        img2 = imbinarize(img2(:,:,3), 0.5);

        if sum(img1 ~= img2, 'all') > 6
            frange(2) = i;
            break
        end
    end
    if numVids == 1
        % Don't make a big empty thing if we only did one
        output(1).StimName = movName;
        output(1).FrameRange = frange;
    else
        output(v).StimName = movName;
        output(v).FrameRange = frange;
    end
    fprintf(1, 'Done.\n')
end