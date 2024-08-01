function input = fixTiming(input)
% Given a table of data containing scanpaths,
% assuming they are all 3xn matrices of X coord, Y coord, Timestamp,
% then allowing for a variable n per subject,
% interpolate data that puts everyone into a common time domain.
%
% This is necessary because some recordings are slightly longer,
% or are at 500 Hz vs 250 Hz,
% or the timestamps don't perfectly line up e.g. odds vs evens,
% etc.

% fprintf(1, "Standardizing timing...")

numCells = height(input);

% Find the common time range
allTimes = [];
for i = 1:numCells
    allTimes = [allTimes, input.Eyetrack{i}(3, :)];
end
commonTimeRange = [max(min(allTimes)), min(max(allTimes))];
commonTimeRange = single(commonTimeRange);
% Define a new time vector with uniform step size within the common time range
timeStep = 4; % 250 Hz is 1/250 == 0.004 sec == 4 msec
newTimeVector = commonTimeRange(1):timeStep:commonTimeRange(2);

% Interpolate the X and Y coordinates for each cell
for i = 1:numCells
    % Convert data from uint32 to single
    d = input.Eyetrack{i};
    currentX = single(d(1, :));
    currentY = single(d(2, :));
    currentTime = single(d(3, :));

    % Censor blink data by dropping any coords beyond the screen resolution
    sz = [1920 1200];
    dropList = currentX > sz(1) | currentY > sz(2);
    currentX(dropList) = [];
    currentY(dropList) = [];
    currentTime(dropList) = [];
    
    % Interpolate data that lines up with the standardized time vector.
    % I've found that 'linear extrapolation' produces smoother results
    % than 'cubic spline', which tends to go to infinity at the edges.
    interpolatedX = interp1(currentTime, currentX, newTimeVector, 'linear', 'extrap');
    interpolatedY = interp1(currentTime, currentY, newTimeVector, 'linear', 'extrap');
    input.Eyetrack{i} = [interpolatedX; interpolatedY; newTimeVector];
end

% fprintf(1, "Done.\n")
end