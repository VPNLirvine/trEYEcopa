function output = findDifferentPositions(posData, varargin)
% Given some character position data, find any lead/lag pauses
% meaning timepoints where nothing happens until a bit later in.
% We expect that some of these will have a short delay before motion,
% and maybe also a short delay after the motion stops.
% So by identifying the times when motion starts and stops
% in both the position data and the video data,
% we can better align the two data sources.
%
% Input 1 is the output of getPosition
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
for i = 1:length(posData.X1_Values{m})-1
    x1 = ~isequal(posData.X1_Values{m}(i), posData.X1_Values{m}(i+1));
    y1 = ~isequal(posData.Y1_Values{m}(i), posData.Y1_Values{m}(i+1));
    x2 = ~isequal(posData.X2_Values{m}(i), posData.X2_Values{m}(i+1));
    y2 = ~isequal(posData.Y2_Values{m}(i), posData.Y2_Values{m}(i+1));
    x3 = ~isequal(posData.X3_Values{m}(i), posData.X3_Values{m}(i+1));
    y3 = ~isequal(posData.Y3_Values{m}(i), posData.Y3_Values{m}(i+1));
    x4 = ~isequal(posData.X4_Values{m}(i), posData.X4_Values{m}(i+1));
    y4 = ~isequal(posData.Y4_Values{m}(i), posData.Y4_Values{m}(i+1));
    r1 = ~isequal(posData.R1_Values{m}(i), posData.R1_Values{m}(i+1));
    r2 = ~isequal(posData.R2_Values{m}(i), posData.R2_Values{m}(i+1));
    r3 = ~isequal(posData.R3_Values{m}(i), posData.R3_Values{m}(i+1));
    r4 = ~isequal(posData.R4_Values{m}(i), posData.R4_Values{m}(i+1));
    if x1 || x2 || x3 || x4 || y1 || y2 || y3 || y4 || r1 || r2 || r3 || r4
        % If ANY character has moved or rotated in frame i+1,
        % then frame i is considered the first frame.
        output(1) = i;
        break
    end
end

% Find the final index with a change in position/rotation
for i = length(posData.X1_Values{m}):-1:2
    x1 = ~isequal(posData.X1_Values{m}(i), posData.X1_Values{m}(i-1));
    y1 = ~isequal(posData.Y1_Values{m}(i), posData.Y1_Values{m}(i-1));
    x2 = ~isequal(posData.X2_Values{m}(i), posData.X2_Values{m}(i-1));
    y2 = ~isequal(posData.Y2_Values{m}(i), posData.Y2_Values{m}(i-1));
    x3 = ~isequal(posData.X3_Values{m}(i), posData.X3_Values{m}(i-1));
    y3 = ~isequal(posData.Y3_Values{m}(i), posData.Y3_Values{m}(i-1));
    x4 = ~isequal(posData.X4_Values{m}(i), posData.X4_Values{m}(i-1));
    y4 = ~isequal(posData.Y4_Values{m}(i), posData.Y4_Values{m}(i-1));
    r1 = ~isequal(posData.R1_Values{m}(i), posData.R1_Values{m}(i-1));
    r2 = ~isequal(posData.R2_Values{m}(i), posData.R2_Values{m}(i-1));
    r3 = ~isequal(posData.R3_Values{m}(i), posData.R3_Values{m}(i-1));
    r4 = ~isequal(posData.R4_Values{m}(i), posData.R4_Values{m}(i-1));
    if x1 || x2 || x3 || x4 || y1 || y2 || y3 || y4 || r1 || r2 || r3 || r4
        % If ANY character has moved or rotated in frame i-1,
        % then frame i is considered the final frame.
        output(2) = i;
        break
    end
end