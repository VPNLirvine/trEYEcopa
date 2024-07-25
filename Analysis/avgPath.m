function [output, newTimeVector] = avgPath(input)
% Given a cell array of scanpaths FOR ONE VIDEO,
% generate an average scanpath that accounts for length/timing variability.
% Each cell of the input should be a 3*n matrix: X, Y, and T
% This function interpolates all data to a common time domain before
% averaging.

numCells = length(input);

% Find the common time range
allTimes = [];
for i = 1:numCells
    allTimes = [allTimes, input{i}(3, :)];
end
commonTimeRange = [max(min(allTimes)), min(max(allTimes))];
commonTimeRange = single(commonTimeRange);
% Define a new time vector with uniform step size within the common time range
timeStep = 4; % 250 Hz is 1/250 == 0.004 sec == 4 msec
newTimeVector = commonTimeRange(1):timeStep:commonTimeRange(2);

% Preallocate arrays for interpolated data
interpolatedX = zeros(numCells, length(newTimeVector));
interpolatedY = zeros(numCells, length(newTimeVector));

% Interpolate the X and Y coordinates for each cell
for i = 1:numCells
    currentX = single(input{i}(1, :));
    currentY = single(input{i}(2, :));
    currentTime = single(input{i}(3, :));

    % Censor blink data
    sz = [1920 1200];
    dropList = currentX > 3*sz(1) | currentY > 3*sz(2);
    currentX(dropList) = [];
    currentY(dropList) = [];
    currentTime(dropList) = [];
    
    interpolatedX(i, :) = interp1(currentTime, currentX, newTimeVector, 'linear', 'extrap');
    interpolatedY(i, :) = interp1(currentTime, currentY, newTimeVector, 'linear', 'extrap');
end

% Calculate the average X and Y coordinates
averageX = mean(interpolatedX, 1);
averageY = mean(interpolatedY, 1);

% Store the averaged data in a new matrix of the same format as the input
output = [averageX; averageY; newTimeVector];
end