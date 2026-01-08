function numDegrees = pix2deg(numPixels)
% Converts a length in pixels to degrees of visual angle
% The opposite of deg2pix, which I wrote first.
% This is a trig problem solving the angle given two lengths.

% First, define our known measurements.
monitorWidthInches = 13;
monitorWidthPixels = 1200;
distanceToScreen = 26; % in inches. This one may vary a bit.

% Convert pixels to inches
% The ratio of segment length to monitor size is equal, regardless of units
% So do the algebra for segPixels/monitorPixels == segInches/monitorInches
segmentInInches = numPixels * (monitorWidthInches / monitorWidthPixels);

% Now perform the trig.
% SOH CAH TOA: we don't have the hypotenuse, so use tangent.
% tan(theta) = opposite / adjacent
% solving for theta = arctangent(opposite / adjacent)
% Use a more plausible geometric model with eye at center of screen
numDegrees = 2 * atand(segmentInInches / (2 * distanceToScreen));
