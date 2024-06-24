function plotGazeChars(posDat, gazeDat, varargin)
% Assuming you've already rescaled everything properly,
% Overlay the gaze and position plots on top of each other.
% Call this from within timeOnTarget().


x = [ posDat.C1(1,:); posDat.C2(1,:); posDat.C3(1,:); posDat.C4(1,:); gazeDat(1,:) ];
y = [ posDat.C1(2,:); posDat.C2(2,:); posDat.C3(2,:); posDat.C4(2,:); gazeDat(2,:) ];
% Time data
if nargin > 2
    % Accept a vector defining the timing of each sample
    % If it's in arbitrary time instead of starting at 0, we fix that.
    timeDat = varargin{1};
    t = timeDat - timeDat(1); % rescale to be relative to onset
else
    % Ignore time scale and just plot it against an index
    t = 1:size(x,2);
end

figure();
h = plot3(x,t,y);

ax = gca;
ax.YDir = 'reverse'; % Time goes from back to front
ax.ZDir = 'reverse'; % Image Y goes from top to bottom

% Restrict plot limits to screen size
% Otherwise it will scale axes to fit blink data that goes to infinity
xlim([0 1920]);
zlim([0 1200]);

xlabel('X');
ylabel('Time');
zlabel('Y');

grid on;

legend({'Big Triangle', 'Circle', 'Door', 'Little Triangle', 'Gaze'}, 'Location', 'southoutside', 'Orientation', 'horizontal');

% Emphasize gaze over the characters
set(h(5), 'linewidth', 2);
end