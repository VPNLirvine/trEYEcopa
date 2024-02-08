function gazeMap = getHeatmap(xdat, ydat, varargin)
% Given timeseries of x and y coordinate data, generate a heatmap of dwell times
% Optionally choose to plot the data, otherwise just output the heatmap
%
% gazeMap = getHeatmap(xdat, ydat, [plotFlag], [screenDims])

if nargin > 2
    % Choose whether to plot or not
    plotFlag = varargin{1};
else
    % Default to plot off
    plotFlag = false;
end

if nargin > 3
    % Define the screen dimensions: [xsize ysize]
    % e.g. a typical HD screen is [1920 1080]
    tmp = varargin{2};
    assert(length(tmp) == 2, '4th input must be a 2-element array of screen dimensions: [xwidth yheight]');
    xMax = tmp(1); yMax = tmp(2);
else
    % Use default values
    xMax = 1920; yMax = 1200;
end

% Validate input
assert(islogical(plotFlag), '3rd input must be a logical - turn plot on yes or no');
assert(iscolumn(xdat) && iscolumn(ydat), 'Inputs 1 and 2 must be column vectors');

% Horizontally concatenate the two column vectors
timeSeries = [xdat, ydat];

% Define the bin centers (as opposed to the edges)
binRes = 1; % number of pixels to average over.
xctr = 1:binRes:xMax;
yctr = 1:binRes:yMax; 

% Calculate a histogram of gaze locations
gazeMap = hist3(timeSeries, 'Ctrs', {xctr,yctr});

% Perform any necessary data rotation here.
% For one, it comes out sideways and needs to be rotated 90 deg.
% Unsure if it also needs to be mirrored in either direction.
gazeMap = gazeMap'; % rotate 90 deg

if plotFlag
    % Instead of displaying as a 3D histogram, visualize with imagesc
    figure();
    imagesc(gazeMap);
    title(sprintf('Gaze heatmap for %s', strrep(tname, '_', '__')));
end

end % function