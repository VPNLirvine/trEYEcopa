function gazeMap = getHeatmap(xdat, ydat, varargin)
% Given timeseries of x and y coordinate data, generate a heatmap of dwell times
% Optionally choose to plot the data, otherwise just output the heatmap
%
% gazeMap = getHeatmap(xdat, ydat, [screenDims])

if nargin > 2
    % Define the screen dimensions: [xsize ysize]
    % e.g. a typical HD screen is [1920 1080]
    tmp = varargin{1};
    assert(length(tmp) == 2, '3rd input must be a 2-element array of screen dimensions: [xwidth yheight]');
    xMax = tmp(1); yMax = tmp(2);
else
    % Use default values
    xMax = 1920; yMax = 1200;
end

if nargin > 3
    binRes = varargin{2};
    assert(isnumeric(binRes), 'Input 4 (bin resolution) must be a number!');
    assert(binRes >= 1, 'Input 4 (bin resolution) must be a positive number!');
else
    binRes = 1; % full resolution
end

% Validate input is the right shape
% First, try just transposing
% If that doesn't work, you've got bigger problems.
if ~iscolumn(xdat)
    xdat = xdat';
end
if ~iscolumn(ydat)
    ydat = ydat';
end
assert(iscolumn(xdat) && iscolumn(ydat), 'Inputs 1 and 2 must be column vectors');

% Horizontally concatenate the two column vectors
timeSeries = [xdat, ydat];

% Define the bin centers (as opposed to the edges)
xctr = 1:binRes:xMax;
yctr = 1:binRes:yMax; 

% Calculate a histogram of gaze locations
gazeMap = hist3(timeSeries, 'Ctrs', {xctr,yctr});

% Perform any necessary data rotation here.
% For one, it comes out sideways and needs to be rotated 90 deg.
% Unsure if it also needs to be mirrored in either direction.
gazeMap = gazeMap'; % rotate 90 deg

end % function