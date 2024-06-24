function [newX, newY] = rotateDoor(oldX, oldY, rot)

% Define the radius of the door
doorLength = 800;
% And apparently the values are off by 90 deg, go figure
angleOffset = 90 * (pi/180);

% Compute the rotated coordinates
% newX = oldX .* cos(rot) - oldY .* sin(rot);
% newY = oldX .* sin(rot) + oldY .* cos(rot);
newX = oldX + doorLength .* cos(rot - angleOffset);
newY = oldY + doorLength .* sin(rot - angleOffset);

end