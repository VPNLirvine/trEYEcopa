function output = extractPosition2(gTruth)
% Input 1 is a .mat file with video labeling session EXPORT data
% i.e. load a Label Session, then on the right, click Export>Labels>To File
% It should have one variable named gTruth, containing a "timetable" var
% We're going to take that and separate the X and Y coords into columns,
% which makes it easier to work with later.

% Get count of labels to iterate through
numLabels = height(gTruth.LabelDefinitions);
numFrames = height(gTruth.LabelData);

% Get rescaling factors so that all data is stored at 4000x3000
[~,vidName,~] = fileparts(gTruth.DataSource.Source);
[vidX, vidY] = getVideoSize(vidName);
xrs = 4000 / vidX;
yrs = 3000 / vidY;

output = struct('Name',{},'X',[],'Y',[],'t',[]);

t = gTruth.LabelData.Time';
for i = 1:numLabels
    % Get all the pertinent info as temp vars first
    labelName = gTruth.LabelDefinitions.Name{i};
    X = [];
    Y = [];
    % Loop over every timepoint, unfortunately
    % There will be empty frames, which are stored as [] in a cell
    % If you just cell2mat the whole thing, it DROPS the empty elements
    % So we loop to preserve the structure and handle the empties later
    for j = 1:numFrames
        pos = extractCenter(gTruth.LabelData.(labelName){j});
        X(1,j) = pos(1);
        Y(1,j) = pos(2);
    end
    X = fixnans(X);
    Y = fixnans(Y);

    % Now dole out into your output struct in one go
    output(i).Name = labelName;
    output(i).X = X .* xrs;
    output(i).Y = Y .* yrs;
    output(i).t = seconds(t);
end
end % main function

% -----SUBFUNCTIONS-----
function xycenter = extractCenter(x)
    % Takes a 4-element vector from the Timetable output of Video Labeler
    % Exports the centerpoint of that rectangle
    if isempty(x)
        xycenter = [NaN, NaN];
    else
        % Index as (r,c) instead of just (i) in case there were >1 boxes
        % bc then you would have an Nx4 and not a 1x4, where x(2)==x(2,1)
        xycenter = [x(1,1) + round(0.5*x(1,3)), x(1,2) + round(0.5*x(1,4))];
    end
end

function newdat = fixnans(dat)
    % NaNs are timepoints when no bounding box was drawn
    % Find these timepoints and replace with interpolated values
    nanlist = isnan(dat);
    if sum(nanlist) == 0
        % Short-circuit since interp1 will likely fail anyway
        newdat = dat;
    else
        x = 1:length(dat);
        newdat = interp1(x(~nanlist), dat(~nanlist), x);
    end
end
