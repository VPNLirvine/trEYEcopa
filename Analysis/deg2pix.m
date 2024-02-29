function numPixels = deg2pix(numDegrees)
% Convert from degrees of visual angle to length in pixels.
% Assumes we know the size, resolution, and distance to the monitor.
% This is a trig problem solving for the side opposite the given angle.

% First, define our known measurements.
monitorWidthInches = 13;
monitorWidthPixels = 1200;
distanceToScreen = 26; % in inches. This one may vary a bit.

% Now perform the trig.
% SOH CAH TOA: we don't have the hypotenuse, so use tangent.
% tan(theta) = opposite / adjacent
% solving for opposite, o = adj * tangent(theta)

segmentInInches = distanceToScreen * tand(numDegrees);

% Finally, convert from inches to pixels.
% The ratio of segment length to monitor size is equal, regardless of units
% So do the algebra for x/monitorPixels == segInches / monitorInches
numPixels = monitorWidthPixels * (segmentInInches / monitorWidthInches);

end