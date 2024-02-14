function vector = mirrorX(vector, maxVal)
% Given a vector of X coordinates and their maximum possible value,
% (which may not actually be present in the vector),
% mirror the data horizontally.
% e.g. if there are 3 positions, 3 becomes 1 and 1 becomes 3.
% This is different from fliplr() in that we're not changing the ORDER,
% we're changing the VALUES.
% A vector of [1 3 1 2] would become [3 1 3 2], not [2 1 3 1].

% Get the centerpoint
center = maxVal/2;

% Normalize to that center
vector = vector - center;

% Flip the signs
vector = vector * -1;

% Add the center value back
vector = vector + center;

end