function plotGaze(xytdat, varargin)
% Plot the 3*n data extracted by selectMetric('gaze')

xytdat = double(xytdat);
xdat = xytdat(1,:);
ydat = xytdat(2,:);
tdat = xytdat(3,:);

% Get optional title text
if nargin > 1
    titxt = varargin{1};
else
    titxt = [];
end

% Censor blinks, which give coordinates of 100 million
dropList = xdat == 100000000 | ydat == 100000000;
xdat(dropList) = [];
ydat(dropList) = [];
tdat(dropList) = [];

plot3(xdat,tdat,ydat, '-o', 'MarkerSize', 3);
    xlabel('X'); ylabel('Time in ms'); zlabel('Y');
    % Set the plot limits to the stimulus monitor resolution
    sz = [1920 1200];
    xlim([0 sz(1)]);
    ylim([0 max(tdat)]);
    zlim([0 sz(2)]);
    % Avoid using scientific notation for the time axis
    ax = gca; % axes handle
    ax.YAxis.Exponent = 0;
    % Overlay grid for reference
    grid on
    set(ax, 'ZDir', 'reverse'); % images go top to bottom
    set(ax, 'YDir', 'reverse'); % time goes from back to front
    
    title(titxt);
    view(-37.5,30); % rotate to default angle, since it starts top-down
end