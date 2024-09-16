function output = findDifferentPositions(posData, varargin)
% Given some character position data, find any lead/lag pauses
% meaning timepoints where nothing happens until a bit later in.
% We expect that some of these will have a short delay before motion,
% and maybe also a short delay after the motion stops.
% So by identifying the times when motion starts and stops
% in both the position data and the video data,
% we can better align the two data sources.
%
% Input 1 is a single row from getPosition
% If you did NOT subset this data before sending it here,
% (i.e. you just passed in the entire structure)
% then please also include:
% Input 2 (optional) is an index saying which row to use.
% If input 2 is not provided, and there is more than one row, error.

% Parse inputs
if nargin > 1
    m = varargin{1};
elseif height(posData) > 1
    error('Unclear which row of input 1 to use! Either pass an index or subset it before calling this function')
else
    % assume it's pre-sliced
    m = 1;
end

% Find the first index with a change in position/rotation
    % diff compares element i to element i+1
    % find the first non-zero element
    x1 = find(diff(posData.X1_Values{m}),1);
    y1 = find(diff(posData.Y1_Values{m}),1);
    x2 = find(diff(posData.X2_Values{m}),1);
    y2 = find(diff(posData.Y2_Values{m}),1);
    x3 = find(diff(posData.X3_Values{m}),1);
    y3 = find(diff(posData.Y3_Values{m}),1);
    x4 = find(diff(posData.X4_Values{m}),1);
    y4 = find(diff(posData.Y4_Values{m}),1);
    r1 = find(diff(posData.R1_Values{m}),1);
    r2 = find(diff(posData.R2_Values{m}),1);
    r3 = find(diff(posData.R3_Values{m}),1);
    r4 = find(diff(posData.R4_Values{m}),1);
    % If ANY character has moved or rotated in frame i+1,
    % then frame i is considered the first frame.
    % But ignore the circle's rotation (r2) since it's perfectly circular.
    output(1) = min([x1 x2 x3 x4 y1 y2 y3 y4 r1 r3 r4]);

% Find the final index with a change in position/rotation
% diff compares i to i+1
% look at the last non-zero element of diff, and use the next one
% since that means i ~= i+1, but i+1 == i+2 and we want to keep all motion
    x1 = find(diff(posData.X1_Values{m}),1, 'last') + 1;
    y1 = find(diff(posData.Y1_Values{m}),1, 'last') + 1;
    x2 = find(diff(posData.X2_Values{m}),1, 'last') + 1;
    y2 = find(diff(posData.Y2_Values{m}),1, 'last') + 1;
    x3 = find(diff(posData.X3_Values{m}),1, 'last') + 1;
    y3 = find(diff(posData.Y3_Values{m}),1, 'last') + 1;
    x4 = find(diff(posData.X4_Values{m}),1, 'last') + 1;
    y4 = find(diff(posData.Y4_Values{m}),1, 'last') + 1;
    r1 = find(diff(posData.R1_Values{m}),1, 'last') + 1;
    r2 = find(diff(posData.R2_Values{m}),1, 'last') + 1;
    r3 = find(diff(posData.R3_Values{m}),1, 'last') + 1;
    r4 = find(diff(posData.R4_Values{m}),1, 'last') + 1;
    % If ANY character has moved or rotated in frame i+1,
    % then frame i is considered the final frame.
    % But ignore the circle's rotation since it's perfectly circular.
    output(2) = max([x1 x2 x3 x4 y1 y2 y3 y4 r1 r3 r4]);
end